function pad(value) {
    return String(value).padStart(2, '0');
}

function updateCountdown() {
    const container = document.getElementById('wedding-countdown');

    if (!container) {
        return;
    }

    const target = new Date(container.dataset.target);
    const now = new Date();
    const diff = Math.max(target.getTime() - now.getTime(), 0);

    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor((diff / (1000 * 60 * 60)) % 24);
    const minutes = Math.floor((diff / (1000 * 60)) % 60);
    const seconds = Math.floor((diff / 1000) % 60);

    const daysEl = container.querySelector('.countdown-days');
    const hoursEl = container.querySelector('.countdown-hours');
    const minutesEl = container.querySelector('.countdown-minutes');
    const secondsEl = container.querySelector('.countdown-seconds');

    if (daysEl) {
        daysEl.textContent = pad(days);
    }

    if (hoursEl) {
        hoursEl.textContent = pad(hours);
    }

    if (minutesEl) {
        minutesEl.textContent = pad(minutes);
    }

    if (secondsEl) {
        secondsEl.textContent = pad(seconds);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    updateCountdown();
    setInterval(updateCountdown, 1000);
});
