<template>
    <a-card bordered>
        <a-table
            :columns="cols"
            :data-source="pagedRows"
            :loading="loading"
            row-key="rowKey"
            :pagination="false"
            :locale="{ emptyText: 'Không có văn bản' }"
        >
            <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'title'">
                    <div class="title">
                        <a-typography-text>{{ record.title }}</a-typography-text>
                    </div>
                </template>

                <template v-else-if="column.key === 'submitted_at'">
                    {{ formatTime(record.submitted_at) || '—' }}
                </template>

                <template v-else-if="column.key === 'action'">
                    <a-space align="center" wrap>
                        <a-button @click="openPreview(record)">Xem trước</a-button>
                        <a-tooltip :title="signedTooltip(record)">
                            <a-button @click="openSignedPreview(record)">
                                {{ signedButtonLabel(record) }}
                            </a-button>
                        </a-tooltip>
                        <a-button danger @click="reject(record)" :disabled="record.__approved">Từ chối</a-button>

                        <a-button
                            :loading="isSigning(record)"
                            :disabled="isSigning(record) || !record.__canSign"
                            @click="signAndPreview(record)"
                        >
                            Ký duyệt
                        </a-button>


                        <a-tooltip :title="smartStatus(record).tooltip">
                            <a-tag :color="smartStatus(record).color" style="margin-left:6px">
                                <CheckCircleTwoTone v-if="record.__approved" twoToneColor="#52c41a" style="margin-right:4px" />
                                {{ smartStatus(record).text }}
                            </a-tag>
                        </a-tooltip>

                    </a-space>
                </template>
            </template>
        </a-table>

        <div class="mt-3" v-if="pager.total > 0">
            <a-pagination
                :current="pager.current"
                :pageSize="pager.pageSize"
                :total="pager.total"
                show-size-changer
                :pageSizeOptions="['10','20','50']"
                @change="onPageChange"
                @showSizeChange="onPageSizeChange"
            />
        </div>
    </a-card>

    <a-modal v-model:open="previewOpen" title="Bản xem trước" :footer="null" width="80%">
        <a-spin :spinning="previewLoading">
            <iframe v-if="previewUrl" :src="previewUrl" style="width:100%;height:78vh;border:none"></iframe>
        </a-spin>
    </a-modal>
</template>

<script setup>
import {computed, onMounted, ref} from 'vue'
import {message} from 'ant-design-vue'
import {PDFDocument, rgb} from 'pdf-lib'
import fontkit from '@pdf-lib/fontkit'
import {CheckCircleTwoTone} from '@ant-design/icons-vue'
import {getDocumentsByDepartment} from '@/api/document'
import {
    approveDocumentApproval,
    fetchActiveInstanceId,
    getApprovalDetail,
    getApprovalsByDocument,
    sendApproval
} from '@/api/approvals'
import {getCurrentUser, getUsers} from '@/api/user'
import notoUrl from '@/assets/fonts/NotoSans-Regular.ttf?url'

/* ---------- UI ---------- */
const signingRowKey = ref(null)
const previewLoading = ref(false)
const previewOpen = ref(false)
const previewUrl = ref('')
const loading = ref(false)

// Chuẩn hoá mọi kiểu response thành mảng
function normalizeArray(res) {
    if (Array.isArray(res)) return res;
    if (Array.isArray(res?.data)) return res.data;
    if (Array.isArray(res?.data?.data)) return res.data.data;
    return [];
}

async function hydrateRowState(rec, currentUserId) {
    try {
        const raw = await getApprovalsByDocument(rec.document_id);
        const approvals = normalizeArray(raw);
        const lower = s => String(s || '').toLowerCase();
        const docFinishedFromRow = lower(rec.approval_status) === 'approved';

        const myEverSigned = approvals.some(a =>
            Array.isArray(a.steps) &&
            a.steps.some(s => Number(s.approver_id) === Number(currentUserId) && lower(s.status) === 'approved')
        );

        const active = approvals
            .filter(a => ['pending', 'active'].includes(lower(a.status)))
            .sort((a, b) => Number(b.id) - Number(a.id))[0];

        const pickName = (s) => s?._approver_name || `User #${s?.approver_id || ''}`;

        if (active) {
            rec.instance_id = Number(active.id);

            const steps = Array.isArray(active.steps) ? active.steps : [];
            const total = steps.length;
            const approvedCount = steps.filter(s => lower(s.status) === 'approved').length;
            const remaining = Math.max(total - approvedCount, 0);

            // người tiếp theo (first step chưa approved)
            const nextStep = steps.find(s => lower(s.status) !== 'approved');
            rec.__nextApproverName = nextStep ? pickName(nextStep) : '';

            // bạn có trong flow không?
            const myStep = steps.find(s => Number(s.approver_id) === Number(currentUserId));
            rec.__inFlow = !!myStep;

            const mySignedInActive = !!(myStep && lower(myStep.status) === 'approved');

            // Số người trước bạn (chưa approved và đứng trước bạn theo sequence)
            const myOrder = myStep?.sequence ?? myStep?.order ?? Infinity;
            rec.__pendingBeforeMe = steps.filter(s => {
                const ord = s?.sequence ?? s?.order ?? 999999;
                return ord < myOrder && lower(s.status) !== 'approved';
            }).length;

            rec.__totalSigners = total;
            rec.__approvedCount = approvedCount;
            rec.__remaining = remaining;

            const signableStatuses = new Set(['pending', 'active', 'waiting', '']);
            const myStepStatus = lower(myStep?.status);

            rec.__signedByMe = myEverSigned || mySignedInActive;
            rec.__canSign = !!myStep && !mySignedInActive && signableStatuses.has(myStepStatus);

            rec.__approved = docFinishedFromRow;
            return;
        }

        // Không có phiên active → lấy phiên mới nhất để thống kê
        const latest = approvals.sort((a, b) => Number(b.id) - Number(a.id))[0];
        const steps = Array.isArray(latest?.steps) ? latest.steps : [];

        rec.__totalSigners = steps.length;
        rec.__approvedCount = steps.filter(s => lower(s.status) === 'approved').length;
        rec.__remaining = Math.max(rec.__totalSigners - rec.__approvedCount, 0);

        rec.__nextApproverName = '';
        rec.__pendingBeforeMe = 0;
        rec.__inFlow = steps.some(s => Number(s.approver_id) === Number(currentUserId));

        rec.__approved = docFinishedFromRow;
        rec.__signedByMe = myEverSigned;
        rec.__canSign = !docFinishedFromRow && !myEverSigned;

    } catch (e) {
        console.warn('hydrateRowState error', e);
        rec.__canSign = false;
    }
}

function smartStatus(rec) {
    // 1) Đã hoàn tất
    if (rec.__approved) {
        const ratio = rec.__totalSigners ? ` (${rec.__approvedCount}/${rec.__totalSigners})` : '';
        return {
            color: 'green',
            text: `Đã duyệt${ratio}`,
            tooltip: 'Tài liệu đã hoàn tất quá trình ký.'
        };
    }

    // 2) Bạn đã ký nhưng chưa hoàn tất
    if (rec.__signedByMe) {
        const remain = rec.__remaining;
        const total = rec.__totalSigners;
        return {
            color: 'blue',
            text: 'Bạn đã ký',
            tooltip: total ? `Còn ${remain} người chưa ký trên tổng ${total}.` : 'Bạn đã ký.'
        };
    }

    // 3) Đến lượt bạn ký
    if (rec.__canSign) {
        const afterYou = Math.max(rec.__remaining - 1, 0);
        const hint = afterYou > 0 ? `Sau bạn còn ${afterYou} người.` : 'Bạn là người cuối cùng.';
        return {
            color: 'geekblue',
            text: 'Đến lượt bạn ký',
            tooltip: hint
        };
    }

    // 4) Bạn trong flow nhưng chưa đến lượt
    if (rec.__inFlow && rec.__pendingBeforeMe > 0) {
        const nextName = rec.__nextApproverName || 'người trước';
        return {
            color: 'gold',
            text: `Chờ ${rec.__pendingBeforeMe} người trước bạn`,
            tooltip: `Tiếp theo: ${nextName}`
        };
    }

    // 5) Bạn không nằm trong luồng ký
    return {
        color: 'default',
        text: 'Ngoài luồng ký',
        tooltip: 'Bạn không nằm trong danh sách ký của tài liệu này.'
    };
}

async function hydrateRows() {
    const me = await getCurrentUser();
    const currentUserId = Number(me?.id || 0);
    const tasks = rows.value.map(r => hydrateRowState(r, currentUserId));
    await Promise.all(tasks);
}


function signedButtonLabel(rec) {
    const n = Number(rec.__approvedCount || 0);
    const total = Number(rec.__totalSigners || 0);

    if (rec.__approved) {
        // Đã hoàn tất
        return total > 0
            ? `Bản hoàn tất (${n}/${total})`
            : `Bản hoàn tất`;
    }

    if (n <= 0) {
        return 'Chưa có chữ ký';
    }

    // Đang trong quá trình, đã có chữ ký
    return total > 0
        ? `Bản có chữ ký (${n}/${total})`
        : `Bản có chữ ký (${n})`;
}

function signedTooltip(rec) {
    const n = Number(rec.__approvedCount || 0);
    const total = Number(rec.__totalSigners || 0);
    const remain = Number(rec.__remaining || 0);
    const nextName = rec.__nextApproverName || '';

    if (rec.__approved) {
        return total > 0
            ? `Tài liệu đã hoàn tất: ${n}/${total} người đã ký.`
            : 'Tài liệu đã hoàn tất.';
    }

    if (n <= 0) {
        return 'Chưa ai ký tài liệu này.';
    }

    // Đang trong quá trình ký
    if (total > 0) {
        const nextHint = nextName ? ` Tiếp theo: ${nextName}.` : '';
        return `Đã có ${n}/${total} người ký. Còn ${remain} người chưa ký.${nextHint}`;
    }

    return `Đã có ${n} người ký.`;
}





const baseURL = import.meta.env.VITE_API_URL
const isSigning = (record) => signingRowKey.value === record.rowKey

const props = defineProps({
    mySignatureUrl: { type: String, default: '' },
})

/* ---------- Table ---------- */
const rows = ref([])
const pager = ref({ current: 1, pageSize: 10, total: 0 })

// handlers khớp với a-pagination (Ant Design Vue 3)
const onPageChange = (page, pageSize) => {
    pager.value.current = page
    if (pageSize && pageSize !== pager.value.pageSize) {
        pager.value.pageSize = pageSize
    }
}

const onPageSizeChange = (current, size) => {
    pager.value.pageSize = size
    pager.value.current = 1
}

const pagedRows = computed(() => {
    const start = (pager.value.current - 1) * pager.value.pageSize
    console.log('rows.value', rows.value)
    return rows.value.slice(start, start + pager.value.pageSize)
})

const cols = [
    { title: 'Tiêu đề', key: 'title', dataIndex: 'title' },
    { title: 'Gửi lúc', key: 'submitted_at', dataIndex: 'submitted_at', width: 180 },
    { title: 'Tác vụ', key: 'action', width: 320 },
]

const formatTime = ts => (ts ? new Date(ts).toLocaleString('vi-VN') : '')
const safeUrl = (p) => /^https?:\/\//i.test(p) ? p : `${baseURL}/${p}`

/* ---------- Fetch documents ---------- */
async function fetchRows() {
    loading.value = true;
    try {
        const res = await getDocumentsByDepartment();
        const docs = normalizeArray(res);

        rows.value = docs
            .filter(d => String(d.file_path || '').endsWith('.pdf'))
            .map(d => ({
                rowKey: `${d.id}-${d.instance_id ?? 'noinst'}`,
                instance_id: d.instance_id ?? null,
                document_id: d.id,
                title: d.title,
                file_url: safeUrl(d.file_path),
                submitted_at: d.created_at,
                approval_status: d.approval_status,
                // hai cờ sẽ được hydrate sau:
                __totalSigners: 0,
                __approvedCount: 0,
                __remaining: 0,
                __nextApproverName: '',
                __pendingBeforeMe: 0,
                __inFlow: false,

            }));

        pager.value.total = rows.value.length;

        // Đồng bộ trạng thái từ /document-approvals
        await hydrateRows();

    } catch (err) {
        console.error(err);
        message.error('Không thể tải danh sách văn bản');
    } finally {
        loading.value = false;
    }
}


/* ---------- User & Approval cache ---------- */
let userCache = null
async function ensureUsersMap() {
    if (!userCache) {
        const { data } = await getUsers()
        const arr = Array.isArray(data) ? data : data?.data || []
        userCache = new Map(arr.map(u => [String(u.id), u]))
    }
    return userCache
}

/* ---------- Load signer records ---------- */
async function loadSignerRecordsFor(rec) {
    let steps = []
    if (rec.instance_id) {
        const { data } = await getApprovalDetail(rec.instance_id)
        steps = data?.steps || []
    } else {
        const raw = await getApprovalsByDocument(rec.document_id);
        const approvals = normalizeArray(raw);
        steps = Array.isArray(approvals?.[0]?.steps) ? approvals[0].steps : [];
    }
    const users = await ensureUsersMap()
    const list = steps.map(s => {
        const u = users.get(String(s.approver_id)) || {}
        const name = s._approver_name || u.name || `User #${s.approver_id}`
        const sigUrl = s._approver_signature_url || u.signature_url || props.mySignatureUrl
        const signedAt = s.acted_at ? { iso: new Date(s.acted_at).toISOString() } : null
        const seq = s.sequence || 0
        const pos = seq <= 3 ? { row: 'top', index: seq - 1 } : { row: 'bottom', index: null }
        return {
            signer_id: s.approver_id,
            name,
            signature_image: sigUrl,
            signed_at: signedAt,
            order: seq,
            position: pos,
            status: s.status === 'approved' ? 'signed' : s.status === 'active' ? 'pending' : 'waiting',
        }
    })
    return list.sort((a, b) => (a.order || 9999) - (b.order || 9999))
}

/* ---------- PDF logic ---------- */
async function embedUnicodeFont(pdfDoc) {
    const res = await fetch(notoUrl)
    const buf = await res.arrayBuffer()
    return pdfDoc.embedFont(buf, { subset: true })
}

async function embedImageFromUrl(pdfDoc, url, cache) {
    if (!url) return null
    if (cache.has(url)) return cache.get(url)
    const res = await fetch(url)
    const ab = await res.arrayBuffer()
    const img = url.endsWith('.png')
        ? await pdfDoc.embedPng(ab)
        : await pdfDoc.embedJpg(ab)
    cache.set(url, img)
    return img
}

async function tryEmbedFallback(pdfDoc, url) {
    try {
        if (!url) return null
        const r = await fetch(url)
        const ab = await r.arrayBuffer()
        return url.endsWith('.png') ? await pdfDoc.embedPng(ab) : await pdfDoc.embedJpg(ab)
    } catch { return null }
}

function parseSignedAt(rec) {
    const d = rec?.signed_at?.iso ? new Date(rec.signed_at.iso) : new Date()
    const z = n => String(n).padStart(2, '0')
    return `${z(d.getDate())}/${z(d.getMonth() + 1)}/${d.getFullYear()} ${z(d.getHours())}:${z(d.getMinutes())}`
}

async function drawOneSignature(pdfDoc, page, rec, xLeft, yBottom, sigW, sigH, aspect, font, fallbackSigImg, cache) {
    let img = await embedImageFromUrl(pdfDoc, rec.signature_image, cache).catch(() => fallbackSigImg)
    if (img) page.drawImage(img, { x: xLeft, y: yBottom, width: sigW, height: sigH })
    const name = rec.name || 'Người ký'
    const timeStr = parseSignedAt(rec)
    const nameW = font.widthOfTextAtSize(name, 16)
    const timeW = font.widthOfTextAtSize(timeStr, 14)
    page.drawText(name, { x: xLeft + (sigW - nameW) / 2, y: yBottom - 26, size: 16, font, color: rgb(0, 0, 0) })
    page.drawText(timeStr, { x: xLeft + (sigW - timeW) / 2, y: yBottom - 44, size: 14, font, color: rgb(0, 0, 0) })
}


async function ensureInstance(rec) {
    // 0) Kiểm tra đầu vào
    const docId = Number(rec?.document_id || 0)
    if (!docId) throw new Error('Thiếu document_id.')

    // 1) Kiểm tra instance có sẵn
    let instanceId = Number(rec?.instance_id || 0)
    if (!instanceId) {
        try {
            const id = await fetchActiveInstanceId(docId)
            instanceId = Number(id || 0)
        } catch (e) {
            console.warn('fetchActiveInstanceId error', e)
        }
    }
    if (instanceId) {
        rec.instance_id = instanceId
        return instanceId
    }

    // 2) Fallback: tìm pending approval mới nhất
    try {
        const { data } = await getApprovalsByDocument(docId)
        const list = Array.isArray(data?.data) ? data.data : []
        const pendingLatest = list
            .filter(r => String(r.status).toLowerCase() === 'pending')
            .sort((a, b) => Number(b.id) - Number(a.id))[0]
        if (pendingLatest?.id) {
            rec.instance_id = Number(pendingLatest.id)
            return pendingLatest.id
        }
    } catch (e) {
        console.warn('getApprovalsByDocument fallback error', e)
    }

    // 3) Không có -> tạo mới
    const user = await getCurrentUser()
    const currentUserId = Number(user?.id || 0)
    if (!currentUserId) throw new Error('Không xác định được người duyệt hiện tại.')

    const payload = {
        document_id: docId,
        approver_ids: [currentUserId],
        note: 'Auto-created from Ký duyệt',
    }

    const res = await sendApproval(payload)
    if (!res.ok) {
        if (res.status === 422) {
            try {
                const again = await fetchActiveInstanceId(docId)
                const id = Number(again || 0)
                if (id) {
                    rec.instance_id = id
                    return id
                }
            } catch {}
        }
        throw new Error(`Không tạo được phiên duyệt (status ${res.status}): ${JSON.stringify(res.data)}`)
    }

    const newId = Number(res?.data?.id || 0)
    if (!newId) throw new Error('sendApproval trả về dữ liệu không có id.')
    rec.instance_id = newId
    return newId
}


// 2) Hàm chính: đã chèn ensureInstance() và giữ nguyên phần ký + approve
async function signAndPreview(rec) {
    signingRowKey.value = rec.rowKey
    previewLoading.value = true
    const msgKey = 'signing'
    message.loading({ content: 'Đang thực hiện ký duyệt, vui lòng chờ...', key: msgKey, duration: 0 })

    try {
        // A) Đảm bảo có instance_id (tự tạo nếu chưa có)
        const instanceId = await ensureInstance(rec)

        // B) Load + ký PDF
        const pdfBytes = await (await fetch(rec.file_url, { cache: 'no-store' })).arrayBuffer()
        const pdfDoc = await PDFDocument.load(pdfBytes)
        pdfDoc.registerFontkit(fontkit)

        const font = await embedUnicodeFont(pdfDoc)
        const signerRecords = await loadSignerRecordsFor(rec)

        const fallbackSigImg = await tryEmbedFallback(pdfDoc, props.mySignatureUrl)
        const pages = pdfDoc.getPages()
        const page = pages[pages.length - 1]
        const width = page.getWidth()
        const sidePad = 40, bottomPad = 30
        const sigW = (width - sidePad * 2) / 3.5
        const sigH = sigW / 2.6
        const cache = new Map()

        // vẽ 3 top
        let x = sidePad
        for (let i = 0; i < 3; i++) {
            const s = signerRecords[i]
            if (s) await drawOneSignature(pdfDoc, page, s, x, 120, sigW, sigH, 2.6, font, fallbackSigImg, cache)
            x += sigW + 20
        }
        // vẽ bottom
        const bottomRec = signerRecords[3]
        if (bottomRec) {
            await drawOneSignature(pdfDoc, page, bottomRec, width / 2 - sigW / 2, bottomPad, sigW, sigH, 2.6, font, fallbackSigImg, cache)
        }

        // C) Hiện bản xem trước
        const out = await pdfDoc.save()
        const blob = new Blob([out], { type: 'application/pdf' })
        previewUrl.value = URL.createObjectURL(blob)
        previewOpen.value = true

        await approveDocumentApproval(instanceId, {
            comment: 'Đã ký duyệt (preview phía client)',
            signature_url: props.mySignatureUrl || null,
            signed_pdf_url: null,
        });

        // Cập nhật lại đúng quyền của bạn & trạng thái phiên
        const me = await getCurrentUser();
        await hydrateRowState(rec, Number(me?.id || 0));

        message.success({ content: 'Đã lưu trạng thái duyệt', key: msgKey });

    } catch (e) {
        console.error(e)
        message.error({ content: e?.message || 'Ký thất bại', key: msgKey })
    } finally {
        signingRowKey.value = null
        previewLoading.value = false
    }
}

// ========== helpers ==========

async function resolveInstanceId(rec) {
    if (rec.instance_id) return rec.instance_id
    const id = await fetchActiveInstanceId(rec.document_id).catch(() => null)
    if (id) { rec.instance_id = id; return id }
    try {
        const raw = await getApprovalsByDocument(rec.document_id);
        const list = normalizeArray(raw);
        const pendingLatest = list
            .filter(r => String(r.status).toLowerCase() === 'pending')
            .sort((a, b) => Number(b.id) - Number(a.id))[0];
        if (pendingLatest?.id) {
            rec.instance_id = pendingLatest.id;
            return pendingLatest.id;
        }
    } catch {}
    return null
}

function fmt(iso) {
    if (!iso) return ''
    const d=new Date(iso); const z=n=>String(n).padStart(2,'0')
    return `${z(d.getDate())}/${z(d.getMonth()+1)}/${d.getFullYear()} ${z(d.getHours())}:${z(d.getMinutes())}`
}

async function openSignedPreview(rec) {
    previewLoading.value = true
    try {
        // A) lấy tất cả chữ ký đã ký của document (kể cả các phiên đã APPROVED)
        const signed = await loadSignedRecordsByDocument(rec.document_id)

        if (!signed.length) {
            message.info('Chưa có ai ký tài liệu này.')
            return
        }

        // B) tải PDF gốc
        const pdfBytes = await (await fetch(rec.file_url, { cache: 'no-store' })).arrayBuffer()
        const pdfDoc = await PDFDocument.load(pdfBytes)
        pdfDoc.registerFontkit(fontkit)
        const font = await embedUnicodeFont(pdfDoc)

        // C) vẽ chữ ký lên trang cuối
        const page = pdfDoc.getPages().slice(-1)[0]
        const width = page.getWidth()
        const sidePad = 40, bottomPad = 30
        const sigW = (width - sidePad * 2) / 3.5
        const sigH = sigW / 2.6
        const cache = new Map()

        const fmt = (iso) => {
            if (!iso) return ''
            const d = new Date(iso), z = n => String(n).padStart(2,'0')
            return `${z(d.getDate())}/${z(d.getMonth()+1)}/${d.getFullYear()} ${z(d.getHours())}:${z(d.getMinutes())}`
        }

        const drawBlock = async (s, x, y) => {
            const img = await embedImageFromUrl(pdfDoc, s.signature_image, cache).catch(() => null)
            if (img) page.drawImage(img, { x, y, width: sigW, height: sigH })
            const name = s.name || 'Người ký'
            const time = fmt(s.signed_at)
            const nameW = font.widthOfTextAtSize(name, 16)
            const timeW = font.widthOfTextAtSize(time, 14)
            page.drawText(name, { x: x + (sigW - nameW)/2, y: y - 26, size: 16, font, color: rgb(0,0,0) })
            page.drawText(time, { x: x + (sigW - timeW)/2, y: y - 44, size: 14, font, color: rgb(0,0,0) })
        }

        // layout 3 trên + 1 dưới (giữ nguyên style của bạn)
        let x = sidePad
        for (let i = 0; i < 3 && i < signed.length; i++) {
            await drawBlock(signed[i], x, 120)
            x += sigW + 20
        }
        if (signed.length > 3) {
            await drawBlock(signed[3], width / 2 - sigW / 2, bottomPad)
        }

        // (nếu >4 người → muốn auto thêm trang, nói mình bổ sung)

        // D) mở preview
        const out = await pdfDoc.save()
        const blob = new Blob([out], { type: 'application/pdf' })
        previewUrl.value = URL.createObjectURL(blob)
        previewOpen.value = true
    } catch (e) {
        console.error(e)
        message.error('Không thể tạo bản có chữ ký')
    } finally {
        previewLoading.value = false
    }
}



// Lấy danh sách chữ ký đã ký (từ mọi phiên của 1 document)
async function loadSignedRecordsByDocument(documentId) {
    const raw = await getApprovalsByDocument(documentId);
    const approvals = normalizeArray(raw);

    const signed = [];
    for (const apv of approvals) {
        const steps = Array.isArray(apv?.steps) ? apv.steps : [];
        for (const s of steps) {
            if (String(s.status).toLowerCase() === 'approved') {
                const sig = s.signature_url || s._acted_by_signature_url || s._approver_signature_url;
                if (sig) {
                    signed.push({
                        name: s._approver_name || `User #${s.approver_id}`,
                        signature_image: sig,
                        signed_at: s.acted_at || s.signed_at || null,
                        order: Number(s.sequence || 0),
                        instance_id: Number(apv.id || 0),
                        instance_status: apv.status,
                        instance_created_at: apv.created_at,
                    });
                }
            }
        }
    }

    signed.sort((a, b) => {
        const ta = a.signed_at ? +new Date(a.signed_at) : 0;
        const tb = b.signed_at ? +new Date(b.signed_at) : 0;
        if (ta !== tb) return ta - tb;
        if (a.order !== b.order) return a.order - b.order;
        return (a.instance_id || 0) - (b.instance_id || 0);
    });
    return signed;
}



// chỉ lấy NHỮNG NGƯỜI ĐÃ KÝ cho tài liệu này
async function loadSignedRecords(rec) {
    const instanceId = await resolveInstanceId(rec)
    if (!instanceId) return []
    const { data } = await getApprovalDetail(instanceId) // { id, steps: [...] }
    const steps = Array.isArray(data?.steps) ? data.steps : []
    // chỉ giữ step đã approved và có signature_url
    return steps
        .filter(s => String(s.status).toLowerCase() === 'approved')
        .map(s => ({
            signer_id: s.approver_id,
            name: s._approver_name || `User #${s.approver_id}`,
            // quan trọng: dùng chữ ký của lần ký (backend đã lưu vào step.signature_url)
            signature_image: s.signature_url || s._acted_by_signature_url || null,
            signed_at: s.acted_at || s.signed_at || null, // datetime
            order: s.sequence || 0,
        }))
        .filter(s => !!s.signature_image)
        .sort((a, b) => (a.order || 9999) - (b.order || 9999))
}


function parseSignedAtISO(iso) {
    if (!iso) return ''
    const d = new Date(iso)
    const z = n => String(n).padStart(2,'0')
    return `${z(d.getDate())}/${z(d.getMonth()+1)}/${d.getFullYear()} ${z(d.getHours())}:${z(d.getMinutes())}`
}

async function drawSignatureBlock(pdfDoc, page, rec, x, y, sigW, sigH, font, cache) {
    // ảnh chữ ký
    let img = await embedImageFromUrl(pdfDoc, rec.signature_image, cache).catch(() => null)
    if (img) page.drawImage(img, { x, y, width: sigW, height: sigH })

    // tên + thời điểm ký
    const name = rec.name || 'Người ký'
    const timeStr = parseSignedAtISO(rec.signed_at)
    const nameW = font.widthOfTextAtSize(name, 16)
    const timeW = font.widthOfTextAtSize(timeStr, 14)
    page.drawText(name, { x: x + (sigW - nameW)/2, y: y - 26, size: 16, font, color: rgb(0,0,0) })
    page.drawText(timeStr, { x: x + (sigW - timeW)/2, y: y - 44, size: 14, font, color: rgb(0,0,0) })
}




function openPreview(rec) {
    previewUrl.value = rec.file_url
    previewOpen.value = true
}

function reject(rec) {
    message.info(`(Demo) Từ chối: ${rec.title}`)
}

/* ---------- Lifecycle ---------- */
onMounted(fetchRows)
</script>

<style scoped>
.mt-3 { margin-top: 12px; }
.title { display: flex; align-items: center; }
</style>
