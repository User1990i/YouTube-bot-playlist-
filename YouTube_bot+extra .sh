#!/bin/bash

# YouTube Downloader Bot - Version 1.5
script_version="1.5"

# Define output directories (No spaces in paths)
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
channel_dir="$base_dir/Channels"
mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"  # Create necessary directories

# Color Scheme
RED='\033[0;31m'
WHITE='\033[1;37m'
BOLD_RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No color

# Function to sanitize folder names
sanitize_folder_name() {
    local input="$1"
    local sanitized=$(echo "$input" | tr -cd '[:alnum:][:space:]._-/' | sed 's/[[:space:]]\+/_/g')
    sanitized=$(echo "$sanitized" | tr -d '\n\r')
    echo "${sanitized^}"
}
# Show banner with ASCII art
show_banner() {
    clear
    echo -e "${BOLD_RED}"
    echo -e "⠐⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠂"
    echo -e "⠀⢹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡇⠀"
    echo -e "⠀⢸⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⣠⣿⡇⠀"
    echo -e "⠀⠸⣿⣿⣷⣦⣀⡴⢶⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣄⣴⣾⣿⣿⠇⠀"
    echo -e "⠀⠀⢻⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣇⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀"
    echo -e "⠀⠀⣠⣻⡿⠿⢿⣫⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⣻⣥⠀⠀"
    echo -e "⠀⠀⣿⣿⣿⣿⣿⣿⣿⡿⣟⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀"
    echo -e "⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⡹⡜⠋⡾⣼⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀"
    echo -e "⠀⠀⣿⣻⣾⣭⣝⣛⣛⣛⣛⣃⣿⣾⣇⣛⣛⣛⣛⣯⣭⣷⣿⣿⡇⠀"
    echo -e "⠀⠰⢿⣿⣎⠙⠛⢻⣿⡿⠿⠟⣿⣿⡟⠿⠿⣿⡛⠛⠋⢹⣿⡿⢳⠀"
    echo -e "⠀⠘⣦⡙⢿⣦⣀⠀⠀⠀⢀⣼⣿⣿⣳⣄⠀⠀⠀⢀⣠⡿⢛⣡⡏⠀"
    echo -e "⠀⠀⠹⣟⢿⣾⣿⣿⣿⣿⣿⣧⣿⣿⣧⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀"
    echo -e "⠀⠀⢰⣿⣣⣿⣭⢿⣿⣱⣶⣿⣿⣿⣿⣿⣿⣷⣶⢹⣿⣭⣻⣶⣿⣿⠀⠀"
    echo -e "⠀⠀⠈⣿⢿⣿⣿⠏⣿⣾⣛⠿⣿⣿⣿⠟⣻⣾⡏⢿⣿⣯⡿⡏⠀⠀"
    echo -e "⠀⠀⠤⠾⣟⣿⡁⠘⢨⣟⢻⡿⠾⠿⠾⢿⡛⣯⠘⠀⣸⣽⡛⠲⠄⠀"
    echo -e "⠀⠀⠀⠀⠘⣿⣧⠀⠸⠃⠈⠙⠛⠛⠉⠈⠁⠹⠀⠀⣿⡟⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⢻⣿⣶⣀⣠⠀⠀⠀⠀⠀⠀⢠⡄⡄⣦⣿⠃⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠘⣿⣷⣻⣿⢷⢶⢶⢶⢆⣗⡿⣇⣷⣿⡿⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣛⣭⣭⣭⣭⣭⣻⣿⡿⠛⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⠟⠛⠛⠛⠻⠿⠟⠀⠀⠀⠀⠀⠀⠀⠀"
    echo -e "${BOLD_RED}==========================================="
    echo -e "          YouTube BOT         "
    echo -e "          Version 1.5         "
    echo -e "==========================================="
}

# Show banner before starting
show_banner

# Display script version
echo -e "${GREEN}YouTube Downloader Bot - Version $script_version${NC}"
echo "Choose an option:"
echo -e "${WHITE}1. Download Audio (FLAC format)${NC}"
echo -e "${WHITE}2. Download Video (choose quality)${NC}"
echo -e "${WHITE}3. Download Playlist (Audio or Video)${NC}"
echo -e "${WHITE}4. Download YouTube Channel Content${NC}"
read -p "Enter your choice (1, 2, 3, or 4): " choice

if [[ $choice == "3" ]]; then
    echo -e "${YELLOW}Downloading a playlist.${NC}"
    echo "1. Download Playlist as Audio (FLAC)"
    echo "2. Download Playlist as Video (MP4)"
    read -p "Enter your choice (1 or 2): " playlist_choice
    echo "Paste a YouTube playlist link."
    read -p "> " playlist_link

    playlist_name=$(yt-dlp --get-title "$playlist_link" 2>/dev/null | head -n 1)
    playlist_name=$(sanitize_folder_name "$playlist_name")
    playlist_folder="$playlist_dir/$playlist_name"
    mkdir -p "$playlist_folder"

    if [[ $playlist_choice == "1" ]]; then
        echo "Downloading playlist as FLAC..."
        yt-dlp --yes-playlist -x --audio-format flac -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
    elif [[ $playlist_choice == "2" ]]; then
        echo "Downloading playlist as MP4..."
        yt-dlp --yes-playlist -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
    fi

elif [[ $choice == "4" ]]; then
    echo -e "${YELLOW}Downloading YouTube channel content.${NC}"
    echo -e "${GREEN}Enter the YouTube Channel ID:${NC}"
    
    while true; do
        read -p "> " channel_id
        channel_url="https://www.youtube.com/channel/$channel_id"
        channel_name=$(yt-dlp --get-filename -o "%(uploader)s" "$channel_url" 2>/dev/null)
        channel_name=$(sanitize_folder_name "$channel_name")

        channel_folder="$channel_dir/$channel_name"
        mkdir -p "$channel_folder"

        echo -e "Download as:"
        echo -e "1. Audio (FLAC format)"
        echo -e "2. Video (MP4 format)"
        read -p "> " media_choice

        if [[ $media_choice == "1" ]]; then
            yt-dlp -f bestaudio --extract-audio --audio-format flac --audio-quality 0 -o "$channel_folder/%(title)s.%(ext)s" "$channel_url"
        elif [[ $media_choice == "2" ]]; then
            yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o "$channel_folder/%(title)s.%(ext)s" "$channel_url"
        fi

        echo -e "${GREEN}Content downloaded to: $channel_folder${NC}"
        break
    done
else
    echo -e "${RED}Invalid choice. Restart the bot.${NC}"
fi
