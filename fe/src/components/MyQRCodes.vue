<template>
    <div>
        <a-page-header title="Mã QR của tôi" />

        <a-row justify="space-between" style="margin-bottom: 16px;">
            <a-col>
                <a-space>
                    <a-input
                            v-model:value="search"
                            placeholder="Tìm theo tên hoặc link..."
                            @pressEnter="fetchQRCodes"
                    />
                    <a-select
                            v-model:value="filterType"
                            placeholder="Đối tượng"
                            style="width: 150px"
                            @change="fetchQRCodes"
                    >
                        <a-select-option value="">Tất cả</a-select-option>
                        <a-select-option value="product">Sản phẩm</a-select-option>
                        <a-select-option value="store">Cửa hàng</a-select-option>
                        <a-select-option value="event">Sự kiện</a-select-option>
                    </a-select>
                </a-space>
            </a-col>

            <a-col>
                <a-button type="primary" @click="goToCreateQR">
                    <template #icon><PlusOutlined /></template>
                    Tạo mã QR
                </a-button>
            </a-col>
        </a-row>

        <a-table :columns="columns" :data-source="qrCodes" row-key="qr_id" :loading="loading">
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'qr_url'">
                    <a
                            :href="httpOnlyUrl(record.qr_url)"
                            target="_blank"
                            rel="noopener noreferrer"
                            style="color: #000000"
                    >
                        {{ httpOnlyUrl(record.qr_url) }}
                    </a>
                </template>

                <template v-if="column.key === 'qr'">
                    <div :ref="el => appendQRCode(el, record)" style="width: 60px; height: 60px;"></div>
                </template>

                <template v-if="column.key === 'target_name'">
                    <a
                        :href="getTargetEditUrl(record)"
                        style="color: #1677ff"
                    >
                        {{ record.target_name }}
                    </a>
                </template>

                <template v-if="column.key === 'action'">
                    <a-space>
                        <a-button @click="download(record)">Tải</a-button>
                        <a-button @click="edit(record)">Sửa</a-button>
                        <a-popconfirm title="Xoá mã QR này?" @confirm="remove(record.qr_id)">
                            <a-button danger>Xoá</a-button>
                        </a-popconfirm>
                    </a-space>
                </template>
            </template>
        </a-table>
    </div>
</template>

<script setup>
    import { ref, onMounted } from 'vue'
    import { message } from 'ant-design-vue'
    import { useRouter } from 'vue-router'
    import { getQRList, deleteQR } from '@/api/qrcode'
    import { PlusOutlined } from '@ant-design/icons-vue'
    import QRCodeStyling from 'qr-code-styling'

    const qrInstances = ref({})
    const router = useRouter()
    const qrCodes = ref([])
    const search = ref('')
    const filterType = ref('')
    const loading = ref(false)

    const columns = [
        { title: 'Mã', key: 'qr', dataIndex: 'qr_image_url' },
        { title: 'Liên kết', key: 'qr_url', dataIndex: 'qr_url' },
        { title: 'Tên mã QR', key: 'qr_name', dataIndex: 'qr_name' },
        { title: 'Tên đối tượng', key: 'target_name', dataIndex: 'target_name' },
        { title: 'Kiểu', key: 'target_type', dataIndex: 'target_type' },
        { title: 'Nhật ký quét', key: 'scan_count', dataIndex: 'scan_count' },
        { title: 'Hành động', key: 'action' },
    ]

    const httpOnlyUrl = (url) => {
        const isLocal = ['localhost', '127.0.0.1', 'giang.test'].includes(window.location.hostname)
        return isLocal && url.startsWith('https://')
            ? url.replace('https://', 'http://')
            : url
    }

    const getTargetEditUrl = (record) => {
        const type = record.target_type
        const id = record.target_id
        if (!type || !id) return '#'
        return `/${type}s/${id}/edit`
    }


    const fetchQRCodes = async () => {
        loading.value = true
        try {
            const params = {
                search: search.value,
                type: filterType.value
            }
            const res = await getQRList(params)
            qrCodes.value = res.data || []
        } catch (err) {
            message.error('Lỗi tải danh sách QR')
            console.error(err)
        } finally {
            loading.value = false
        }
    }

    const download = (record) => {
        window.open(httpOnlyUrl(record.qr_image_url), '_blank')
    }

    const edit = (record) => {
        if (!record.qr_id) {
            message.error('Không tìm thấy ID mã QR')
            return
        }
        router.push(`/my-qr-codes/${record.qr_id}/edit`)
    }

    const remove = async (qr_id) => {
        try {
            await deleteQR(qr_id)
            message.success('Đã xoá thành công')
            await fetchQRCodes()
        } catch (err) {
            message.error('Xoá thất bại')
        }
    }

    const goToCreateQR = () => {
        router.push('/my-qr-codes/create')
    }

    const appendQRCode = (el, record) => {
        if (!el || qrInstances.value[record.qr_id]) return

        try {
            const config = typeof record.settings_json === 'string'
                ? JSON.parse(record.settings_json)
                : record.settings_json

            const qrCode = new QRCodeStyling({
                ...config,
                width: 60,
                height: 60,
                data: httpOnlyUrl(record.qr_url || config.data || 'https://example.com')
            })

            qrCode.append(el)
            qrInstances.value[record.qr_id] = qrCode
        } catch (e) {
            console.error('QR init failed for', record.qr_id, e)
        }
    }

    onMounted(fetchQRCodes)
</script>
