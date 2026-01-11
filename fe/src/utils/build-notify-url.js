export function buildNotifyUrl(n) {
    console.log(n);
    switch (n.type) {

        case "bidding":
            return `/biddings/${n.bid_id}/steps/${n.step_id}/tasks/${n.task_id}/info`;

        case "contract":
            return `/contract/${n.contract_id}/steps/${n.step_id}/tasks/${n.task_id}/info`;

        case "workflow":
            return `/workflow/tasks/${n.task_id}/info`;

        case "non-workflow":
            return `/non-workflow/tasks/${n.task_id}/info`;

        default:
            return `/task-approvals`;
    }
}
