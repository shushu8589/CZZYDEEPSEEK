<template>
  <el-container class="layout">
    <!-- 侧边栏（手机端可通过按钮折叠） -->
    <el-aside :width="isCollapse ? '64px' : '200px'" class="aside-menu">
      <div class="logo" @click="toggleCollapse">
        <span v-if="!isCollapse">CZZY</span>
        <el-icon v-else><Menu /></el-icon>
      </div>
      <el-menu
        :default-active="activeMenu"
        router
        :collapse="isCollapse"
        background-color="#1f2d3d"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <template v-for="menu in menus" :key="menu.name">
          <!-- 有子菜单 -->
          <el-sub-menu v-if="menu.children && menu.children.length" :index="menu.path">
            <template #title>
              <el-icon v-if="menu.icon"><component :is="menu.icon" /></el-icon>
              <span>{{ menu.name }}</span>
            </template>
            <el-menu-item v-for="child in menu.children" :key="child.path" :index="child.path">
              {{ child.name }}
            </el-menu-item>
          </el-sub-menu>
          <!-- 没有子菜单 -->
          <el-menu-item v-else :index="menu.path">
            <el-icon v-if="menu.icon"><component :is="menu.icon" /></el-icon>
            <span>{{ menu.name }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </el-aside>

    <el-container>
      <!-- 顶部栏 -->
      <el-header class="header-bar">
        <div class="header-left">
          <el-icon class="collapse-icon" @click="toggleCollapse">
            <Fold v-if="!isCollapse" />
            <Expand v-else />
          </el-icon>
          <span class="title">挤出切割综合管理系统</span>
        </div>
        <div class="header-right">
          <el-dropdown trigger="click">
            <span class="user-info">
              <el-icon><UserFilled /></el-icon>
              {{ user.display_name || user.username }}
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="handleLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- 主内容区（子路由页面在这里渲染） -->
      <el-main>
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import http from '@/api/http'
import {
  Menu, Fold, Expand, UserFilled, ArrowDown
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const isCollapse = ref(false)
const menus = ref([])
const user = ref({})

const activeMenu = ref(route.path)

onMounted(async () => {
  try {
    const [menuRes, userRes] = await Promise.all([
      http.get('/api/menus/my'),
      http.get('/api/auth/me')
    ])
    menus.value = menuRes.data
    user.value = userRes.data
    localStorage.setItem('user', JSON.stringify(userRes.data))
  } catch (e) {
    console.error('获取菜单或用户信息失败', e)
  }
})

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

const handleLogout = async () => {
  try {
    await http.post('/api/auth/logout')
  } finally {
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    router.push('/login')
  }
}
</script>

<style scoped>
.layout {
  height: 100vh;
}

/* 侧边栏 */
.aside-menu {
  background-color: #1f2d3d;
  transition: width 0.3s;
  overflow-x: hidden;
}
.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 20px;
  font-weight: bold;
  cursor: pointer;
  background-color: #263445;
}

/* 顶部栏 */
.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #fff;
  border-bottom: 1px solid #e6e6e6;
  padding: 0 20px;
}
.collapse-icon {
  font-size: 20px;
  cursor: pointer;
  margin-right: 20px;
}
.title {
  font-size: 18px;
  font-weight: bold;
}
.user-info {
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
}

/* 原有移动端响应式保留并扩展 */
@media (max-width: 768px) {
  .header-bar {
    padding: 0 10px;
  }
  .title {
    font-size: 14px;
  }
  .logo {
    font-size: 16px;
  }
}
</style>
