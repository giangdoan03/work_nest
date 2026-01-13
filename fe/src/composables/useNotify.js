import { ref, computed } from "vue";
import { useNotifyStore } from "@/stores/notifyStore";
import { getNotificationAPI, markNotificationReadAPI } from "@/api/notifications";
import { connectNotifyChannel, onNotifyEvent } from "@/utils/notify-socket";
import { useUserStore } from "@/stores/user";
import { useRouter } from "vue-router";

export function useNotify() {
    const notifyStore = useNotifyStore();
    const userStore = useUserStore();
    const router = useRouter();  // <<< FIX QUAN TRỌNG

    const notifyOpen = ref(false);
    const notifyPage = ref(1);
    const notifyHasMore = ref(false);
    const notifyLoading = ref(false);

    const newNotifyItems = computed(() =>
        notifyStore.items.filter(i => i.is_unread)
    );

    const oldNotifyItems = computed(() =>
        notifyStore.items.filter(i => !i.is_unread)
    );

    const moreNotifyUnread = computed(() =>
        Math.max(0, notifyStore.unread - newNotifyItems.value.length)
    );

    const fetchNotify = async (page = 1) => {
        notifyLoading.value = true;

        const { data } = await getNotificationAPI(userStore.user.id, page);
        const list = (data?.data || []).map(n => ({
            ...n,
            is_unread: !!Number(n.is_unread)
        }));

        if (page === 1) {
            notifyStore.setList(list);
        } else {
            notifyStore.items = [...notifyStore.items, ...list];
        }

        notifyStore.unread = notifyStore.items.filter(i => i.is_unread).length;
        notifyPage.value = page;
        notifyHasMore.value = data?.pager?.hasMore || false;

        notifyLoading.value = false;
    };

    const handleRealtimeNotify = () => {
        connectNotifyChannel(userStore.user.id);

        onNotifyEvent((data) => {
            notifyStore.addRealtime(data);
        });
    };

    const openApproval = async (item) => {
        notifyOpen.value = false;

        if (item.is_unread) {
            try {
                await markNotificationReadAPI(item.id);
                notifyStore.markRead(item.id);
            } catch (err) {
                console.error("❌ markRead failed:", err);
            }
        }

        const url = item.url || "/task-approvals";

        try {
            await router.push(url);
        } catch (err) {
            console.error("❌ router.push error:", err);
        }
    };

    return {
        notifyOpen,
        notifyLoading,
        newNotifyItems,
        oldNotifyItems,
        moreNotifyUnread,
        fetchNotify,
        handleRealtimeNotify,
        openApproval,
    };
}