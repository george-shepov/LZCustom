
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
  message: ''
})

const submitForm = () => {
  console.log('Submitted', form.value)
  alert('Your request was submitted. Thank you!')
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
  border: 2px solid #d1d5db;
  border-radius: 8px;
  background: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: #f39c12;
  box-shadow: 0 0 0 3px rgba(243, 156, 18, 0.1);
  transform: translateY(-1px);
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
