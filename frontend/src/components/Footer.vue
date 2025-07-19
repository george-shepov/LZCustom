<template>
  <footer class="footer">
    <div class="container">
      <div class="footer-content">
        <div class="footer-section company-info">
          <div class="logo">
            <h3>LZ Custom</h3>
            <p class="tagline">Fabrication Excellence Since 1990</p>
          </div>
          
          <p class="company-description">
            Northeast Ohio's premier custom fabrication company specializing in cabinets, countertops, 
            stone fabrication, and commercial services. Proudly serving the region for over 30 years.
          </p>
          
          <div class="certifications">
            <div class="cert-item">
              <i class="fas fa-certificate"></i>
              <span>Licensed & Insured</span>
            </div>
            <div class="cert-item">
              <i class="fas fa-award"></i>
              <span>BBB Accredited</span>
            </div>
          </div>
        </div>
        
        <div class="footer-section services-links">
          <h4>Our Services</h4>
          <ul>
            <li><a href="#services">Custom Cabinets</a></li>
            <li><a href="#services">Countertops</a></li>
            <li><a href="#services">Stone Fabrication</a></li>
            <li><a href="#services">Plastics & Laminate</a></li>
            <li><a href="#services">Tile & Flooring</a></li>
            <li><a href="#services">Commercial Painting</a></li>
          </ul>
        </div>
        
        <div class="footer-section contact-info">
          <h4>Contact Information</h4>
          
          <div class="contact-item">
            <i class="fas fa-phone"></i>
            <div>
              <strong>Phone</strong>
              <a href="tel:216-268-2990">216-268-2990</a>
            </div>
          </div>
          
          <div class="contact-item">
            <i class="fas fa-clock"></i>
            <div>
              <strong>Business Hours</strong>
              <span>Mon-Fri: 8AM-5PM</span>
              <span>Saturday: 9AM-3PM</span>
              <span>Sunday: Closed</span>
            </div>
          </div>
          
          <div class="contact-item">
            <i class="fas fa-map-marker-alt"></i>
            <div>
              <strong>Service Area</strong>
              <span>Cleveland, Akron, Canton</span>
              <span>Youngstown, Lorain, Ashtabula</span>
              <span>& Surrounding Areas</span>
            </div>
          </div>
        </div>
        
        <div class="footer-section cta-section">
          <h4>Ready to Start?</h4>
          <p>Get your free consultation and quote today!</p>
          
          <div class="cta-buttons">
            <button @click="scrollToForm" class="btn-primary">Get Quote</button>
            <a href="tel:216-268-2990" class="btn-secondary">Call Now</a>
          </div>
          
          <div class="social-links">
            <a @click="showFacebookInfo" class="social-link" aria-label="Facebook">
              <i class="fab fa-facebook-f"></i>
            </a>
            <a @click="showInstagramInfo" class="social-link" aria-label="Instagram">
              <i class="fab fa-instagram"></i>
            </a>
            <a @click="showLinkedInInfo" class="social-link" aria-label="LinkedIn">
              <i class="fab fa-linkedin-in"></i>
            </a>
          </div>
        </div>
      </div>
      
      <div class="footer-bottom">
        <div class="footer-bottom-content">
          <p>&copy; {{ currentYear }} LZ Custom Fabrication. All rights reserved.</p>
          <div class="footer-links">
            <a href="#privacy">Privacy Policy</a>
            <a href="#terms">Terms of Service</a>
            <a href="#sitemap">Sitemap</a>
          </div>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup>
import { computed } from 'vue'

const currentYear = computed(() => new Date().getFullYear())

const scrollToForm = () => {
  const el = document.querySelector('#quote-form')
  if (el) el.scrollIntoView({ behavior: 'smooth' })
}

const showFacebookInfo = () => {
  alert(`📘 Connect with LZ Custom on Facebook!

🏠 What you'll find:
• Before/after project photos
• Customer testimonials and reviews
• Behind-the-scenes workshop videos
• Design inspiration and trends
• Special promotions and updates

💡 Pro tip: Follow us to see our latest work and get design ideas for your own project!

📞 Ready to start your project? Call 216-268-2990 for a free consultation!`)
}

const showInstagramInfo = () => {
  alert(`📸 Follow LZ Custom on Instagram!

✨ What you'll see:
• Stunning project photography
• Time-lapse fabrication videos
• Material close-ups and textures
• Design process behind-the-scenes
• Customer feature stories

💡 Pro tip: Tag us in your project photos for a chance to be featured!

📞 Ready to create something beautiful? Call 216-268-2990!`)
}

const showLinkedInInfo = () => {
  alert(`💼 Connect with LZ Custom on LinkedIn!

🏢 Professional content:
• Industry insights and trends
• Company news and updates
• Team member spotlights
• Commercial project showcases
• Business partnership opportunities

💡 Perfect for contractors, designers, and commercial clients!

📞 Interested in partnering? Call 216-268-2990 to discuss opportunities!`)
}
</script>

<style scoped>
.footer {
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  position: relative;
}

.footer::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="footerPattern" width="30" height="30" patternUnits="userSpaceOnUse"><path d="M0 0h30v30H0z" fill="none"/><path d="M15 0v30M0 15h30" stroke="%23ffffff" stroke-width="0.3" opacity="0.1"/></pattern></defs><rect width="100" height="100" fill="url(%23footerPattern)"/></svg>');
  pointer-events: none;
}

.footer-content {
  position: relative;
  z-index: 2;
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr;
  gap: 3rem;
  padding: 4rem 0 2rem;
}

.footer-section h4 {
  color: #f39c12;
  margin-bottom: 1.5rem;
  font-size: 1.2rem;
  font-weight: 600;
}

.company-info .logo h3 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
  color: white;
}

.tagline {
  color: #bdc3c7;
  font-style: italic;
  margin-bottom: 1.5rem;
}

.company-description {
  color: #bdc3c7;
  line-height: 1.6;
  margin-bottom: 2rem;
}

.certifications {
  display: flex;
  gap: 1.5rem;
  flex-wrap: wrap;
}

.cert-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: rgba(255, 255, 255, 0.1);
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.9rem;
}

.cert-item i {
  color: #f39c12;
}

.services-links ul {
  list-style: none;
  padding: 0;
}

.services-links li {
  margin-bottom: 0.8rem;
}

.services-links a {
  color: #bdc3c7;
  text-decoration: none;
  transition: color 0.3s ease;
}

.services-links a:hover {
  color: #f39c12;
}

.contact-item {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.contact-item i {
  color: #f39c12;
  margin-top: 0.2rem;
  width: 20px;
  flex-shrink: 0;
}

.contact-item div {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
}

.contact-item strong {
  color: white;
  font-size: 0.9rem;
}

.contact-item span,
.contact-item a {
  color: #bdc3c7;
  text-decoration: none;
  font-size: 0.9rem;
}

.contact-item a:hover {
  color: #f39c12;
}

.cta-section p {
  color: #bdc3c7;
  margin-bottom: 1.5rem;
}

.cta-buttons {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 2rem;
}

.btn-primary,
.btn-secondary {
  padding: 0.8rem 1.5rem;
  border-radius: 6px;
  font-weight: 600;
  text-decoration: none;
  text-align: center;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
}

.btn-primary {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(243, 156, 18, 0.3);
}

.btn-secondary {
  background: transparent;
  color: white;
  border: 2px solid white;
}

.btn-secondary:hover {
  background: white;
  color: #2c3e50;
}

.social-links {
  display: flex;
  gap: 1rem;
}

.social-link {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #bdc3c7;
  text-decoration: none;
  transition: all 0.3s ease;
}

.social-link:hover {
  background: #f39c12;
  color: white;
  transform: translateY(-2px);
}

.footer-bottom {
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  padding: 2rem 0;
  position: relative;
  z-index: 2;
}

.footer-bottom-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #bdc3c7;
  font-size: 0.9rem;
}

.footer-links {
  display: flex;
  gap: 2rem;
}

.footer-links a {
  color: #bdc3c7;
  text-decoration: none;
  transition: color 0.3s ease;
}

.footer-links a:hover {
  color: #f39c12;
}

/* Mobile Responsiveness */
@media (max-width: 968px) {
  .footer-content {
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
  }
}

@media (max-width: 768px) {
  .footer-content {
    grid-template-columns: 1fr;
    gap: 2rem;
    padding: 3rem 0 2rem;
  }
  
  .footer-bottom-content {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }
  
  .footer-links {
    gap: 1rem;
  }
}

@media (max-width: 480px) {
  .certifications {
    flex-direction: column;
    gap: 0.8rem;
  }
  
  .cert-item {
    justify-content: center;
  }
  
  .social-links {
    justify-content: center;
  }
}
</style>
