<template>
    <div class="tpl-wrapper">
        <div class="tpl-image">
            <img src="http://assets.giang.test/image/1745030161_1629c049dd5304b986df.jpg" alt="Sản phẩm" class="slide-img"/>
        </div>

        <div class="tpl-info">
            <div class="tpl-price-section">
                <div class="tpl-name">{{ product.name }}</div>
                <div class="tpl-price">{{ formatCurrency(product.price) }}</div>
                <div class="tpl-code">{{ product.sku }}</div>
                <div class="tpl-size">
                    Kích thước:
                    <span v-if="product.attributes?.length" class="pill">
                        {{ product.attributes[0].name }}
                    </span>
                </div>
            </div>

            <div class="tpl-company" v-if="businessList.length">
                <div class="tpl-company-label">Doanh nghiệp</div>
                <div v-for="biz in businessList" :key="biz.id" class="tpl-company-detail">
                    <div class="company-logo">
                        <img :src="biz.logo?.[0] || defaultLogo" alt="logo" />
                    </div>
                    <div class="company-info">
                        <div class="company-name">{{ biz.name }}</div>
                        <div class="company-phone">{{ biz.phone }}</div>
                    </div>
                </div>
            </div>

            <div class="tpl-company" v-if="storeList.length">
                <div class="tpl-company-label">Cửa hàng</div>
                <div v-for="st in storeList" :key="st.id" class="tpl-company-detail">
                    <div class="company-logo">
                        <img :src="st.logo || defaultLogo" alt="logo" />
                    </div>
                    <div class="company-info">
                        <div class="company-name">{{ st.name }}</div>
                        <div class="company-phone">{{ st.phone }}</div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</template>

<script setup>
const props = defineProps({
    product: Object,
    business: Object,
    store: Object
})

const defaultLogo = 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Ant_Design_Logo_1x.svg/768px-Ant_Design_Logo_1x.svg.png'

// Truy cập props đúng cách
const businessList = props.business
    ? (Array.isArray(props.business) ? props.business : [props.business])
    : [];

const storeList = props.store
    ? (Array.isArray(props.store) ? props.store : [props.store])
    : [];


console.log('businessItem',businessList)
console.log('storeItem',storeList)

const formatCurrency = (value) => {
    if (!value) return ''
    return new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(value)
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
    background: #fff;
    border-radius: 12px;
    overflow-y: scroll;
    color: #000;
    display: flex;
    flex-direction: column;
    height: 100%;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
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


.tpl-image img {
    width: 100%;
    height: auto;
    object-fit: cover;
    display: block;
}

.tpl-info {
    display: flex;
    flex-direction: column;
    padding: 16px;
    gap: 16px;
}

.tpl-price-section {
    background: #22c55e;
    padding: 16px;
    border-radius: 8px;
    color: #fff;
}

.tpl-price {
    font-size: 20px;
    font-weight: bold;
    margin-bottom: 4px;
}

.tpl-code {
    font-size: 13px;
    opacity: 0.9;
    margin-bottom: 4px;
}

.tpl-size {
    font-size: 13px;
}

.pill {
    background: #fff;
    color: #22c55e;
    padding: 2px 8px;
    border-radius: 12px;
    font-weight: 600;
    font-size: 12px;
}

.tpl-company {
    background: #f5f5f5;
    padding: 12px;
    border-radius: 8px;
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
    color: #22c55e;
}

.tpl-image {
    width: 100%;
    height: auto;
}

.slide-img {
    width: 100%;
    height: 200px; /* Hoặc chiều cao mong muốn */
    object-fit: cover;
    border-radius: 8px;
}

/* Tùy chỉnh dots nếu muốn */
:deep(.slick-dots li button) {
    background: rgba(0, 0, 0, 0.3);
}

:deep(.slick-dots li.slick-active button) {
    background: #22c55e;
}
</style>
