#!/bin/bash

# Website Content Creation Script
# Creates professional websites for all 4 domains

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🎨 Creating Website Content${NC}"
echo "============================"

# Create giorgiy.org (LZ Custom) - Port 3001/4001
create_lz_custom() {
    echo -e "${BLUE}Creating LZ Custom website (giorgiy.org)...${NC}"
    
    cat > sites/giorgiy.org/frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LZ Custom - Professional Fabrication Services</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Arial', sans-serif; line-height: 1.6; color: #333; }
        
        .hero { 
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white; 
            padding: 100px 20px; 
            text-align: center;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .hero h1 { font-size: 4em; margin-bottom: 20px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
        .hero .tagline { font-size: 1.5em; margin-bottom: 30px; color: #f39c12; font-weight: bold; }
        .services-list { font-size: 1.3em; margin-bottom: 40px; line-height: 1.8; }
        .phone-large { font-size: 3.5em; font-weight: bold; color: #f39c12; margin: 30px 0; text-shadow: 2px 2px 4px rgba(0,0,0,0.5); }
        
        .contact-section { background: #34495e; padding: 80px 20px; text-align: center; }
        .contact-form { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; color: #333; }
        .form-group { margin-bottom: 20px; text-align: left; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group textarea, .form-group select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 16px; }
        .form-group textarea { height: 120px; resize: vertical; }
        .contact-methods { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; margin: 20px 0; }
        .contact-method { padding: 8px; background: #f8f9fa; border-radius: 5px; text-align: center; cursor: pointer; border: 2px solid transparent; }
        .contact-method.selected { border-color: #3498db; background: #e3f2fd; }
        .submit-btn { background: #3498db; color: white; padding: 15px 30px; border: none; border-radius: 5px; font-size: 18px; cursor: pointer; width: 100%; }
        .submit-btn:hover { background: #2980b9; }
    </style>
</head>
<body>
    <section class="hero">
        <h1>LZ Custom</h1>
        <div class="tagline">Northeast Ohio's Premier Fabrication Company</div>
        <div class="services-list">
            <strong>Custom Cabinets | Countertops | Plastics | Stone Fabrication<br>
            Tile Installation | Flooring | Commercial Painting</strong>
        </div>
        <div class="phone-large">📞 216-268-2990</div>
        <div style="font-size: 1.2em;">
            <strong>30+ Years in Business • In House Manufacturing</strong><br>
            <em>We do not outsource</em>
        </div>
    </section>
    
    <section class="contact-section">
        <h2 style="color: white; margin-bottom: 40px; font-size: 2.5em;">Get Your Free Quote</h2>
        <form class="contact-form" id="contactForm">
            <div class="form-group">
                <label for="name">Full Name *</label>
                <input type="text" id="name" name="name" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email">
            </div>
            
            <div class="form-group">
                <label for="phone">Phone Number</label>
                <input type="tel" id="phone" name="phone">
            </div>
            
            <div class="form-group">
                <label for="project">Project Type</label>
                <select id="project" name="project">
                    <option value="kitchen">Kitchen Remodel</option>
                    <option value="bathroom">Bathroom Remodel</option>
                    <option value="countertops">Countertops Only</option>
                    <option value="cabinets">Custom Cabinets</option>
                    <option value="commercial">Commercial Project</option>
                    <option value="other">Other</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Preferred Contact Method(s):</label>
                <div class="contact-methods">
                    <div class="contact-method" data-method="phone">📞 Phone</div>
                    <div class="contact-method" data-method="text">📱 Text</div>
                    <div class="contact-method" data-method="email">📧 Email</div>
                    <div class="contact-method" data-method="telegram">📲 Telegram</div>
                    <div class="contact-method" data-method="linkedin">💼 LinkedIn</div>
                    <div class="contact-method" data-method="github">💻 GitHub</div>
                </div>
                <input type="hidden" id="contactMethods" name="contactMethods">
            </div>
            
            <div class="form-group">
                <label for="message">Project Details *</label>
                <textarea id="message" name="message" placeholder="Tell us about your project..." required></textarea>
            </div>
            
            <button type="submit" class="submit-btn">Send Quote Request</button>
        </form>
    </section>
    
    <script>
        // Contact method selection
        document.querySelectorAll('.contact-method').forEach(method => {
            method.addEventListener('click', function() {
                this.classList.toggle('selected');
                updateContactMethods();
            });
        });
        
        function updateContactMethods() {
            const selected = Array.from(document.querySelectorAll('.contact-method.selected'))
                .map(el => el.dataset.method);
            document.getElementById('contactMethods').value = selected.join(',');
        }
        
        // Form submission
        document.getElementById('contactForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const data = Object.fromEntries(formData.entries());
            
            try {
                const response = await fetch('/api/contact', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });
                
                if (response.ok) {
                    alert('Thank you! Your quote request has been submitted. We\'ll contact you within 24 hours.');
                    this.reset();
                    document.querySelectorAll('.contact-method.selected').forEach(el => el.classList.remove('selected'));
                } else {
                    alert('There was an error submitting your request. Please call us at 216-268-2990.');
                }
            } catch (error) {
                alert('There was an error submitting your request. Please call us at 216-268-2990.');
            }
        });
    </script>
</body>
</html>
EOF
    
    echo -e "${GREEN}✅ LZ Custom website created${NC}"
}

# Create giorgiy-shepov.com (Personal) - Port 3002/4002
create_personal_site() {
    echo -e "${BLUE}Creating Personal website (giorgiy-shepov.com)...${NC}"
    
    cat > sites/giorgiy-shepov.com/frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giorgiy Shepov - Technology Professional</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Arial', sans-serif; line-height: 1.6; color: #333; }
        
        .hero { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white; 
            padding: 100px 20px; 
            text-align: center;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .hero h1 { font-size: 4em; margin-bottom: 20px; }
        .hero .tagline { font-size: 1.5em; margin-bottom: 30px; color: #f1c40f; }
        
        .contact-section { background: #2c3e50; padding: 80px 20px; text-align: center; }
        .contact-form { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; color: #333; }
        .form-group { margin-bottom: 20px; text-align: left; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group textarea, .form-group select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; }
        .contact-methods { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; margin: 20px 0; }
        .contact-method { padding: 8px; background: #f8f9fa; border-radius: 5px; text-align: center; cursor: pointer; border: 2px solid transparent; }
        .contact-method.selected { border-color: #667eea; background: #e8f0fe; }
        .submit-btn { background: #667eea; color: white; padding: 15px 30px; border: none; border-radius: 5px; font-size: 18px; cursor: pointer; width: 100%; }
    </style>
</head>
<body>
    <section class="hero">
        <h1>Giorgiy Shepov</h1>
        <div class="tagline">Technology Professional & Entrepreneur</div>
        <p style="font-size: 1.2em; max-width: 800px; margin: 0 auto;">
            Passionate about technology, innovation, and building solutions that make a difference.
        </p>
    </section>
    
    <section class="contact-section">
        <h2 style="color: white; margin-bottom: 40px; font-size: 2.5em;">Get In Touch</h2>
        <form class="contact-form" id="contactForm">
            <div class="form-group">
                <label for="name">Full Name *</label>
                <input type="text" id="name" name="name" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email">
            </div>
            
            <div class="form-group">
                <label for="subject">Subject</label>
                <select id="subject" name="subject">
                    <option value="business">Business Inquiry</option>
                    <option value="collaboration">Collaboration</option>
                    <option value="consulting">Consulting</option>
                    <option value="other">Other</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Preferred Contact Method(s):</label>
                <div class="contact-methods">
                    <div class="contact-method" data-method="email">📧 Email</div>
                    <div class="contact-method" data-method="phone">📞 Phone</div>
                    <div class="contact-method" data-method="telegram">📲 Telegram</div>
                    <div class="contact-method" data-method="linkedin">💼 LinkedIn</div>
                    <div class="contact-method" data-method="github">💻 GitHub</div>
                </div>
                <input type="hidden" id="contactMethods" name="contactMethods">
            </div>
            
            <div class="form-group">
                <label for="message">Message *</label>
                <textarea id="message" name="message" placeholder="Tell me about your project or inquiry..." required></textarea>
            </div>
            
            <button type="submit" class="submit-btn">Send Message</button>
        </form>
    </section>
    
    <script>
        // Same contact method and form handling JavaScript as LZ Custom
        document.querySelectorAll('.contact-method').forEach(method => {
            method.addEventListener('click', function() {
                this.classList.toggle('selected');
                updateContactMethods();
            });
        });
        
        function updateContactMethods() {
            const selected = Array.from(document.querySelectorAll('.contact-method.selected'))
                .map(el => el.dataset.method);
            document.getElementById('contactMethods').value = selected.join(',');
        }
        
        document.getElementById('contactForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const data = Object.fromEntries(formData.entries());
            
            try {
                const response = await fetch('/api/contact', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });
                
                if (response.ok) {
                    alert('Thank you! Your message has been sent. I\'ll get back to you soon.');
                    this.reset();
                    document.querySelectorAll('.contact-method.selected').forEach(el => el.classList.remove('selected'));
                } else {
                    alert('There was an error sending your message. Please try again.');
                }
            } catch (error) {
                alert('There was an error sending your message. Please try again.');
            }
        });
    </script>
</body>
</html>
EOF
    
    echo -e "${GREEN}✅ Personal website created${NC}"
}

# Create lodexinc.com - Port 3003/4003
create_lodex_site() {
    echo -e "${BLUE}Creating Lodex Inc website (lodexinc.com)...${NC}"

    cat > sites/lodexinc.com/frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lodex Inc - Innovation & Technology Solutions</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Arial', sans-serif; line-height: 1.6; color: #333; }

        .hero {
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            color: white;
            padding: 100px 20px;
            text-align: center;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .hero h1 { font-size: 4em; margin-bottom: 20px; }
        .hero .tagline { font-size: 1.5em; margin-bottom: 30px; color: #ffd700; }

        .contact-section { background: #34495e; padding: 80px 20px; text-align: center; }
        .contact-form { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; color: #333; }
        .form-group { margin-bottom: 20px; text-align: left; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group textarea, .form-group select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; }
        .contact-methods { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; margin: 20px 0; }
        .contact-method { padding: 8px; background: #f8f9fa; border-radius: 5px; text-align: center; cursor: pointer; border: 2px solid transparent; }
        .contact-method.selected { border-color: #1e3c72; background: #e8f0fe; }
        .submit-btn { background: #1e3c72; color: white; padding: 15px 30px; border: none; border-radius: 5px; font-size: 18px; cursor: pointer; width: 100%; }
    </style>
</head>
<body>
    <section class="hero">
        <h1>Lodex Inc</h1>
        <div class="tagline">Innovation & Technology Solutions</div>
        <p style="font-size: 1.2em; max-width: 800px; margin: 0 auto;">
            Delivering cutting-edge technology solutions for modern businesses.
        </p>
    </section>

    <section class="contact-section">
        <h2 style="color: white; margin-bottom: 40px; font-size: 2.5em;">Contact Us</h2>
        <form class="contact-form" id="contactForm">
            <div class="form-group">
                <label for="name">Full Name *</label>
                <input type="text" id="name" name="name" required>
            </div>

            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email">
            </div>

            <div class="form-group">
                <label for="subject">Subject</label>
                <select id="subject" name="subject">
                    <option value="technology">Technology Solutions</option>
                    <option value="consulting">Consulting</option>
                    <option value="partnership">Partnership</option>
                    <option value="other">Other</option>
                </select>
            </div>

            <div class="form-group">
                <label>Preferred Contact Method(s):</label>
                <div class="contact-methods">
                    <div class="contact-method" data-method="email">📧 Email</div>
                    <div class="contact-method" data-method="phone">📞 Phone</div>
                    <div class="contact-method" data-method="telegram">📲 Telegram</div>
                    <div class="contact-method" data-method="linkedin">💼 LinkedIn</div>
                    <div class="contact-method" data-method="github">💻 GitHub</div>
                </div>
                <input type="hidden" id="contactMethods" name="contactMethods">
            </div>

            <div class="form-group">
                <label for="message">Message *</label>
                <textarea id="message" name="message" placeholder="Tell us about your project..." required></textarea>
            </div>

            <button type="submit" class="submit-btn">Send Message</button>
        </form>
    </section>

    <script>
        document.querySelectorAll('.contact-method').forEach(method => {
            method.addEventListener('click', function() {
                this.classList.toggle('selected');
                updateContactMethods();
            });
        });

        function updateContactMethods() {
            const selected = Array.from(document.querySelectorAll('.contact-method.selected'))
                .map(el => el.dataset.method);
            document.getElementById('contactMethods').value = selected.join(',');
        }

        document.getElementById('contactForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const data = Object.fromEntries(formData.entries());

            try {
                const response = await fetch('/api/contact', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });

                if (response.ok) {
                    alert('Thank you! Your message has been sent.');
                    this.reset();
                    document.querySelectorAll('.contact-method.selected').forEach(el => el.classList.remove('selected'));
                } else {
                    alert('There was an error sending your message. Please try again.');
                }
            } catch (error) {
                alert('There was an error sending your message. Please try again.');
            }
        });
    </script>
</body>
</html>
EOF

    echo -e "${GREEN}✅ Lodex Inc website created${NC}"
}

# Create bravoohiocci.org - Port 3004/4004
create_bravo_site() {
    echo -e "${BLUE}Creating Bravo Ohio CCI website (bravoohiocci.org)...${NC}"

    cat > sites/bravoohiocci.org/frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bravo Ohio CCI - Community & Commerce Initiative</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Arial', sans-serif; line-height: 1.6; color: #333; }

        .hero {
            background: linear-gradient(135deg, #c0392b 0%, #e74c3c 100%);
            color: white;
            padding: 100px 20px;
            text-align: center;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .hero h1 { font-size: 4em; margin-bottom: 20px; }
        .hero .tagline { font-size: 1.5em; margin-bottom: 30px; color: #f1c40f; }

        .contact-section { background: #2c3e50; padding: 80px 20px; text-align: center; }
        .contact-form { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; color: #333; }
        .form-group { margin-bottom: 20px; text-align: left; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group textarea, .form-group select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; }
        .contact-methods { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; margin: 20px 0; }
        .contact-method { padding: 8px; background: #f8f9fa; border-radius: 5px; text-align: center; cursor: pointer; border: 2px solid transparent; }
        .contact-method.selected { border-color: #c0392b; background: #ffeaea; }
        .submit-btn { background: #c0392b; color: white; padding: 15px 30px; border: none; border-radius: 5px; font-size: 18px; cursor: pointer; width: 100%; }
    </style>
</head>
<body>
    <section class="hero">
        <h1>Bravo Ohio CCI</h1>
        <div class="tagline">Community & Commerce Initiative</div>
        <p style="font-size: 1.2em; max-width: 800px; margin: 0 auto;">
            Building stronger communities through commerce and collaboration in Ohio.
        </p>
    </section>

    <section class="contact-section">
        <h2 style="color: white; margin-bottom: 40px; font-size: 2.5em;">Get Involved</h2>
        <form class="contact-form" id="contactForm">
            <div class="form-group">
                <label for="name">Full Name *</label>
                <input type="text" id="name" name="name" required>
            </div>

            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email">
            </div>

            <div class="form-group">
                <label for="subject">Interest Area</label>
                <select id="subject" name="subject">
                    <option value="community">Community Development</option>
                    <option value="business">Business Opportunities</option>
                    <option value="partnership">Partnership</option>
                    <option value="volunteer">Volunteer</option>
                    <option value="other">Other</option>
                </select>
            </div>

            <div class="form-group">
                <label>Preferred Contact Method(s):</label>
                <div class="contact-methods">
                    <div class="contact-method" data-method="email">📧 Email</div>
                    <div class="contact-method" data-method="phone">📞 Phone</div>
                    <div class="contact-method" data-method="text">📱 Text</div>
                    <div class="contact-method" data-method="telegram">📲 Telegram</div>
                    <div class="contact-method" data-method="linkedin">💼 LinkedIn</div>
                </div>
                <input type="hidden" id="contactMethods" name="contactMethods">
            </div>

            <div class="form-group">
                <label for="message">Message *</label>
                <textarea id="message" name="message" placeholder="Tell us how you'd like to get involved..." required></textarea>
            </div>

            <button type="submit" class="submit-btn">Send Message</button>
        </form>
    </section>

    <script>
        document.querySelectorAll('.contact-method').forEach(method => {
            method.addEventListener('click', function() {
                this.classList.toggle('selected');
                updateContactMethods();
            });
        });

        function updateContactMethods() {
            const selected = Array.from(document.querySelectorAll('.contact-method.selected'))
                .map(el => el.dataset.method);
            document.getElementById('contactMethods').value = selected.join(',');
        }

        document.getElementById('contactForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const data = Object.fromEntries(formData.entries());

            try {
                const response = await fetch('/api/contact', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });

                if (response.ok) {
                    alert('Thank you! Your message has been sent.');
                    this.reset();
                    document.querySelectorAll('.contact-method.selected').forEach(el => el.classList.remove('selected'));
                } else {
                    alert('There was an error sending your message. Please try again.');
                }
            } catch (error) {
                alert('There was an error sending your message. Please try again.');
            }
        });
    </script>
</body>
</html>
EOF

    echo -e "${GREEN}✅ Bravo Ohio CCI website created${NC}"
}

# Main execution
main() {
    create_lz_custom
    create_personal_site
    create_lodex_site
    create_bravo_site

    echo -e "${GREEN}[COMPLETE] All website content created${NC}"
    echo -e "${BLUE}[INFO] Next: Create backend applications with ./create-backends.sh${NC}"
}

main "$@"
