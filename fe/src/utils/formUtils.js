import dayjs from "dayjs";
// formUtils.js
export const normalizeProductData = (data) => {
    const fieldsToParse = ['avatar', 'image', 'video', 'certificate_file']

    fieldsToParse.forEach(field => {
        try {
            if (!data[field]) {
                data[field] = []
            } else {
                let parsed = JSON.parse(data[field])
                if (Array.isArray(parsed)) {
                    data[field] = parsed
                } else if (typeof parsed === 'string') {
                    // Trường hợp bị JSON stringify nhiều lớp, ví dụ: "\"http://url.jpg\""
                    data[field] = [parsed.replace(/^"(.*)"$/, '$1')]
                } else {
                    data[field] = []
                }
            }
        } catch {
            // Nếu JSON.parse thất bại, cố gắng loại bỏ dấu nháy ngoài cùng
            data[field] = [data[field].replace(/^"(.*)"$/, '$1')]
        }
    })

    data.show_contact_price = !!Number(data.show_contact_price)
    data.status = !!Number(data.status)

    return data
}


export const formatDate = (value) => {
    if (!value) return ''
    const date = new Date(value)
    return date.toLocaleDateString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    })
}

export const toDayjs = (value) => {
    return value ? dayjs(value) : null
}



export const formatDateForSave = (value) => {
    if (!value) return null
    return dayjs(value).format('YYYY-MM-DD HH:mm:ss') // format chuẩn cho backend PHP/MySQL
}


export const parseFieldsForList = (list, fields = ['logo']) => {
    return list.map(item => {
        fields.forEach(field => {
            const value = item[field]
            if (typeof value === 'string') {
                try {
                    const parsed = JSON.parse(value)
                    item[field] = Array.isArray(parsed) ? parsed : []
                } catch (e) {
                    item[field] = []
                }
            }
        })
        return item
    })
}

export const formatCurrency = (value) => {
    if (!value) return '0 đ'
    return Number(value).toLocaleString('vi-VN', {
        style: 'currency',
        currency: 'VND',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    })
}
