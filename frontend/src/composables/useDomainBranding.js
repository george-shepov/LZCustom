import { ref, computed, onMounted } from 'vue'

export function useDomainBranding() {
  const currentDomain = ref('')
  
  const domainConfigs = {
    'giorgiy.org': {
      companyName: 'LZ Custom Fabrication',
      tagline: 'Premier Custom Cabinet & Stone Fabrication',
      specialty: 'custom cabinets, granite countertops, stone fabrication',
      location: 'Northeast Ohio',
      phone: '216-268-2990',
      colorScheme: {
        primary: '#2c5282',
        secondary: '#4a5568',
        accent: '#3182ce'
      },
      logo: '/assets/logos/lz-custom-logo.png',
      heroImage: '/assets/hero/hero-kitchen-hd.jpg',
      services: [
        { name: 'Custom Cabinets', icon: 'fas fa-hammer', description: 'Handcrafted cabinets for kitchens and bathrooms' },
        { name: 'Granite Countertops', icon: 'fas fa-gem', description: 'Premium granite fabrication and installation' },
        { name: 'Quartz Surfaces', icon: 'fas fa-cube', description: 'Engineered quartz countertops and surfaces' },
        { name: 'Tile Installation', icon: 'fas fa-th', description: 'Professional tile and backsplash installation' }
      ]
    },
    'giorgiy-shepov.com': {
      companyName: 'Giorgiy Shepov Consulting',
      tagline: 'Business Development & Technical Solutions', 
      specialty: 'business consulting, technical strategy, digital transformation',
      location: 'Cleveland, Ohio',
      phone: '216-268-2990',
      colorScheme: {
        primary: '#1a202c',
        secondary: '#2d3748',
        accent: '#ecc94b'
      },
      logo: '/assets/logos/gs-consulting-logo.png',
      heroImage: '/assets/hero/hero-office-consulting.jpg',
      services: [
        { name: 'Business Strategy', icon: 'fas fa-chart-line', description: 'Strategic planning and business development' },
        { name: 'Digital Transformation', icon: 'fas fa-digital-tachograph', description: 'Technology integration and optimization' },
        { name: 'Process Optimization', icon: 'fas fa-cogs', description: 'Operational efficiency and workflow improvement' },
        { name: 'Technical Solutions', icon: 'fas fa-laptop-code', description: 'Custom software and technical implementations' }
      ]
    },
    'bravoohio.org': {
      companyName: 'Bravo Ohio Business Consulting',
      tagline: 'Strategic Business Growth Solutions',
      specialty: 'business consulting, market analysis, operational optimization',
      location: 'Ohio',
      phone: '216-268-2990',
      colorScheme: {
        primary: '#c53030',
        secondary: '#2b6cb0',
        accent: '#ed8936'
      },
      logo: '/assets/logos/bravo-ohio-logo.png',
      heroImage: '/assets/hero/hero-business-growth.jpg',
      services: [
        { name: 'Market Analysis', icon: 'fas fa-chart-bar', description: 'Comprehensive market research and analysis' },
        { name: 'Growth Strategy', icon: 'fas fa-rocket', description: 'Strategic planning for business expansion' },
        { name: 'Operations Consulting', icon: 'fas fa-tasks', description: 'Operational efficiency and optimization' },
        { name: 'Financial Planning', icon: 'fas fa-calculator', description: 'Financial strategy and planning services' }
      ]
    },
    'lodexinc.com': {
      companyName: 'Lodex Inc',
      tagline: 'Corporate Development & Strategy',
      specialty: 'corporate consulting, business development, strategic planning',
      location: 'Ohio',
      phone: '216-268-2990',
      colorScheme: {
        primary: '#2d3748',
        secondary: '#4a5568',
        accent: '#718096'
      },
      logo: '/assets/logos/lodex-inc-logo.png',
      heroImage: '/assets/hero/hero-corporate.jpg',
      services: [
        { name: 'Corporate Strategy', icon: 'fas fa-building', description: 'Enterprise-level strategic planning' },
        { name: 'Business Development', icon: 'fas fa-handshake', description: 'Partnership and growth opportunities' },
        { name: 'Investment Analysis', icon: 'fas fa-coins', description: 'Financial analysis and investment planning' },
        { name: 'Risk Management', icon: 'fas fa-shield-alt', description: 'Comprehensive risk assessment and mitigation' }
      ]
    }
  }

  const brandConfig = computed(() => {
    const hostname = currentDomain.value || window.location.hostname
    const domain = hostname.replace('www.', '')
    return domainConfigs[domain] || domainConfigs['giorgiy.org']
  })

  const getDomainBrand = () => {
    const hostname = window.location.hostname.replace('www.', '')
    return {
      'giorgiy.org': 'giorgiy',
      'giorgiy-shepov.com': 'giorgiy-shepov', 
      'bravoohio.org': 'bravoohio',
      'lodexinc.com': 'lodexinc'
    }[hostname] || 'giorgiy'
  }

  onMounted(() => {
    currentDomain.value = window.location.hostname
  })

  return {
    currentDomain,
    brandConfig,
    getDomainBrand
  }
}