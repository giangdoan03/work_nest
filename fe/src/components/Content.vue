<template>
    <a-layout-content
        :style="{
      margin: '24px 16px',
      padding: '24px',
      background: '#fff',
      height: '100%',
      overflow: 'auto',
    }"
    >
        <router-view :key="$route.fullPath"/>
    </a-layout-content>
</template>
