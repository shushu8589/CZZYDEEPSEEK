<script setup>
import { onMounted, ref } from 'vue'
import http from '../../api/http'
import BaseLayout from '../../layout/BaseLayout.vue'

const loading = ref(false)
const health = ref(null)
const errorMsg = ref('')

const loadHealth = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const { data } = await http.get('/api/health')
    health.value = data
  } catch (error) {
    errorMsg.value = error?.message || '健康检查请求失败'
  } finally {
    loading.value = false
  }
}

onMounted(loadHealth)
</script>

<template>
  <BaseLayout>
    <el-card>
      <template #header>
        <div class="title-row">
          <span>系统首页（第0步基础架构）</span>
          <el-button type="primary" :loading="loading" @click="loadHealth">刷新健康检查</el-button>
        </div>
      </template>

      <el-alert
        v-if="errorMsg"
        type="error"
        :closable="false"
        :title="`接口访问失败：${errorMsg}`"
        show-icon
      />

      <el-descriptions v-else-if="health" :column="1" border>
        <el-descriptions-item label="success">{{ health.success }}</el-descriptions-item>
        <el-descriptions-item label="message">{{ health.message }}</el-descriptions-item>
        <el-descriptions-item label="app">{{ health.data?.app }}</el-descriptions-item>
        <el-descriptions-item label="database">{{ health.data?.database }}</el-descriptions-item>
      </el-descriptions>

      <el-skeleton v-else :rows="4" animated />
    </el-card>
  </BaseLayout>
</template>

<style scoped>
.title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
}

@media (max-width: 768px) {
  .title-row {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
