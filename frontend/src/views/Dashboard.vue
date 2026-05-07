<template>
  <div>
    <h1>欢迎使用 CZZY 系统</h1>
    <p>当前登录人：{{ user.name || user.username }}</p>
    <p>当前登录IP：{{ user.currentLoginIp || '-' }}</p>
    <p>上次登录时间：{{ user.lastLoginTime || '-' }}</p>
  </div>
</template>

<script setup>
const user = JSON.parse(localStorage.getItem('user') || '{}')
</script>
