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
mkdir -p "$channel_dir"  # Create the channel directory if it doesn't exist

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
    local sanitized=$(echo "$input" | awk '!seen[$0]++')  # Remove duplicate lines
    sanitized=$(echo "$sanitized" | tr -cd '[:alnum:][:space:]._-/' | sed 's/[[:space:]]\+/_/g')  # Replace spaces with underscores
    sanitized=${sanitized:0:50}  # Trim to a max length of 50 chars
    echo "$sanitized"
}

# Show banner with ASCII art
show_banner() {
    clear
    echo -e "${BOLD_RED}"
    echo -e "YouTube BOT - STBV2"
    echo -e "${BOLD_RED}==========================================="
    echo -e "         YouTube Downloader Bot          "
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

    while true; do
        read -p "> " youtube_link
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo -e "${GREEN}Downloading audio in FLAC format...${NC}"
            yt-dlp -x --audio-format flac -o "$audio_dir/%(title)s.%(ext)s" "$youtube_link"
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
    echo -e "${BOLD_RED}Choose a video quality:${NC}"
    echo -e "Available qualities: 144p, 240p, 360p, 480p, 720p, 1080p, best"
    read -p "Enter your preferred quality: " quality
    echo -e "Paste a YouTube link and press Enter to download the video."

    while true; do
        read -p "> " youtube_link
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo -e "${GREEN}Downloading video in $quality quality...${NC}"
            yt-dlp -f "bestvideo[height<=$quality]+bestaudio/best" --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "$youtube_link"
            go_back
            break
        else
            echo -e "${RED}Invalid input. Please paste a valid YouTube link.${NC}"
        fi
    done
}

# Function to validate YouTube URL
validate_youtube_url() {
    local url="$1"
    if [[ ! "$url" =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/.*$ ]]; then
        echo -e "${RED}Invalid YouTube URL. Please try again.${NC}"
        return 1
    fi
    return 0
}

# Function to download channel content
download_channel() {
    show_banner
    echo -e "${BOLD_RED}Enter the YouTube channel ID:${NC}"
    read -p "> " channel_id

    if ! validate_youtube_url "https://www.youtube.com/channel/$channel_id"; then
        go_back
        return
    fi

    echo -e "Download as:"
    echo -e "1. Audio (FLAC)"
    echo -e "2. Video (MP4)"
    read -p "> " media_choice

    case $media_choice in
    1)
        echo -e "${GREEN}Downloading audio from the channel...${NC}"
        yt-dlp -f bestaudio --extract-audio --audio-format flac -o "$audio_dir/%(title)s.%(ext)s" "https://www.youtube.com/channel/$channel_id"
        ;;
    2)
        echo -e "${GREEN}Downloading video from the channel...${NC}"
        yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "https://www.youtube.com/channel/$channel_id"
        ;;
    *)
        echo -e "${RED}Invalid choice.${NC}"
        download_channel
        ;;
    esac

    go_back
}

# Function to download playlist
download_playlist() {
    show_banner
    echo -e "${BOLD_RED}Choose an option:${NC}"
    echo -e "1. Download Playlist as Audio (FLAC)"
    echo -e "2. Download Playlist as Video (MP4)"
    read -p "> " playlist_choice
    echo -e "Paste a YouTube playlist link:"
    read -p "> " playlist_link

    if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
        playlist_name=$(yt-dlp --get-filename -o "%(playlist_title)s" "$playlist_link")
        playlist_name=$(sanitize_folder_name "$playlist_name")
        playlist_folder="$playlist_dir/$playlist_name"
        mkdir -p "$playlist_folder"

        if [[ $playlist_choice == "1" ]]; then
            yt-dlp -x --audio-format flac -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
        elif [[ $playlist_choice == "2" ]]; then
            yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
        else
            echo -e "${RED}Invalid choice.${NC}"
        fi
        go_back
    else
        echo -e "${RED}Invalid playlist link.${NC}"
    fi
}

# Start script
main_menu
