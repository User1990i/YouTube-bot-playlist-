#!/bin/bash

# Function for clear screen
clear_screen() {
    clear
}

# Banner
banner() {
    clear_screen
    echo -e "\e[1;33m"
    echo "  __     ______  _    _   _      ____   ____   ____    _    _   _    _ "
    echo "  \ \   / / __ \| |  | | | |    / __ \ / __ \ / __ \  | |  | | | |  | |"
    echo "   \ \_/ / |  | | |  | | | |   | |  | | |  | | |  | | | |  | | | |  | |"
    echo "    \   /| |  | | |  | | | |   | |  | | |  | | |  | | | |  | | | |  | |"
    echo "     | | | |__| | |__| | | |___| |__| | |__| | |__| | | |__| | | |__| |"
    echo "     |_|  \____/ \____/  |______\____/ \____/ \____/   \____/  |______|"
    echo -e "\e[0m"
    echo " YouTube BOT stable build v1"
    echo " ============================================"
    echo " 1. Download Audio (FLAC format)"
    echo " 2. Download Video (choose quality)"
    echo " 3. Download Playlist (Audio or Video)"
    echo " ============================================"
}

# Show back navigation option
back_navigation() {
    echo "-------------------------------------------"
    echo " Press [B] to go back to the main menu."
    read -p "> " back_choice
    if [[ $back_choice == "B" || $back_choice == "b" ]]; then
        main_menu
    else
        echo "Invalid option. Press [B] to go back."
        back_navigation
    fi
}

# Download audio function
download_audio() {
    echo "You selected to download audio in FLAC format."
    echo "Paste a YouTube link and press Enter to download the song."
    while true; do
        read -p "> " youtube_link
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo "Downloading audio in FLAC format..."
            yt-dlp -x --audio-format flac -o "/storage/emulated/0/Music_Vids/Songs/%(title)s.%(ext)s" "$youtube_link"
            if [ $? -eq 0 ]; then
                echo "Download completed!"
            else
                echo "An error occurred. Please try again."
            fi
            back_navigation
            break
        else
            echo "Invalid link. Please paste a valid YouTube link."
        fi
    done
}

# Download video function
download_video() {
    echo "You selected to download video. Choose a quality:"
    echo "Available qualities: 144p, 240p, 360p, 480p, 720p, 1080p, 1440p, 2160p (4K), best"
    read -p "Enter your preferred quality: " quality
    echo "Paste a YouTube link and press Enter to download the video."
    while true; do
        read -p "> " youtube_link
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo "Downloading video in $quality quality..."
            yt-dlp -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" --merge-output-format mp4 -o "/storage/emulated/0/Music_Vids/Videos/%(title)s.%(ext)s" "$youtube_link"
            if [ $? -eq 0 ]; then
                echo "Download completed!"
            else
                echo "An error occurred. Please try again."
            fi
            back_navigation
            break
        else
            echo "Invalid link. Please paste a valid YouTube link."
        fi
    done
}

# Download playlist function
download_playlist() {
    echo "You selected to download a playlist."
    echo "Choose an option:"
    echo "1. Download Playlist as Audio (FLAC format)"
    echo "2. Download Playlist as Video (MP4 format)"
    read -p "Enter your choice (1 or 2): " playlist_choice
    echo "Paste a YouTube playlist link and press Enter to download the playlist."
    read -p "> " playlist_link
    if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
        echo "Fetching playlist metadata..."
        playlist_name=$(yt-dlp --get-filename -o "%(playlist_title)s" "$playlist_link")
        playlist_folder="/storage/emulated/0/Music_Vids/playlists/$playlist_name"
        mkdir -p "$playlist_folder"
        echo "Playlist folder created: $playlist_folder"
        if [[ $playlist_choice == "1" ]]; then
            echo "Downloading playlist as audio in FLAC format..."
            yt-dlp --yes-playlist -x --audio-format flac -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
            if [ $? -eq 0 ]; then
                echo "Playlist download completed!"
            else
                echo "An error occurred. Please try again."
            fi
        elif [[ $playlist_choice == "2" ]]; then
            echo "Downloading playlist as video in MP4 format..."
            yt-dlp --yes-playlist -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
            if [ $? -eq 0 ]; then
                echo "Playlist download completed!"
            else
                echo "An error occurred. Please try again."
            fi
        else
            echo "Invalid choice. Please try again."
        fi
        back_navigation
    else
        echo "Invalid link. Please paste a valid YouTube playlist link."
    fi
}

# Main menu function
main_menu() {
    banner
    read -p "Enter your choice (1, 2, or 3): " choice
    case $choice in
        1) download_audio ;;
        2) download_video ;;
        3) download_playlist ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
}

# Run the bot
main_menu
