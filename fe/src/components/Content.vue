<template>
    <div class="content">
        <a-layout-content
            :style="{
            margin: '24px 16px',
            padding: '24px',
            background: '#fff',
            }"
        >
            <router-view :key="$route.fullPath"/>
        </a-layout-content>
    </div>
</template>
<style scoped>
.content{
    width: 100%;
    height: calc(100vh - 65px);
    overflow: auto;
}
</style>