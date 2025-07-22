#!/bin/bash

# LZ Custom - Image Organization and Optimization Script
# This script organizes gallery images into proper categories and optimizes them for web

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GALLERY_DIR="/home/shepov/Documents/Source/LZCustom/frontend/public/assets/gallery"
OPTIMIZED_DIR="${GALLERY_DIR}/optimized"
BACKUP_DIR="${GALLERY_DIR}/backup"
LOG_FILE="${GALLERY_DIR}/optimization.log"

echo -e "${BLUE}🖼️  LZ Custom - Image Optimization & Cataloging${NC}"
echo "=================================================="

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo -e "$1"
}

# Function to check if ImageMagick is installed
check_imagemagick() {
    if ! command -v convert &> /dev/null; then
        log_message "${YELLOW}[WARNING] ImageMagick not found. Installing...${NC}"
        sudo apt update && sudo apt install -y imagemagick
    fi
    log_message "${GREEN}[SUCCESS] ImageMagick is available${NC}"
}

# Function to check if jpegoptim is installed
check_jpegoptim() {
    if ! command -v jpegoptim &> /dev/null; then
        log_message "${YELLOW}[WARNING] jpegoptim not found. Installing...${NC}"
        sudo apt install -y jpegoptim
    fi
    log_message "${GREEN}[SUCCESS] jpegoptim is available${NC}"
}

# Function to check if pngquant is installed
check_pngquant() {
    if ! command -v pngquant &> /dev/null; then
        log_message "${YELLOW}[WARNING] pngquant not found. Installing...${NC}"
        sudo apt install -y pngquant
    fi
    log_message "${GREEN}[SUCCESS] pngquant is available${NC}"
}

# Function to create directory structure
create_directories() {
    log_message "${BLUE}[INFO] Creating directory structure...${NC}"
    
    # Create main categories
    mkdir -p "$OPTIMIZED_DIR"/{hero,kitchens,countertops,cabinets,bathrooms,commercial,projects,materials}
    mkdir -p "$BACKUP_DIR"
    
    # Create subcategories
    mkdir -p "$OPTIMIZED_DIR/countertops"/{granite,quartz,marble,quartzite,porcelain}
    mkdir -p "$OPTIMIZED_DIR/cabinets"/{kitchen,bathroom,custom,commercial}
    mkdir -p "$OPTIMIZED_DIR/materials"/{stone-samples,wood-samples,hardware}
    
    log_message "${GREEN}[SUCCESS] Directory structure created${NC}"
}

# Function to backup original images
backup_images() {
    log_message "${BLUE}[INFO] Creating backup of original images...${NC}"
    
    if [ -d "$GALLERY_DIR" ] && [ "$(ls -A $GALLERY_DIR 2>/dev/null)" ]; then
        cp -r "$GALLERY_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true
        log_message "${GREEN}[SUCCESS] Backup created at $BACKUP_DIR${NC}"
    else
        log_message "${YELLOW}[WARNING] No images found to backup${NC}"
    fi
}

# Function to optimize JPEG images - HIGH QUALITY
optimize_jpeg() {
    local input_file="$1"
    local output_file="$2"
    local category="$3"

    # Determine quality and size based on category
    local quality=95
    local max_size="2560x1440"

    case "$category" in
        "hero")
            quality=98
            max_size="2560x1440"  # Full HD+ for hero images
            ;;
        "kitchens"|"countertops"|"cabinets")
            quality=95
            max_size="2048x1536"  # High quality for main gallery
            ;;
        "materials"|"projects")
            quality=92
            max_size="1600x1200"  # Good quality for detail shots
            ;;
        *)
            quality=90
            max_size="1920x1080"  # Standard high quality
            ;;
    esac

    # High-quality optimization with proper sharpening
    convert "$input_file" \
        -resize "${max_size}>" \
        -quality "$quality" \
        -sampling-factor 4:2:0 \
        -strip \
        -interlace Plane \
        -colorspace sRGB \
        -unsharp 0x0.75+0.75+0.008 \
        "$output_file"

    # Light optimization while preserving quality
    jpegoptim --max="$quality" --strip-all "$output_file" >/dev/null 2>&1
}

# Function to optimize PNG images - HIGH QUALITY
optimize_png() {
    local input_file="$1"
    local output_file="$2"
    local category="$3"

    # Determine size based on category
    local max_size="2560x1440"

    case "$category" in
        "hero")
            max_size="2560x1440"
            ;;
        "kitchens"|"countertops"|"cabinets")
            max_size="2048x1536"
            ;;
        "materials"|"projects")
            max_size="1600x1200"
            ;;
        *)
            max_size="1920x1080"
            ;;
    esac

    # High-quality PNG optimization
    convert "$input_file" \
        -resize "${max_size}>" \
        -strip \
        -colorspace sRGB \
        "$output_file"

    # Conservative PNG optimization (maintain quality)
    pngquant --quality=85-98 --ext .png --force "$output_file" >/dev/null 2>&1 || true
}

# Function to categorize images based on filename
categorize_image() {
    local filename="$1"
    local lowercase_name=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    
    # Hero/Main images
    if [[ $lowercase_name =~ (hero|main|banner|slide) ]]; then
        echo "hero"
    # Kitchen images
    elif [[ $lowercase_name =~ (kitchen|cook) ]]; then
        echo "kitchens"
    # Countertop images
    elif [[ $lowercase_name =~ (counter|granite|quartz|marble|quartzite|porcelain) ]]; then
        if [[ $lowercase_name =~ granite ]]; then
            echo "countertops/granite"
        elif [[ $lowercase_name =~ quartz ]]; then
            echo "countertops/quartz"
        elif [[ $lowercase_name =~ marble ]]; then
            echo "countertops/marble"
        elif [[ $lowercase_name =~ quartzite ]]; then
            echo "countertops/quartzite"
        elif [[ $lowercase_name =~ porcelain ]]; then
            echo "countertops/porcelain"
        else
            echo "countertops"
        fi
    # Cabinet images
    elif [[ $lowercase_name =~ (cabinet|cupboard|vanity) ]]; then
        if [[ $lowercase_name =~ bathroom ]]; then
            echo "cabinets/bathroom"
        elif [[ $lowercase_name =~ commercial ]]; then
            echo "cabinets/commercial"
        else
            echo "cabinets/kitchen"
        fi
    # Bathroom images
    elif [[ $lowercase_name =~ (bathroom|bath|shower|vanity) ]]; then
        echo "bathrooms"
    # Commercial images
    elif [[ $lowercase_name =~ (commercial|restaurant|office|business) ]]; then
        echo "commercial"
    # Material samples
    elif [[ $lowercase_name =~ (sample|material|wood|stone) ]]; then
        if [[ $lowercase_name =~ wood ]]; then
            echo "materials/wood-samples"
        elif [[ $lowercase_name =~ stone ]]; then
            echo "materials/stone-samples"
        else
            echo "materials"
        fi
    # Default to projects
    else
        echo "projects"
    fi
}

# Function to process all images
process_images() {
    log_message "${BLUE}[INFO] Processing and optimizing images...${NC}"
    
    local total_images=0
    local processed_images=0
    local total_size_before=0
    local total_size_after=0
    
    # Count total images
    total_images=$(find "$GALLERY_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) ! -path "*/optimized/*" ! -path "*/backup/*" | wc -l)
    
    if [ "$total_images" -eq 0 ]; then
        log_message "${YELLOW}[WARNING] No images found to process${NC}"
        return
    fi
    
    log_message "${BLUE}[INFO] Found $total_images images to process (targeting high-quality web optimization)${NC}"

    # Process each image with progress tracking
    local current_image=0
    find "$GALLERY_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) ! -path "*/optimized/*" ! -path "*/backup/*" | while read -r image_path; do
        current_image=$((current_image + 1))
        local filename=$(basename "$image_path")
        local extension="${filename##*.}"
        local name_without_ext="${filename%.*}"
        
        # Get file size before optimization
        local size_before=$(stat -f%z "$image_path" 2>/dev/null || stat -c%s "$image_path" 2>/dev/null || echo "0")
        total_size_before=$((total_size_before + size_before))
        
        # Categorize the image
        local category=$(categorize_image "$filename")
        local output_dir="$OPTIMIZED_DIR/$category"
        mkdir -p "$output_dir"
        
        # Generate output filename
        local output_file="$output_dir/$filename"
        
        # Skip if already processed
        if [ -f "$output_file" ]; then
            log_message "${YELLOW}[SKIP] $filename already optimized${NC}"
            continue
        fi
        
        log_message "${BLUE}[PROCESSING $current_image/$total_images] $filename -> $category/ ($(echo "scale=1; $current_image * 100 / $total_images" | bc 2>/dev/null || echo "0")%)${NC}"
        
        # Optimize based on file type with category-specific settings
        if [[ "$extension" =~ ^(jpg|jpeg|JPG|JPEG)$ ]]; then
            optimize_jpeg "$image_path" "$output_file" "$category"
        elif [[ "$extension" =~ ^(png|PNG)$ ]]; then
            optimize_png "$image_path" "$output_file" "$category"
        else
            log_message "${YELLOW}[SKIP] Unsupported format: $filename${NC}"
            continue
        fi
        
        # Get file size after optimization
        local size_after=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "0")
        total_size_after=$((total_size_after + size_after))
        
        # Calculate compression ratio
        local compression_ratio=0
        if [ "$size_before" -gt 0 ]; then
            compression_ratio=$(echo "scale=1; (($size_before - $size_after) * 100) / $size_before" | bc 2>/dev/null || echo "0")
        fi
        
        log_message "${GREEN}[SUCCESS] $filename optimized (${compression_ratio}% reduction)${NC}"
        processed_images=$((processed_images + 1))
    done
    
    log_message "${GREEN}[COMPLETE] Processed $processed_images images${NC}"
}

# Function to create image catalog
create_catalog() {
    log_message "${BLUE}[INFO] Creating image catalog...${NC}"

    local catalog_file="$OPTIMIZED_DIR/image-catalog.json"
    local catalog_html="$OPTIMIZED_DIR/catalog.html"

    # Create JSON catalog
    echo "{" > "$catalog_file"
    echo '  "gallery": {' >> "$catalog_file"
    echo '    "generated": "'$(date -Iseconds)'",' >> "$catalog_file"
    echo '    "total_images": 0,' >> "$catalog_file"
    echo '    "categories": {' >> "$catalog_file"

    local first_category=true
    for category_dir in "$OPTIMIZED_DIR"/*; do
        if [ -d "$category_dir" ] && [ "$(basename "$category_dir")" != "backup" ]; then
            local category_name=$(basename "$category_dir")
            local image_count=$(find "$category_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | wc -l)

            if [ "$image_count" -gt 0 ]; then
                if [ "$first_category" = false ]; then
                    echo ',' >> "$catalog_file"
                fi
                echo "      \"$category_name\": {" >> "$catalog_file"
                echo "        \"count\": $image_count," >> "$catalog_file"
                echo '        "images": [' >> "$catalog_file"

                local first_image=true
                find "$category_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r image_path; do
                    local filename=$(basename "$image_path")
                    local size=$(stat -f%z "$image_path" 2>/dev/null || stat -c%s "$image_path" 2>/dev/null || echo "0")
                    local dimensions=$(identify -format "%wx%h" "$image_path" 2>/dev/null || echo "unknown")

                    if [ "$first_image" = false ]; then
                        echo ',' >> "$catalog_file"
                    fi
                    echo "          {" >> "$catalog_file"
                    echo "            \"filename\": \"$filename\"," >> "$catalog_file"
                    echo "            \"size\": $size," >> "$catalog_file"
                    echo "            \"dimensions\": \"$dimensions\"" >> "$catalog_file"
                    echo -n "          }" >> "$catalog_file"
                    first_image=false
                done

                echo '' >> "$catalog_file"
                echo '        ]' >> "$catalog_file"
                echo -n "      }" >> "$catalog_file"
                first_category=false
            fi
        fi
    done

    echo '' >> "$catalog_file"
    echo '    }' >> "$catalog_file"
    echo '  }' >> "$catalog_file"
    echo '}' >> "$catalog_file"

    # Create HTML catalog for easy viewing
    cat > "$catalog_html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LZ Custom - Image Gallery Catalog</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
        .header { text-align: center; margin-bottom: 30px; }
        .category { margin-bottom: 30px; border: 1px solid #ddd; border-radius: 8px; overflow: hidden; }
        .category-header { background: #2c3e50; color: white; padding: 15px; font-size: 1.2em; font-weight: bold; }
        .images-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 15px; padding: 15px; }
        .image-item { border: 1px solid #eee; border-radius: 5px; overflow: hidden; }
        .image-item img { width: 100%; height: 150px; object-fit: cover; }
        .image-info { padding: 10px; font-size: 0.9em; }
        .stats { background: #3498db; color: white; padding: 15px; text-align: center; margin-bottom: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>LZ Custom - Image Gallery Catalog</h1>
            <p>Generated on: <span id="generated-date"></span></p>
        </div>

        <div class="stats">
            <h3>Gallery Statistics</h3>
            <p>Total Categories: <span id="total-categories">0</span> | Total Images: <span id="total-images">0</span></p>
        </div>

        <div id="gallery-content">
            <!-- Content will be populated by JavaScript -->
        </div>
    </div>

    <script>
        // This will be populated with the actual catalog data
        // For now, it's a template
        document.getElementById('generated-date').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

    log_message "${GREEN}[SUCCESS] Image catalog created${NC}"
    log_message "${BLUE}[INFO] Catalog files: $catalog_file, $catalog_html${NC}"
}

# Function to create deployment package
create_package() {
    log_message "${BLUE}[INFO] Creating deployment package...${NC}"

    local package_name="lz-custom-gallery-$(date +%Y%m%d-%H%M%S).tar.gz"
    local package_path="$GALLERY_DIR/$package_name"

    # Create compressed package
    cd "$OPTIMIZED_DIR"
    tar -czf "$package_path" .

    local package_size=$(stat -f%z "$package_path" 2>/dev/null || stat -c%s "$package_path" 2>/dev/null || echo "0")
    local package_size_mb=$(echo "scale=2; $package_size / 1024 / 1024" | bc 2>/dev/null || echo "0")

    log_message "${GREEN}[SUCCESS] Package created: $package_name (${package_size_mb}MB)${NC}"
    log_message "${BLUE}[INFO] Package location: $package_path${NC}"

    # Create deployment instructions
    cat > "$GALLERY_DIR/DEPLOYMENT-INSTRUCTIONS.md" << EOF
# LZ Custom Gallery Deployment Instructions

## Package Information
- **Package**: $package_name
- **Size**: ${package_size_mb}MB
- **Created**: $(date)

## VPS Deployment Steps

### 1. Upload Package to VPS
\`\`\`bash
scp $package_name shepov@104.237.9.52:~/
\`\`\`

### 2. Extract on VPS
\`\`\`bash
ssh shepov@104.237.9.52
cd ~/LZCustom/frontend/public/assets/
rm -rf gallery  # Remove old gallery
mkdir gallery
cd gallery
tar -xzf ~//$package_name
\`\`\`

### 3. Set Permissions
\`\`\`bash
chmod -R 755 ~/LZCustom/frontend/public/assets/gallery/
\`\`\`

### 4. Restart Frontend
\`\`\`bash
cd ~/LZCustom/frontend
npm run dev -- --host 0.0.0.0
\`\`\`

## Gallery Structure
$(find "$OPTIMIZED_DIR" -type d | sed 's|'$OPTIMIZED_DIR'||' | sed 's|^/||' | sort)

## Total Images: $(find "$OPTIMIZED_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | wc -l)
EOF

    log_message "${GREEN}[SUCCESS] Deployment instructions created${NC}"
}

# Main execution
main() {
    log_message "${BLUE}[START] Image optimization started${NC}"

    # Check dependencies
    check_imagemagick
    check_jpegoptim
    check_pngquant

    # Create directories
    create_directories

    # Backup original images
    backup_images

    # Process and optimize images
    process_images

    # Create catalog
    create_catalog

    # Create deployment package
    create_package

    log_message "${GREEN}[COMPLETE] Image optimization completed${NC}"
    log_message "${BLUE}[INFO] Check $LOG_FILE for detailed logs${NC}"
    log_message "${YELLOW}[NEXT] Review DEPLOYMENT-INSTRUCTIONS.md for VPS deployment steps${NC}"
}

# Run main function
main "$@"
