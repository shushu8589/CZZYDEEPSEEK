<template>
  <div class="layout">
    <header class="layout__header">CZZY 企业管理系统（Web）</header>
    <main class="layout__content">
      <slot />
    </main>
  </div>
</template>

<style scoped>
.layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f5f7fa;
}

.layout__header {
  padding: 14px 20px;
  background: #1f2d3d;
  color: #fff;
  font-size: 16px;
  font-weight: 600;
}

.layout__content {
  flex: 1;
  padding: 16px;
}

@media (max-width: 768px) {
  .layout__header {
    font-size: 14px;
    padding: 12px;
  }

  .layout__content {
    padding: 12px;
  }
}
</style>
