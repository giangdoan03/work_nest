// src/utils/breadcrumb-params.js

export const buildParamsMap = (p) => ({
    // Dashboard & chung
    'project-overview': () => ({}),
    'dashboard': () => ({}),

    // Users
    'persons-info': () => ({ id: p.id }),
    'user-detail': () => ({ id: p.id }),

    // Internal Tasks (workflow)
    'workflow': () => ({}),
    'workflow-task-info': () => ({ id: p.id }),
    'workflow-info': () => ({ id: p.id }),

    // Bidding
    'bid-list': () => ({}),
    'bid-detail': () => ({ id: p.id }),
    'biddings-info': () => ({ id: p.id }),
    'bidding-step-tasks': () => ({ bidId: p.bidId, stepId: p.stepId }),
    'bidding-task-info-in-step': () => ({ bidId: p.bidId, stepId: p.stepId, id: p.id }),
    'bidding-task-info': () => ({ id: p.id }),

    // Contract
    'contracts-tasks': () => ({}),
    'contract-detail': () => ({ id: p.id ?? p.contractId }),
    'contract-step-tasks': () => ({ contractId: p.contractId, stepId: p.stepId }),
    'contract-task-info-in-step': () => ({ contractId: p.contractId, stepId: p.stepId, id: p.id }),
    'contract-task-info': () => ({ id: p.id }),

    // Documents
    'documents': () => ({}),
    'documents-my': () => ({}),
    'documents-shared': () => ({}),
    'documents-department': () => ({}),
    'documents-permission': () => ({}),
    'documents-settings': () => ({}),
    'documents-info': () => ({ id: p.id }),
    'document.detail': () => ({ id: p.id }),

    // Settings
    'cau-hinh-dau-thau': () => ({}),
    'cau-hinh-hop-dong': () => ({}),

    // Customers
    'customers': () => ({}),
    'customer-detail': () => ({ id: p.id }),

    // My Tasks
    'my-tasks': () => ({}),
    'task-approvals': () => ({}),

    // Charts
    'GanttChart': () => ({}),

    // Steps detail
    'BiddingStepDetail': () => ({ id: p.id }),
    'ContractStepDetail': () => ({ id: p.id }),

    // Non-workflow
    'non-workflow': () => ({}),
    'tasks-detail': () => ({ id: p.id }),

    // Department task
    'department-task-detail': () => ({ id: p.id }),
});
