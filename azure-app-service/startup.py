# Azure App Service Startup Script
# This file is used by Azure App Service to start the Flask application

import os
from app import app

if __name__ == "__main__":
    # Azure App Service will set the PORT environment variable
    port = int(os.environ.get('PORT', 8000))
    
    # Run the Flask app
    app.run(
        host='0.0.0.0',
        port=port,
        debug=False  # Always False in production
    )
