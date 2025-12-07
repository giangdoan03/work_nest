<template>
    <component :is="componentMap[module]" />
</template>

<script setup>
import GuideBidding from "./GuideBidding.vue"
import GuideWorkflow from "./GuideWorkflow.vue"
import GuideDocuments from "./GuideDocuments.vue"
import GuideOverview from "./GuideOverview.vue"
import GuideCustomers from "./GuideCustomers.vue"
import GuideDepartments from "./GuideDepartments.vue"
import GuideSettings from "./GuideSettings.vue"

const props = defineProps({
    module: {
        type: String,
        required: true
    }
})

const componentMap = {
    bidding: GuideBidding,
    workflow: GuideWorkflow,
    documents: GuideDocuments,
    overview: GuideOverview,
    customers: GuideCustomers,
    departments: GuideDepartments,
    settings: GuideSettings
}
</script>
