#!/bin/bash

# Function to display a colorful YTBot banner in red shades
display_banner() {
    echo -e "\e[31m██████╗ ██╗   ██╗███████╗██╗  ██╗███████╗██████╗ \e[0m"
    echo -e "\e[91m██╔══██╗╚██╗ ██╔╝██╔════╝██║  ██║██╔════╝██╔══██╗\e[0m"
    echo -e "\e[38;5;196m██████╔╝ ╚████╔╝ █████╗  ███████║█████╗  ██████╔╝ ♥️ YTBot\e[0m"
    echo -e "\e[38;5;203m██╔══██╗  ╚██╔╝  ██╔══╝  ██╔══██║██╔══╝  ██╔══██╗\e[0m"
    echo -e "\e[38;5;204m██████╔╝   ██║   ███████╗██║  ██║███████╗██║  ██║\e[0m"
    echo -e "\e[38;5;209m╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝\e[0m"
    echo -e "\e[38;5;217mYouTube Downloader Bot - Fixed Version!\e[0m"
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
    pkg update -y && pkg install yt-dlp ffmpeg pv -y
fi

# Function to show a red progress bar
show_progress() {
    local size=$(stat -c%s "$1")  # Get file size
    pv -p -t -e -N "Processing" -c -s $size < "$1" > /dev/null 2>&1
}

# Function to download YouTube content with progress bar
download_content() {
    local url=$1
    local format=$2
    local output=$3

    echo -e "\e[38;5;196mDownloading...\e[0m"
    
    # Run yt-dlp and capture output
    yt-dlp -f "$format" -o "$output" "$url" | tee yt-dlp-log.txt | while read line; do
        echo -ne "\e[38;5;196m>\e[0m $line\r"  # Show live progress
    done
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
            ffmpeg -y -i "concat:$(ls "$download_path"/*.flac | tr '\n' '|')" -c copy "$download_path/Merged_Audio_$playlist_name.flac"
            rm "$download_path"/*.flac  # Delete individual files
            echo -e "\e[38;5;196mMerged file saved to: $download_path/Merged_Audio_$playlist_name.flac\e[0m"
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
        download_content "$url" "best" "%(title)s.%(ext)s"
    done < "$file"
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
        echo -e "\e[38;5;209mYouTube Downloader Bot - Fixed Version\e[0m"
        echo "1. Download Audio (FLAC)"
        echo "2. Download Video"
        echo "3. Download Playlist"
        echo "4. Batch Download"
        echo "5. Check for Updates"
        echo "6. Exit"
        read -p "Choose an option: " choice

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
            *) 
                echo "Invalid option, try again."
                ;;
        esac
    done
}

# Run the menu
show_menu
