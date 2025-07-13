<template>
    <div style="text-align: center; margin-top: 100px">
        <h1>🚫 403 - Không có quyền truy cập</h1>
        <p>Bạn không được cấp quyền để xem trang này.</p>
        <router-link to="/project-overview">Quay lại trang chính</router-link>
    </div>
</template>

<script>
export default {
    name: 'Forbidden403'
}
</script>
