// src/api/workflow.js

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
