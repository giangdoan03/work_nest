import { canAccessEntity } from "@/api/entityMembers";
import { message } from "ant-design-vue";
import { useRouter } from "vue-router";
import { useUserStore } from "@/stores/user";

export function useEntityAccess() {
    const router = useRouter();
    const store = useUserStore();

    // TỰ ĐỘNG xác định param name theo route
    const ROUTE_PARAM = {
        bidding: "id",          // /biddings/:id
        contract: "id",         // /contracts/:id
        non_workflow: "id",     // /non-workflow/:id
    };

    const openEntity = async (entityType, entityId, routeName) => {
        const userId = store.currentUser?.id;
        if (!userId) {
            message.error("Không xác định người dùng hiện tại");
            return;
        }

        try {
            const res = await canAccessEntity({
                entity_type: entityType,
                entity_id: entityId,
                user_id: userId
            });

            if (!res.data?.access) {
                message.error("Bạn không có quyền truy cập mục này.");
                return;
            }

            const paramName = ROUTE_PARAM[entityType] || "id";

            await router.push({
                name: routeName,
                params: { [paramName]: entityId }
            });

        } catch (e) {
            console.error(e);
            message.error("Không thể kiểm tra quyền truy cập.");
        }
    };

    return { openEntity };
}
