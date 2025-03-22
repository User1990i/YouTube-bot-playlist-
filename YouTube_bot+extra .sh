#!/bin/bash

# Define the output directories (No spaces in path)
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

# Welcome message
echo -e "\e[32mYouTube Downloader Bot is running.\e[0m"
echo "Choose an option:"
echo -e "\e[34m1. Download Audio (FLAC format)\e[0m"
echo -e "\e[34m2. Download Video (choose quality)\e[0m"
echo -e "\e[34m3. Download Playlist (Audio or Video)\e[0m"
read -p "Enter your choice (1, 2, or 3): " choice

if [[ $choice == "1" ]]; then
    echo -e "\e[33mYou selected to download audio in FLAC format.\e[0m"
    echo "Paste a YouTube link and press Enter to download the song. Type 'q' to exit."

    while true; do
        read -p "> " youtube_link
        [[ $youtube_link == "q" ]] && echo "Exiting..." && break
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo "Downloading audio..."
            yt-dlp -x --audio-format flac -o "$audio_dir/%(title)s.%(ext)s" "$youtube_link"
            if [ $? -eq 0 ]; then
                echo -e "\e[32mDownload completed!\e[0m"
            else
                echo -e "\e[31mError downloading song.\e[0m"
            fi
        else
            echo -e "\e[31mInvalid link. Please try again.\e[0m"
        fi
    done

elif [[ $choice == "2" ]]; then
    echo -e "\e[33mYou selected to download a video.\e[0m"
    echo "Available qualities: 144p, 240p, 360p, 480p, 720p, 1080p, 1440p, 2160p (4K), best"
    read -p "Enter quality (e.g., 720p, best): " quality
    echo "Paste a YouTube link to download the video. Type 'q' to exit."

    while true; do
        read -p "> " youtube_link
        [[ $youtube_link == "q" ]] && echo "Exiting..." && break
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo "Downloading video in $quality quality..."
            if [[ $quality == "best" ]]; then
                yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "$youtube_link"
            else
                yt-dlp -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "$youtube_link"
            fi
            if [ $? -eq 0 ]; then
                echo -e "\e[32mDownload completed!\e[0m"
            else
                echo -e "\e[31mError downloading video.\e[0m"
            fi
        else
            echo -e "\e[31mInvalid link. Please try again.\e[0m"
        fi
    done

elif [[ $choice == "3" ]]; then
    echo -e "\e[33mYou selected to download a playlist.\e[0m"
    echo "1. Download Playlist as Audio (FLAC format)"
    echo "2. Download Playlist as Video (MP4 format)"
    read -p "Enter your choice (1 or 2): " playlist_choice
    echo "Paste a YouTube playlist link and press Enter to download."
    read -p "> " playlist_link

    if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
        echo "Fetching playlist metadata..."
        playlist_name=$(yt-dlp --get-filename -o "%(playlist_title)s" "$playlist_link")
        playlist_name=$(sanitize_folder_name "$playlist_name")
        playlist_folder="$playlist_dir/$playlist_name"
        mkdir -p "$playlist_folder"
        echo "Playlist folder created: $playlist_folder"

        if [[ $playlist_choice == "1" ]]; then
            echo "Downloading playlist as FLAC audio..."
            yt-dlp --yes-playlist -x --audio-format flac -o "$playlist_folder/%(title)s.%(ext)s" \
                2> "${playlist_folder}/error_log.txt" | tee -a "${playlist_folder}/download_log.txt"
        elif [[ $playlist_choice == "2" ]]; then
            echo "Downloading playlist as MP4 video..."
            yt-dlp --yes-playlist -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" \
                2> "${playlist_folder}/error_log.txt" | tee -a "${playlist_folder}/download_log.txt"
        else
            echo -e "\e[31mInvalid choice. Restart the bot.\e[0m"
        fi

    else
        echo -e "\e[31mInvalid playlist link.\e[0m"
    fi

else
    echo -e "\e[31mInvalid choice. Restart the bot.\e[0m"
fi
