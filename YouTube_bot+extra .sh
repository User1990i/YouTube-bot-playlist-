#!/bin/bash

# Welcome message
echo "Welcome to the YouTube Downloader Bot!"
echo "This script will install required dependencies and allow you to download YouTube videos, audio, and playlists."

# Auto-update function
update_bot() {
    echo "Checking for updates..."
    remote_version=$(curl -s https://raw.githubusercontent.com/User1990i/YouTube-bot/main/version.txt)
    local_version=$(cat ~/.youtube_bot_version 2>/dev/null || echo "0")

    if [[ "$remote_version" != "$local_version" ]]; then
        echo "Updating bot..."
        curl -o ~/youtube_bot.sh https://raw.githubusercontent.com/User1990i/YouTube-bot/main/youtube_bot.sh
        chmod +x ~/youtube_bot.sh
        echo "$remote_version" > ~/.youtube_bot_version
        echo "Update complete! Restarting bot..."
        exec bash ~/youtube_bot.sh
    else
        echo "You're using the latest version."
    fi
}

# Update Termux packages and install dependencies
pkg update -y && pkg upgrade -y
pkg install -y python ffmpeg termux-api git curl jq

# Install yt-dlp
pip install yt-dlp mutagen

# Grant storage permissions
termux-setup-storage

# Define directories
base_dir="/storage/emulated/0/YT-Downloads"
audio_dir="$base_dir/Audio"
video_dir="$base_dir/Video"
playlist_audio_dir="$base_dir/Playlists/Audio"
playlist_video_dir="$base_dir/Playlists/Video"
mkdir -p "$audio_dir" "$video_dir" "$playlist_audio_dir" "$playlist_video_dir"

# Add alias to .bashrc
if ! grep -q "alias youtube-bot" ~/.bashrc; then
    echo 'alias youtube-bot="bash ~/youtube_bot.sh"' >> ~/.bashrc
fi
source ~/.bashrc

echo "Installation complete! Type 'youtube-bot' to run the script."

# ---- Main Menu ----
while true; do
    echo -e "\nSelect an option:"
    echo "1. Download Audio (FLAC)"
    echo "2. Download Video"
    echo "3. Download Playlist"
    echo "4. Convert Video to GIF"
    echo "5. Search YouTube"
    echo "6. Exit"
    read -p "Choice: " choice

    case $choice in
        1)  # Download Audio
            read -p "Enter YouTube link: " youtube_link
            yt-dlp -x --audio-format flac -o "$audio_dir/%(title)s.%(ext)s" "$youtube_link"
            echo "Download complete: $audio_dir"
            ;;
        
        2)  # Download Video
            read -p "Enter YouTube link: " youtube_link
            read -p "Enter video quality (e.g., 720p, best): " quality
            yt-dlp -f "bestvideo[height<=$quality]+bestaudio/best" --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "$youtube_link"
            echo "Download complete: $video_dir"
            ;;
        
        3)  # Download Playlist
            read -p "Enter playlist link: " playlist_link
            echo "1. Download as Songs (FLAC)"
            echo "2. Download as Videos (MP4)"
            read -p "Choice: " playlist_choice
            
            if [[ $playlist_choice == "1" ]]; then
                playlist_name=$(yt-dlp --print "%(playlist_title)s" "$playlist_link" | head -n 1 | tr ' ' '_')
                output_dir="$playlist_audio_dir/$playlist_name"
                mkdir -p "$output_dir"
                yt-dlp -x --audio-format flac -o "$output_dir/%(title)s.%(ext)s" "$playlist_link"
                echo "Playlist saved in: $output_dir"

                # Merge option
                read -p "Merge all audio files into one? (y/n): " merge_choice
                if [[ $merge_choice == "y" ]]; then
                    ffmpeg -i "concat:$(ls "$output_dir"/*.flac | tr '\n' '|' | sed 's/|$//')" -acodec copy "$output_dir/Merged_Playlist.flac"
                    echo "Merged file saved in: $output_dir"
                fi

            elif [[ $playlist_choice == "2" ]]; then
                playlist_name=$(yt-dlp --print "%(playlist_title)s" "$playlist_link" | head -n 1 | tr ' ' '_')
                output_dir="$playlist_video_dir/$playlist_name"
                mkdir -p "$output_dir"
                yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$output_dir/%(title)s.%(ext)s" "$playlist_link"
                echo "Playlist saved in: $output_dir"
            fi
            ;;
        
        4)  # Convert Video to GIF
            read -p "Enter video file path: " video_file
            read -p "Enter GIF output name (without .gif): " gif_name
            ffmpeg -i "$video_file" -vf "fps=10,scale=320:-1" "$base_dir/$gif_name.gif"
            echo "GIF saved in: $base_dir/$gif_name.gif"
            ;;
        
        5)  # YouTube Search
            read -p "Enter search query: " query
            yt-dlp "ytsearch5:$query" --print "Title: %(title)s | URL: %(webpage_url)s"
            ;;
        
        6)  # Exit
            echo "Goodbye!"
            exit 0
            ;;
        
        *) echo "Invalid choice. Try again." ;;
    esac
done
