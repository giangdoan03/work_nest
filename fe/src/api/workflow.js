// src/api/workflow.js
import axios from 'axios'

/**
 * ======================================================
 * AXIOS INSTANCE (GIỐNG customers.js)
 * ======================================================
 */
const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // giữ session login
})


// giả lập delay giống API thật
const sleep = (ms = 300) => new Promise(r => setTimeout(r, ms))

// ===== DATA FAKE (theo cấu trúc DB + task của bạn) =====
const FAKE_WORKFLOW_TASKS = [
    {
        id: 101,
        title: 'Soạn hồ sơ chào giá',
        department_id: 3,
        department_name: 'Phòng Kinh doanh',
        position_code: 'manager',
        level: 2,
        status: 'request_approval',
        assigned_to: 7,
        assigned_to_name: 'Nguyễn Cảnh Hợp',
    },
    {
        id: 102,
        title: 'Kiểm tra điều khoản thương mại',
        department_id: 4,
        department_name: 'Phòng Thương mại',
        position_code: 'manager',
        level: 2,
        status: 'request_approval',
        assigned_to: 14,
        assigned_to_name: 'Nguyễn Thị Hạnh',
    },
    {
        id: 103,
        title: 'Phê duyệt báo giá',
        department_id: 4,
        department_name: 'Phòng Thương mại',
        position_code: 'senior_manager',
        level: 3,
        status: 'pending',
        assigned_to: 10,
        assigned_to_name: 'Vũ Thị Thuỷ',
    },
    {
        id: 104,
        title: 'Phê duyệt hợp đồng',
        department_id: 3,
        department_name: 'Phòng Kinh doanh',
        position_code: 'senior_manager',
        level: 3,
        status: 'pending',
        assigned_to: 7,
        assigned_to_name: 'Nguyễn Cảnh Hợp',
    },
    {
        id: 105,
        title: 'Ký duyệt cuối',
        department_id: 6,
        department_name: 'Ban giám đốc',
        position_code: 'executive',
        level: 4,
        status: 'pending',
        assigned_to: 1,
        assigned_to_name: 'Lương Đức Thuỷ',
    },
    {
        id: 106,
        title: 'Hoàn tất hồ sơ',
        department_id: null,
        department_name: 'Hoàn tất',
        position_code: null,
        level: 999,
        status: 'approved',
        assigned_to: null,
        assigned_to_name: '',
    },
]

// ===== FAKE API =====
export async function getWorkflowTasks(params = {}) {
    const {
        department_id = null,
        position_code = null,
        level = null,
    } = params

    await sleep(300)

    let result = [...FAKE_WORKFLOW_TASKS]

    if (department_id !== null) {
        result = result.filter(t => t.department_id === department_id)
    }

    if (position_code !== null) {
        result = result.filter(t => t.position_code === position_code)
    }

    if (level !== null) {
        result = result.filter(t => t.level === level)
    }

    return {
        data: result,
    }
}


// ===== ACTIONS =====

// duyệt → sang level tiếp theo
export async function approveWorkflowTask(taskId) {
    await sleep(200)

    const task = FAKE_WORKFLOW_TASKS.find(t => t.id === taskId)
    if (!task) return

    // DONE
    if (task.level >= 4) {
        task.level = 999
        task.department_id = null
        task.position_code = null
        task.department_name = 'Hoàn tất'
        task.status = 'approved'
        return
    }

    // tăng level
    task.level += 1
    task.status = 'pending'

    // map level → role + department
    if (task.level === 3) {
        task.position_code = 'senior_manager'
    }

    if (task.level === 4) {
        task.position_code = 'executive'
        task.department_id = 6
        task.department_name = 'Ban giám đốc'
    }
}

// từ chối → giữ nguyên cột, đổi trạng thái
export async function rejectWorkflowTask(taskId) {
    await sleep(200)

    const task = FAKE_WORKFLOW_TASKS.find(t => t.id === taskId)
    if (!task) return

    task.status = 'rejected'
}

// trả về phòng → về level 2 (trưởng phòng)
export async function returnWorkflowTask(taskId) {
    await sleep(200)

    const task = FAKE_WORKFLOW_TASKS.find(t => t.id === taskId)
    if (!task) return

    task.level = 2
    task.position_code = 'manager'
    task.status = 'request_approval'
}


/**
 * ======================================================
 * WORKFLOW – BOARD
 * ======================================================
 */

/**
 * Lấy danh sách workflow để hiển thị board
 * params:
 *  - department_id
 *  - position_code
 *  - level
 */
// export const getWorkflowTasks = (params) =>
//     api.get('/workflow/board', { params })


/**
 * ======================================================
 * WORKFLOW – ACTIONS
 * ======================================================
 */

/**
 * Submit workflow mới (nhân viên trình giấy tờ)
 * data:
 *  - title
 *  - department_id
 *  - documents[]  (3 loại giấy tờ)
 *  - note
 */
export const submitWorkflow = (data) =>
    api.post('/workflow/submit', data)


/**
 * Duyệt workflow (approve)
 * payload:
 *  - comment (optional)
 */
export const approveWorkflow = (workflowId, data = {}) =>
    api.post(`/workflow/${workflowId}/approve`, data)


/**
 * Từ chối workflow
 * payload:
 *  - reason
 */
export const rejectWorkflow = (workflowId, data = {}) =>
    api.post(`/workflow/${workflowId}/reject`, data)


/**
 * Trả workflow về bước trước (trả về phòng)
 * payload:
 *  - reason
 */
export const returnWorkflowToPreviousStep = (workflowId, data = {}) =>
    api.post(`/workflow/${workflowId}/return`, data)


/**
 * ======================================================
 * WORKFLOW – LOGS & STATS
 * ======================================================
 */

/**
 * Lấy log xử lý của workflow
 */
export const getWorkflowLogs = (workflowId) =>
    api.get(`/workflow/${workflowId}/logs`)


/**
 * Thống kê workflow (dùng cho WorkflowStats.vue)
 */
export const getWorkflowStats = (params) =>
    api.get('/workflow/stats', { params })


/**
 * ======================================================
 * WORKFLOW – DETAIL
 * ======================================================
 */

/**
 * Lấy chi tiết 1 workflow (khi click card)
 */
export const getWorkflowDetail = (workflowId) =>
    api.get(`/workflow/${workflowId}`)
