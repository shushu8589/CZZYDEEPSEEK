<template>
  <div class="login-container">
    <el-card class="login-card">
      <h2 class="title">CZZY 公司管理系统</h2>
      <el-form :model="form" :rules="rules" ref="formRef" @keyup.enter="handleLogin">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="请输入账号" :prefix-icon="UserFilled" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" :prefix-icon="Lock" />
        </el-form-item>
        <el-form-item class="actions">
          <el-button type="primary" :loading="loading" @click="handleLogin">登录</el-button>
          <el-button @click="handleExit">退出</el-button>
        </el-form-item>
      </el-form>
      <p class="status" :class="{ error: isError }">{{ statusMsg }}</p>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { UserFilled, Lock } from '@element-plus/icons-vue'
import http from '@/api/http'

const router = useRouter()
const form = reactive({ username: '', password: '' })
const loading = ref(false)
const statusMsg = ref('')
const isError = ref(false)

const rules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
  loading.value = true
  isError.value = false
  statusMsg.value = '正在连接数据库……'
  try {
    const { data } = await http.post('/api/auth/login', form)
    localStorage.setItem('token', data.data.token)
    localStorage.setItem('user', JSON.stringify(data.data.user))
    statusMsg.value = data.message
    router.push('/')
  } catch (err) {
    isError.value = true
    statusMsg.value = err.response?.data?.detail || '登录失败，请检查用户名或密码'
  } finally {
    loading.value = false
  }
}

const handleExit = () => {
  statusMsg.value = '已取消登录'
  form.username = ''
  form.password = ''
}
</script>

<style scoped>
.login-container { height: 100vh; display:flex; justify-content:center; align-items:center; background: linear-gradient(135deg,#667eea 0%,#764ba2 100%);}
.login-card { width: 420px; border-radius: 8px; }
.title { text-align: center; margin-bottom: 20px; }
.actions :deep(.el-form-item__content) { display:flex; gap:12px; }
.status { text-align:center; color:#666; min-height:20px; }
.status.error { color: #d03050; }
</style>
