
<template>
  <section class="quote" id="quote-form">
    <h2>Request a Quote</h2>
    <form @submit.prevent="submitForm">
      <input type="text" v-model="form.name" placeholder="Your Name" required />
      <input type="email" v-model="form.email" placeholder="Email Address" required />
      <input type="tel" v-model="form.phone" placeholder="Phone Number" required />
      <select v-model="form.project">
        <option disabled value="">Select Project Type</option>
        <option>Cabinets</option>
        <option>Countertops</option>
        <option>Flooring</option>
        <option>Painting</option>
        <option>Other</option>
      </select>
      <input v-if="form.project === 'Countertops'" type="number" v-model="form.squareFootage" placeholder="Square footage (optional)" min="1" step="1" />
      <textarea v-model="form.message" placeholder="Tell us about your project..." rows="4"></textarea>
      <button type="submit">Send Request</button>
    </form>
  </section>
</template>

<script setup>
import { ref } from 'vue'

const form = ref({
  name: '',
  email: '',
  phone: '',
  project: '',
  message: '',
  squareFootage: ''
})

const submitForm = async () => {
  try {
    // Prepare form data with proper type conversion
    const formData = {
      ...form.value,
      squareFootage: form.value.squareFootage && String(form.value.squareFootage).trim() !== ''
        ? parseInt(form.value.squareFootage)
        : null
    }

    // Validate squareFootage if provided
    if (form.value.squareFootage && String(form.value.squareFootage).trim() !== '' && isNaN(parseInt(form.value.squareFootage))) {
      alert('Please enter a valid number for square footage.')
      return
    }

    console.log('Submitting form data:', formData)

    const response = await fetch('/api/prospects', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(formData)
    })

    if (response.ok) {
      const result = await response.json()
      console.log('Success response:', result)
      alert('Your request was submitted successfully! We\'ll contact you soon.')
    } else {
      const errorData = await response.text()
      console.error('Error response:', response.status, errorData)
      throw new Error(`Server error: ${response.status}`)
    }
  } catch (error) {
    console.error('Form submission error:', error)
    alert(`There was an error submitting your request: ${error.message}. Please try again or call us directly at 216-268-2990.`)
  }
}
</script>

<style scoped>
.quote {
  padding: 4rem 2rem;
  background: #fff;
  max-width: 700px;
  margin: auto;
  border-radius: 8px;
  box-shadow: 0 1px 6px rgba(0,0,0,0.1);
}
form {
  display: flex;
  flex-direction: column;
}
input, select, textarea {
  margin: 0.5rem 0;
  padding: 0.8rem;
  font-size: 1rem;
  border: 1px solid #ccc;
  border-radius: 4px;
}
button {
  background: #222;
  color: white;
  font-weight: bold;
  padding: 0.8rem;
  margin-top: 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
</style>
