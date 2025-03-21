#!/bin/bash

# Function to display a colorful YTBot banner
display_banner() {
    echo -e "\e[31m██████╗ ██╗   ██╗███████╗██╗  ██╗███████╗██████╗ \e[0m"
    echo -e "\e[91m██╔══██╗╚██╗ ██╔╝██╔════╝██║  ██║██╔════╝██╔══██╗\e[0m"
    echo -e "\e[38;5;196m██████╔╝ ╚████╔╝ █████╗  ███████║█████╗  ██████╔╝ ♥️ YTBot\e[0m"
    echo -e "\e[38;5;203m██╔══██╗  ╚██╔╝  ██╔══╝  ██╔══██║██╔══╝  ██╔══██╗\e[0m"
    echo -e "\e[38;5;204m██████╔╝   ██║   ███████╗██║  ██║███████╗██║  ██║\e[0m"
    echo -e "\e[38;5;209m╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝\e[0m"
    echo -e "\e[38;5;217mYouTube Downloader Bot v1.0 - Welcome!\e[0m"
}

# Display the banner
display_banner

# Ensure script runs from its directory
cd "$(dirname "$0")"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure yt-dlp and ffmpeg are installed
if ! command_exists yt-dlp; then
    echo "yt-dlp is not installed. Installing..."
    pkg update -y && pkg install yt-dlp -y
fi

if ! command_exists ffmpeg; then
    echo "ffmpeg is not installed. Installing..."
    pkg install ffmpeg -y
fi

# Function to display a red progress bar
progress_bar() {
    local pid=$1
    local delay=0.2
    local spin='▰▰▰▰▰▰▰▰▰▰'
    local i=0
    echo -n "Downloading: "
    while kill -0 $pid 2>/dev/null; do
        echo -ne "\e[91m${spin:0:$((i % 10 + 1))}\e[0m\r"
        sleep $delay
        ((i++))
    done
    echo -e "\e[92mDownload complete! \e[0m"
}

# Function to download with progress bar
download_with_progress() {
    local url=$1
    local format=$2
    local output=$3
    yt-dlp -f "$format" -o "$output" "$url" >/dev/null 2>&1 &  # Start download in background
    progress_bar $!  # Call progress bar with download process ID
}

# Function to download a playlist
download_playlist() {
    read -p "Enter playlist URL: " url
    read -p "Choose format: (1) FLAC (2) MP4: " format_choice

    playlist_name=$(yt-dlp --get-title --flat-playlist "$url" | head -n 1 | tr -d '[:punct:]')
    output_folder="/storage/emulated/0/Music/Songs/${playlist_name}"

    mkdir -p "$output_folder"

    if [[ "$format_choice" == "1" ]]; then
        read -p "Merge audio? (Y/N): " merge_choice
        if [[ "$merge_choice" =~ ^[Yy]$ ]]; then
            download_with_progress "$url" "bestaudio --extract-audio --audio-format flac" "$output_folder/%(title)s.%(ext)s"
            echo "Merging audio files..."
            ffmpeg -i "concat:$(ls "$output_folder"/*.flac | tr '\n' '|' | sed 's/|$//')" -acodec flac "$output_folder/Merged_Audio_${playlist_name}.flac"
            rm "$output_folder"/*.flac
            echo "Merged audio saved at $output_folder/Merged_Audio_${playlist_name}.flac"
        else
            download_with_progress "$url" "bestaudio --extract-audio --audio-format flac" "$output_folder/%(title)s.%(ext)s"
            echo "Playlist downloaded in FLAC format at $output_folder"
        fi
    elif [[ "$format_choice" == "2" ]]; then
        download_with_progress "$url" "best" "$output_folder/%(title)s.%(ext)s"
        echo "Playlist downloaded in MP4 format at $output_folder"
    else
        echo "Invalid choice. Returning to menu."
    fi
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
        echo "4. Batch Download"
        echo "5. Check for Updates"
        echo "6. Exit"
        read -p "Choose an option: " choice

        case $choice in
            1) read -p "Enter video URL: " url; download_with_progress "$url" "bestaudio --extract-audio --audio-format flac" "%(title)s.flac" ;;
            2) read -p "Enter video URL: " url; download_with_progress "$url" "best" "%(title)s.%(ext)s" ;;
            3) download_playlist ;;
            4) read -p "Enter file with URLs: " file; while read -r url; do download_with_progress "$url" "best" "%(title)s.%(ext)s"; done < "$file" ;;
            5) update_bot ;;
            6) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid option, try again." ;;
        esac
    done
}

# Run the menu
show_menu
