const ANIMATION_DURATION = 650

export function flyImageToCart(imageUrl, sourceElement, targetSelector = '#cart-link') {
    if (!imageUrl || !sourceElement || window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        return
    }

    const targetElement = document.querySelector(targetSelector)
    if (!targetElement) return

    const sourceRect = sourceElement.getBoundingClientRect()
    const targetRect = targetElement.getBoundingClientRect()
    const flyingImage = document.createElement('img')

    flyingImage.src = imageUrl
    flyingImage.alt = ''
    flyingImage.setAttribute('aria-hidden', 'true')
    Object.assign(flyingImage.style, {
        position: 'fixed',
        left: `${sourceRect.left + sourceRect.width / 2}px`,
        top: `${sourceRect.top + sourceRect.height / 2}px`,
        width: '64px',
        height: '64px',
        objectFit: 'contain',
        padding: '6px',
        borderRadius: '12px',
        background: '#ffffff',
        boxShadow: '0 10px 24px rgba(0, 0, 0, 0.2)',
        pointerEvents: 'none',
        zIndex: '9999',
        transform: 'translate(-50%, -50%)',
    })

    document.body.appendChild(flyingImage)

    const animation = flyingImage.animate(
        [{
                left: `${sourceRect.left + sourceRect.width / 2}px`,
                top: `${sourceRect.top + sourceRect.height / 2}px`,
                transform: 'translate(-50%, -50%) scale(1)',
                opacity: 1,
            },
            {
                left: `${targetRect.left + targetRect.width / 2}px`,
                top: `${targetRect.top + targetRect.height / 2}px`,
                transform: 'translate(-50%, -50%) scale(0.2)',
                opacity: 0.8,
            },
        ], {
            duration: ANIMATION_DURATION,
            easing: 'cubic-bezier(0.2, 0.8, 0.2, 1)',
            fill: 'forwards',
        },
    )

    animation.onfinish = () => {
        flyingImage.remove()
        targetElement.animate(
            [
                { transform: 'scale(1)' },
                { transform: 'scale(1.18)' },
                { transform: 'scale(1)' },
            ], { duration: 280, easing: 'ease-out' },
        )
    }

    animation.oncancel = () => flyingImage.remove()
}