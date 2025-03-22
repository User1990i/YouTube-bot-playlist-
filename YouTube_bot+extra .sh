#!/bin/bash

# Define the output directories
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
channel_dir="$base_dir/Channels"
mkdir -p "$audio_dir"  # Create the audio directory if it doesn't exist
mkdir -p "$video_dir"  # Create the video directory if it doesn't exist
mkdir -p "$playlist_dir"  # Create the playlists directory if it doesn't exist
mkdir -p "$channel_dir"  # Create the channels directory if it doesn't exist

# YouTube colors
RED='\033[0;31m'
WHITE='\033[1;37m'
BLACK='\033[0;30m'
BOLD_RED='\033[1;31m'
GREEN='\033[0;32m'
NC='\033[0m'  # No color

# Function to sanitize folder names
sanitize_folder_name() {
    local input="$1"
    # Remove duplicate lines
    local sanitized=$(echo "$input" | awk '!seen[$0]++')
    # Replace special characters with underscores
    sanitized=$(echo "$sanitized" | tr -cd '[:alnum:][:space:]._-/' | sed 's/[[:space:]]\+/_/g')
    # Trim to a maximum length of 50 characters
    sanitized=${sanitized:0:50}
    echo "$sanitized"
}

# Function to show progress
show_progress() {
    # Create a smooth, animated download progress bar
    total_size=$1
    file_url=$2
    file_name=$3
    curl -# -o "$file_name" "$file_url" | pv -n -s $total_size > /dev/null
}

# Show banner with ASCII art
show_banner() {
    clear
    echo -e "${BOLD_RED}"
    echo -e "⠐⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠂"
    echo -e "⠀⢹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡇⠀"
    echo -e "⠀⢸⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⣠⣿⡇⠀"
    echo -e "⠀⠸⣿⣿⣷⣦⣀⡴⢶⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣄⣴⣾⣿⣿⠇⠀"
    echo -e "⠀⠀⢻⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣇⣿⣿⣿⣿⣿⡟⠀⠀"
    echo -e "⠀⠀⣠⣻⡿⠿⢿⣫⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⣻⣥⠀⠀"
    echo -e "⠀⠀⣿⣿⣿⣿⣿⣿⣿⡿⣟⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀"
    echo -e "⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⡹⡜⠋⡾⣼⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀"
    echo -e "⠀⠀⣿⣻⣾⣭⣝⣛⣛⣛⣛⣃⣿⣾⣇⣛⣛⣛⣛⣯⣭⣷⣿⣿⡇⠀"
    echo -e "⠀⠰⢿⣿⣎⠙⠛⢻⣿⡿⠿⠟⣿⣿⡟⠿⠿⣿⡛⠛⠋⢹⣿⡿⢳⠀"
    echo -e "⠀⠘⣦⡙⢿⣦⣀⠀⠀⠀⢀⣼⣿⣿⣳⣄⠀⠀⠀⢀⣠⡿⢛⣡⡏⠀"
    echo -e "⠀⠀⠹⣟⢿⣾⣿⣿⣿⣿⣿⣧⣿⣿⣧⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀"
    echo -e "⠀⠀⢰⣿⣣⣿⣭⢿⣿⣱⣶⣿⣿⣿⣿⣿⣷⣶⢹⣿⣭⣻⣶⣿⣿⠀⠀"
    echo -e "⠀⠀⠈⣿⢿⣿⣿⠏⣿⣾⣛⠿⣿⣿⣿⠟⣻⣾⡏⢿⣿⣯⡿⡏⠀⠀"
    echo -e "⠀⠀⠤⠾⣟⣿⡁⠘⢨⣟⢻⡿⠾⠿⠾⢿⡛⣯⠘⠀⣸⣽⡛⠲⠄⠀"
    echo -e "⠀⠀⠀⠀⠘⣿⣧⠀⠸⠃⠈⠙⠛⠛⠉⠈⠁⠹⠀⠀⣿⡟⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⢻⣿⣶⣀⣠⠀⠀⠀⠀⠀⠀⢠⡄⡄⣦⣿⠃⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠘⣿⣷⣻⣿⢷⢶⢶⢶⢆⣗⡿⣇⣷⣿⣿⡿⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣛⣭⣭⣭⣭⣭⣻⣿⡿⠛⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⠟⠛⠛⠛⠻⠿⠟⠀⠀⠀⠀⠀⠀⠀⠀"
    echo -e "" 
    echo -e "${BOLD_RED}==========================================="
    echo -e "          YouTube BOT         "
    echo -e "          STBV2              "
    echo -e "==========================================="
}

# Go Back function
go_back() {
    read -p "Press Enter to go back to the main menu."
    main_menu
}

# Main menu
main_menu() {
    clear
    # Display bot name and version above the options menu
    echo -e "${BOLD_RED}YouTube Downloader Bot"
    echo -e "Build v1        "
    echo -e "${NC}"
    show_banner
    echo -e "${BOLD_RED}Choose an option:${NC}"
    echo -e "1. Download Audio (FLAC format)"
    echo -e "2. Download Video (choose quality)"
    echo -e "3. Download Playlist (Audio or Video)"
    echo -e "4. Download All Videos from a Channel"
    echo -e "5. Exit"
    read -p "Enter your choice (1, 2, 3, 4, or 5): " choice

    case $choice in
    1) download_audio ;;
    2) download_video ;;
    3) download_playlist ;;
    4) download_channel_videos ;;
    5) exit 0 ;;
    *) 
        echo -e "${RED}Invalid choice. Please try again.${NC}"
        main_menu
        ;;
    esac
}

# Function to download all videos from a channel
download_channel_videos() {
    show_banner
    echo -e "${BOLD_RED}You selected to download all videos from a channel.${NC}"
    read -p "Enter the YouTube channel URL: " channel_url
    if [[ $channel_url == *"youtube.com"* || $channel_url == *"youtu.be"* ]]; then
        # Extract channel name
        channel_name=$(yt-dlp --get-filename -o "%(uploader)s" "$channel_url")
        channel_name=$(sanitize_folder_name "$channel_name")
        channel_folder="$channel_dir/$channel_name"
        mkdir -p "$channel_folder"
        echo -e "${GREEN}Downloading all videos from channel '$channel_name'...${NC}"
        
        # Download all videos from the channel
        yt-dlp -o "$channel_folder/%(title)s.%(
