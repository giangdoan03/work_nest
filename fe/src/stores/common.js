import {defineStore} from 'pinia';
import {getBiddingStepsAPI} from "@/api/bidding.js";

export const useCommonStore = defineStore('common', {
    state: () => ({
        contractStep: [],
        biddingStep: [],
        linkedType: null,
        linkedIdParent: null,
        biddingIdParent: null,
        createTaskSignal: 0,
        createTaskType: 'internal',
        parentTaskId: null
    }),
    getters: {
        getContractStep: state => state.contractStep,
        getBiddingStep: state => state.biddingStep,
        getLinkedType: state => state.linkedType
    },
    actions: {
        async init() {
            await this.setContractStep()
        },
        async setContractStep() {
            try {
                this.contractStep = await getBiddingStepsAPI()
            } catch (error) {
                console.log(error)
            }
        },
        setBiddingStep(steps) {
            this.biddingStep = steps
        },
        setLinkedType(type) {
            this.linkedType = type
        },
        setLinkedIdParent(id) {
            this.linkedIdParent = id
        },
        setBiddingIdParent(id) {     // <— ✅ action setter
            this.biddingIdParent = id
        },
        setParentTaskId(id)   { this.parentTaskId = id ? Number(id) : null },
        triggerCreateTask(type = 'internal') {
            this.createTaskType = type
            this.createTaskSignal++ // tăng để trigger watcher
        }
    }
})
