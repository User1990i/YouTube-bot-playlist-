#!/bin/bash

# YouTube Downloader Bot - Version 1.5
script_version="1.5"

# Define output directories (No spaces in paths)
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
channel_dir="$base_dir/Channels"
mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"  # Create necessary directories

# Function to sanitize folder names
sanitize_folder_name() {
    local input="$1"
    local sanitized=$(echo "$input" | tr -d '\n\r' | sed 's/[^a-zA-Z0-9 _-]//g' | sed 's/[[:space:]]\+/_/g')
    sanitized=$(echo "$sanitized" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')  # Capitalize first letter properly
    echo "$sanitized"
}

# Display script version
echo -e "\e[32mYouTube Downloader Bot - Version $script_version\e[0m"
echo "Choose an option:"
echo -e "\e[34m1. Download Audio (FLAC format)\e[0m"
echo -e "\e[34m2. Download Video (choose quality)\e[0m"
echo -e "\e[34m3. Download Playlist (Audio or Video)\e[0m"
echo -e "\e[34m4. Download YouTube Channel Content\e[0m"
read -p "Enter your choice (1, 2, 3, or 4): " choice

if [[ $choice == "4" ]]; then
    echo -e "\e[33mDownloading YouTube channel content.\e[0m"
    echo -e "\e[32mEnter the **YouTube Channel ID** (alphanumeric string starting with 'UC'):"
    
    while true; do
        read -p "> " channel_id

        if [[ ! "$channel_id" =~ ^UC[a-zA-Z0-9_-]+$ ]]; then
            echo -e "\e[31mInvalid Channel ID! It must start with 'UC' and contain only alphanumeric characters, dashes, or underscores.\e[0m"
            continue
        fi

        channel_url="https://www.youtube.com/channel/$channel_id"

        # Fetch the channel name properly
        channel_name=$(yt-dlp --print "%(uploader)s" "$channel_url" 2>/dev/null | head -n 1)
        
        if [[ -z "$channel_name" ]]; then
            echo -e "\e[31mFailed to fetch channel name. Please ensure the Channel ID is correct.\e[0m"
            echo -e "Would you like to manually enter the channel name? (y/n)"
            read -p "> " manual_input
            if [[ "$manual_input" == "y" || "$manual_input" == "Y" ]]; then
                echo -e "Enter the channel name manually:"
                read -p "> " channel_name
            else
                echo -e "\e[31mOperation canceled. Returning to the main menu.\e[0m"
                break
            fi
        fi

        channel_name=$(sanitize_folder_name "$channel_name")
        channel_folder="$channel_dir/$channel_name"
        mkdir -p "$channel_folder"

        echo -e "Download as:"
        echo -e "1. Audio (FLAC format)"
        echo -e "2. Video (MP4 format)"
        read -p "> " media_choice

        case $media_choice in
        1) 
            echo -e "Downloading audio from the channel..."
            yt-dlp -f bestaudio --extract-audio --audio-format flac --audio-quality 0 -o "$channel_folder/%(title)s.%(ext)s" "$channel_url"
            ;;
        2) 
            echo -e "Downloading video from the channel..."
            yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o "$channel_folder/%(title)s.%(ext)s" "$channel_url"
            ;;
        *)
            echo -e "\e[31mInvalid choice. Please select 1 or 2.\e[0m"
            continue
            ;;
        esac

        echo -e "\e[32mContent downloaded to: $channel_folder\e[0m"
        break
    done
    echo -e "\e[32mDownload completed!\e[0m"
else
    echo -e "\e[31mInvalid choice. Restart the bot.\e[0m"
fi
