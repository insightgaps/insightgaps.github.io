/**
 * Insight Gaps UI Tools
 * Handles: Popups, Active Navigation States
 */

// 1. POPUP SYSTEM
function openPopup(imageSrc, captionText, targetUrl) {
    const popup = document.getElementById('imagePopup');
    if(!popup) return; // Guard clause
    
    document.getElementById('popupImg').src = imageSrc;
    document.getElementById('popupCaption').innerText = captionText;
    document.getElementById('popupLink').href = targetUrl;
    
    popup.classList.add('active');
    document.body.style.overflow = 'hidden'; // Prevent background scrolling
}

function closePopup() {
    const popup = document.getElementById('imagePopup');
    if(!popup) return;
    
    popup.classList.remove('active');
    document.body.style.overflow = '';
}

// Close on Escape Key
document.addEventListener('keydown', function(event) {
    if (event.key === "Escape") closePopup();
});


// 2. ACTIVE NAVIGATION HIGHLIGHTER
document.addEventListener('DOMContentLoaded', function() {
    const currentPath = window.location.pathname;
    
    // Find all nav links
    const navLinks = document.querySelectorAll('.nav-link, .mega-sidebar-link, .subnav-link');
    
    navLinks.forEach(link => {
        // Exact match or sub-directory match
        if (link.getAttribute('href') === currentPath || (currentPath.includes(link.getAttribute('href')) && link.getAttribute('href') !== '/')) {
            link.classList.add('active');
        }
    });
});
