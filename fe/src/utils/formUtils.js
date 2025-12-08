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
    if (!value) return '0 VNĐ'
    return `${Number(value).toLocaleString('vi-VN')} VNĐ`
}


export const deadlineInfo = (end) => {
    if (!end) return { type: 'none' }
    const today = dayjs().startOf('day')
    const due = dayjs(end).startOf('day')
    if (!due.isValid()) return { type: 'none' }
    const diff = due.diff(today, 'day')
    if (diff === 0) return { type: 'today', days: 0 }
    if (diff > 0)   return { type: 'remaining', days: diff }
    return { type: 'overdue', days: Math.abs(diff) }
}

// ---------- Utils ----------
const OFFICE_EXTS = new Set(['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx']);

function getExt(nameOrUrl = '') {
    try {
        const clean = String(nameOrUrl).split('?')[0].split('#')[0];
        const dot = clean.lastIndexOf('.');
        return dot >= 0 ? clean.slice(dot + 1).toLowerCase() : '';
    } catch {
        return '';
    }
}

function pickUrl(obj = {}) {
    // Ưu tiên các field hay gặp
    return obj.file_url || obj.url || obj.file_path || obj.link_url || '';
}

// ---------- Openers ----------
/**
 * Mở xem trước tài liệu:
 * - Nếu là file Office -> mở Office Online Viewer
 * - Còn lại -> mở trực tiếp
 * @param {Object} file like { url/file_url/file_path, ext?, name? }
 * @returns {boolean} true nếu đã cố mở
 */
export function openPreviewFile(file) {
    if (!file) return false;
    const url = pickUrl(file);
    if (!url) return false;

    const ext = (file.ext || getExt(file.name || url)).toLowerCase();

    if (OFFICE_EXTS.has(ext)) {
        const enc = encodeURIComponent(url);
        window.open(`https://view.officeapps.live.com/op/view.aspx?src=${enc}`, '_blank', 'noopener');
        return true;
    }

    // PDF / ảnh / các loại khác: để trình duyệt tự xử lý
    window.open(url, '_blank', 'noopener');
    return true;
}

/**
 * Mở/tải file (không ép Office viewer), dùng khi muốn “Tải xuống/Mở”
 */
export function openDownloadFile(file) {
    if (!file) return false;
    const url = pickUrl(file);
    if (!url) return false;
    window.open(url, '_blank', 'noopener');
    return true;
}

export function getAvatarColor(name) {
    return '#004270'
}
