#!/bin/bash

# Auto-Update System
update_script() {
    echo "Checking for updates..."
    latest_script_url="https://raw.githubusercontent.com/User1990i/YouTube-bot-playlist-/main/YouTube_bot.sh"
    curl -o ~/youtube_bot.sh "$latest_script_url"
    chmod +x ~/youtube_bot.sh
    echo "Update completed! Restarting bot..."
    exec bash ~/youtube_bot.sh
}

# Define Directories
base_audio_dir="/storage/emulated/0/Music"
base_video_dir="/storage/emulated/0/Videos"
mkdir -p "$base_audio_dir" "$base_video_dir"

# Function to Normalize Audio
normalize_audio() {
    for file in "$1"/*.flac; do
        ffmpeg -i "$file" -af loudnorm "$file.normalized.flac"
        mv "$file.normalized.flac" "$file"
    done
}

# Function to Convert Video to GIF
convert_to_gif() {
    read -p "Enter video file path: " video_path
    gif_path="${video_path%.*}.gif"
    ffmpeg -i "$video_path" -vf "fps=10,scale=320:-1:flags=lanczos" -c:v gif "$gif_path"
    echo "GIF saved at: $gif_path"
}

# YouTube Search Function
search_youtube() {
    read -p "Enter search query: " query
    yt-dlp "ytsearch5:$query" --print "Title: %(title)s | URL: %(webpage_url)s"
}

# Batch Download Function
batch_download() {
    echo "Enter multiple YouTube URLs (separate by spaces):"
    read -a urls
    for url in "${urls[@]}"; do
        yt-dlp -f bestvideo+bestaudio/best -o "$base_video_dir/%(title)s.%(ext)s" "$url" &
    done
    wait
}

# Main Menu
while true; do
    echo -e "\nYouTube Downloader Bot"
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
        1)  # Audio Download
            read -p "Enter YouTube URL: " url
            yt-dlp -x --audio-format flac -o "$base_audio_dir/%(title)s.%(ext)s" "$url"
            ;;
        2)  # Video Download
            read -p "Enter YouTube URL: " url
            read -p "Enter preferred quality (144p-4K/best): " quality
            yt-dlp -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" -o "$base_video_dir/%(title)s.%(ext)s" "$url"
            ;;
        3)  # Playlist Download
            read -p "Enter YouTube playlist URL: " playlist_url
            read -p "Download as (1: Audio, 2: Video): " format_choice
            if [[ $format_choice == "1" ]]; then
                yt-dlp -x --audio-format flac -o "$base_audio_dir/Playlists/%(playlist_title)s/%(title)s.%(ext)s" "$playlist_url"
                read -p "Merge all audio into one file? (y/n): " merge_choice
                if [[ $merge_choice == "y" ]]; then
                    normalize_audio "$base_audio_dir/Playlists/$(yt-dlp --print "%(playlist_title)s" "$playlist_url" | head -n 1)"
                fi
            else
                yt-dlp -f bestvideo+bestaudio/best -o "$base_video_dir/Playlists/%(playlist_title)s/%(title)s.%(ext)s" "$playlist_url"
            fi
            ;;
        4)  # YouTube Search
            search_youtube
            ;;
        5)  # Convert Video to GIF
            convert_to_gif
            ;;
        6)  # Batch Download
            batch_download
            ;;
        7)  # Update
            update_script
            ;;
        8)  # Exit
            echo "Goodbye!"
            exit 0
            ;;
        *)  # Invalid Choice
            echo "Invalid choice, please select again."
            ;;
    esac
done
