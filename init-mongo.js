// MongoDB Initialization for Multi-Domain Document Storage
// Creates collections and indexes for flexible document storage

// Switch to the application database
db = db.getSiblingDB('lzcustom_docs');

// Create collections for each domain
// Content Management System
db.createCollection('lz_custom_content');
db.createCollection('gs_consulting_content');
db.createCollection('bravo_ohio_content');
db.createCollection('lodex_inc_content');

// File uploads and media
db.createCollection('media_files');
db.createCollection('documents');

// Dynamic forms and surveys
db.createCollection('form_templates');
db.createCollection('form_submissions');

// Knowledge base and FAQ
db.createCollection('knowledge_base');
db.createCollection('faq_items');

// Blog posts and articles
db.createCollection('blog_posts');
db.createCollection('case_studies');

// Customer interactions and feedback
db.createCollection('customer_feedback');
db.createCollection('support_tickets');

// Insert sample documents for each domain

// LZ Custom content
db.lz_custom_content.insertMany([
    {
        _id: ObjectId(),
        type: 'service',
        title: 'Custom Kitchen Cabinets',
        description: 'Premium handcrafted kitchen cabinets made to your exact specifications',
        content: {
            features: ['Soft-close hinges', 'Full extension drawers', 'Custom wood species'],
            pricing: { starting_price: 15000, price_range: '15k-50k' },
            timeline: '4-8 weeks',
            gallery_images: []
        },
        seo: {
            meta_title: 'Custom Kitchen Cabinets Cleveland Ohio | LZ Custom',
            meta_description: 'Professional custom kitchen cabinet fabrication in Cleveland Ohio'
        },
        status: 'published',
        created_at: new Date(),
        updated_at: new Date()
    },
    {
        _id: ObjectId(),
        type: 'testimonial',
        customer_name: 'Sarah Johnson',
        rating: 5,
        content: 'LZ Custom did an amazing job on our kitchen renovation. The quality is outstanding!',
        project_type: 'kitchen_cabinets',
        created_at: new Date()
    }
]);

// Giorgiy Shepov Consulting content
db.gs_consulting_content.insertMany([
    {
        _id: ObjectId(),
        type: 'service',
        title: 'Business Digital Transformation',
        description: 'Strategic guidance for modernizing your business operations',
        content: {
            approach: ['Assessment', 'Strategy', 'Implementation', 'Optimization'],
            industries: ['Manufacturing', 'Healthcare', 'Professional Services'],
            deliverables: ['Digital roadmap', 'Technology recommendations', 'Implementation plan']
        },
        pricing: { consultation_fee: 250, project_range: '5k-25k' },
        status: 'published',
        created_at: new Date(),
        updated_at: new Date()
    }
]);

// Bravo Ohio content
db.bravo_ohio_content.insertMany([
    {
        _id: ObjectId(),
        type: 'service',
        title: 'Market Analysis & Growth Strategy',
        description: 'Comprehensive market research and strategic growth planning',
        content: {
            methodology: ['Market research', 'Competitive analysis', 'Growth planning'],
            deliverables: ['Market report', 'Competitor analysis', 'Growth strategy'],
            timeline: '2-6 weeks'
        },
        pricing: { starting_price: 3000, price_range: '3k-15k' },
        status: 'published',
        created_at: new Date()
    }
]);

// Lodex Inc content
db.lodex_inc_content.insertMany([
    {
        _id: ObjectId(),
        type: 'service',
        title: 'Corporate Development Strategy',
        description: 'Enterprise-level strategic planning and development services',
        content: {
            focus_areas: ['Mergers & Acquisitions', 'Strategic Partnerships', 'Market Expansion'],
            client_size: 'Enterprise (500+ employees)',
            engagement_models: ['Retainer', 'Project-based', 'Advisory']
        },
        pricing: { retainer_min: 10000, project_range: '25k-100k+' },
        status: 'published',
        created_at: new Date()
    }
]);

// Form templates for dynamic forms
db.form_templates.insertMany([
    {
        _id: ObjectId(),
        domain: 'giorgiy.org',
        name: 'Kitchen Cabinet Quote',
        fields: [
            { name: 'project_type', type: 'select', options: ['Kitchen', 'Bathroom', 'Custom'] },
            { name: 'budget_range', type: 'select', options: ['Under 10k', '10k-25k', '25k-50k', '50k+'] },
            { name: 'timeline', type: 'select', options: ['ASAP', '1-3 months', '3-6 months', 'Flexible'] },
            { name: 'room_dimensions', type: 'text', placeholder: 'e.g., 12x15 feet' },
            { name: 'special_requirements', type: 'textarea', placeholder: 'Any special requirements...' }
        ],
        created_at: new Date()
    },
    {
        _id: ObjectId(),
        domain: 'giorgiy-shepov.com',
        name: 'Consulting Inquiry',
        fields: [
            { name: 'company_size', type: 'select', options: ['1-10', '11-50', '51-200', '200+'] },
            { name: 'industry', type: 'select', options: ['Technology', 'Healthcare', 'Manufacturing', 'Other'] },
            { name: 'challenge_type', type: 'select', options: ['Digital Transformation', 'Process Optimization', 'Strategy', 'Other'] },
            { name: 'budget_range', type: 'select', options: ['Under 5k', '5k-15k', '15k-50k', '50k+'] },
            { name: 'project_description', type: 'textarea', placeholder: 'Describe your project...' }
        ],
        created_at: new Date()
    }
]);

// Knowledge base entries
db.knowledge_base.insertMany([
    {
        _id: ObjectId(),
        domain: 'giorgiy.org',
        category: 'Cabinet Care',
        title: 'How to Maintain Your Custom Cabinets',
        content: 'Regular cleaning with appropriate products will keep your cabinets looking new...',
        tags: ['maintenance', 'care', 'cabinets'],
        views: 0,
        created_at: new Date()
    },
    {
        _id: ObjectId(),
        domain: 'giorgiy-shepov.com',
        category: 'Digital Transformation',
        title: 'Common Digital Transformation Pitfalls',
        content: 'Many businesses make these mistakes when undergoing digital transformation...',
        tags: ['digital transformation', 'strategy', 'best practices'],
        views: 0,
        created_at: new Date()
    }
]);

// Create indexes for performance
db.lz_custom_content.createIndex({ "type": 1, "status": 1 });
db.lz_custom_content.createIndex({ "created_at": -1 });
db.lz_custom_content.createIndex({ "seo.meta_title": "text", "title": "text", "description": "text" });

db.gs_consulting_content.createIndex({ "type": 1, "status": 1 });
db.gs_consulting_content.createIndex({ "created_at": -1 });

db.bravo_ohio_content.createIndex({ "type": 1, "status": 1 });
db.bravo_ohio_content.createIndex({ "created_at": -1 });

db.lodex_inc_content.createIndex({ "type": 1, "status": 1 });
db.lodex_inc_content.createIndex({ "created_at": -1 });

db.form_templates.createIndex({ "domain": 1, "name": 1 });
db.form_submissions.createIndex({ "domain": 1, "template_id": 1, "created_at": -1 });

db.knowledge_base.createIndex({ "domain": 1, "category": 1 });
db.knowledge_base.createIndex({ "tags": 1 });
db.knowledge_base.createIndex({ "title": "text", "content": "text" });

db.blog_posts.createIndex({ "domain": 1, "status": 1, "created_at": -1 });
db.blog_posts.createIndex({ "tags": 1 });

db.media_files.createIndex({ "domain": 1, "file_type": 1, "created_at": -1 });
db.documents.createIndex({ "domain": 1, "document_type": 1, "created_at": -1 });

print("MongoDB collections and indexes created successfully!");
print("Database: lzcustom_docs");
print("Collections created:");
print("- Domain-specific content collections");
print("- Form templates and submissions");
print("- Knowledge base and FAQ");
print("- Media files and documents");
print("- Blog posts and case studies");
print("Sample data inserted for all domains.");