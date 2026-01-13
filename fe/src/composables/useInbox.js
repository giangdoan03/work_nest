import { ref, computed } from "vue";
import { useCommentNotifyStore } from "@/stores/commentNotify";
import { getMyRecentCommentsAPI, getMyUnreadCommentsCountAPI } from "@/api/task";
import { connectChatChannel, onIncomingComment } from "@/utils/notify-socket";
import { useUserStore } from "@/stores/user";

export function useInbox() {
    const userStore = useUserStore();
    const userId = computed(() => userStore.user?.id);

    const commentStore = useCommentNotifyStore();

    const inboxItems = ref([]);
    const inboxPage = ref(1);
    const inboxHasMore = ref(false);
    const inboxLoading = ref(false);
    const inboxOpen = ref(false);

    const newInboxItems = computed(() =>
        inboxItems.value.filter(i => +i.is_unread === 1)
    );

    const oldInboxItems = computed(() =>
        inboxItems.value.filter(i => +i.is_unread !== 1)
    );

    const moreUnread = computed(() => {
        const displayedUnread = newInboxItems.value.length;
        return Math.max(0, commentStore.unread - displayedUnread);
    });

    const fetchUnread = async () => {
        if (!userId.value) return;
        const { data } = await getMyUnreadCommentsCountAPI(userId.value);
        commentStore.unread = data.unread ?? 0;
    };

    const fetchInbox = async (page = 1) => {
        if (!userId.value) return;

        inboxLoading.value = true;
        try {
            const { data } = await getMyRecentCommentsAPI({
                user_id: userId.value,
                page,
                limit: 10
            });

            const list = data?.comments || [];

            inboxItems.value = page === 1 ? list : [...inboxItems.value, ...list];

            inboxHasMore.value = (data?.pagination?.currentPage || 1) < (data?.pagination?.totalPages || 1);
            inboxPage.value = page;

        } finally {
            inboxLoading.value = false;
        }
    };

    const refreshInbox = () => fetchInbox(1);
    const loadMoreInbox = () => fetchInbox(inboxPage.value + 1);

    const handleRealtime = () => {
        if (!userId.value) return;

        connectChatChannel(userId.value);

        onIncomingComment((payload) => {
            const sender = payload.user_id || payload.author_id;

            // Không tăng badge nếu chính mình gửi
            if (sender === userStore.user.id) return;

            commentStore.unread++;

            if (inboxOpen.value) refreshInbox();
        });
    };

    return {
        inboxItems,
        inboxOpen,
        inboxLoading,
        newInboxItems,
        oldInboxItems,
        moreUnread,
        fetchUnread,
        fetchInbox,
        refreshInbox,
        loadMoreInbox,
        handleRealtime
    };
}
