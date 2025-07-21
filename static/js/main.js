// LZ Custom - Main JavaScript for Azure App Service

// Smooth scrolling
function scrollToSection(sectionId) {
    document.getElementById(sectionId).scrollIntoView({
        behavior: 'smooth'
    });
}

// Form submission
document.getElementById('quoteForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    const data = Object.fromEntries(formData.entries());
    
    try {
        const response = await fetch('/api/prospects', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });
        
        const result = await response.json();
        
        if (response.ok) {
            alert('Thank you! Your quote request has been submitted successfully. We\'ll contact you soon!');
            this.reset();
        } else {
            alert('Thank you for your interest! Please call us at 216-268-2990 to ensure we received your request.');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Thank you for your interest! Please call us at 216-268-2990 to discuss your project.');
    }
});

// Chat functionality
let chatOpen = false;

function toggleChat() {
    const chatWindow = document.getElementById('chatWindow');
    chatOpen = !chatOpen;
    
    if (chatOpen) {
        chatWindow.style.display = 'flex';
        document.getElementById('chatInput').focus();
    } else {
        chatWindow.style.display = 'none';
    }
}

async function sendMessage() {
    const input = document.getElementById('chatInput');
    const message = input.value.trim();
    
    if (!message) return;
    
    // Add user message to chat
    addMessageToChat(message, 'user');
    input.value = '';
    
    try {
        const response = await fetch('/api/chat', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ message: message })
        });
        
        const result = await response.json();
        
        // Add bot response to chat
        addMessageToChat(result.response, 'bot');
    } catch (error) {
        console.error('Error:', error);
        addMessageToChat('Sorry, I\'m having trouble right now. Please call us at 216-268-2990 for immediate assistance!', 'bot');
    }
}

function addMessageToChat(message, sender) {
    const messagesContainer = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${sender}-message`;
    messageDiv.innerHTML = `<p>${message}</p>`;
    
    messagesContainer.appendChild(messageDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Enter key support for chat
document.getElementById('chatInput').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        sendMessage();
    }
});

// Mobile menu toggle (if needed)
function toggleMobileMenu() {
    const navLinks = document.querySelector('.nav-links');
    navLinks.classList.toggle('active');
}

// Intersection Observer for animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('animate-in');
        }
    });
}, observerOptions);

// Observe elements for animation
document.addEventListener('DOMContentLoaded', function() {
    const animateElements = document.querySelectorAll('.service-card, .gallery-item, .stat-card');
    animateElements.forEach(el => observer.observe(el));
});

// Navbar scroll effect
window.addEventListener('scroll', function() {
    const header = document.querySelector('.header');
    if (window.scrollY > 100) {
        header.classList.add('scrolled');
    } else {
        header.classList.remove('scrolled');
    }
});

// Gallery image modal (simple version)
function openImageModal(src, alt) {
    const modal = document.createElement('div');
    modal.className = 'image-modal';
    modal.innerHTML = `
        <div class="image-modal-content">
            <img src="${src}" alt="${alt}">
            <button class="close-modal" onclick="this.parentElement.parentElement.remove()">×</button>
        </div>
    `;
    document.body.appendChild(modal);
    
    modal.addEventListener('click', function(e) {
        if (e.target === modal) {
            modal.remove();
        }
    });
}

// Add click handlers to gallery items
document.addEventListener('DOMContentLoaded', function() {
    const galleryItems = document.querySelectorAll('.gallery-item img');
    galleryItems.forEach(img => {
        img.addEventListener('click', function() {
            openImageModal(this.src, this.alt);
        });
    });
});

// Form validation helpers
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

function validatePhone(phone) {
    const re = /^[\+]?[1-9][\d]{0,15}$/;
    return re.test(phone.replace(/\D/g, ''));
}

// Enhanced form validation
document.getElementById('quoteForm').addEventListener('input', function(e) {
    const field = e.target;
    
    // Remove previous validation classes
    field.classList.remove('valid', 'invalid');
    
    // Validate based on field type
    if (field.type === 'email' && field.value) {
        if (validateEmail(field.value)) {
            field.classList.add('valid');
        } else {
            field.classList.add('invalid');
        }
    }
    
    if (field.type === 'tel' && field.value) {
        if (validatePhone(field.value)) {
            field.classList.add('valid');
        } else {
            field.classList.add('invalid');
        }
    }
});

// Auto-format phone number
document.querySelector('input[name="phone"]').addEventListener('input', function(e) {
    let value = e.target.value.replace(/\D/g, '');
    
    if (value.length >= 6) {
        value = value.replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
    } else if (value.length >= 3) {
        value = value.replace(/(\d{3})(\d{3})/, '($1) $2');
    }
    
    e.target.value = value;
});

// Service worker registration (for PWA capabilities)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
        navigator.serviceWorker.register('/static/sw.js')
            .then(function(registration) {
                console.log('ServiceWorker registration successful');
            })
            .catch(function(err) {
                console.log('ServiceWorker registration failed');
            });
    });
}

// Analytics tracking (simple)
function trackEvent(eventName, properties = {}) {
    console.log('Event:', eventName, properties);
    // Could integrate with Azure Application Insights here
}
