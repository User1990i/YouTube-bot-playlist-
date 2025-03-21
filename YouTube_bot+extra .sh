#!/bin/bash

# Function to display a colorful YTBot banner in multiple shades of red
display_banner() {
    echo -e "\e[31m██████╗ ██╗   ██╗███████╗██╗  ██╗███████╗██████╗ \e[0m"  # Dark Red
    echo -e "\e[91m██╔══██╗╚██╗ ██╔╝██╔════╝██║  ██║██╔════╝██╔══██╗\e[0m"  # Light Red
    echo -e "\e[38;5;196m██████╔╝ ╚████╔╝ █████╗  ███████║█████╗  ██████╔╝ ♥️ YTBot\e[0m"  # Bright Red
    echo -e "\e[38;5;203m██╔══██╗  ╚██╔╝  ██╔══╝  ██╔══██║██╔══╝  ██╔══██╗\e[0m"  # Salmon Red
    echo -e "\e[38;5;204m██████╔╝   ██║   ███████╗██║  ██║███████╗██║  ██║\e[0m"  # Tomato Red
    echo -e "\e[38;5;209m╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝\e[0m"  # Coral Red
    echo -e "\e[38;5;217mYouTube Downloader Bot v1.0 - Welcome!\e[0m"     # Light Coral
}

# Display the banner
display_banner

# Ensure script runs from its directory
cd "$(dirname "$0")"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Trap Ctrl+C (SIGINT) to gracefully exit the bot
trap 'echo "Exiting bot..."; exit 0' SIGINT

# Ensure yt-dlp is installed
if ! command_exists yt-dlp; then
    echo "yt-dlp is not installed. Installing..."
    pkg update -y && pkg install yt-dlp -y
fi

# Function to download YouTube content with sanitized file names
download_content() {
    local url=$1
    local format=$2
    local output_dir=$3
    local file_format=$4

    # Create the output directory if it doesn't exist
    mkdir -p "$output_dir"

    echo "Downloading..."
    
    # Use yt-dlp with restricted file names and truncated titles
    yt-dlp -f "$format" --restrict-filenames --parse-metadata "title:%(title).50s" -o "$output_dir/%(title)s.$file_format" "$url"
    echo "Download complete!"
}

# Function to download audio (FLAC)
download_audio() {
    read -p "Enter video URL: " url
    download_content "$url" "bestaudio --extract-audio --audio-format flac" "/storage/emulated/0/Music/Songs" "flac"
}

# Function to download video
download_video() {
    read -p "Enter video URL: " url
    download_content "$url" "best" "/storage/emulated/0/Videos" "mp4"
}

# Function to download a playlist
download_playlist() {
    read -p "Enter playlist URL: " url
    download_content "$url" "best" "/storage/emulated/0/Music/Playlists" "mp4"
}

# Function to convert video to GIF
convert_to_gif() {
    read -p "Enter video file path: " video
    read -p "Enter start time (e.g., 00:00:05): " start
    read -p "Enter duration (e.g., 5): " duration
    ffmpeg -i "$video" -vf "fps=10,scale=320:-1:flags=lanczos" -t "$duration" "${video%.mp4}.gif"
    echo "GIF created: ${video%.mp4}.gif"
}

# Function to search YouTube
youtube_search() {
    read -p "Enter search query: " query
    yt-dlp "ytsearch5:$query" --get-title --get-id
}

# Function to check for updates
update_bot() {
    echo "Updating yt-dlp..."
    yt-dlp -U
    echo "Update complete!"
}

# Function to display menu
show_menu() {
    while true; do
        echo "YouTube Downloader Bot"
        echo "1. Download Audio (FLAC)"
        echo "2. Download Video"
        echo "3. Download Playlist"
        echo "4. YouTube Search"
        echo "5. Convert Video to GIF"
        echo "6. Check for Updates"
        echo "7. Exit"
        read -p "Choose an option: " choice

        case $choice in
            1) download_audio ;;
            2) download_video ;;
            3) download_playlist ;;
            4) youtube_search ;;
            5) convert_to_gif ;;
            6) update_bot ;;
            7) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid option, try again." ;;
        esac
    done
}

# Run the menu
show_menu
