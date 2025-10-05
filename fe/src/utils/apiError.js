// src/utils/apiError.js
export function parseApiError(err) {
    const out = {
        title: 'Lỗi hệ thống',
        desc: 'Không thể xử lý yêu cầu.',
        code: null,
        extra: null,
    };

    try {
        const data = err?.response?.data ?? {};
        out.title = String(data.title || data.error || data.message || 'Lỗi yêu cầu');
        // Bắt mọi loại (string/object/array) -> string an toàn
        const rawDesc = data.message ?? data.error ?? err?.message ?? '';
        out.desc = typeof rawDesc === 'string' ? rawDesc : JSON.stringify(rawDesc);
        out.code = data.code ?? err?.response?.status ?? null;
        out.extra = data.extra ?? null;
    } catch (_) {}

    return out;
}
