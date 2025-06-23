import { defineStore } from 'pinia'
import { getBiddingStepsAPI } from '@/api/bidding';
import { onMounted } from 'vue';
import { init } from 'echarts';

export const useCommonStore = defineStore('common', {
    state: () => ({
        contractStep: [],
        biddingStep: [],
    }),
    getters: {
        getContractStep: state => state.contractStep,
        getBiddingStep: state => state.biddingStep,
    },
    actions: {
        init() {
            console.log(415135);
            
            setContractStep()
        },
        setContractStep() {
            try {
                
                let respon = getBiddingStepsAPI()
                console.log(444,respon);
                this.contractStep= respon;
            } catch (error) {
                console.log(error);
            }
        },
        setBiddingStep(steps) {
            this.biddingStep= steps;
        }
    }
})
