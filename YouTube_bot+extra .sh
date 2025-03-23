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
    # Remove unwanted characters, including newlines and spaces
    local sanitized=$(echo "$input" | tr -cd '[:alnum:][:space:]._-' | sed 's/[[:space:]]\+/_/g')
    # Replace any newline or carriage return with an underscore
    sanitized=$(echo "$sanitized" | tr -d '\n\r')
    echo "${sanitized^}"  # Capitalize the first letter to fix the double naming issue and trim to 50 characters
}

# Display script version in red
echo -e "\e[31mYouTube Downloader Bot - Version $script_version\e[0m"
echo "Choose an option:"
echo -e "\e[34m1. Download Audio (FLAC format)\e[0m"
echo -e "\e[34m2. Download Video (choose quality)\e[0m"
echo -e "\e[34m3. Download Playlist (Audio or Video)\e[0m"
echo -e "\e[34m4. Download YouTube Channel Content\e[0m"
read -p "Enter your choice (1, 2, 3, or 4): " choice

if [[ $choice == "3" ]]; then
    echo -e "\e[33mDownloading a playlist.\e[0m"
    echo "1. Download Playlist as Audio (FLAC)"
    echo "2. Download Playlist as Video (MP4)"
    read -p "Enter your choice (1 or 2): " playlist_choice
    echo "Paste a YouTube playlist link."
    read -p "> " playlist_link

    if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
        echo "Fetching playlist metadata..."
        
        # Extract playlist name safely
        playlist_name=$(yt-dlp --get-title "$playlist_link" 2>/dev/null | head -n 1)
        if [[ -z "$playlist_name" ]]; then
            echo -e "\e[31mFailed to fetch playlist metadata. Please check the link.\e[0m"
            exit 1
        fi

        playlist_name=$(sanitize_folder_name "$playlist_name")
        playlist_folder="$playlist_dir/$playlist_name"
        mkdir -p "$playlist_folder"
        echo "Playlist folder created: $playlist_folder"

        # Permission check before writing logs
        if [[ ! -w "$playlist_folder" ]]; then
            echo -e "\e[31mError: No write permission for $playlist_folder\e[0m"
            exit 1
        fi

        if [[ $playlist_choice == "1" ]]; then
            echo "Downloading playlist as FLAC..."
            yt-dlp --yes-playlist -x --audio-format flac -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link" \
                2> "$playlist_folder/error_log.txt" | tee -a "$playlist_folder/download_log.txt"
        elif [[ $playlist_choice == "2" ]]; then
            echo "Downloading playlist as MP4..."
            yt-dlp --yes-playlist -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link" \
                2> "$playlist_folder/error_log.txt" | tee -a "$playlist_folder/download_log.txt"
        else
            echo -e "\e[31mInvalid choice. Restart the bot.\e[0m"
        fi
    else
        echo -e "\e[31mInvalid playlist link.\e[0m"
    fi
elif [[ $choice == "4" ]]; then
    echo -e "\e[33mDownloading YouTube channel content.\e[0m"
    # Function to download channel content
    echo -e "\e[32mEnter the **YouTube Channel ID** (alphanumeric string starting with 'UC'):"
    
    while true; do
        read -p "> " channel_id

        # Validate Channel ID (must start with 'UC' and contain only alphanumeric characters, dashes, or underscores)
        if [[ ! "$channel_id" =~ ^UC[a-zA-Z0-9_-]+$ ]]; then
            echo -e "\e[31mInvalid Channel ID! It must start with 'UC' and contain only alphanumeric characters, dashes, or underscores.\e[0m"
            continue
        fi

        # Construct the channel URL using the provided Channel ID
        channel_url="https://www.youtube.com/channel/$channel_id"

        # Attempt to fetch the channel name
        channel_name=$(yt-dlp --get-filename -o "%(uploader)s" "$channel_url" 2>/dev/null)
        if [[ -z "$channel_name" ]]; then
            echo -e "\e[31mFailed to fetch channel name. Please ensure the Channel ID is correct.\e[0m"
            echo -e "Would you like to manually enter the channel name? (y/n)"
            read -p "> " manual_input
            if [[ "$manual_input" == "y" || "$manual_input" == "Y" ]]; then
                echo -e "Enter the channel name manually:"
                read -p "> " channel_name
                channel_name=$(sanitize_folder_name "$channel_name")
            else
                echo -e "\e[31mOperation canceled. Returning to the main menu.\e[0m"
                break
            fi
        else
            channel_name=$(sanitize_folder_name "$channel_name")
        fi

        # Create the channel folder
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

        # Confirm the download location
        echo -e "\e[32mContent downloaded to: $channel_folder\e[0m"
        break
    done
    echo -e "\e[32mDownload completed!\e[0m"
else
    echo -e "\e[31mInvalid choice. Restart the bot.\e[0m"
fi
