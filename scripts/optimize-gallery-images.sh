#!/bin/bash

# Gallery Image Optimization Script
# Optimizes all images in the gallery directory for web use

echo "🎨 Starting Gallery Image Optimization..."

GALLERY_DIR="/home/shepov/Documents/Source/LZCustom/frontend/public/assets/gallery"
TEMP_DIR="/tmp/gallery_optimization"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Function to optimize images
optimize_image() {
    local input="$1"
    local output="$2"
    local width="$3"
    local height="$4"
    local quality="$5"
    
    echo "  Processing: $(basename "$input")"
    
    if command -v convert >/dev/null 2>&1; then
        # Using ImageMagick - resize and optimize
        convert "$input" \
            -resize "${width}x${height}^" \
            -gravity center \
            -extent "${width}x${height}" \
            -quality "$quality" \
            -strip \
            -interlace Plane \
            "$output"
    elif command -v ffmpeg >/dev/null 2>&1; then
        # Using FFmpeg as fallback
        ffmpeg -i "$input" \
            -vf "scale=${width}:${height}:force_original_aspect_ratio=decrease,pad=${width}:${height}:(ow-iw)/2:(oh-ih)/2" \
            -q:v "$quality" \
            "$output" -y
    else
        echo "  ⚠️  No optimization tools found, copying original"
        cp "$input" "$output"
    fi
}

# Create optimized directory structure
mkdir -p "$GALLERY_DIR/hero"
mkdir -p "$GALLERY_DIR/projects"
mkdir -p "$GALLERY_DIR/icons/services"
mkdir -p "$GALLERY_DIR/workshop"
mkdir -p "$GALLERY_DIR/textures"

echo "📸 Optimizing Hero Images (1200x675 - 16:9 ratio)..."
hero_count=0
find "$GALLERY_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read img; do
    if [ $hero_count -lt 5 ]; then
        output_name="hero-$(($hero_count + 1)).jpg"
        optimize_image "$img" "$GALLERY_DIR/hero/$output_name" 1200 675 85
        hero_count=$((hero_count + 1))
    fi
done

echo "🏠 Optimizing Project Gallery Images (800x600 - 4:3 ratio)..."
project_count=0
find "$GALLERY_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read img; do
    if [ $project_count -lt 12 ]; then
        output_name="project-$(($project_count + 1)).jpg"
        optimize_image "$img" "$GALLERY_DIR/projects/$output_name" 800 600 80
        project_count=$((project_count + 1))
    fi
done

echo "🔧 Optimizing Service Icons (400x400 - 1:1 ratio)..."
icon_count=0
find "$GALLERY_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read img; do
    if [ $icon_count -lt 6 ]; then
        output_name="service-$(($icon_count + 1)).jpg"
        optimize_image "$img" "$GALLERY_DIR/icons/services/$output_name" 400 400 75
        icon_count=$((icon_count + 1))
    fi
done

echo "🏭 Optimizing Workshop Images (1000x750)..."
workshop_count=0
find "$GALLERY_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read img; do
    if [ $workshop_count -lt 4 ]; then
        output_name="workshop-$(($workshop_count + 1)).jpg"
        optimize_image "$img" "$GALLERY_DIR/workshop/$output_name" 1000 750 80
        workshop_count=$((workshop_count + 1))
    fi
done

echo "🎨 Optimizing Texture Images (800x600)..."
texture_count=0
find "$GALLERY_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read img; do
    if [ $texture_count -lt 3 ]; then
        output_name="texture-$(($texture_count + 1)).jpg"
        optimize_image "$img" "$GALLERY_DIR/textures/$output_name" 800 600 70
        texture_count=$((texture_count + 1))
    fi
done

echo "✅ Optimization Complete!"
echo "📊 Summary:"
echo "   - Hero images: gallery/hero/"
echo "   - Project images: gallery/projects/"
echo "   - Service icons: gallery/icons/services/"
echo "   - Workshop images: gallery/workshop/"
echo "   - Texture images: gallery/textures/"

# Display optimized file sizes
echo "📏 Optimized file sizes:"
find "$GALLERY_DIR/hero" "$GALLERY_DIR/projects" "$GALLERY_DIR/icons" "$GALLERY_DIR/workshop" "$GALLERY_DIR/textures" -name "*.jpg" 2>/dev/null | while read file; do
    if [ -f "$file" ]; then
        size=$(ls -lh "$file" | awk '{print $5}')
        echo "   $(basename "$file"): $size"
    fi
done

echo "🎉 Images ready for web deployment!"
