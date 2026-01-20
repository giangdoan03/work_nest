import { ref, onMounted, onBeforeUnmount } from 'vue'

export function useHorizontalScroll(options = {}) {
    const {
        snap = true,
        snapWidth = 312, // 300 + gap 12
        autoScrollEdge = 80,
        autoScrollSpeed = 18,
    } = options

    const containerRef = ref(null)

    let isDragging = false
    let startX = 0
    let startScrollLeft = 0
    let autoScrollRAF = null

    /* ================= WHEEL ================= */
    const onWheel = (e) => {
        const el = containerRef.value
        if (!el) return

        let horizontalDelta = 0

        // Trackpad (scroll ngang thật)
        if (Math.abs(e.deltaX) > Math.abs(e.deltaY)) {
            horizontalDelta = e.deltaX
        } else {
            // Mouse wheel (map Y → X có chủ đích)
            e.preventDefault()
            horizontalDelta = e.deltaY
        }

        el.scrollLeft += horizontalDelta
    }



    /* ================= DRAG ================= */
    const startDrag = (e) => {
        if (e.target !== containerRef.value) return

        isDragging = true
        startX = getX(e)
        startScrollLeft = containerRef.value.scrollLeft
        containerRef.value.classList.add('dragging')
    }

    const onDrag = (e) => {
        if (!isDragging) return

        const x = getX(e)
        const dx = x - startX
        containerRef.value.scrollLeft = startScrollLeft - dx

        handleAutoScroll(e)
    }

    const stopDrag = () => {
        if (!isDragging) return
        isDragging = false
        containerRef.value.classList.remove('dragging')

        cancelAutoScroll()
        if (snap) snapToColumn()
    }

    /* ================= AUTO SCROLL ================= */
    const handleAutoScroll = (e) => {
        const rect = containerRef.value.getBoundingClientRect()
        const x = getX(e)

        if (x < rect.left + autoScrollEdge) {
            startAutoScroll(-autoScrollSpeed)
        } else if (x > rect.right - autoScrollEdge) {
            startAutoScroll(autoScrollSpeed)
        } else {
            cancelAutoScroll()
        }
    }

    const startAutoScroll = (speed) => {
        if (autoScrollRAF) return

        const loop = () => {
            containerRef.value.scrollLeft += speed
            autoScrollRAF = requestAnimationFrame(loop)
        }
        loop()
    }

    const cancelAutoScroll = () => {
        if (autoScrollRAF) {
            cancelAnimationFrame(autoScrollRAF)
            autoScrollRAF = null
        }
    }

    /* ================= SNAP ================= */
    const snapToColumn = () => {
        const el = containerRef.value
        const target =
            Math.round(el.scrollLeft / snapWidth) * snapWidth

        el.scrollTo({
            left: target,
            behavior: 'smooth',
        })
    }

    /* ================= UTILS ================= */
    const getX = (e) => (e.touches ? e.touches[0].pageX : e.pageX)

    /* ================= LIFECYCLE ================= */
    onMounted(() => {
        const el = containerRef.value
        el.addEventListener('wheel', onWheel, { passive: false })
    })

    onBeforeUnmount(() => {
        cancelAutoScroll()
    })

    return {
        containerRef,
        startDrag,
        onDrag,
        stopDrag,
    }
}
