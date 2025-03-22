#!/bin/bash

# YouTube Downloader Bot - Version 1.4
script_version="1.4"

# Define output directories (No spaces in paths)
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
mkdir -p "$audio_dir" "$video_dir" "$playlist_dir"  # Create necessary directories

# Function to sanitize folder names
sanitize_folder_name() {
    local input="$1"
    local sanitized=$(echo "$input" | tr -cd '[:alnum:][:space:]._-' | sed 's/[[:space:]]\+/_/g')
    echo "${sanitized:0:50}"  # Trim to 50 characters
}

# Display script version
echo -e "\e[32mYouTube Downloader Bot - Version $script_version\e[0m"
echo "Choose an option:"
echo -e "\e[34m1. Download Audio (FLAC format)\e[0m"
echo -e "\e[34m2. Download Video (choose quality)\e[0m"
echo -e "\e[34m3. Download Playlist (Audio or Video)\e[0m"
read -p "Enter your choice (1, 2, or 3): " choice

if [[ "$choice" == "1" ]]; then
    echo -e "\e[33mYou selected to download audio in FLAC format.\e[0m"
    echo "Paste a YouTube link and press Enter to download."
    while true; do
        read -p "> " youtube_link
        if [[ "$youtube_link" == *"youtube.com"* || "$youtube_link" == *"youtu.be"* ]]; then
            echo "Downloading audio in FLAC format..."
            yt-dlp -x --audio-format flac -o "$audio_dir/%(title)s.%(ext)s" "$youtube_link"
            if [[ $? -eq 0 ]]; then
                echo -e "\e[32mDownload completed successfully!\e[0m"
            else
                echo -e "\e[31mError downloading audio. Please try again.\e[0m"
            fi
        else
            echo -e "\e[31mInvalid YouTube link. Try again.\e[0m"
        fi
    done

elif [[ "$choice" == "2" ]]; then
    echo -e "\e[33mYou selected to download a video.\e[0m"
    echo "Available qualities: 144p, 240p, 360p, 480p, 720p, 1080p, 1440p, 2160p (4K), best"
    read -p "Enter preferred quality (e.g., 720p, 1080p, best): " quality
    echo "Paste a YouTube link and press Enter to download."
    while true; do
        read -p "> " youtube_link
        if [[ "$youtube_link" == *"youtube.com"* || "$youtube_link" == *"youtu.be"* ]]; then
            echo "Downloading video in $quality quality..."
            yt-dlp -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "$youtube_link"
            if [[ $? -eq 0 ]]; then
                echo -e "\e[32mDownload completed successfully!\e[0m"
            else
                echo -e "\e[31mError downloading video. Please try again.\e[0m"
            fi
        else
            echo -e "\e[31mInvalid YouTube link. Try again.\e[0m"
        fi
    done

elif [[ "$choice" == "3" ]]; then
    echo -e "\e[33mDownloading a playlist.\e[0m"
    echo "1. Download Playlist as Audio (FLAC)"
    echo "2. Download Playlist as Video (MP4)"
    read -p "Enter your choice (1 or 2): " playlist_choice
    echo "Paste a YouTube playlist link."
    read -p "> " playlist_link

    if [[ "$playlist_link" == *"youtube.com/playlist"* ]]; then
        echo "Fetching playlist metadata..."
        playlist_name=$(yt-dlp --get-title "$playlist_link" 2>/dev/null | head -n 1)
        if [[ -z "$playlist_name" ]]; then
            echo -e "\e[31mFailed to fetch playlist metadata. Check the link.\e[0m"
            exit 1
        fi

        playlist_name=$(sanitize_folder_name "$playlist_name")
        playlist_folder="$playlist_dir/$playlist_name"
        mkdir -p "$playlist_folder"
        echo "Playlist folder created: $playlist_folder"

        if [[ ! -w "$playlist_folder" ]]; then
            echo -e "\e[31mError: No write permission for $playlist_folder\e[0m"
            exit 1
        fi

        if [[ "$playlist_choice" == "1" ]]; then
            echo "Downloading playlist as FLAC..."
            yt-dlp --yes-playlist -x --audio-format flac -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link" \
                2> "$playlist_folder/error_log.txt" | tee -a "$playlist_folder/download_log.txt"
        elif [[ "$playlist_choice" == "2" ]]; then
            echo "Downloading playlist as MP4..."
            yt-dlp --yes-playlist -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link" \
                2> "$playlist_folder/error_log.txt" | tee -a "$playlist_folder/download_log.txt"
        else
            echo -e "\e[31mInvalid choice. Restart the bot.\e[0m"
        fi
    else
        echo -e "\e[31mInvalid playlist link.\e[0m"
    fi

else
    echo -e "\e[31mInvalid choice. Please enter 1, 2, or 3.\e[0m"
fi
