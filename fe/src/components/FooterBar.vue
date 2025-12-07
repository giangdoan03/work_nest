<template>
    <div class="footer-bar">
        © {{ new Date().getFullYear() }} TTID Office Portal. All rights reserved.
    </div>
</template>

<style scoped>
.footer-bar {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;

    height: 32px;
    text-align: center;
    padding: 6px 0;

    font-size: 12px;
    color: #98a2b3;

    border-top: 1px solid #e5e7eb;
    background: #fafafa;

    z-index: 999; /* đảm bảo nằm trên layout */
}

</style>
