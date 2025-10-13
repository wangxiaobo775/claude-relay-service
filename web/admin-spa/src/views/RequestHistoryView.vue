<template>
  <div class="request-history-container">
    <!-- 页面标题 -->
    <div class="mb-6">
      <h2 class="text-2xl font-bold text-gray-900 dark:text-gray-100">请求历史记录</h2>
      <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
        查看所有 API 请求的详细历史记录，包括输入、输出和 Token 使用情况
      </p>
    </div>

    <!-- 筛选和搜索区域 -->
    <div class="card mb-6 p-4 sm:p-6">
      <div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
        <!-- API Key 筛选 -->
        <div>
          <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">
            API Key
          </label>
          <select
            v-model="filters.apiKeyId"
            class="w-full rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm text-gray-900 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 dark:focus:border-blue-400 dark:focus:ring-blue-800"
            @change="loadHistory"
          >
            <option value="">全部 API Keys</option>
            <option v-for="key in apiKeys" :key="key.id" :value="key.id">
              {{ key.name }}
            </option>
          </select>
        </div>

        <!-- 日期筛选 -->
        <div>
          <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">
            日期
          </label>
          <input
            v-model="filters.date"
            type="date"
            class="w-full rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm text-gray-900 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 dark:focus:border-blue-400 dark:focus:ring-blue-800"
            @change="loadHistory"
          />
        </div>

        <!-- 状态筛选 -->
        <div>
          <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">
            状态
          </label>
          <select
            v-model="filters.status"
            class="w-full rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm text-gray-900 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-100 dark:focus:border-blue-400 dark:focus:ring-blue-800"
            @change="loadHistory"
          >
            <option value="">全部状态</option>
            <option value="success">成功</option>
            <option value="error">失败</option>
            <option value="pending">进行中</option>
          </select>
        </div>

        <!-- 刷新按钮 -->
        <div class="flex items-end">
          <button
            class="w-full rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 dark:bg-blue-500 dark:hover:bg-blue-600"
            :disabled="loading"
            @click="loadHistory"
          >
            <i :class="['fas fa-sync-alt mr-2', { 'animate-spin': loading }]" />
            {{ loading ? '加载中...' : '刷新' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 请求历史列表 -->
    <div class="card p-4 sm:p-6">
      <!-- 加载状态 -->
      <div v-if="loading && historyList.length === 0" class="py-12 text-center">
        <i class="fas fa-spinner fa-spin text-4xl text-blue-500" />
        <p class="mt-4 text-gray-600 dark:text-gray-400">加载中...</p>
      </div>

      <!-- 空状态 -->
      <div v-else-if="historyList.length === 0" class="py-12 text-center">
        <i class="fas fa-inbox text-6xl text-gray-300 dark:text-gray-600" />
        <p class="mt-4 text-lg text-gray-600 dark:text-gray-400">暂无请求历史记录</p>
        <p class="mt-2 text-sm text-gray-500 dark:text-gray-500">
          当有新的 API 请求时，历史记录会显示在这里
        </p>
      </div>

      <!-- 历史记录表格 -->
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-800">
            <tr>
              <th
                class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-700 dark:text-gray-300"
              >
                时间
              </th>
              <th
                class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-700 dark:text-gray-300"
              >
                API Key
              </th>
              <th
                class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-700 dark:text-gray-300"
              >
                模型
              </th>
              <th
                class="px-4 py-3 text-right text-xs font-medium uppercase tracking-wider text-gray-700 dark:text-gray-300"
              >
                输入 Tokens
              </th>
              <th
                class="px-4 py-3 text-right text-xs font-medium uppercase tracking-wider text-gray-700 dark:text-gray-300"
              >
                输出 Tokens
              </th>
              <th
                class="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-700 dark:text-gray-300"
              >
                状态
              </th>
              <th
                class="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-700 dark:text-gray-300"
              >
                操作
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 bg-white dark:divide-gray-700 dark:bg-gray-900">
            <tr
              v-for="item in historyList"
              :key="item.requestId"
              class="hover:bg-gray-50 dark:hover:bg-gray-800"
            >
              <!-- 时间 -->
              <td class="whitespace-nowrap px-4 py-3 text-sm text-gray-900 dark:text-gray-100">
                {{ formatTime(item.timestamp) }}
              </td>

              <!-- API Key -->
              <td class="px-4 py-3 text-sm">
                <span
                  class="inline-block max-w-[150px] truncate font-medium text-blue-600 dark:text-blue-400"
                  :title="item.apiKeyName"
                >
                  {{ item.apiKeyName }}
                </span>
              </td>

              <!-- 模型 -->
              <td class="px-4 py-3 text-sm">
                <span
                  class="inline-block max-w-[200px] truncate text-gray-700 dark:text-gray-300"
                  :title="item.model"
                >
                  {{ item.model || 'N/A' }}
                </span>
              </td>

              <!-- 输入 Tokens -->
              <td
                class="whitespace-nowrap px-4 py-3 text-right text-sm text-gray-600 dark:text-gray-400"
              >
                {{ formatNumber(item.inputTokens || 0) }}
              </td>

              <!-- 输出 Tokens -->
              <td
                class="whitespace-nowrap px-4 py-3 text-right text-sm text-gray-600 dark:text-gray-400"
              >
                {{ formatNumber(item.outputTokens || 0) }}
              </td>

              <!-- 状态 -->
              <td class="whitespace-nowrap px-4 py-3 text-center text-sm">
                <span
                  :class="[
                    'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium',
                    getStatusClass(item.status)
                  ]"
                >
                  <i :class="['fas mr-1', getStatusIcon(item.status)]" />
                  {{ getStatusText(item.status) }}
                </span>
              </td>

              <!-- 操作 -->
              <td class="whitespace-nowrap px-4 py-3 text-center text-sm">
                <button
                  class="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
                  @click="viewDetails(item.requestId)"
                >
                  <i class="fas fa-eye" />
                  <span class="ml-1">详情</span>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- 分页 -->
      <div
        v-if="historyList.length > 0"
        class="mt-6 flex flex-col items-center justify-between gap-4 sm:flex-row"
      >
        <div class="text-sm text-gray-600 dark:text-gray-400">
          显示 {{ (pagination.page - 1) * pagination.limit + 1 }} 到
          {{ Math.min(pagination.page * pagination.limit, pagination.total) }} 条，共
          {{ pagination.total }} 条记录
        </div>
        <div class="flex gap-2">
          <button
            class="rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 dark:border-gray-600 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700"
            :disabled="pagination.page <= 1"
            @click="prevPage"
          >
            <i class="fas fa-chevron-left" />
            上一页
          </button>
          <button
            class="rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 dark:border-gray-600 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700"
            :disabled="!hasMore"
            @click="nextPage"
          >
            下一页
            <i class="fas fa-chevron-right" />
          </button>
        </div>
      </div>
    </div>

    <!-- 详情模态框 -->
    <div
      v-if="showDetailsModal"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 p-4"
      @click.self="closeDetails"
    >
      <div
        class="max-h-[90vh] w-full max-w-4xl overflow-y-auto rounded-lg bg-white p-6 shadow-xl dark:bg-gray-800"
      >
        <div class="mb-4 flex items-center justify-between">
          <h3 class="text-xl font-bold text-gray-900 dark:text-gray-100">请求详情</h3>
          <button
            class="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
            @click="closeDetails"
          >
            <i class="fas fa-times text-xl" />
          </button>
        </div>

        <div v-if="selectedRequest" class="space-y-4">
          <!-- 基本信息 -->
          <div class="rounded-lg bg-gray-50 p-4 dark:bg-gray-700">
            <h4 class="mb-3 font-semibold text-gray-900 dark:text-gray-100">基本信息</h4>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <span class="text-sm text-gray-600 dark:text-gray-400">请求 ID:</span>
                <p class="mt-1 font-mono text-sm text-gray-900 dark:text-gray-100">
                  {{ selectedRequest.requestId }}
                </p>
              </div>
              <div>
                <span class="text-sm text-gray-600 dark:text-gray-400">API Key:</span>
                <p class="mt-1 text-sm font-medium text-gray-900 dark:text-gray-100">
                  {{ selectedRequest.apiKeyName }}
                </p>
              </div>
              <div>
                <span class="text-sm text-gray-600 dark:text-gray-400">模型:</span>
                <p class="mt-1 text-sm text-gray-900 dark:text-gray-100">
                  {{ selectedRequest.model }}
                </p>
              </div>
              <div>
                <span class="text-sm text-gray-600 dark:text-gray-400">时间:</span>
                <p class="mt-1 text-sm text-gray-900 dark:text-gray-100">
                  {{ formatTime(selectedRequest.timestamp) }}
                </p>
              </div>
              <div>
                <span class="text-sm text-gray-600 dark:text-gray-400">状态:</span>
                <p class="mt-1">
                  <span
                    :class="[
                      'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium',
                      getStatusClass(selectedRequest.status)
                    ]"
                  >
                    {{ getStatusText(selectedRequest.status) }}
                  </span>
                </p>
              </div>
              <div>
                <span class="text-sm text-gray-600 dark:text-gray-400">状态码:</span>
                <p class="mt-1 text-sm text-gray-900 dark:text-gray-100">
                  {{ selectedRequest.statusCode || 'N/A' }}
                </p>
              </div>
            </div>
          </div>

          <!-- Token 使用统计 -->
          <div class="rounded-lg bg-gray-50 p-4 dark:bg-gray-700">
            <h4 class="mb-3 font-semibold text-gray-900 dark:text-gray-100">Token 使用统计</h4>
            <div class="grid grid-cols-2 gap-4 sm:grid-cols-4">
              <div>
                <span class="text-sm text-gray-600 dark:text-gray-400">输入:</span>
                <p class="mt-1 text-lg font-bold text-blue-600">
                  {{ formatNumber(selectedRequest.inputTokens || 0) }}
                </p>
              </div>
              <div>
                <span class="text-sm text-gray-600 dark:text-gray-400">输出:</span>
                <p class="mt-1 text-lg font-bold text-green-600">
                  {{ formatNumber(selectedRequest.outputTokens || 0) }}
                </p>
              </div>
              <div>
                <span class="text-sm text-gray-600 dark:text-gray-400">缓存创建:</span>
                <p class="mt-1 text-lg font-bold text-purple-600">
                  {{ formatNumber(selectedRequest.cacheCreateTokens || 0) }}
                </p>
              </div>
              <div>
                <span class="text-sm text-gray-600 dark:text-gray-400">缓存读取:</span>
                <p class="mt-1 text-lg font-bold text-purple-600">
                  {{ formatNumber(selectedRequest.cacheReadTokens || 0) }}
                </p>
              </div>
            </div>
          </div>

          <!-- 请求内容 -->
          <div class="rounded-lg bg-gray-50 p-4 dark:bg-gray-700">
            <h4 class="mb-3 font-semibold text-gray-900 dark:text-gray-100">请求内容</h4>
            <pre
              class="max-h-60 overflow-auto rounded bg-gray-800 p-3 text-xs text-green-400"
            ><code>{{ formatJSON(selectedRequest.requestBody) }}</code></pre>
          </div>

          <!-- 响应内容 -->
          <div class="rounded-lg bg-gray-50 p-4 dark:bg-gray-700">
            <h4 class="mb-3 font-semibold text-gray-900 dark:text-gray-100">响应内容</h4>
            <pre
              class="max-h-60 overflow-auto rounded bg-gray-800 p-3 text-xs text-blue-400"
            ><code>{{ formatJSON(selectedRequest.responseBody) }}</code></pre>
          </div>

          <!-- 错误信息（如果有） -->
          <div v-if="selectedRequest.error" class="rounded-lg bg-red-50 p-4 dark:bg-red-900/20">
            <h4 class="mb-3 font-semibold text-red-900 dark:text-red-300">错误信息</h4>
            <p class="text-sm text-red-800 dark:text-red-400">
              {{ selectedRequest.error }}
            </p>
          </div>
        </div>

        <div v-else class="py-8 text-center">
          <i class="fas fa-spinner fa-spin text-4xl text-blue-500" />
          <p class="mt-4 text-gray-600 dark:text-gray-400">加载详情中...</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

// 数据
const loading = ref(false)
const historyList = ref([])
const apiKeys = ref([])
const showDetailsModal = ref(false)
const selectedRequest = ref(null)

// 筛选条件
const filters = ref({
  apiKeyId: '',
  date: new Date().toISOString().split('T')[0], // 默认今天
  status: ''
})

// 分页
const pagination = ref({
  page: 1,
  limit: 50,
  total: 0
})

const hasMore = ref(false)

// 加载 API Keys 列表
async function loadApiKeys() {
  try {
    const response = await axios.get('/admin/api-keys')
    if (response.data.success) {
      apiKeys.value = response.data.data.keys || []
    }
  } catch (error) {
    console.error('Failed to load API keys:', error)
  }
}

// 加载历史记录
async function loadHistory() {
  loading.value = true
  try {
    const params = {
      limit: pagination.value.limit,
      offset: (pagination.value.page - 1) * pagination.value.limit
    }

    if (filters.value.apiKeyId) {
      params.apiKeyId = filters.value.apiKeyId
    }
    if (filters.value.date) {
      params.date = filters.value.date
    }
    if (filters.value.status) {
      params.status = filters.value.status
    }

    const response = await axios.get('/admin/request-history', { params })

    if (response.data.success) {
      historyList.value = response.data.data.history || []
      hasMore.value = response.data.data.pagination?.hasMore || false
      pagination.value.total = response.data.data.pagination?.total || historyList.value.length
    }
  } catch (error) {
    console.error('Failed to load history:', error)
    historyList.value = []
  } finally {
    loading.value = false
  }
}

// 查看详情
async function viewDetails(requestId) {
  showDetailsModal.value = true
  selectedRequest.value = null

  try {
    const response = await axios.get(`/admin/request-history/${requestId}`)
    if (response.data.success) {
      selectedRequest.value = response.data.data.request
    }
  } catch (error) {
    console.error('Failed to load request details:', error)
  }
}

// 关闭详情
function closeDetails() {
  showDetailsModal.value = false
  selectedRequest.value = null
}

// 分页操作
function nextPage() {
  if (hasMore.value) {
    pagination.value.page++
    loadHistory()
  }
}

function prevPage() {
  if (pagination.value.page > 1) {
    pagination.value.page--
    loadHistory()
  }
}

// 工具函数
function formatTime(timestamp) {
  if (!timestamp) return 'N/A'
  const date = new Date(timestamp)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

function formatNumber(num) {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(2) + 'M'
  } else if (num >= 1000) {
    return (num / 1000).toFixed(2) + 'K'
  }
  return num.toString()
}

function formatJSON(obj) {
  if (!obj) return 'N/A'
  if (typeof obj === 'string') {
    try {
      return JSON.stringify(JSON.parse(obj), null, 2)
    } catch {
      return obj
    }
  }
  return JSON.stringify(obj, null, 2)
}

function getStatusClass(status) {
  switch (status) {
    case 'completed':
    case 'success':
      return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300'
    case 'failed':
    case 'error':
      return 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300'
    case 'pending':
      return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300'
    default:
      return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'
  }
}

function getStatusIcon(status) {
  switch (status) {
    case 'completed':
    case 'success':
      return 'fa-check-circle'
    case 'failed':
    case 'error':
      return 'fa-times-circle'
    case 'pending':
      return 'fa-clock'
    default:
      return 'fa-question-circle'
  }
}

function getStatusText(status) {
  switch (status) {
    case 'completed':
      return '成功'
    case 'failed':
      return '失败'
    case 'pending':
      return '进行中'
    default:
      return '未知'
  }
}

// 初始化
onMounted(() => {
  loadApiKeys()
  loadHistory()
})
</script>

<style scoped>
@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

/* 自定义滚动条样式 */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.3);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.5);
}

/* 暗黑模式滚动条 */
.dark ::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
}

.dark ::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
}

.dark ::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.3);
}
</style>
