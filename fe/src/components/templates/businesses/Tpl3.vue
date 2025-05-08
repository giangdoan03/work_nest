<template>
    <div class="tpl3-wrapper" v-if="product">
        <div class="tpl3-header">
            <a-carousel autoplay dots>
                <div v-for="(img, index) in product.image" :key="index">
                    <img :src="img" alt="Sản phẩm"/>
                </div>
            </a-carousel>
        </div>

        <div class="tpl3-info">
            <div class="tpl3-title tpl-name">{{ product.name }}</div>
            <div class="tpl3-price">{{ formatCurrency(product.price) }}</div>
            <div class="tpl3-size">
                Kích thước:
                <span v-if="product.attributes?.length" class="pill">
          {{ product.attributes[0].name }}
        </span>
            </div>
        </div>

        <div class="tpl3-button">
            <a-button block shape="round">Liên hệ mua hàng</a-button>
        </div>

        <div class="tpl3-description">
            <div class="tpl3-tab">
                <div class="tab-title">Mô tả sản phẩm</div>
                <div class="tab-content" v-html="product.description"></div>
            </div>
        </div>

        <div class="tpl3-company" v-if="businessItem">
            <div class="tpl3-company-title">Doanh nghiệp</div>
            <div class="tpl3-company-box">
                <img :src="businessItem.logo?.[0] || defaultLogo" class="logo"/>
                <div class="info">
                    <div class="name">{{ businessItem.name }}</div>
                    <div class="phone">{{ businessItem.phone }}</div>
                </div>
            </div>
        </div>

        <div class="tpl3-related" v-if="relatedProducts.length">
            <div class="tpl3-related-title">Sản phẩm liên quan</div>
            <div
                class="tpl3-related-item"
                v-for="(related, index) in relatedProducts"
                :key="index"
            >
                <img :src="related.image?.[0]"/>
                <div class="name">{{ related.name }}</div>
                <div class="price">{{ formatCurrency(related.price) }}</div>
            </div>
        </div>

        <div class="tpl3-powered">
            <span>Powered by <strong>iCheckQR</strong></span>
        </div>
    </div>
</template>


<script setup>
const props = defineProps({
    product: Object,
    business: [Object, Array],
    relatedProducts: {
        type: Array,
        default: () => [],
    },
})

const businessItem = Array.isArray(props.business)
    ? props.business[0]
    : props.business

const defaultLogo =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Ant_Design_Logo_1x.svg/768px-Ant_Design_Logo_1x.svg.png'

const formatCurrency = (value) => {
    if (!value) return ''
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND',
    }).format(value)
}
</script>


<style scoped>
.tpl-name {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 6px;
    display: -webkit-box;
    -webkit-line-clamp: 2; /* Tối đa 2 dòng */
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
}

.tpl3-wrapper {
    font-family: 'Segoe UI', sans-serif;
    background: #fff;
    border-radius: 12px;
    overflow-y: scroll;
    color: #111;
    display: flex;
    flex-direction: column;
    height: 100%;
    padding-bottom: 32px;
}

.tpl3-wrapper::-webkit-scrollbar {
    width: 4px; /* Chiều rộng thanh cuộn */
}

.tpl3-wrapper::-webkit-scrollbar-thumb {
    background-color: rgba(0, 0, 0, 0.2); /* Màu thanh cuộn */
    border-radius: 3px; /* Bo tròn thanh cuộn */
}

.tpl3-wrapper::-webkit-scrollbar-track {
    background: transparent; /* Màu nền track */
}

.tpl3-header img {
    width: 100%;
    object-fit: cover;
}

.tpl3-info {
    padding: 16px;
}

.tpl3-title {
    font-weight: 600;
    font-size: 18px;
    margin-bottom: 6px;
}

.tpl3-price {
    font-size: 20px;
    color: #8b4513;
    font-weight: bold;
    margin-bottom: 4px;
}

.tpl3-size {
    font-size: 14px;
    color: #555;
}

.pill {
    background: #eee;
    padding: 2px 8px;
    border-radius: 12px;
    font-weight: 600;
    font-size: 12px;
    margin-left: 6px;
}

.tpl3-button {
    padding: 0 16px;
}

.tpl3-description {
    padding: 16px;
}

.tpl3-tab {
    background: #fff;
    padding: 12px;
    border-radius: 12px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.tab-title {
    font-weight: 600;
    font-size: 14px;
    margin-bottom: 6px;
}

.tab-content {
    font-size: 13px;
    color: #444;
}

.tpl3-company {
    background: #fcf5f0;
    padding: 16px;
    margin-top: 12px;
}

.tpl3-company-title {
    font-weight: bold;
    font-size: 14px;
    margin-bottom: 8px;
}

.tpl3-company-box {
    display: flex;
    gap: 12px;
    align-items: center;
    background: #fff;
    padding: 12px;
    border-radius: 12px;
}

.logo {
    width: 32px;
    height: 32px;
}

.info .name {
    font-weight: 600;
    font-size: 14px;
}

.info .phone {
    font-size: 13px;
    color: #555;
}

.tpl3-related {
    padding: 16px;
}

.tpl3-related-title {
    font-weight: 600;
    font-size: 14px;
    margin-bottom: 8px;
}

.tpl3-related-item {
    text-align: center;
}

.tpl3-related-item img {
    width: 100%;
    border-radius: 8px;
    margin-bottom: 8px;
}

.tpl3-related-item .name {
    font-size: 14px;
    font-weight: 500;
    margin-bottom: 4px;
}

.tpl3-related-item .price {
    font-weight: bold;
    color: #333;
}

.tpl3-powered {
    text-align: center;
    font-size: 12px;
    color: #888;
    margin-top: 16px;
}
</style>