// LZ Custom - Admin Dashboard JavaScript for Azure App Service

const { createApp } = Vue;

createApp({
    data() {
        return {
            activeTab: 'leads',
            prospects: [],
            chatStats: {},
            selectedProspect: null,
            prospectNotes: '',
            searchQuery: '',
            statusFilter: '',
            loading: false
        };
    },
    computed: {
        filteredProspects() {
            let filtered = this.prospects;
            
            // Filter by search query
            if (this.searchQuery) {
                const query = this.searchQuery.toLowerCase();
                filtered = filtered.filter(prospect => 
                    (prospect.name && prospect.name.toLowerCase().includes(query)) ||
                    (prospect.email && prospect.email.toLowerCase().includes(query)) ||
                    (prospect.phone && prospect.phone.includes(query)) ||
                    (prospect.project_type && prospect.project_type.toLowerCase().includes(query))
                );
            }
            
            // Filter by status
            if (this.statusFilter) {
                filtered = filtered.filter(prospect => prospect.status === this.statusFilter);
            }
            
            return filtered;
        },
        highPriorityCount() {
            return this.prospects.filter(p => p.priority === 'high').length;
        },
        newLeadsCount() {
            const today = new Date().toISOString().split('T')[0];
            return this.prospects.filter(p => 
                p.created_at && p.created_at.startsWith(today)
            ).length;
        },
        conversionRate() {
            const total = this.prospects.length;
            const won = this.prospects.filter(p => p.status === 'won').length;
            return total > 0 ? Math.round((won / total) * 100) : 0;
        }
    },
    methods: {
        async loadProspects() {
            this.loading = true;
            try {
                const response = await fetch('/api/prospects');
                if (response.ok) {
                    this.prospects = await response.json();
                } else {
                    console.error('Failed to load prospects');
                }
            } catch (error) {
                console.error('Error loading prospects:', error);
            } finally {
                this.loading = false;
            }
        },
        
        async loadAnalytics() {
            try {
                const response = await fetch('/api/analytics/dashboard');
                if (response.ok) {
                    const data = await response.json();
                    this.chatStats = data.chats || {};
                } else {
                    console.error('Failed to load analytics');
                }
            } catch (error) {
                console.error('Error loading analytics:', error);
            }
        },
        
        async updateStatus(prospect) {
            try {
                // In a full implementation, you'd send a PATCH request
                // For now, we'll just update locally
                console.log('Status updated for prospect:', prospect.id, 'to:', prospect.status);
                
                // You could implement this with a backend endpoint:
                // const response = await fetch(`/api/prospects/${prospect.id}`, {
                //     method: 'PATCH',
                //     headers: { 'Content-Type': 'application/json' },
                //     body: JSON.stringify({ status: prospect.status })
                // });
                
            } catch (error) {
                console.error('Error updating status:', error);
            }
        },
        
        viewDetails(prospect) {
            this.selectedProspect = { ...prospect };
            this.prospectNotes = prospect.notes || '';
        },
        
        closeModal() {
            this.selectedProspect = null;
            this.prospectNotes = '';
        },
        
        async saveNotes() {
            if (this.selectedProspect) {
                try {
                    // In a full implementation, you'd save notes to backend
                    this.selectedProspect.notes = this.prospectNotes;
                    
                    // Update the prospect in the main list
                    const index = this.prospects.findIndex(p => p.id === this.selectedProspect.id);
                    if (index !== -1) {
                        this.prospects[index].notes = this.prospectNotes;
                    }
                    
                    alert('Notes saved successfully!');
                } catch (error) {
                    console.error('Error saving notes:', error);
                    alert('Error saving notes. Please try again.');
                }
            }
        },
        
        formatProjectType(type) {
            if (!type) return 'Not specified';
            
            const types = {
                'cabinets': 'Kitchen Cabinets',
                'countertops': 'Countertops',
                'tile': 'Tile Work',
                'painting': 'Commercial Painting',
                'other': 'Other'
            };
            
            return types[type] || type;
        },
        
        formatBudget(budget) {
            if (!budget) return 'Not specified';
            
            const budgets = {
                'under-5k': 'Under $5,000',
                '5k-15k': '$5,000 - $15,000',
                '15k-30k': '$15,000 - $30,000',
                '30k-50k': '$30,000 - $50,000',
                'over-50k': 'Over $50,000'
            };
            
            return budgets[budget] || budget;
        },
        
        formatTimeline(timeline) {
            if (!timeline) return 'Not specified';
            
            const timelines = {
                'asap': 'ASAP',
                '1-month': 'Within 1 Month',
                '3-months': 'Within 3 Months',
                '6-months': 'Within 6 Months',
                'flexible': 'Flexible'
            };
            
            return timelines[timeline] || timeline;
        },
        
        formatDate(dateString) {
            if (!dateString) return 'Unknown';
            
            try {
                const date = new Date(dateString);
                return date.toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                });
            } catch (error) {
                return dateString;
            }
        },
        
        exportProspects() {
            // Simple CSV export
            const headers = ['Name', 'Email', 'Phone', 'Project', 'Budget', 'Timeline', 'Status', 'Date'];
            const csvContent = [
                headers.join(','),
                ...this.prospects.map(p => [
                    p.name || '',
                    p.email || '',
                    p.phone || '',
                    this.formatProjectType(p.project_type),
                    this.formatBudget(p.budget_range),
                    this.formatTimeline(p.timeline),
                    p.status || 'new',
                    this.formatDate(p.created_at)
                ].join(','))
            ].join('\n');
            
            const blob = new Blob([csvContent], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `lz-custom-leads-${new Date().toISOString().split('T')[0]}.csv`;
            a.click();
            window.URL.revokeObjectURL(url);
        }
    },
    
    async mounted() {
        // Load initial data
        await this.loadProspects();
        await this.loadAnalytics();
        
        // Set up auto-refresh every 5 minutes
        setInterval(() => {
            this.loadProspects();
            this.loadAnalytics();
        }, 5 * 60 * 1000);
    }
}).mount('#app');

// Keyboard shortcuts
document.addEventListener('keydown', function(e) {
    // Escape key to close modal
    if (e.key === 'Escape') {
        const app = document.querySelector('#app').__vue_app__.config.globalProperties;
        if (app && app.selectedProspect) {
            app.closeModal();
        }
    }
    
    // Ctrl/Cmd + E to export
    if ((e.ctrlKey || e.metaKey) && e.key === 'e') {
        e.preventDefault();
        const app = document.querySelector('#app').__vue_app__.config.globalProperties;
        if (app && app.exportProspects) {
            app.exportProspects();
        }
    }
});

// Auto-save functionality for notes
let notesSaveTimeout;
function autoSaveNotes() {
    clearTimeout(notesSaveTimeout);
    notesSaveTimeout = setTimeout(() => {
        const app = document.querySelector('#app').__vue_app__.config.globalProperties;
        if (app && app.selectedProspect && app.prospectNotes !== app.selectedProspect.notes) {
            app.saveNotes();
        }
    }, 2000);
}

// Add event listener for notes textarea when it's created
document.addEventListener('input', function(e) {
    if (e.target.tagName === 'TEXTAREA' && e.target.placeholder.includes('notes')) {
        autoSaveNotes();
    }
});

// Simple notification system
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.classList.add('show');
    }, 100);
    
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}
