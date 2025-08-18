import {defineStore} from 'pinia';
import {getBiddingStepsAPI} from "@/api/bidding.js";

export const useCommonStore = defineStore('common', {
    state: () => ({
        contractStep: [],
        biddingStep: [],
        linkedType: null,
        linkedIdParent: null
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
        }
    }
})
