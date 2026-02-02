// ========================================
// GLOBAL VARIABLES
// ========================================

let currentMode = 'circular';
let isVisible = false;
let currentStyle = 'style-modern';
let currentSize = 'size-medium';
let currentPosition = 'pos-bottom-right';

// ========================================
// STYLE MANAGEMENT
// ========================================

function changeStyle(style, size, position) {
    const display = document.querySelector('.xp-display');
    if (!display) return;
    
    // Remove old classes
    display.className = 'xp-display';
    
    // Add new classes
    currentStyle = style;
    currentSize = 'size-' + (size || 'medium');
    currentPosition = 'pos-' + (position || 'bottom-right');
    
    display.classList.add(currentStyle);
    display.classList.add(currentSize);
    display.classList.add(currentPosition);
    
    // Show briefly if hidden
    if (!isVisible) {
        display.style.opacity = '1';
        setTimeout(() => {
            if (!isVisible) display.style.opacity = '0';
        }, 3000);
    }
}

// ========================================
// UTILITY FUNCTIONS
// ========================================

function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function updateCircularProgress(percentage) {
    const circle = document.querySelector('.progress-circle');
    const radius = circle.r.baseVal.value;
    const circumference = radius * 2 * Math.PI;
    const offset = circumference - (percentage / 100) * circumference;
    
    circle.style.strokeDashoffset = offset;
}

function updateRectangularProgress(percentage) {
    const progressBar = document.getElementById('rect-progress-bar');
    progressBar.style.width = percentage + '%';
}

// ========================================
// UI UPDATE FUNCTIONS
// ========================================

function updateXPDisplay(data) {
    const { level, currentXP, requiredXP, progress, totalXP } = data;
    
    // Update circular mode
    document.getElementById('circular-level').textContent = level;
    document.getElementById('circular-current-xp').textContent = formatNumber(currentXP);
    document.getElementById('circular-required-xp').textContent = formatNumber(requiredXP);
    document.getElementById('circular-percentage').textContent = progress.toFixed(1) + '%';
    updateCircularProgress(progress);
    
    // Update rectangular mode
    document.getElementById('rect-level').textContent = level;
    document.getElementById('rect-current-xp').textContent = formatNumber(currentXP);
    document.getElementById('rect-required-xp').textContent = formatNumber(requiredXP);
    document.getElementById('rect-percentage').textContent = progress.toFixed(1) + '%';
    updateRectangularProgress(progress);
}

function showLevelUp(data) {
    const { level, levelsGained } = data;
    const animation = document.getElementById('levelup-animation');
    const levelElement = document.getElementById('levelup-level');
    
    levelElement.textContent = level;
    animation.classList.add('active');
    
    // Hide after 3 seconds
    setTimeout(() => {
        animation.classList.remove('active');
    }, 3000);
}

let statsCountdownInterval = null;

function showStats(message) {
    const popup = document.getElementById('stats-popup');
    const messageElement = document.getElementById('stats-message');
    const countdownElement = document.getElementById('stats-countdown');
    
    messageElement.innerHTML = message;
    popup.classList.remove('closing');
    popup.classList.add('active');
    
    // Clear any existing countdown
    if (statsCountdownInterval) {
        clearInterval(statsCountdownInterval);
    }
    
    // Countdown timer
    let timeLeft = 10;
    countdownElement.textContent = `(schließt in ${timeLeft}s)`;
    
    statsCountdownInterval = setInterval(() => {
        timeLeft--;
        if (timeLeft > 0) {
            countdownElement.textContent = `(schließt in ${timeLeft}s)`;
        } else {
            clearInterval(statsCountdownInterval);
            countdownElement.textContent = '';
        }
    }, 1000);
    
    // Auto-close after 10 seconds with fade-out
    setTimeout(() => {
        clearInterval(statsCountdownInterval);
        popup.classList.add('closing');
        setTimeout(() => {
            popup.classList.remove('active');
            popup.classList.remove('closing');
        }, 500); // Wait for fade-out animation
    }, 10000);
}

function closeStats() {
    const popup = document.getElementById('stats-popup');
    const countdownElement = document.getElementById('stats-countdown');
    
    if (statsCountdownInterval) {
        clearInterval(statsCountdownInterval);
    }
    
    countdownElement.textContent = '';
    popup.classList.add('closing');
    setTimeout(() => {
        popup.classList.remove('active');
        popup.classList.remove('closing');
    }, 500);
}

function closeStatsPopup() {
    closeStats();
}

// ========================================
// VISIBILITY MANAGEMENT
// ========================================

function showUI(mode, position) {
    const circularMode = document.getElementById('xp-circular');
    const rectangularMode = document.getElementById('xp-rectangular');
    
    // Hide both first
    circularMode.classList.remove('active');
    rectangularMode.classList.remove('active');
    
    // Set mode
    currentMode = mode || 'circular';
    
    // Show correct mode
    if (currentMode === 'circular') {
        circularMode.classList.add('active');
    } else {
        rectangularMode.classList.add('active');
    }
    
    // Set position if provided
    if (position) {
        const container = currentMode === 'circular' ? circularMode : rectangularMode;
        container.style.left = position.x + '%';
        container.style.top = position.y + '%';
        container.style.transform = 'translate(-50%, -50%)';
    }
    
    isVisible = true;
}

function hideUI() {
    const circularMode = document.getElementById('xp-circular');
    const rectangularMode = document.getElementById('xp-rectangular');
    
    circularMode.classList.remove('active');
    rectangularMode.classList.remove('active');
    
    isVisible = false;
}

// ========================================
// MESSAGE LISTENER
// ========================================

window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch (data.action) {
        case 'show':
            showUI(data.mode, data.position);
            break;
            
        case 'hide':
            hideUI();
            break;
            
        case 'updateXP':
            updateXPDisplay(data.data);
            break;
            
        case 'levelUp':
            showLevelUp(data.data);
            break;
            
        case 'showStats':
            showStats(data.data.message);
            break;
            
        case 'closeStats':
            closeStatsPopup();
            break;
            
        case 'changeStyle':
            changeStyle(data.style, data.size, data.position);
            break;
    }
});

// ========================================
// GRADIENT DEFINITION (for circular progress)
// ========================================

// Create SVG gradient dynamically
document.addEventListener('DOMContentLoaded', function() {
    const svg = document.querySelector('.circular-progress');
    const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
    const gradient = document.createElementNS('http://www.w3.org/2000/svg', 'linearGradient');
    
    gradient.setAttribute('id', 'gradient');
    gradient.setAttribute('x1', '0%');
    gradient.setAttribute('y1', '0%');
    gradient.setAttribute('x2', '100%');
    gradient.setAttribute('y2', '100%');
    
    const stop1 = document.createElementNS('http://www.w3.org/2000/svg', 'stop');
    stop1.setAttribute('offset', '0%');
    stop1.setAttribute('style', 'stop-color:#667eea;stop-opacity:1');
    
    const stop2 = document.createElementNS('http://www.w3.org/2000/svg', 'stop');
    stop2.setAttribute('offset', '100%');
    stop2.setAttribute('style', 'stop-color:#764ba2;stop-opacity:1');
    
    gradient.appendChild(stop1);
    gradient.appendChild(stop2);
    defs.appendChild(gradient);
    svg.insertBefore(defs, svg.firstChild);
});

// ========================================
// HELPER FOR GETTING RESOURCE NAME
// ========================================

function GetParentResourceName() {
    const url = window.location.href;
    const match = url.match(/https?:\/\/([\w-]+)\//);
    return match ? match[1] : 'qb-xpsystem';
}

// ========================================
// ESCAPE KEY TO CLOSE STATS
// ========================================

document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        const statsPopup = document.getElementById('stats-popup');
        if (statsPopup.classList.contains('active')) {
            closeStats();
        }
    }
});

console.log('[XP System] UI initialized successfully');
