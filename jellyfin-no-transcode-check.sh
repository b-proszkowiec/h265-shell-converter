#!/bin/bash

# Script to check video file compatibility with Jellyfin
# Usage: ./jellyfin_check.sh <file_path>

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_dependencies() {
    if ! command -v ffprobe &> /dev/null; then
        echo -e "${RED}Error: ffprobe is not installed. Please install ffmpeg.${NC}"
        exit 1
    fi
}

analyze_file() {
    local file="$1"
    
    echo -e "${YELLOW}Analyzing file: $file${NC}"
    echo "=========================================="
    
    # Basic container information
    local format=$(ffprobe -v quiet -select_streams v:0 -show_entries format=format_name -of default=noprint_wrappers=1:nokey=1 "$file")
    echo -e "Container: ${GREEN}$format${NC}"
    
    # Check video codec
    local video_codec=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=codec_name,profile,width,height -of csv=p=0 "$file")
    IFS=',' read -r vcodec vprofile vwidth vheight <<< "$video_codec"
    
    echo -e "Video codec: $vcodec (profile: $vprofile, resolution: ${vwidth}x${vheight})"
    
    if [[ "$vcodec" == "h264" ]]; then
        echo -e "${GREEN}✓ H.264 video codec - GOOD${NC}"
    elif [[ "$vcodec" == "hevc" ]]; then
        echo -e "${YELLOW}⚠ HEVC codec - may require transcoding on older devices${NC}"
    else
        echo -e "${RED}✗ $vcodec codec - will likely require transcoding${NC}"
    fi
    
    # Check audio tracks
    echo ""
    echo "Audio tracks:"
    ffprobe -v quiet -select_streams a -show_entries stream=codec_name,channels,bit_rate -of csv=p=0 "$file" | while IFS= read -r line; do
        IFS=',' read -r acodec channels bitrate <<< "$line"
        if [[ "$acodec" == "aac" ]]; then
            echo -e "  ${GREEN}✓ AAC ($channels channels)${NC}"
        elif [[ "$acodec" == "ac3" ]]; then
            echo -e "  ${YELLOW}⚠ AC3 ($channels channels) - check compatibility${NC}"
        else
            echo -e "  ${RED}✗ $acodec ($channels channels) - may require transcoding${NC}"
        fi
    done
    
    # Check subtitles
    echo ""
    echo "Subtitles:"
    ffprobe -v quiet -select_streams s -show_entries stream=codec_name -of csv=p=0 "$file" 2>/dev/null | while IFS= read -r line; do
        if [[ "$line" == "ass" || "$line" == "hdmv_pgs_subtitle" ]]; then
            echo -e "  ${RED}✗ $line - image-based subtitles, require transcoding${NC}"
        elif [[ "$line" == "subrip" ]]; then
            echo -e "  ${GREEN}✓ SRT - text-based, good compatibility${NC}"
        else
            echo -e "  ${YELLOW}⚠ $line - check compatibility${NC}"
        fi
    done
    
    echo ""
    echo "=========================================="
    echo -e "${YELLOW}JELLYFIN COMPATIBILITY ASSESSMENT:${NC}"
    
    if [[ "$vcodec" == "h264" ]] && [[ "$format" == *"mp4"* ]]; then
        echo -e "${GREEN}✓ HIGH COMPATIBILITY${NC}"
        echo "File should work without transcoding on most devices"
    elif [[ "$vcodec" == "hevc" ]]; then
        echo -e "${YELLOW}⚠ MEDIUM COMPATIBILITY${NC}"
        echo "HEVC requires newer devices. Older devices may need transcoding"
    else
        echo -e "${RED}✗ LOW COMPATIBILITY${NC}"
        echo "File will likely require transcoding"
    fi
}


main() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <file_path>"
        echo "You can also use: $0 *.mkv (for multiple files)"
        exit 1
    fi
    
    check_dependencies
    
    for file in "$@"; do
        if [ ! -f "$file" ]; then
            echo -e "${RED}Error: File '$file' does not exist${NC}"
            continue
        fi
        
        analyze_file "$file"
        echo ""
        echo "================================"
        echo ""
    done
}


main "$@"
