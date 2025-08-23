<template>
    <div class="content">
        <a-layout-content
            :style="{
            margin: '15px 15px',
            padding: '15px',
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