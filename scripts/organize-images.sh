#!/bin/bash

# LZ Custom Image Organization and Optimization Script
# This script will rename, organize, and compress the Midjourney images

echo "🎨 LZ Custom Image Organization Starting..."

# Create organized directory structure
mkdir -p gallery/hero
mkdir -p gallery/projects
mkdir -p icons/services
mkdir -p textures
mkdir -p workshop

# Function to compress and convert images
compress_image() {
    local input="$1"
    local output="$2"
    local quality="$3"
    
    if command -v convert >/dev/null 2>&1; then
        # Using ImageMagick
        convert "$input" -quality "$quality" -strip -resize 1200x800\> "$output"
    elif command -v ffmpeg >/dev/null 2>&1; then
        # Using FFmpeg as fallback
        ffmpeg -i "$input" -q:v "$quality" -vf "scale=1200:800:force_original_aspect_ratio=decrease" "$output" -y
    else
        # Just copy if no compression tools available
        cp "$input" "$output"
    fi
}

# Hero Background Images (16:9 ratio)
echo "📸 Processing Hero Images..."

# Main hero background
if [ -f "gallery/u6358423361_Professional_stone_fabrication_workshop_with_gran_ae924d45-f47d-4fc7-94b8-eb24de635d3e_3.png" ]; then
    compress_image "gallery/u6358423361_Professional_stone_fabrication_workshop_with_gran_ae924d45-f47d-4fc7-94b8-eb24de635d3e_3.png" "gallery/hero/hero-main.jpg" 85
fi

# Alternative hero backgrounds
if [ -f "gallery/u6358423361_Elegant_kitchen_showroom_with_custom_cabinets_and_ae5d1636-40d4-4b6e-a03a-86b615e647fc_0.png" ]; then
    compress_image "gallery/u6358423361_Elegant_kitchen_showroom_with_custom_cabinets_and_ae5d1636-40d4-4b6e-a03a-86b615e647fc_0.png" "gallery/hero/hero-showroom.jpg" 85
fi

if [ -f "gallery/u6358423361_Stone_fabrication_facility_with_multiple_granite__8e5f3a86-1923-43e0-803c-b65cad517253_0.png" ]; then
    compress_image "gallery/u6358423361_Stone_fabrication_facility_with_multiple_granite__8e5f3a86-1923-43e0-803c-b65cad517253_0.png" "gallery/hero/hero-facility.jpg" 85
fi

# Gallery Project Images (4:3 ratio)
echo "🏠 Processing Gallery Images..."

# Kitchen with granite countertops
if [ -f "gallery/u6358423361_Luxury_modern_kitchen_with_beautiful_granite_coun_07a300a5-aa75-4625-8165-3dcb4fe28efa_0.png" ]; then
    compress_image "gallery/u6358423361_Luxury_modern_kitchen_with_beautiful_granite_coun_07a300a5-aa75-4625-8165-3dcb4fe28efa_0.png" "gallery/projects/kitchen-granite-1.jpg" 80
fi

# Custom oak cabinets
if [ -f "gallery/u6358423361_andcrafted_oak_kitchen_cabinets_with_soft-close_h_f3935a67-2994-44ce-b732-c95ad7de892f_1.png" ]; then
    compress_image "gallery/u6358423361_andcrafted_oak_kitchen_cabinets_with_soft-close_h_f3935a67-2994-44ce-b732-c95ad7de892f_1.png" "gallery/projects/custom-cabinets-1.jpg" 80
fi

# Marble bathroom
if [ -f "gallery/u6358423361_Elegant_marble_bathroom_vanity_top_and_shower_sur_35164169-f227-4bc5-b255-d3b845104eb3_0.png" ]; then
    compress_image "gallery/u6358423361_Elegant_marble_bathroom_vanity_top_and_shower_sur_35164169-f227-4bc5-b255-d3b845104eb3_0.png" "gallery/projects/bathroom-marble-1.jpg" 80
fi

# Commercial laminate
if [ -f "gallery/u6358423361_Modern_commercial_office_space_with_durable_lamin_6e25e604-46fe-49e7-816f-423717499296_0.png" ]; then
    compress_image "gallery/u6358423361_Modern_commercial_office_space_with_durable_lamin_6e25e604-46fe-49e7-816f-423717499296_0.png" "gallery/projects/commercial-laminate-1.jpg" 80
fi

# Tile flooring
if [ -f "gallery/u6358423361_Intricate_geometric_tile_pattern_flooring_expert__bec8e5ac-8a9c-4831-8c48-d865023de519_0.png" ]; then
    compress_image "gallery/u6358423361_Intricate_geometric_tile_pattern_flooring_expert__bec8e5ac-8a9c-4831-8c48-d865023de519_0.png" "gallery/projects/tile-flooring-1.jpg" 80
fi

# Commercial painting
if [ -f "gallery/u6358423361_Professional_commercial_interior_painting_premium_fe294b7e-0227-404b-bed4-28fc32e6bb35_0.png" ]; then
    compress_image "gallery/u6358423361_Professional_commercial_interior_painting_premium_fe294b7e-0227-404b-bed4-28fc32e6bb35_0.png" "gallery/projects/commercial-painting-1.jpg" 80
fi

# Service Icons (1:1 ratio)
echo "🔧 Processing Service Icons..."

# Custom cabinets icon
if [ -f "gallery/u6358423361_Close-up_of_custom_cabinet_door_profile_rich_wood_1b57e59b-8f33-4d10-8a86-c98d5ddad455_0.png" ]; then
    compress_image "gallery/u6358423361_Close-up_of_custom_cabinet_door_profile_rich_wood_1b57e59b-8f33-4d10-8a86-c98d5ddad455_0.png" "icons/services/cabinets.jpg" 75
fi

# Countertops icon
if [ -f "gallery/u6358423361_Beautiful_granite_slab_edge_detail_polished_stone_9bc42d53-abae-4c53-bee6-3a1b16a30a08_0.png" ]; then
    compress_image "gallery/u6358423361_Beautiful_granite_slab_edge_detail_polished_stone_9bc42d53-abae-4c53-bee6-3a1b16a30a08_0.png" "icons/services/countertops.jpg" 75
fi

# Stone fabrication icon
if [ -f "gallery/u6358423361_CNC_stone_cutting_machine_in_action_precision_fab_ab6cd175-5d15-4e71-bf0b-8e7d076e0ee8_1.png" ]; then
    compress_image "gallery/u6358423361_CNC_stone_cutting_machine_in_action_precision_fab_ab6cd175-5d15-4e71-bf0b-8e7d076e0ee8_1.png" "icons/services/stone-fabrication.jpg" 75
fi

# Plastics & laminate icon
if [ -f "gallery/u6358423361_Modern_laminate_surface_texture_close-up_durable__bc6f64c7-f79e-48fb-8321-490da6cd4102_0.png" ]; then
    compress_image "gallery/u6358423361_Modern_laminate_surface_texture_close-up_durable__bc6f64c7-f79e-48fb-8321-490da6cd4102_0.png" "icons/services/plastics-laminate.jpg" 75
fi

# Tile & flooring icon
if [ -f "gallery/u6358423361_Detailed_tile_installation_process_precision_layi_7bf162e0-3734-4ecc-a9f8-ad63c54c5a4b_0.png" ]; then
    compress_image "gallery/u6358423361_Detailed_tile_installation_process_precision_layi_7bf162e0-3734-4ecc-a9f8-ad63c54c5a4b_0.png" "icons/services/tile-flooring.jpg" 75
fi

# Commercial painting icon
if [ -f "gallery/u6358423361_Professional_spray_gun_application_commercial_pai_cc478bd8-6472-431f-88db-a351feb655ac_1.png" ]; then
    compress_image "gallery/u6358423361_Professional_spray_gun_application_commercial_pai_cc478bd8-6472-431f-88db-a351feb655ac_1.png" "icons/services/commercial-painting.jpg" 75
fi

# Workshop/Process Images
echo "🏭 Processing Workshop Images..."

if [ -f "gallery/u6358423361_Professional_fabrication_workshop_organized_tools_0b9da7fe-81f6-4a14-be21-3774da70db7a_0.png" ]; then
    compress_image "gallery/u6358423361_Professional_fabrication_workshop_organized_tools_0b9da7fe-81f6-4a14-be21-3774da70db7a_0.png" "workshop/fabrication-workshop.jpg" 80
fi

if [ -f "gallery/u6358423361_Craftsman_measuring_granite_slab_with_precision_t_8bc71f32-8315-422f-8907-45f0c659a0d4_0.png" ]; then
    compress_image "gallery/u6358423361_Craftsman_measuring_granite_slab_with_precision_t_8bc71f32-8315-422f-8907-45f0c659a0d4_0.png" "workshop/precision-measurement.jpg" 80
fi

if [ -f "gallery/u6358423361_Professional_installation_team_installing_custom__5ff864f3-abb0-4f3c-b70c-711097d96e74_0.png" ]; then
    compress_image "gallery/u6358423361_Professional_installation_team_installing_custom__5ff864f3-abb0-4f3c-b70c-711097d96e74_0.png" "workshop/installation-process.jpg" 80
fi

# Texture/Background Elements
echo "🎨 Processing Textures..."

if [ -f "gallery/u6358423361_Subtle_wood_grain_texture_with_brushed_steel_over_bad835c2-f13f-4565-be4d-fb961df6ada1_0.png" ]; then
    compress_image "gallery/u6358423361_Subtle_wood_grain_texture_with_brushed_steel_over_bad835c2-f13f-4565-be4d-fb961df6ada1_0.png" "textures/wood-steel-texture.jpg" 70
fi

if [ -f "gallery/u6358423361_Geometric_pattern_inspired_by_tile_work_and_stone_88d6704b-af11-49ca-b397-f21e45ed8738_0.png" ]; then
    compress_image "gallery/u6358423361_Geometric_pattern_inspired_by_tile_work_and_stone_88d6704b-af11-49ca-b397-f21e45ed8738_0.png" "textures/geometric-pattern.jpg" 70
fi

# Material Showcase
echo "📋 Processing Material Samples..."

if [ -f "gallery/u6358423361_Collection_of_granite_slab_samples_natural_stone__668014ef-391a-49d5-90e0-b50532401f32_2.png" ]; then
    compress_image "gallery/u6358423361_Collection_of_granite_slab_samples_natural_stone__668014ef-391a-49d5-90e0-b50532401f32_2.png" "gallery/projects/granite-samples.jpg" 80
fi

if [ -f "gallery/u6358423361_Various_wood_species_samples_for_custom_cabinets__0ccfe8f4-934d-4f62-bf68-c4208c673a0e_0.png" ]; then
    compress_image "gallery/u6358423361_Various_wood_species_samples_for_custom_cabinets__0ccfe8f4-934d-4f62-bf68-c4208c673a0e_0.png" "gallery/projects/wood-samples.jpg" 80
fi

if [ -f "gallery/u6358423361_Modern_engineered_quartz_surfaces_consistent_patt_9bad55a7-8119-4466-b1b1-09e31a28fd21_2.png" ]; then
    compress_image "gallery/u6358423361_Modern_engineered_quartz_surfaces_consistent_patt_9bad55a7-8119-4466-b1b1-09e31a28fd21_2.png" "gallery/projects/engineered-stone.jpg" 80
fi

echo "✅ Image organization complete!"
echo "📊 Summary:"
echo "   - Hero backgrounds: gallery/hero/"
echo "   - Project gallery: gallery/projects/"
echo "   - Service icons: icons/services/"
echo "   - Workshop images: workshop/"
echo "   - Textures: textures/"

# Display file sizes
echo "📏 Optimized file sizes:"
find gallery/hero gallery/projects icons/services workshop textures -name "*.jpg" 2>/dev/null | while read file; do
    if [ -f "$file" ]; then
        size=$(ls -lh "$file" | awk '{print $5}')
        echo "   $file: $size"
    fi
done

echo "🎉 Ready for web deployment!"
