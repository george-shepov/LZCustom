<template>
  <section class="testimonials section-padding">
    <div class="container">
      <div class="section-header">
        <h2 class="section-title">What Our Clients Say</h2>
        <p class="section-subtitle">Trusted by homeowners and businesses across Northeast Ohio</p>
      </div>

      <div class="testimonials-grid">
        <div 
          class="testimonial-card" 
          v-for="testimonial in testimonials" 
          :key="testimonial.id"
        >
          <div class="testimonial-content">
            <div class="quote-icon">
              <i class="fas fa-quote-left"></i>
            </div>
            <p class="testimonial-text">{{ testimonial.text }}</p>
            <div class="testimonial-author">
              <div class="author-info">
                <h4 class="author-name">{{ testimonial.name }}</h4>
                <p class="author-location">{{ testimonial.location }}</p>
                <p class="project-type">{{ testimonial.project }}</p>
              </div>
              <div class="rating">
                <i v-for="star in 5" :key="star" class="fas fa-star"></i>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="trust-badges">
        <div class="badge-item">
          <div class="badge-icon">
            <i class="fas fa-certificate"></i>
          </div>
          <div class="badge-text">
            <strong>Licensed & Insured</strong>
            <span>Ohio State License #12345</span>
          </div>
        </div>
        <div class="badge-item">
          <div class="badge-icon">
            <i class="fas fa-award"></i>
          </div>
          <div class="badge-text">
            <strong>BBB Accredited</strong>
            <span>A+ Rating Since 1995</span>
          </div>
        </div>
        <div class="badge-item">
          <div class="badge-icon">
            <i class="fas fa-handshake"></i>
          </div>
          <div class="badge-text">
            <strong>Satisfaction Guaranteed</strong>
            <span>100% Customer Satisfaction</span>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
const testimonials = [
  {
    id: 1,
    text: "LZ Custom transformed our kitchen with beautiful granite countertops and custom oak cabinets. The craftsmanship is exceptional and they completed everything on time and within budget.",
    name: "Sarah & Mike Johnson",
    location: "Westlake, OH",
    project: "Kitchen Renovation"
  },
  {
    id: 2,
    text: "We needed commercial-grade surfaces for our restaurant. LZ Custom delivered outstanding results with durable materials and professional installation. Highly recommended!",
    name: "Tony Martinez",
    location: "Cleveland, OH", 
    project: "Commercial Installation"
  },
  {
    id: 3,
    text: "From design to installation, the team was professional and detail-oriented. Our new marble bathroom vanity is absolutely stunning. Worth every penny!",
    name: "Jennifer Chen",
    location: "Akron, OH",
    project: "Bathroom Remodel"
  }
]
</script>

<style scoped>
.testimonials {
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

.section-padding {
  padding: 5rem 0;
}

.section-header {
  text-align: center;
  margin-bottom: 4rem;
}

.section-title {
  font-size: clamp(2.5rem, 5vw, 3.5rem);
  color: #1e293b;
  font-weight: 600;
  margin-bottom: 1rem;
  font-family: 'Playfair Display', serif;
}

.section-subtitle {
  font-size: 1.2rem;
  color: #64748b;
  max-width: 600px;
  margin: 0 auto;
}

.testimonials-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 2rem;
  margin-bottom: 4rem;
}

.testimonial-card {
  background: white;
  border-radius: 16px;
  padding: 2rem;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
  position: relative;
  transition: transform 0.3s ease;
}

.testimonial-card:hover {
  transform: translateY(-5px);
}

.quote-icon {
  color: #f39c12;
  font-size: 2rem;
  margin-bottom: 1rem;
}

.testimonial-text {
  font-size: 1.1rem;
  line-height: 1.6;
  color: #374151;
  margin-bottom: 1.5rem;
  font-style: italic;
}

.testimonial-author {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.author-name {
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 0.25rem;
}

.author-location {
  color: #64748b;
  font-size: 0.9rem;
  margin-bottom: 0.25rem;
}

.project-type {
  color: #f39c12;
  font-size: 0.9rem;
  font-weight: 500;
}

.rating {
  color: #f39c12;
}

.rating i {
  margin-left: 2px;
}

.trust-badges {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-top: 3rem;
}

.badge-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
}

.badge-icon {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.2rem;
}

.badge-text strong {
  display: block;
  color: #1e293b;
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.badge-text span {
  color: #64748b;
  font-size: 0.9rem;
}

@media (max-width: 768px) {
  .testimonials-grid {
    grid-template-columns: 1fr;
  }
  
  .testimonial-author {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .trust-badges {
    grid-template-columns: 1fr;
  }
}
</style>
