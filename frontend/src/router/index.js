import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/home/HomeView.vue'   // 你原有的 Home 页面（可以保留）

// ========== 新增导入 ==========
import LoginView from '@/views/login/LoginView.vue'
import BaseLayout from '@/layout/BaseLayout.vue'
import Dashboard from '@/views/Dashboard.vue'
// =============================

const routes = [
  // ========== 新增登录路由 ==========
  {
    path: '/login',
    name: 'login',
    component: LoginView
  },
  // =================================

  {
    path: '/',
    // ========== 修改主路由为布局组件 ==========
    name: 'home',
    component: BaseLayout,   // 原来是 HomeView，改为布局
    meta: { requiresAuth: true },  // 需要登录
    children: [
      {
        path: '',                // 默认子路由
        name: 'dashboard',
        component: Dashboard
      },
      // 你原有的 HomeView 可以作为一个子路由，如果需要保留：
      // {
      //   path: 'old-home',
      //   name: 'old-home',
      //   component: HomeView
      // }
    ]
    // =========================================
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// ========== 新增全局路由守卫 ==========
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!token) {
      next('/login')
    } else {
      next()
    }
  } else {
    // 已登录时访问登录页，直接到首页
    if (to.path === '/login' && token) {
      next('/')
    } else {
      next()
    }
  }
})
// =====================================

export default router