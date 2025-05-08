// src/components/templates/index.js
export default [
    {
        id: 'tpl-1',
        title: 'Mẫu 1',
        description: 'Giao diện vàng nhẹ',
        thumbnail: 'http://assets.giang.test/image/1745030161_1629c049dd5304b986df.jpg',
        component: () => import('./Tpl1.vue'),
    },
    {
        id: 'tpl-2',
        title: 'Mẫu 2',
        description: 'Giao diện tím sang trọng',
        thumbnail: 'http://assets.giang.test/image/1745030182_9c8ac5def4099a010923.jpg',
        component: () => import('./Tpl2.vue'),
    },
    {
        id: 'tpl-3',
        title: 'Mẫu doanh nghiệp hiện đại',
        description: 'Giao diện sáng, hiển thị chuyên nghiệp, bố cục rõ ràng',
        thumbnail: 'http://assets.giang.test/image/1745030199_204f7c732930f2e30a52.jpg',
        component: () => import('./Tpl3.vue'),
    },
    // ...
]
