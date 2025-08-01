// stores/step.js
import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useStepStore = defineStore('step', () => {
    const selectedStep = ref(null)
    const relatedTasks = ref([]) // ← thêm để lưu danh sách task

    const setSelectedStep = (step) => {
        selectedStep.value = { ...(step || {}) } // clone để Vue reactivity hoạt động
    }

    const setRelatedTasks = (tasks) => {
        relatedTasks.value = [...(tasks || [])] // clone danh sách để reactive
    }

    return {
        selectedStep,
        relatedTasks,
        setSelectedStep,
        setRelatedTasks
    }
})
