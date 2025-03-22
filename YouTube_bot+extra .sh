#!/bin/bash

# Define the output directories
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
channel_dir="$base_dir/Channels"

mkdir -p "$audio_dir"  
mkdir -p "$video_dir"  
mkdir -p "$playlist_dir"  
mkdir -p "$channel_dir"  

# YouTube colors
RED='\033[0;31m'
WHITE='\033[1;37m'
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
    echo -e "" 
    echo -e "${BOLD_RED}==========================================="
    echo -e "          YouTube BOT         "
    echo -e "          NEW STABLE          "
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
    show_banner
    echo -e "${BOLD_RED}Choose an option:${NC}"
    echo -e "1. Download Audio (FLAC format)"
    echo -e "2. Download Video (choose quality)"
    echo -e "3. Download Playlist (Audio or Video)"
    echo -e "4. Download Channel Content (Audio or Video)"
    echo -e "5. Exit"
    read -p "Enter your choice (1, 2, 3, 4, or 5): " choice

    case $choice in
    1) download_audio ;;
    2) download_video ;;
    3) download_playlist ;;
    4) download_channel ;;
    5) exit 0 ;;
    *) 
        echo -e "${RED}Invalid choice. Please try again.${NC}"
        main_menu
        ;;
    esac
}

# Function to download audio
download_audio() {
    show_banner
    echo -e "${BOLD_RED}You selected to download audio in FLAC format.${NC}"
    echo -e "Paste a YouTube link and press Enter to download the song."
    read -p "> " youtube_link

    yt-dlp -x --audio-format flac -o "$audio_dir/%(title)s.%(ext)s" "$youtube_link"
    echo -e "${GREEN}Download completed!${NC}"
    go_back
}

# Function to download video
download_video() {
    show_banner
    echo -e "${BOLD_RED}Select Video Quality:${NC}"
    echo -e "Available: 144p, 240p, 360p, 480p, 720p, 1080p, 1440p, 2160p (4K), best"
    read -p "Enter quality (e.g., 720p, best): " quality
    echo -e "Paste a YouTube link and press Enter."
    read -p "> " youtube_link

    yt-dlp -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "$youtube_link"
    echo -e "${GREEN}Download completed!${NC}"
    go_back
}

# Function to download playlist (Reverted to v1.4 stable)
download_playlist() {
    show_banner
    echo -e "${BOLD_RED}You selected to download a playlist.${NC}"
    echo -e "Choose an option:"
    echo -e "1. Download Playlist as Audio (FLAC format)"
    echo -e "2. Download Playlist as Video (MP4 format)"
    read -p "Enter your choice (1 or 2): " playlist_choice
    echo -e "Paste a YouTube playlist link and press Enter to download the playlist."
    read -p "> " playlist_link
    
    if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
        echo -e "${GREEN}Fetching playlist metadata. Please wait...${NC}"
        
        # Extract the playlist name
        playlist_name=$(yt-dlp --get-filename -o "%(playlist_title)s" "$playlist_link")
        playlist_name=$(sanitize_folder_name "$playlist_name")
        playlist_folder="$playlist_dir/$playlist_name"
        mkdir -p "$playlist_folder"
        echo -e "${GREEN}Playlist folder created: $playlist_folder${NC}"
        
        if [[ $playlist_choice == "1" ]]; then
            echo -e "${GREEN}Downloading playlist '$playlist_name' as audio in FLAC format...${NC}"
            yt-dlp --yes-playlist -x --audio-format flac -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Playlist download completed successfully!${NC}"
                echo -e "The songs have been saved in: $playlist_folder"
            else
                echo -e "${RED}An error occurred while downloading the playlist. Please try again.${NC}"
            fi
            go_back
        elif [[ $playlist_choice == "2" ]]; then
            echo -e "${GREEN}Downloading playlist '$playlist_name' as video in MP4 format...${NC}"
            yt-dlp --yes-playlist -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Playlist download completed successfully!${NC}"
                echo -e "The videos have been saved in: $playlist_folder"
            else
                echo -e "${RED}An error occurred while downloading the playlist. Please try again.${NC}"
            fi
            go_back
        else
            echo -e "${RED}Invalid choice. Please restart the bot and enter 1 or 2.${NC}"
        fi
    else
        echo -e
