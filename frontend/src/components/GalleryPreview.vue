<template>
  <section id="gallery-preview" class="gallery-preview section-padding">
    <div class="container">
      <div class="section-header">
        <h2 class="section-title">Our Work Speaks for Itself</h2>
        <p class="section-subtitle">Browse our portfolio of custom fabrication and installation projects</p>
      </div>
      
      <!-- Materials & Samples Section -->
      <div class="materials-section">
        <h3 class="materials-title">Premium Materials & Samples</h3>
        <div class="materials-grid">
          <div class="material-card" @click="openMaterialLightbox('granite')">
            <img src="/assets/gallery/projects/granite-samples.jpg" alt="Granite Samples" />
            <div class="material-info">
              <h4>Granite Varieties</h4>
              <p>Natural stone with unique patterns, exceptional durability, and timeless beauty</p>
            </div>
          </div>
          <div class="material-card" @click="openMaterialLightbox('wood')">
            <img src="/assets/gallery/projects/wood-samples.jpg" alt="Wood Species" />
            <div class="material-info">
              <h4>Wood Species</h4>
              <p>Premium hardwoods including oak, maple, cherry, and walnut for custom cabinetry</p>
            </div>
          </div>
          <div class="material-card" @click="openMaterialLightbox('engineered')">
            <img src="/assets/gallery/projects/engineered-stone.jpg" alt="Engineered Stone" />
            <div class="material-info">
              <h4>Engineered Quartz</h4>
              <p>Consistent patterns, non-porous surfaces, and superior stain resistance</p>
            </div>
          </div>
        </div>
      </div>
      
      <div class="gallery-grid">
        <div
          class="gallery-item"
          v-for="(item, index) in galleryItems"
          :key="index"
          @click="openLightbox(index)"
          :class="{ 'featured': item.featured }"
          :aria-label="`View ${item.title} - ${item.category} project details`"
          role="button"
          tabindex="0"
          @keydown.enter="openLightbox(index)"
          @keydown.space="openLightbox(index)"
        >
          <div class="image-container">
            <img :src="item.image" :alt="item.title" loading="lazy" />
            <div class="image-overlay">
              <div class="overlay-content">
                <h4>{{ item.title }}</h4>
                <p>{{ item.category }}</p>
                <div class="view-icon">
                  <i class="fas fa-search-plus"></i>
                </div>
              </div>
            </div>
          </div>
          <div class="item-info">
            <span class="category-tag">{{ item.category }}</span>
            <h4>{{ item.title }}</h4>
          </div>
        </div>
      </div>
      
      <div class="gallery-cta">
        <button @click="openCarousel(0)" class="btn-primary">View Full Portfolio</button>
        <button @click="scrollToForm" class="btn-secondary">Request Quote</button>
      </div>
    </div>
    
    <!-- Full-Screen Carousel -->
    <div v-if="carouselOpen" class="carousel-overlay" @click="closeCarousel">
      <div class="carousel-container" @click.stop>
        <button class="carousel-close" @click="closeCarousel">
          <i class="fas fa-times"></i>
        </button>
        
        <div class="carousel-main">
          <button class="carousel-nav prev" @click="previousCarouselImage" v-if="allGalleryImages.length > 1">
            <i class="fas fa-chevron-left"></i>
          </button>
          
          <div class="carousel-image-container">
            <img :src="allGalleryImages[currentCarouselIndex].src" :alt="allGalleryImages[currentCarouselIndex].title" />
            <div class="carousel-info">
              <h3>{{ allGalleryImages[currentCarouselIndex].title }}</h3>
              <p class="carousel-category">{{ allGalleryImages[currentCarouselIndex].category }}</p>
            </div>
          </div>
          
          <button class="carousel-nav next" @click="nextCarouselImage" v-if="allGalleryImages.length > 1">
            <i class="fas fa-chevron-right"></i>
          </button>
        </div>
        
        <div class="carousel-thumbnails">
          <div class="thumbnails-container">
            <div 
              v-for="(image, index) in allGalleryImages" 
              :key="index"
              class="thumbnail"
              :class="{ 'active': index === currentCarouselIndex }"
              @click="goToCarouselImage(index)"
            >
              <img :src="image.src" :alt="image.title" />
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Original Lightbox Modal -->
    <div v-if="lightboxOpen" class="lightbox-overlay" @click="closeLightbox">
      <div class="lightbox-container" @click.stop>
        <button class="lightbox-close" @click="closeLightbox">
          <i class="fas fa-times"></i>
        </button>
        
        <div class="lightbox-content">
          <img :src="galleryItems[currentImageIndex].image" :alt="galleryItems[currentImageIndex].title" />
          
          <div class="lightbox-info">
            <h3>{{ galleryItems[currentImageIndex].title }}</h3>
            <p class="lightbox-category">{{ galleryItems[currentImageIndex].category }}</p>
            <p class="lightbox-description">{{ galleryItems[currentImageIndex].description }}</p>
          </div>
        </div>
        
        <button class="lightbox-nav prev" @click="previousImage" v-if="galleryItems.length > 1">
          <i class="fas fa-chevron-left"></i>
        </button>
        <button class="lightbox-nav next" @click="nextImage" v-if="galleryItems.length > 1">
          <i class="fas fa-chevron-right"></i>
        </button>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const lightboxOpen = ref(false)
const currentImageIndex = ref(0)
const carouselOpen = ref(false)
const currentCarouselIndex = ref(0)

// Complete gallery with high-resolution images
const allGalleryImages = [
  // Hero Images (4 high-res images)
  { src: '/assets/gallery/hero/hero-main-hd.png', title: 'Stone Fabrication Workshop', category: 'Workshop', type: 'hero' },
  { src: '/assets/gallery/hero/hero-showroom-hd.png', title: 'Kitchen Showroom Display', category: 'Showroom', type: 'hero' },
  { src: '/assets/gallery/hero/hero-kitchen-hd.png', title: 'Luxury Kitchen Installation', category: 'Kitchen', type: 'hero' },
  { src: '/assets/gallery/hero/hero-workshop-hd.png', title: 'Professional Workshop', category: 'Workshop', type: 'hero' },

  // Project Gallery (high-resolution project images)
  { src: '/assets/gallery/projects/kitchen-granite-hd.png', title: 'Modern Kitchen with Granite Countertops', category: 'Countertops', type: 'project' },
  { src: '/assets/gallery/projects/custom-cabinets-hd.png', title: 'Custom Oak Kitchen Cabinets', category: 'Cabinets', type: 'project' },
  { src: '/assets/gallery/projects/bathroom-marble-hd.png', title: 'Luxury Marble Bathroom', category: 'Stone Fabrication', type: 'project' },
  { src: '/assets/gallery/u6358423361_Modern_commercial_office_space_with_durable_lamin_6e25e604-46fe-49e7-816f-423717499296_0.png', title: 'Commercial Laminate Installation', category: 'Plastics & Laminate', type: 'project' },
  { src: '/assets/gallery/u6358423361_Intricate_geometric_tile_pattern_flooring_expert__bec8e5ac-8a9c-4831-8c48-d865023de519_0.png', title: 'Custom Tile Pattern Flooring', category: 'Tile & Flooring', type: 'project' },
  { src: '/assets/gallery/u6358423361_Professional_commercial_interior_painting_premium_fe294b7e-0227-404b-bed4-28fc32e6bb35_0.png', title: 'Commercial Interior Painting', category: 'Commercial Painting', type: 'project' },
  { src: '/assets/gallery/u6358423361_Collection_of_granite_slab_samples_natural_stone__668014ef-391a-49d5-90e0-b50532401f32_2.png', title: 'Premium Granite Selection', category: 'Materials', type: 'material' },
  { src: '/assets/gallery/u6358423361_Various_wood_species_samples_for_custom_cabinets__0ccfe8f4-934d-4f62-bf68-c4208c673a0e_0.png', title: 'Wood Species Showcase', category: 'Materials', type: 'material' },
  { src: '/assets/gallery/u6358423361_Modern_engineered_quartz_surfaces_consistent_patt_9bad55a7-8119-4466-b1b1-09e31a28fd21_2.png', title: 'Engineered Quartz Surfaces', category: 'Materials', type: 'material' },
  
  // Service Icons (6 images)
  { src: '/assets/icons/services/cabinets.jpg', title: 'Custom Cabinet Services', category: 'Services', type: 'service' },
  { src: '/assets/icons/services/countertops.jpg', title: 'Countertop Installation', category: 'Services', type: 'service' },
  { src: '/assets/icons/services/stone-fabrication.jpg', title: 'Stone Fabrication', category: 'Services', type: 'service' },
  { src: '/assets/icons/services/plastics-laminate.jpg', title: 'Laminate Solutions', category: 'Services', type: 'service' },
  { src: '/assets/icons/services/tile-flooring.jpg', title: 'Tile & Flooring', category: 'Services', type: 'service' },
  { src: '/assets/icons/services/commercial-painting.jpg', title: 'Commercial Painting', category: 'Services', type: 'service' },
  
  // Workshop Images (3 images)
  { src: '/assets/workshop/fabrication-workshop.jpg', title: 'Precision Fabrication Process', category: 'Workshop', type: 'workshop' },
  { src: '/assets/workshop/precision-measurement.jpg', title: 'Expert Measurement Techniques', category: 'Workshop', type: 'workshop' },
  { src: '/assets/workshop/installation-process.jpg', title: 'Professional Installation', category: 'Workshop', type: 'workshop' },
  
  // Textures (2 images)
  { src: '/assets/textures/wood-steel-texture.jpg', title: 'Wood & Steel Textures', category: 'Materials', type: 'texture' },
  { src: '/assets/textures/geometric-pattern.jpg', title: 'Geometric Design Elements', category: 'Design', type: 'texture' }
]

// Featured gallery items for main grid (high-resolution images)
const galleryItems = [
  {
    image: '/assets/gallery/projects/kitchen-granite-hd.png',
    title: 'Custom Kitchen Countertops',
    category: 'Granite & Stone',
    featured: true
  },
  {
    image: '/assets/gallery/projects/custom-cabinets-hd.png',
    title: 'Handcrafted Oak Cabinets',
    category: 'Custom Cabinets',
    featured: true
  },
  {
    image: '/assets/gallery/projects/bathroom-marble-hd.png',
    title: 'Marble Bathroom Vanity',
    category: 'Stone Fabrication',
    featured: false
  },
  {
    image: '/assets/gallery/u6358423361_Modern_commercial_office_space_with_durable_lamin_6e25e604-46fe-49e7-816f-423717499296_0.png',
    title: 'Commercial Laminate Installation',
    category: 'Commercial Projects',
    featured: false
  },
  {
    image: '/assets/gallery/u6358423361_Intricate_geometric_tile_pattern_flooring_expert__bec8e5ac-8a9c-4831-8c48-d865023de519_0.png',
    title: 'Geometric Tile Flooring',
    category: 'Tile & Flooring',
    featured: false
  },
  {
    image: '/assets/gallery/u6358423361_Professional_commercial_interior_painting_premium_fe294b7e-0227-404b-bed4-28fc32e6bb35_0.png',
    title: 'Professional Interior Painting',
    category: 'Commercial Painting',
    featured: false
  },
  {
    image: '/assets/gallery/projects/granite-samples.jpg',
    title: 'Stone Sample Collection',
    category: 'Materials',
    featured: false
  },
  {
    image: '/assets/gallery/projects/wood-samples.jpg',
    title: 'Wood Species Showcase',
    category: 'Materials',
    featured: false
  },
  {
    image: '/assets/gallery/projects/engineered-stone.jpg',
    title: 'Engineered Quartz Surfaces',
    category: 'Materials',
    featured: false
  }
]

// Carousel functions
const openCarousel = (index = 0) => {
  currentCarouselIndex.value = index
  carouselOpen.value = true
  document.body.style.overflow = 'hidden'
}

const closeCarousel = () => {
  carouselOpen.value = false
  document.body.style.overflow = 'auto'
}

const nextCarouselImage = () => {
  currentCarouselIndex.value = (currentCarouselIndex.value + 1) % allGalleryImages.length
}

const previousCarouselImage = () => {
  currentCarouselIndex.value = currentCarouselIndex.value === 0 ? allGalleryImages.length - 1 : currentCarouselIndex.value - 1
}

const goToCarouselImage = (index) => {
  currentCarouselIndex.value = index
}

// Material lightbox functions
const openMaterialLightbox = (materialType) => {
  const materialImages = {
    granite: '/assets/gallery/projects/granite-samples.jpg',
    wood: '/assets/gallery/projects/wood-samples.jpg',
    engineered: '/assets/gallery/projects/engineered-stone.jpg'
  }
  
  const imageIndex = allGalleryImages.findIndex(img => img.src === materialImages[materialType])
  if (imageIndex !== -1) {
    openCarousel(imageIndex)
  }
}

// Original lightbox functions
const openLightbox = (index) => {
  currentImageIndex.value = index
  lightboxOpen.value = true
  document.body.style.overflow = 'hidden'
}

const closeLightbox = () => {
  lightboxOpen.value = false
  document.body.style.overflow = 'auto'
}

const nextImage = () => {
  currentImageIndex.value = (currentImageIndex.value + 1) % galleryItems.length
}

const previousImage = () => {
  currentImageIndex.value = currentImageIndex.value === 0 ? galleryItems.length - 1 : currentImageIndex.value - 1
}

const scrollToForm = () => {
  const el = document.querySelector('#quote-form')
  if (el) el.scrollIntoView({ behavior: 'smooth' })
}

// Handle keyboard navigation
const handleKeydown = (event) => {
  if (carouselOpen.value) {
    if (event.key === 'Escape') {
      closeCarousel()
    } else if (event.key === 'ArrowRight') {
      nextCarouselImage()
    } else if (event.key === 'ArrowLeft') {
      previousCarouselImage()
    }
  } else if (lightboxOpen.value) {
    if (event.key === 'Escape') {
      closeLightbox()
    } else if (event.key === 'ArrowRight') {
      nextImage()
    } else if (event.key === 'ArrowLeft') {
      previousImage()
    }
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
/* Base Gallery Styles */
.gallery-preview {
  background: #f8f9fa;
}

.container {
  max-width: 1400px;
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
  color: #2c3e50;
  margin-bottom: 1rem;
  position: relative;
  font-family: 'Cormorant Garamond', serif;
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: -10px;
  left: 50%;
  transform: translateX(-50%);
  width: 80px;
  height: 4px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 2px;
}

.section-subtitle {
  font-size: 1.2rem;
  color: #7f8c8d;
  max-width: 600px;
  margin: 0 auto;
  line-height: 1.6;
}

/* Materials Section - Fixed Alignment */
.materials-section {
  margin-bottom: 4rem;
  padding: 3rem 2rem;
  background: linear-gradient(135deg, #fff9f0 0%, #fef7ed 100%);
  border-radius: 20px;
}

.materials-title {
  text-align: center;
  font-size: 2.2rem;
  color: #2c3e50;
  margin-bottom: 2.5rem;
  font-family: 'Cormorant Garamond', serif;
  font-weight: 600;
}

.materials-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  justify-items: center;
}

.material-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  width: 100%;
  max-width: 350px;
}

.material-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

.material-card img {
  width: 100%;
  height: 220px;
  object-fit: cover;
  object-position: center;
  transition: transform 0.3s ease;
  image-rendering: -webkit-optimize-contrast;
  image-rendering: crisp-edges;
}

.material-card:hover img {
  transform: scale(1.05);
}

.material-info {
  padding: 1.5rem;
}

.material-info h4 {
  font-size: 1.3rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  font-family: 'Cormorant Garamond', serif;
  font-weight: 600;
}

.material-info p {
  color: #7f8c8d;
  line-height: 1.6;
  font-size: 0.95rem;
}

/* Gallery Grid - Fixed Alignment */
.gallery-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 2rem;
  margin-bottom: 3rem;
  justify-items: center;
  align-items: start;
}

.gallery-item {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
  width: 100%;
  max-width: 400px;
}

.gallery-item.featured {
  grid-column: span 2;
  max-width: 820px;
}

.gallery-item:hover,
.gallery-item:focus {
  transform: translateY(-8px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
  outline: 3px solid #f39c12;
  outline-offset: 2px;
}

.image-container {
  position: relative;
  overflow: hidden;
  aspect-ratio: 4/3;
}

.gallery-item.featured .image-container {
  aspect-ratio: 16/9;
}

.image-container img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
  transition: transform 0.3s ease;
  image-rendering: -webkit-optimize-contrast;
  image-rendering: crisp-edges;
}

.gallery-item:hover .image-container img,
.gallery-item:focus .image-container img {
  transform: scale(1.1);
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(44, 62, 80, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: all 0.3s ease;
}

.gallery-item:hover .image-overlay,
.gallery-item:focus .image-overlay {
  opacity: 1;
}

.overlay-content {
  text-align: center;
  color: white;
  transform: translateY(20px);
  transition: transform 0.3s ease;
}

.gallery-item:hover .overlay-content,
.gallery-item:focus .overlay-content {
  transform: translateY(0);
}

.overlay-content h4 {
  font-size: 1.3rem;
  margin-bottom: 0.5rem;
  font-family: 'Cormorant Garamond', serif;
}

.overlay-content p {
  margin-bottom: 1rem;
  color: #bdc3c7;
}

.view-icon {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
}

.view-icon i {
  font-size: 1.2rem;
}

.item-info {
  padding: 1.5rem;
}

.category-tag {
  background: #ecf0f1;
  color: #2c3e50;
  padding: 0.3rem 0.8rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
}

.item-info h4 {
  margin-top: 1rem;
  color: #2c3e50;
  font-size: 1.1rem;
  font-family: 'Cormorant Garamond', serif;
}

.gallery-cta {
  text-align: center;
  display: flex;
  justify-content: center;
  gap: 1.5rem;
  flex-wrap: wrap;
}

.btn-primary, .btn-secondary {
  padding: 1rem 2rem;
  border-radius: 8px;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  font-family: 'Inter', sans-serif;
}

.btn-primary {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(243, 156, 18, 0.3);
}

.btn-secondary {
  background: transparent;
  color: #3b82f6;
  border: 2px solid #3b82f6;
}

.btn-secondary:hover {
  background: #3b82f6;
  color: white;
}

/* Full-Screen Carousel - Fixed Resolution & Alignment */
.carousel-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.95);
  z-index: 3000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.carousel-container {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  position: relative;
}

.carousel-close {
  position: absolute;
  top: 2rem;
  right: 2rem;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  cursor: pointer;
  z-index: 3001;
  transition: background 0.3s ease;
  font-size: 1.2rem;
  backdrop-filter: blur(10px);
}

.carousel-close:hover {
  background: rgba(255, 255, 255, 0.3);
}

.carousel-main {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  padding: 2rem;
  min-height: 0;
}

.carousel-image-container {
  max-width: 85%;
  max-height: 75%;
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.carousel-image-container img {
  max-width: 100%;
  max-height: 100%;
  width: auto;
  height: auto;
  object-fit: contain;
  object-position: center;
  border-radius: 12px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
  image-rendering: -webkit-optimize-contrast;
  image-rendering: crisp-edges;
}

.carousel-info {
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 1rem 2rem;
  border-radius: 8px;
  margin-top: 1rem;
  text-align: center;
  backdrop-filter: blur(10px);
  max-width: 600px;
}

.carousel-info h3 {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
  font-family: 'Cormorant Garamond', serif;
  font-weight: 600;
}

.carousel-category {
  color: #f39c12;
  font-weight: 600;
  font-size: 1rem;
}

.carousel-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 1.5rem;
  backdrop-filter: blur(10px);
}

.carousel-nav:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-50%) scale(1.1);
}

.carousel-nav.prev {
  left: 2rem;
}

.carousel-nav.next {
  right: 2rem;
}

/* Carousel Thumbnails - Fixed Alignment */
.carousel-thumbnails {
  background: rgba(0, 0, 0, 0.8);
  padding: 1rem 0;
  backdrop-filter: blur(10px);
  flex-shrink: 0;
}

.thumbnails-container {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.5rem;
  overflow-x: auto;
  padding: 0 2rem;
  scrollbar-width: none;
  -ms-overflow-style: none;
  max-width: 100%;
}

.thumbnails-container::-webkit-scrollbar {
  display: none;
}

.thumbnail {
  flex-shrink: 0;
  width: 80px;
  height: 60px;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.thumbnail.active {
  border-color: #f39c12;
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(243, 156, 18, 0.4);
}

.thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
  image-rendering: -webkit-optimize-contrast;
  image-rendering: crisp-edges;
}

.thumbnail:hover {
  transform: scale(1.05);
  border-color: rgba(243, 156, 18, 0.5);
}

/* Lightbox Styles */
.lightbox-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 2rem;
}

.lightbox-container {
  position: relative;
  max-width: 90vw;
  max-height: 90vh;
  background: white;
  border-radius: 16px;
  overflow: hidden;
  display: flex;
}

.lightbox-close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  cursor: pointer;
  z-index: 1001;
  transition: background 0.3s ease;
}

.lightbox-close:hover {
  background: rgba(0, 0, 0, 0.7);
}

.lightbox-content {
  display: flex;
  max-height: 90vh;
  width: 100%;
}

.lightbox-content img {
  max-width: 60%;
  height: auto;
  object-fit: contain;
  object-position: center;
  image-rendering: -webkit-optimize-contrast;
  image-rendering: crisp-edges;
}

.lightbox-info {
  padding: 2rem;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.lightbox-info h3 {
  font-size: 1.8rem;
  color: #2c3e50;
  margin-bottom: 1rem;
  font-family: 'Cormorant Garamond', serif;
}

.lightbox-category {
  color: #f39c12;
  font-weight: 600;
  margin-bottom: 1rem;
}

.lightbox-description {
  color: #7f8c8d;
  line-height: 1.6;
}

.lightbox-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(0, 0, 0, 0.5);
  color: white;
  border: none;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  cursor: pointer;
  transition: background 0.3s ease;
}

.lightbox-nav:hover {
  background: rgba(0, 0, 0, 0.7);
}

.lightbox-nav.prev {
  left: 1rem;
}

.lightbox-nav.next {
  right: 1rem;
}

/* Mobile Responsiveness */
@media (max-width: 1200px) {
  .gallery-item.featured {
    grid-column: span 1;
    max-width: 400px;
  }
}

@media (max-width: 768px) {
  .container {
    padding: 0 1rem;
  }
  
  .materials-section {
    padding: 2rem 1rem;
    margin-bottom: 2rem;
  }
  
  .materials-grid {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
  
  .gallery-grid {
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 1.5rem;
  }
  
  .carousel-close {
    top: 1rem;
    right: 1rem;
    width: 40px;
    height: 40px;
    font-size: 1rem;
  }
  
  .carousel-main {
    padding: 1rem;
  }
  
  .carousel-nav {
    width: 50px;
    height: 50px;
    font-size: 1.2rem;
  }
  
  .carousel-nav.prev {
    left: 1rem;
  }
  
  .carousel-nav.next {
    right: 1rem;
  }
  
  .carousel-info {
    padding: 0.75rem 1rem;
    margin-top: 0.5rem;
  }
  
  .carousel-info h3 {
    font-size: 1.2rem;
  }
  
  .thumbnail {
    width: 60px;
    height: 45px;
  }
  
  .thumbnails-container {
    padding: 0 1rem;
    gap: 0.25rem;
  }
  
  .lightbox-content {
    flex-direction: column;
  }
  
  .lightbox-content img {
    max-width: 100%;
    max-height: 50%;
  }
  
  .lightbox-info {
    padding: 1rem;
  }
}

@media (max-width: 480px) {
  .section-padding {
    padding: 3rem 0;
  }
  
  .gallery-grid {
    grid-template-columns: 1fr;
  }
  
  .materials-grid {
    grid-template-columns: 1fr;
  }
  
  .gallery-cta {
    flex-direction: column;
    align-items: center;
  }
  
  .btn-primary, .btn-secondary {
    width: 100%;
    max-width: 300px;
  }
}
</style>
