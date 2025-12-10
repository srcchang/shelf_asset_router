// Click counter functionality
let clickCount = 0;

function handleClick() {
    clickCount++;
    const countElement = document.getElementById('click-count');
    if (countElement) {
        countElement.textContent = `Clicks: ${clickCount}`;

        // Add animation effect
        countElement.style.transform = 'scale(1.2)';
        setTimeout(() => {
            countElement.style.transform = 'scale(1)';
        }, 200);
    }
}

// Log page load
console.log('Shelf Asset Router - Page loaded successfully!');
console.log('Current URL:', window.location.href);

// Add smooth transition for count element
document.addEventListener('DOMContentLoaded', () => {
    const countElement = document.getElementById('click-count');
    if (countElement) {
        countElement.style.transition = 'transform 0.2s ease';
    }

    console.log('DOM fully loaded');
});
