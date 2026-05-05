<template>
  <div>
    <h1>欢迎使用 CZZY 系统</h1>
    <p>当前用户：{{ user?.display_name }}</p>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import http from '@/api/http'

const user = ref(null)
onMounted(async () => {
  try {
    const res = await http.get('/api/auth/me')
    user.value = res.data
  } catch (e) {
    console.error('获取用户信息失败', e)
  }
})
</script>