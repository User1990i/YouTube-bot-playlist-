#!/bin/bash

# Define the output directories
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
mkdir -p "$audio_dir"  # Create the audio directory if it doesn't exist
mkdir -p "$video_dir"  # Create the video directory if it doesn't exist
mkdir -p "$playlist_dir"  # Create the playlists directory if it doesn't exist

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
    echo -e "⠀⠀⠀⠀⠀⠘⣿⣷⣻⣿⢷⢶⢶⢶⢆⣗⡿⣇⣷⣿⡿⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣛⣭⣭⣭⣭⣭⣻⣿⡿⠛⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⠟⠛⠛⠛⠻⠿⠟⠀⠀⠀⠀⠀⠀⠀⠀"
    echo -e "" 
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
    echo -e "4. Exit"
    read -p "Enter your choice (1, 2, 3, or 4): " choice

    case $choice in
    1) download_audio ;;
    2) download_video ;;
    3) download_playlist ;;
    4) exit 0 ;;
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

    while true; do
        read -p "> " youtube_link
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo -e "${GREEN}Downloading audio in FLAC format from the provided link...${NC}"
            yt-dlp -x --audio-format flac -o "$audio_dir/%(title)s.%(ext)s" "$youtube_link"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Download completed successfully!${NC}"
                echo -e "The song has been saved in: $audio_dir"
            else
                echo -e "${RED}An error occurred while downloading the song. Please try again.${NC}"
            fi
            go_back
            break
        else
            echo -e "${RED}Invalid input. Please paste a valid YouTube link.${NC}"
        fi
    done
}

# Function to download video
download_video() {
    show_banner
    echo -e "${BOLD_RED}You selected to download video. Choose a quality:${NC}"
    echo -e "Available qualities: 144p, 240p, 360p, 480p, 720p, 1080p, 1440p, 2160p (4K), best"
    read -p "Enter your preferred quality (e.g., 720p, 1080p, best): " quality
    echo -e "Paste a YouTube link and press Enter to download the video."
    
    while true; do
        read -p "> " youtube_link
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo -e "${GREEN}Downloading video in $quality quality from the provided link...${NC}"
            yt-dlp -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "$youtube_link"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Download completed successfully!${NC}"
                echo -e "The video has been saved in: $video_dir"
            else
                echo -e "${RED}An error occurred while downloading the video. Please try again.${NC}"
            fi
            go_back
            break
        else
            echo -e "${RED}Invalid input. Please paste a valid YouTube link.${NC}"
        fi
    done
}

# Function to download playlist
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
        echo -e "${RED}Invalid input. Please paste a valid YouTube playlist link.${NC}"
    fi
}

# Start the bot
main_menu
