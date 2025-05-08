<template>
    <div class="tpl-wrapper" v-if="product">
        <div class="tpl-image">
            <a-carousel autoplay dots>
                <div v-for="(img, index) in product.image" :key="index">
                    <img :src="img" alt="Sản phẩm" class="slide-img"/>
                </div>
            </a-carousel>
        </div>

        <div class="tpl-info">
            <div class="tpl-title tpl-name">{{ product.name }}</div>
            <div class="tpl-price">{{ formatCurrency(product.price) }}</div>
            <div class="tpl-size">
                Kích thước:
                <span v-if="product.attributes?.length" class="pill">
          {{ product.attributes[0].name }}
        </span>
            </div>

            <div class="tpl-button">
                <a-button block shape="round" class="buy-button">Mua ngay</a-button>
            </div>

            <div class="tpl-description-block">
                <div class="tpl-desc-title">Mô tả</div>
                <div class="tpl-desc-content" v-html="product.description"></div>
            </div>

            <div class="tpl-company" v-if="businessItem">
                <div class="tpl-company-label">Doanh nghiệp</div>
                <div class="tpl-company-detail">
                    <div class="company-logo">
                        <img :src="businessItem.logo?.[0] || defaultLogo" alt="logo"/>
                    </div>
                    <div class="company-info">
                        <div class="company-name">{{ businessItem.name }}</div>
                        <div class="company-phone">{{ businessItem.phone }}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>


<script setup>
const props = defineProps({
    product: Object,
    business: [Object, Array],
})

const defaultLogo =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Ant_Design_Logo_1x.svg/768px-Ant_Design_Logo_1x.svg.png'

// Xử lý nếu business là mảng
const businessItem = Array.isArray(props.business)
    ? props.business[0]
    : props.business

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

.tpl-wrapper {
    font-family: 'Segoe UI', sans-serif;
    background: #fef6ec;
    border-radius: 16px;
    overflow: hidden;
    color: #111;
    display: flex;
    flex-direction: column;
    height: 100%;
}

.tpl-image img {
    width: 100%;
    height: auto;
    object-fit: cover;
    display: block;
}

.tpl-info {
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.tpl-title {
    font-size: 18px;
    font-weight: 600;
}

.tpl-price {
    font-size: 20px;
    font-weight: 700;
    color: #3b0086;
}

.tpl-size {
    font-size: 14px;
    color: #444;
}

.pill {
    background: #eee;
    color: #111;
    padding: 2px 8px;
    border-radius: 12px;
    font-weight: 600;
    font-size: 12px;
    margin-left: 6px;
}

.tpl-button .buy-button {
    background-color: #1e1c9c;
    color: #fff;
    font-weight: 500;
    border-radius: 999px;
}

.tpl-description-block {
    background: #fff;
    padding: 12px;
    border-radius: 12px;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

.tpl-desc-title {
    font-weight: 600;
    font-size: 14px;
    margin-bottom: 4px;
}

.tpl-desc-content {
    font-size: 13px;
    color: #666;
}

.tpl-company {
    margin-top: 12px;
    background: #fff;
    padding: 12px;
    border-radius: 12px;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

.tpl-company-label {
    font-weight: bold;
    font-size: 14px;
    margin-bottom: 8px;
}

.tpl-company-detail {
    display: flex;
    gap: 12px;
    align-items: center;
}

.company-logo img {
    width: 32px;
    height: 32px;
    object-fit: contain;
}

.company-info {
    display: flex;
    flex-direction: column;
}

.company-name {
    font-size: 14px;
    font-weight: 600;
}

.company-phone {
    font-size: 13px;
    color: #1e1c9c;
}

.tpl-wrapper {
    font-family: 'Segoe UI', sans-serif;
    background: #fef6ec;
    border-radius: 16px;
    overflow-y: scroll;
    color: #111;
    display: flex;
    flex-direction: column;
    height: 100%;
}

.tpl-wrapper::-webkit-scrollbar {
    width: 4px; /* Chiều rộng thanh cuộn */
}

.tpl-wrapper::-webkit-scrollbar-thumb {
    background-color: rgba(0, 0, 0, 0.2); /* Màu thanh cuộn */
    border-radius: 3px; /* Bo tròn thanh cuộn */
}

.tpl-wrapper::-webkit-scrollbar-track {
    background: transparent; /* Màu nền track */
}


.tpl-image {
    width: 100%;
    height: auto;
}

.slide-img {
    width: 100%;
    height: 240px;
    object-fit: cover;
    display: block;
    border-radius: 8px;
}

/* Dots */
:deep(.slick-dots li button) {
    background: rgba(0, 0, 0, 0.3);
}

:deep(.slick-dots li.slick-active button) {
    background: #3b0086;
}
</style>