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

# Function to show a simple text-based loading animation
loading_animation() {
    local message=$1
    echo -n "$message "
    while true; do
        echo -ne "\e[38;5;196m.\e[0m"  # Bright Red dot
        sleep 0.5
        echo -ne "\e[38;5;203m.\e[0m"  # Salmon Red dot
        sleep 0.5
        echo -ne "\e[38;5;204m.\e[0m"  # Tomato Red dot
        sleep 0.5
        echo -ne "\r$message                 \r"  # Clear the line
    done
}

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

# Function to download YouTube content with animation
download_content() {
    local url=$1
    local format=$2
    local output=$3
    echo "Downloading..."
    
    # Start the loading animation in the background
    loading_animation "Downloading" &
    local pid=$!  # Get the process ID of the animation
    
    # Perform the download
    yt-dlp -f "$format" -o "$output" "$url" >/dev/null 2>&1
    
    # Stop the loading animation
    kill $pid 2>/dev/null
    wait $pid 2>/dev/null
    echo -e "\rDownload complete!               "  # Clear the animation line
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
    echo "Converting to GIF..."
    
    # Start the loading animation in the background
    loading_animation "Converting to GIF" &
    local pid=$!
    
    # Perform the conversion
    ffmpeg -i "$video" -vf "fps=10,scale=320:-1:flags=lanczos" -t "$duration" "${video%.mp4}.gif" >/dev/null 2>&1
    
    # Stop the loading animation
    kill $pid 2>/dev/null
    wait $pid 2>/dev/null
    echo -e "\rGIF created: ${video%.mp4}.gif               "  # Clear the animation line
}

# Function to search YouTube
youtube_search() {
    read -p "Enter search query: " query
    yt-dlp "ytsearch5:$query" --get-title --get-id
}

# Function to check for updates
update_bot() {
    echo "Updating yt-dlp..."
    
    # Start the loading animation in the background
    loading_animation "Updating yt-dlp" &
    local pid=$!
    
    # Perform the update
    yt-dlp -U >/dev/null 2>&1
    
    # Stop the loading animation
    kill $pid 2>/dev/null
    wait $pid 2>/dev/null
    echo -e "\rUpdate complete!               "  # Clear the animation line
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
