#!/bin/bash

# Function to display a colorful YTBot banner in red shades
display_banner() {
    if [[ $TERM == "xterm"* || $TERM == "screen"* ]]; then
        echo -e "\e[31m██████╗ ██╗   ██╗███████╗██╗  ██╗███████╗██████╗ \e[0m"
        echo -e "\e[91m██╔══██╗╚██╗ ██╔╝██╔════╝██║  ██║██╔════╝██╔══██╗\e[0m"
        echo -e "\e[38;5;196m██████╔╝ ╚████╔╝ █████╗  ███████║█████╗  ██████╔╝ ♥️ YTBot\e[0m"
        echo -e "\e[38;5;203m██╔══██╗  ╚██╔╝  ██╔══╝  ██╔══██║██╔══╝  ██╔══██╗\e[0m"
        echo -e "\e[38;5;204m██████╔╝   ██║   ███████╗██║  ██║███████╗██║  ██║\e[0m"
        echo -e "\e[38;5;209m╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝\e[0m"
        echo -e "\e[38;5;217mYouTube Downloader Bot - Fixed Version!\e[0m"
    else
        echo "██████╗ ██╗   ██╗███████╗██╗  ██╗███████╗██████╗"
        echo "██╔══██╗╚██╗ ██╔╝██╔════╝██║  ██║██╔════╝██╔══██╗"
        echo "██████╔╝ ╚████╔╝ █████╗  ███████║█████╗  ██████╔╝ ♥️ YTBot"
        echo "██╔══██╗  ╚██╔╝  ██╔══╝  ██╔══██║██╔══╝  ██╔══██╗"
        echo "██████╔╝   ██║   ███████╗██║  ██║███████╗██║  ██║"
        echo "╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
        echo "YouTube Downloader Bot - Fixed Version!"
    fi
}

# Display the banner
display_banner

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure yt-dlp & ffmpeg are installed
if ! command_exists yt-dlp || ! command_exists ffmpeg; then
    echo "Installing required packages..."
    if [[ -f /etc/os-release ]]; then
        # Detect OS and use appropriate package manager
        . /etc/os-release
        case $ID in
            ubuntu|debian)
                sudo apt update && sudo apt install -y yt-dlp ffmpeg pv
                ;;
            fedora)
                sudo dnf install -y yt-dlp ffmpeg pv
                ;;
            arch)
                sudo pacman -Syu --noconfirm yt-dlp ffmpeg pv
                ;;
            *)
                echo "Unsupported OS. Please install yt-dlp, ffmpeg, and pv manually."
                exit 1
                ;;
        esac
    elif command_exists pkg; then
        pkg update -y && pkg install -y yt-dlp ffmpeg pv
    else
        echo "Unable to detect package manager. Please install yt-dlp, ffmpeg, and pv manually."
        exit 1
    fi
fi

# Function to show a progress bar
show_progress() {
    local size
    if [[ "$OSTYPE" == "darwin"* ]]; then
        size=$(stat -f%z "$1")  # macOS
    else
        size=$(stat -c%s "$1")  # Linux
    fi
    pv -p -t -e -N "Processing" -c -s "$size" < "$1" > /dev/null 2>&1
}

# Function to download YouTube content with progress bar
download_content() {
    local url=$1
    local format=$2
    local output=$3

    echo -e "\e[38;5;196mDownloading...\e[0m"
    
    # Run yt-dlp with built-in progress reporting
    yt-dlp -f "$format" -o "$output" --progress-template "Downloading... %(progress._percent_str)s" "$url"
    if [[ $? -ne 0 ]]; then
        echo -e "\e[38;5;196mDownload failed.\e[0m"
        return 1
    fi
    echo -e "\nDownload complete!"
}

# Function to download a playlist
download_playlist() {
    read -p "Enter playlist URL: " url
    read -p "Choose format: (1) FLAC (2) MP4: " choice

    playlist_name=$(yt-dlp --print "%(playlist_title)s" "$url" | tr -d '[:punct:]')  # Get playlist name
    download_path="/storage/emulated/0/Music/Songs/$playlist_name"
    mkdir -p "$download_path"

    if [[ $choice == 1 ]]; then
        read -p "Merge audio? (Y/N): " merge_choice
        if [[ $merge_choice == "Y" || $merge_choice == "y" ]]; then
            yt-dlp -f bestaudio --extract-audio --audio-format flac -o "$download_path/%(title)s.flac" "$url"
            echo -e "\e[38;5;196mMerging audio...\e[0m"
            file_list=$(ls "$download_path"/*.flac | tr '\n' '|')
            ffmpeg -y -i "concat:$file_list" -c copy "$download_path/Merged_Audio_$playlist_name.flac"
            if [[ $? -eq 0 ]]; then
                rm "$download_path"/*.flac  # Delete individual files
                echo -e "\e[38;5;196mMerged file saved to: $download_path/Merged_Audio_$playlist_name.flac\e[0m"
            else
                echo -e "\e[38;5;196mMerge failed. Individual files preserved.\e[0m"
            fi
        else
            yt-dlp -f bestaudio --extract-audio --audio-format flac -o "$download_path/%(title)s.flac" "$url"
            echo -e "\e[38;5;196mFiles saved in: $download_path\e[0m"
        fi
    elif [[ $choice == 2 ]]; then
        yt-dlp -f best -o "$download_path/%(title)s.%(ext)s" "$url"
        echo -e "\e[38;5;196mVideos saved in: $download_path\e[0m"
    else
        echo "Invalid choice!"
    fi
}

# Function to batch download URLs from a file
batch_download() {
    read -p "Enter file with URLs: " file
    while read -r url; do
        if [[ -z "$url" || "$url" == "#"* ]]; then
            continue  # Skip empty lines or comments
        fi
        download_content "$url" "best" "%(title)s.%(ext)s"
    done < "$file"
}

# Function to check for updates
update_bot() {
    echo "Updating yt-dlp..."
    if command_exists pip; then
        pip install --upgrade yt-dlp
    elif command_exists brew; then
        brew upgrade yt-dlp
    elif command_exists apt; then
        sudo apt install --only-upgrade yt-dlp
    else
        yt-dlp -U
    fi
    echo "Update complete!"
}

# Function to display menu
show_menu() {
    while true; do
        echo -e "\e[38;5;209mYouTube Downloader Bot - Fixed Version\e[0m"
        echo "1. Download Audio (FLAC)"
        echo "2. Download Video"
        echo "3. Download Playlist"
        echo "4. Batch Download"
        echo "5. Check for Updates"
        echo "6. Exit"
        read -p "Choose an option (1-6): " choice

        if ! [[ "$choice" =~ ^[1-6]$ ]]; then
            echo "Invalid option. Please enter a number between 1 and 6."
            continue
        fi

        case $choice in
            1) 
                read -p "Enter video URL: " url
                download_content "$url" "bestaudio --extract-audio --audio-format flac" "%(title)s.flac"
                ;;
            2) 
                read -p "Enter video URL: " url
                download_content "$url" "best" "%(title)s.%(ext)s"
                ;;
            3) 
                download_playlist
                ;;
            4) 
                batch_download
                ;;
            5) 
                update_bot
                ;;
            6) 
                echo "Exiting..."
                exit 0
                ;;
        esac
    done
}

# Run the menu
show_menu
