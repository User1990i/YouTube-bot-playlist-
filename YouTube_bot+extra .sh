#!/bin/bash

# YouTube Downloader Bot - Version 1.8
script_version="1.8"

# Define output directories (No spaces in paths)
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
channel_dir="$base_dir/Channels"
mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"  # Create necessary directories

# Function to sanitize folder names
sanitize_folder_name() {
    local input="$1"
    local sanitized=$(echo "$input" | tr -cd '[:alnum:][:space:]._-' | sed 's/[[:space:]]\+/_/g')
    sanitized=$(echo "$sanitized" | tr -d '\n\r')
    echo "${sanitized^}"
}

# Color Scheme for YouTube Red and White
RED='\033[0;31m'
WHITE='\033[1;37m'
BLUE='\033[0;34m'  # Blue color for sizes
NC='\033[0m'  # No color

# Show banner with ASCII art
show_banner() {
    clear
    echo -e "${RED}"
    # ASCII art here
    echo -e "${RED}==========================================="
    echo -e "          YouTube BOT         "
    echo -e "          Version 1.8         "
    echo -e "==========================================="
}

# Show banner before starting
show_banner

# Display script version
echo -e "${RED}YouTube Downloader Bot - Version $script_version${NC}"
echo "Choose an option:"
echo -e "${WHITE}1. Download Audio (choose format)${NC}"
echo -e "${WHITE}2. Download Video (choose quality & format)${NC}"
echo -e "${WHITE}3. Download Playlist (Audio or Video)${NC}"
echo -e "${WHITE}4. Download YouTube Channel Content${NC}"
read -p "Enter your choice (1, 2, 3, or 4): " choice

# Function to show format options and sizes
show_format_options() {
    local link="$1"
    echo -e "${BLUE}Fetching available formats and their sizes...${NC}"
    yt-dlp -F "$link" | awk '{print $1, $2, $3, $4}' | sed '1d'  # Show formats and their sizes
}

if [[ $choice == "1" ]]; then
    echo -e "${RED}Downloading Audio.${NC}"
    echo "Paste a YouTube link."
    read -p "> " link

    if [[ $link == *"youtube.com"* ]]; then
        show_format_options "$link"
        echo -e "${WHITE}Choose your audio format based on the size you prefer.${NC}"
        read -p "Enter your audio format ID (from the list above): " format_id

        echo -e "${RED}Downloading audio...${NC}"
        yt-dlp -f "$format_id" -o "$audio_dir/%(title)s.%(ext)s" "$link"
    else
        echo -e "${RED}Invalid YouTube link.${NC}"
    fi

elif [[ $choice == "2" ]]; then
    echo -e "${RED}Downloading Video.${NC}"
    echo "Paste a YouTube link."
    read -p "> " link

    if [[ $link == *"youtube.com"* ]]; then
        show_format_options "$link"
        echo -e "${WHITE}Choose your video format based on the size you prefer.${NC}"
        read -p "Enter your video format ID (from the list above): " format_id

        echo -e "${RED}Downloading video...${NC}"
        yt-dlp -f "$format_id" -o "$video_dir/%(title)s.%(ext)s" "$link"
    else
        echo -e "${RED}Invalid YouTube link.${NC}"
    fi

elif [[ $choice == "3" ]]; then
    echo -e "${RED}Downloading Playlist.${NC}"
    echo "Would you like to download Audio or Video?"
    echo -e "${WHITE}1. Audio${NC}"
    echo -e "${WHITE}2. Video${NC}"
    read -p "Enter your choice (1 or 2): " playlist_choice
    echo "Paste the Playlist URL."
    read -p "> " playlist_link

    if [[ $playlist_link == *"youtube.com"* ]]; then
        if [[ $playlist_choice == "1" ]]; then
            show_format_options "$playlist_link"
            echo -e "${WHITE}Choose your audio format based on the size you prefer.${NC}"
            read -p "Enter your audio format ID (from the list above): " format_id
            yt-dlp -f "$format_id" -o "$playlist_dir/%(playlist)s/%(title)s.%(ext)s" "$playlist_link"
        elif [[ $playlist_choice == "2" ]]; then
            show_format_options "$playlist_link"
            echo -e "${WHITE}Choose your video format based on the size you prefer.${NC}"
            read -p "Enter your video format ID (from the list above): " format_id
            yt-dlp -f "$format_id" -o "$playlist_dir/%(playlist)s/%(title)s.%(ext)s" "$playlist_link"
        else
            echo -e "${RED}Invalid choice.${NC}"
        fi
    else
        echo -e "${RED}Invalid Playlist URL.${NC}"
    fi

elif [[ $choice == "4" ]]; then
    echo -e "${RED}Downloading Channel Content.${NC}"
    echo "Paste the Channel URL."
    read -p "> " channel_link

    if [[ $channel_link == *"youtube.com"* ]]; then
        show_format_options "$channel_link"
        echo -e "${WHITE}Choose your format based on the size you prefer.${NC}"
        read -p "Enter your format ID (from the list above): " format_id
        yt-dlp -f "$format_id" -o "$channel_dir/%(uploader)s/%(title)s.%(ext)s" "$channel_link"
    else
        echo -e "${RED}Invalid Channel URL.${NC}"
    fi

else
    echo -e "${RED}Invalid choice. Restart the bot.${NC}"
fi
