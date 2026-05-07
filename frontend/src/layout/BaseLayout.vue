<template>
  <el-container class="layout">
    <el-aside :width="isCollapse ? '64px' : '200px'" class="aside-menu">
      <div class="logo" @click="toggleCollapse"><span v-if="!isCollapse">CZZY</span><el-icon v-else><Menu /></el-icon></div>
      <el-menu :default-active="activeMenu" router :collapse="isCollapse" background-color="#1f2d3d" text-color="#bfcbd9" active-text-color="#409EFF">
        <el-menu-item v-for="menu in menus" :key="menu.path" :index="menu.path">{{ menu.name }}</el-menu-item>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header class="header-bar">
        <div class="header-left"><el-icon class="collapse-icon" @click="toggleCollapse"><Fold v-if="!isCollapse" /><Expand v-else /></el-icon><span class="title">CZZY 公司管理系统</span></div>
        <div class="user-info"><el-icon><UserFilled /></el-icon>{{ user.name || user.username || '未登录用户' }}</div>
      </el-header>
      <el-main><router-view /></el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import { Menu, Fold, Expand, UserFilled } from '@element-plus/icons-vue'

const route = useRoute()
const isCollapse = ref(false)
const user = ref(JSON.parse(localStorage.getItem('user') || '{}'))
const displayProjects = user.value.displayProjects || ''
const baseMenus = [{ path: '/', name: '系统首页' }]
const menus = ref(baseMenus.filter((item) => !displayProjects || displayProjects.includes(item.name)))
const activeMenu = ref(route.path)
const toggleCollapse = () => { isCollapse.value = !isCollapse.value }
</script>

<style scoped>.layout{height:100vh}.aside-menu{background-color:#1f2d3d;transition:width .3s;overflow-x:hidden}.logo{height:60px;display:flex;align-items:center;justify-content:center;color:white;font-size:20px;font-weight:bold;cursor:pointer;background-color:#263445}.header-bar{display:flex;justify-content:space-between;align-items:center;background-color:#fff;border-bottom:1px solid #e6e6e6;padding:0 20px}.collapse-icon{font-size:20px;cursor:pointer;margin-right:20px}.title{font-size:18px;font-weight:bold}.user-info{display:flex;align-items:center;gap:5px}</style>
