<template>
    <div class="content">
        <a-layout-content :style="{ padding: '15px'}">
            <router-view :key="$route.fullPath"/>
        </a-layout-content>
    </div>
</template>
<style scoped>
.content {
    width: 100%;
    height: calc(100vh - 65px);
    overflow: auto;
}
</style>