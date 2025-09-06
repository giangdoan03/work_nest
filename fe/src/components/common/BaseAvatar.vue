<template>
    <a-avatar
        v-bind="$attrs"
        :src="showImage ? fullSrc : undefined"
        :size="size"
        :shape="shape"
        :alt="altText"
        :style="!showImage ? { backgroundColor: bgColor, color: '#fff', userSelect: 'none' } : {}"
        @error="handleImgError"
    >
        <!-- fallback initials -->
        <span v-if="!showImage" style="font-weight:600; text-transform:uppercase;">
      {{ initials }}
    </span>
    </a-avatar>
</template>

<script setup>
import { computed, ref, watch } from 'vue'

// props
const props = defineProps({
    /** Đường dẫn ảnh: có thể là relative (uploads/...) hoặc absolute (http...) */
    src: { type: String, default: '' },
    /** Tên người dùng để lấy chữ cái đầu */
    name: { type: String, default: '' },
    /** Kích thước Avatar (số hoặc 'small'|'default'|'large') */
    size: { type: [Number, String], default: 40 },
    /** 'circle' | 'square' */
    shape: { type: String, default: 'circle' },
    /** Nếu muốn giữ nguyên host của src khi là absolute, đặt false (mặc định true: ép về API origin) */
    preferApiOrigin: { type: Boolean, default: true },
})

// Lấy origin từ VITE_API_URL (vd: http://api.worknest.local/api -> http://api.worknest.local)
const API_ORIGIN = new URL(import.meta.env.VITE_API_URL).origin

// Chuẩn hoá URL: nhận relative hoặc absolute; nếu preferApiOrigin=true sẽ ép host về API_ORIGIN
const normalizeUrl = (p) => {
    if (!p) return ''
    const u = new URL(p, API_ORIGIN)
    if (props.preferApiOrigin) {
        const base = new URL(API_ORIGIN)
        u.protocol = base.protocol
        u.host = base.host
    }
    return u.toString()
}

const fullSrc = computed(() => normalizeUrl(props.src))
const altText = computed(() => props.name || 'avatar')

// Khi src đổi phải thử hiển thị lại ảnh
const showImage = ref(!!props.src)
watch(() => props.src, () => {
    showImage.value = !!props.src
})

// Ảnh lỗi -> đổi qua initials
const handleImgError = () => {
    showImage.value = false
}

// Lấy initials: ký tự đầu của từ đầu tiên (bỏ khoảng trắng)
const initials = computed(() => {
    const n = (props.name || '').trim()
    if (!n) return '?'
    // Nếu muốn giữ dấu: dùng dòng dưới
    // return n[0].toLocaleUpperCase('vi')

    // Nếu muốn bỏ dấu (Á -> A) cho đồng nhất:
    const first = n.normalize('NFD').replace(/[\u0300-\u036f]/g, '')[0]
    return (first || '?').toUpperCase()
})


// Màu “random theo tên” (ổn định): hash tên -> chọn màu trong palette
const palette = [
    '#1abc9c','#2ecc71','#3498db','#9b59b6','#e67e22',
    '#e74c3c','#16a085','#27ae60','#2980b9','#8e44ad',
    '#d35400','#c0392b','#7f8c8d','#2c3e50'
]
const hash = (str) => {
    if (!str) return 0
    let h = 5381
    for (let i = 0; i < str.length; i++) h = ((h << 5) + h) + str.charCodeAt(i) // djb2
    return Math.abs(h)
}
const bgColor = computed(() => palette[hash(props.name) % palette.length])
</script>
