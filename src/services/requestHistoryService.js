const redis = require('../models/redis')
const logger = require('../utils/logger')
const { v4: uuidv4 } = require('uuid')

class RequestHistoryService {
  constructor() {
    this.enableHistoryLogging = true // 可通过配置控制
    this.maxRequestBodySize = 10000 // 最大存储的请求体大小
    this.maxResponseBodySize = 1200000 // 最大存储的响应体大小 (1.2 MB, 支持 200k tokens)
  }

  // 📝 记录请求开始
  async startRequest(requestData) {
    if (!this.enableHistoryLogging) return null

    try {
      const requestId = uuidv4()
      const timestamp = new Date().toISOString()

      // 处理请求体大小限制
      let requestBody = requestData.requestBody
      if (requestBody && JSON.stringify(requestBody).length > this.maxRequestBodySize) {
        requestBody = {
          ...requestBody,
          messages: requestBody.messages ? '[TRUNCATED - Large Messages]' : requestBody.messages
        }
      }

      const historyRecord = {
        requestId,
        timestamp,
        apiKeyId: requestData.apiKeyId,
        apiKeyName: requestData.apiKeyName,
        model: requestData.model || requestData.requestBody?.model || 'unknown',
        status: 'pending',
        requestBody,
        headers: this.sanitizeHeaders(requestData.headers),
        startTime: Date.now()
      }

      await redis.saveRequestHistory(historyRecord)

      logger.debug(`📝 Request started: ${requestId}`)
      return requestId
    } catch (error) {
      logger.error('❌ Failed to start request history:', error)
      return null
    }
  }

  // ✅ 记录请求成功完成
  async completeRequest(requestId, responseData) {
    if (!this.enableHistoryLogging || !requestId) return

    try {
      // 获取现有记录
      const existingRecord = await redis.getRequestHistory(requestId)
      if (!existingRecord) {
        logger.warn(`⚠️ Request history not found for completion: ${requestId}`)
        return
      }

      const endTime = Date.now()
      const duration = endTime - parseInt(existingRecord.startTime)

      // 处理响应体大小限制
      let responseBody = responseData.responseBody
      if (responseBody && JSON.stringify(responseBody).length > this.maxResponseBodySize) {
        responseBody = {
          type: 'truncated',
          originalLength: JSON.stringify(responseData.responseBody).length,
          preview: JSON.stringify(responseData.responseBody).substring(0, 1000) + '...'
        }
      }

      const updatedRecord = {
        ...existingRecord,
        status: 'success',
        duration,
        responseBody,
        statusCode: responseData.statusCode,
        inputTokens: responseData.inputTokens || 0,
        outputTokens: responseData.outputTokens || 0,
        cacheCreateTokens: responseData.cacheCreateTokens || 0,
        cacheReadTokens: responseData.cacheReadTokens || 0,
        totalTokens:
          (responseData.inputTokens || 0) +
          (responseData.outputTokens || 0) +
          (responseData.cacheCreateTokens || 0) +
          (responseData.cacheReadTokens || 0),
        endTime
      }

      await redis.saveRequestHistory(updatedRecord)

      logger.debug(`✅ Request completed: ${requestId}, duration: ${duration}ms`)
    } catch (error) {
      logger.error('❌ Failed to complete request history:', error)
    }
  }

  // ❌ 记录请求失败
  async failRequest(requestId, errorData) {
    if (!this.enableHistoryLogging || !requestId) return

    try {
      // 获取现有记录
      const existingRecord = await redis.getRequestHistory(requestId)
      if (!existingRecord) {
        logger.warn(`⚠️ Request history not found for failure: ${requestId}`)
        return
      }

      const endTime = Date.now()
      const duration = endTime - parseInt(existingRecord.startTime)

      const updatedRecord = {
        ...existingRecord,
        status: 'error',
        duration,
        error: errorData.error || 'Unknown error',
        statusCode: errorData.statusCode || 500,
        endTime
      }

      await redis.saveRequestHistory(updatedRecord)

      logger.debug(
        `❌ Request failed: ${requestId}, duration: ${duration}ms, error: ${errorData.error}`
      )
    } catch (error) {
      logger.error('❌ Failed to record request failure:', error)
    }
  }

  // 📊 获取请求历史列表（支持筛选）
  async getRequestHistory(options = {}) {
    try {
      return await redis.getRequestHistoryList(options)
    } catch (error) {
      logger.error('❌ Failed to get request history:', error)
      return []
    }
  }

  // 📋 获取单个请求详情
  async getRequestDetails(requestId) {
    try {
      return await redis.getRequestHistory(requestId)
    } catch (error) {
      logger.error('❌ Failed to get request details:', error)
      return null
    }
  }

  // 📈 获取请求统计
  async getRequestStats(date = null) {
    try {
      return await redis.getRequestHistoryStats(date)
    } catch (error) {
      logger.error('❌ Failed to get request stats:', error)
      return {
        totalRequests: 0,
        successRequests: 0,
        failedRequests: 0,
        totalTokens: 0,
        avgDuration: 0,
        modelStats: {},
        statusStats: {}
      }
    }
  }

  // 🗑️ 删除请求记录
  async deleteRequest(requestId) {
    try {
      return await redis.deleteRequestHistory(requestId)
    } catch (error) {
      logger.error('❌ Failed to delete request:', error)
      return false
    }
  }

  // 🧹 清理历史记录（按日期）
  async cleanupHistory(beforeDate) {
    try {
      // 这里可以实现批量清理逻辑
      // 由于Redis已经设置了30天TTL，主要依赖自动过期
      logger.info(`🧹 History cleanup initiated for records before ${beforeDate}`)
      return true
    } catch (error) {
      logger.error('❌ Failed to cleanup history:', error)
      return false
    }
  }

  // 🔒 清理敏感headers
  sanitizeHeaders(headers) {
    if (!headers) return {}

    const sensitiveHeaders = [
      'authorization',
      'x-api-key',
      'cookie',
      'set-cookie',
      'proxy-authorization'
    ]

    const sanitized = {}
    for (const [key, value] of Object.entries(headers)) {
      if (sensitiveHeaders.includes(key.toLowerCase())) {
        sanitized[key] = '[REDACTED]'
      } else {
        sanitized[key] = value
      }
    }

    return sanitized
  }

  // ⚙️ 配置管理
  setHistoryLogging(enabled) {
    this.enableHistoryLogging = enabled
    logger.info(`📝 Request history logging ${enabled ? 'enabled' : 'disabled'}`)
  }

  setMaxSizes(requestBodySize, responseBodySize) {
    this.maxRequestBodySize = requestBodySize || this.maxRequestBodySize
    this.maxResponseBodySize = responseBodySize || this.maxResponseBodySize
    logger.info(
      `📏 Max sizes updated: request=${this.maxRequestBodySize}, response=${this.maxResponseBodySize}`
    )
  }
}

module.exports = new RequestHistoryService()
