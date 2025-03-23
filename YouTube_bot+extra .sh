#!/bin/bash

# YouTube Downloader Bot - Version 1.7
script_version="1.7"

# Define output directories
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
channel_dir="$base_dir/Channels"
mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"

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
NC='\033[0m'

# Show banner with ASCII art
show_banner() {
    clear
    echo -e "${RED}"
    echo -e "==========================================="
    echo -e "          YouTube BOT         "
    echo -e "          Version 1.7         "
    echo -e "==========================================="
}

# Function to update the bot automatically
update_bot() {
    echo -e "${RED}Checking for updates...${NC}"
    curl -o ~/youtube_bot.sh "https://raw.githubusercontent.com/User1990i/YouTube-bot-playlist-/refs/heads/main/YouTube_bot%2Bextra%20.sh" && chmod +x ~/youtube_bot.sh
    echo -e "${RED}Bot updated. Restarting...${NC}"
    bash ~/youtube_bot.sh
    exit 0
}

# Show banner before starting
show_banner

# Display script version
echo -e "${RED}YouTube Downloader Bot - Version $script_version${NC}"
echo "Choose an option:"
echo -e "${WHITE}1. Download Audio (M4A, MP3, FLAC)${NC}"
echo -e "${WHITE}2. Download Video (choose quality)${NC}"
echo -e "${WHITE}3. Download Playlist (Audio or Video)${NC}"
echo -e "${WHITE}4. Download YouTube Channel Content${NC}"
echo -e "${WHITE}5. Check for Updates${NC}"
read -p "Enter your choice (1, 2, 3, 4, or 5): " choice

# Auto-update option (Choice 5)
if [[ $choice == "5" ]]; then
    update_bot

# Handle Audio Download (Choice 1)
elif [[ $choice == "1" ]]; then
    echo -e "${RED}Download Audio${NC}"
    echo -e "${WHITE}Select the audio format:${NC}"
    echo -e "${WHITE}1. M4A${NC}"
    echo -e "${WHITE}2. MP3${NC}"
    echo -e "${WHITE}3. FLAC${NC}"
    read -p "Enter your choice (1, 2, or 3): " audio_format

    echo "Paste the YouTube link for audio download:"
    read -p "> " audio_link

    # Check if it's a valid YouTube link
    if [[ "$audio_link" =~ ^https?://(www\.)?youtube\.com/ ]]; then
        echo "Fetching audio..."

        case $audio_format in
            1)
                # Download audio in M4A format
                yt-dlp -x --audio-format m4a -o "$audio_dir/%(title)s.%(ext)s" "$audio_link"
                ;;
            2)
                # Download audio in MP3 format
                yt-dlp -x --audio-format mp3 -o "$audio_dir/%(title)s.%(ext)s" "$audio_link"
                ;;
            3)
                # Download audio in FLAC format
                yt-dlp -x --audio-format flac -o "$audio_dir/%(title)s.%(ext)s" "$audio_link"
                ;;
            *)
                echo -e "${RED}Invalid choice.${NC}"
                ;;
        esac
    else
        echo -e "${RED}Invalid YouTube link. Please provide a valid YouTube URL.${NC}"
    fi

# Handle Video Download (Choice 2)
elif [[ $choice == "2" ]]; then
    echo -e "${RED}Download Video${NC}"
    echo -e "${WHITE}Select the video format:${NC}"
    echo -e "${WHITE}1. MP4${NC}"
    echo -e "${WHITE}2. WEBM${NC}"
    echo -e "${WHITE}3. MKV${NC}"
    read -p "Enter your choice (1, 2, or 3): " video_format

    echo "Paste the YouTube link for video download:"
    read -p "> " video_link

    # Check if it's a valid YouTube link
    if [[ "$video_link" =~ ^https?://(www\.)?youtube\.com/ ]]; then
        echo "Fetching video..."

        case $video_format in
            1)
                # Download video in MP4 format
                yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "$video_link"
                ;;
            2)
                # Download video in WEBM format
                yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format webm -o "$video_dir/%(title)s.%(ext)s" "$video_link"
                ;;
            3)
                # Download video in MKV format
                yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mkv -o "$video_dir/%(title)s.%(ext)s" "$video_link"
                ;;
            *)
                echo -e "${RED}Invalid choice.${NC}"
                ;;
        esac
    else
        echo -e "${RED}Invalid YouTube link. Please provide a valid YouTube URL.${NC}"
    fi

# Handle Playlist Download (Choice 3)
elif [[ $choice == "3" ]]; then
    echo -e "${RED}Downloading a playlist.${NC}"
    # Additional code for downloading playlist
else
    echo -e "${RED}Invalid choice. Restart the bot.${NC}"
fi
