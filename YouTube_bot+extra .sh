#!/bin/bash

# Function to display a colorful YouTube banner
display_banner() {
    echo -e "\e[31m████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗\e[0m"  # Red
    echo -e "\e[33m╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║\e[0m"  # Yellow
    echo -e "\e[32m   ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║\e[0m"  # Green
    echo -e "\e[36m   ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║\e[0m"  # Cyan
    echo -e "\e[34m   ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║\e[0m"  # Blue
    echo -e "\e[35m   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝\e[0m"  # Magenta
    echo -e "\e[37mYouTube Downloader Bot v1.0 - Welcome!\e[0m"     # White
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

# Function to download YouTube content
download_content() {
    local url=$1
    local format=$2
    local output=$3
    echo "Downloading..."
    yt-dlp -f "$format" -o "$output" "$url"
    echo "Download complete!"
}

# Function to download a playlist
download_playlist() {
    read -p "Enter playlist URL: " url
    download_content "$url" "best" "Playlist_%(title)s.%(ext)s"
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
        echo "6. Batch Download"
        echo "7. Check for Updates"
        echo "8. Exit"
        read -p "Choose an option: " choice

        case $choice in
            1) read -p "Enter video URL: " url; download_content "$url" "bestaudio --extract-audio --audio-format flac" "%(title)s.flac" ;;
            2) read -p "Enter video URL: " url; download_content "$url" "best" "%(title)s.%(ext)s" ;;
            3) download_playlist ;;
            4) youtube_search ;;
            5) convert_to_gif ;;
            6) read -p "Enter file with URLs: " file; while read -r url; do download_content "$url" "best" "%(title)s.%(ext)s"; done < "$file" ;;
            7) update_bot ;;
            8) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid option, try again." ;;
        esac
    done
}

# Run the menu
show_menu
