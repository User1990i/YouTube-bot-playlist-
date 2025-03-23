#!/bin/bash

# YouTube Downloader Bot - Version 1.8
script_version="1.8"

# Define output directories
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
channel_dir="$base_dir/Channels"
mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"

# Function to sanitize folder names
sanitize_folder_name() {
    local input="$1"
    local sanitized=$(echo "$input" | tr -cd '[:alnum:][:space:]._-' | sed 's/[[:space:]]\+/_/g')
    sanitized=$(echo "$sanitized" | tr -d '\n\r')
    echo "${sanitized^}"
}

# Color Scheme for YouTube Red and White
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m'

# Show banner with ASCII art
show_banner() {
    clear
    echo -e "${RED}"
    echo -e "==========================================="
    echo -e "          YouTube BOT         "
    echo -e "          Version 1.8         "
    echo -e "==========================================="
}

# Function to update the bot automatically
update_bot() {
    echo -e "${RED}Checking for updates...${NC}"
    curl -o ~/youtube_bot.sh "https://raw.githubusercontent.com/User1990i/YouTube-bot-playlist-/refs/heads/main/YouTube_bot%2Bextra%20.sh" && chmod +x ~/youtube_bot.sh
    echo -e "${RED}Bot updated. Restarting...${NC}"
    bash ~/youtube_bot.sh
    exit 0
}

# Show banner before starting
show_banner

# Display script version
echo -e "${RED}YouTube Downloader Bot - Version $script_version${NC}"
echo "Choose an option:"
echo -e "${WHITE}1. Download Audio (M4A, MP3, FLAC)${NC}"
echo -e "${WHITE}2. Download Video (choose quality)${NC}"
echo -e "${WHITE}3. Download Playlist (Audio or Video)${NC}"
echo -e "${WHITE}4. Download YouTube Channel Content${NC}"
echo -e "${WHITE}5. Check for Updates${NC}"
read -p "Enter your choice (1, 2, 3, 4, or 5): " choice

# Auto-update option (Choice 5)
if [[ $choice == "5" ]]; then
    update_bot

# Handle Audio Download (Choice 1)
elif [[ $choice == "1" ]]; then
    echo -e "${RED}Download Audio${NC}"
    echo -e "${WHITE}Select the audio format:${NC}"
    echo -e "${WHITE}1. M4A${NC}"
    echo -e "${WHITE}2. MP3${NC}"
    echo -e "${WHITE}3. FLAC${NC}"
    read -p "Enter your choice (1, 2, or 3): " audio_format

    echo "Paste the YouTube link for audio download:"
    read -p "> " audio_link

    if [[ $audio_link == *"youtube.com"* ]]; then
        echo "Fetching audio..."
        
        case $audio_format in
            1)
                # Download audio in M4A format
                yt-dlp -x --audio-format m4a -o "$audio_dir/%(title)s.%(ext)s" "$audio_link"
                ;;
            2)
                # Download audio in MP3 format
                yt-dlp -x --audio-format mp3 -o "$audio_dir/%(title)s.%(ext)s" "$audio_link"
                ;;
            3)
                # Download audio in FLAC format
                yt-dlp -x --audio-format flac -o "$audio_dir/%(title)s.%(ext)s" "$audio_link"
                ;;
            *)
                echo -e "${RED}Invalid choice.${NC}"
                ;;
        esac
    else
        echo -e "${RED}Invalid YouTube link.${NC}"
    fi

# Handle Video Download (Choice 2)
elif [[ $choice == "2" ]]; then
    echo -e "${RED}Download Video${NC}"
    echo -e "${WHITE}Select the video format:${NC}"
    echo -e "${WHITE}1. MP4${NC}"
    echo -e "${WHITE}2. WEBM${NC}"
    echo -e "${WHITE}3. MKV${NC}"
    read -p "Enter your choice (1, 2, or 3): " video_format

    echo "Paste the YouTube link for video download:"
    read -p "> " video_link

    if [[ $video_link == *"youtube.com"* ]]; then
        echo "Fetching video..."
        
        case $video_format in
            1)
                # Download video in MP4 format
                yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "$video_link"
                ;;
            2)
                # Download video in WEBM format
                yt-dlp -f bestvideo+bestaudio --merge-output-format webm -o "$video_dir/%(title)s.%(ext)s" "$video_link"
                ;;
            3)
                # Download video in MKV format
                yt-dlp -f bestvideo+bestaudio --merge-output-format mkv -o "$video_dir/%(title)s.%(ext)s" "$video_link"
                ;;
            *)
                echo -e "${RED}Invalid choice.${NC}"
                ;;
        esac
    else
        echo -e "${RED}Invalid YouTube link.${NC}"
    fi

# Handle Playlist Download (Choice 3)
elif [[ $choice == "3" ]]; then
    echo -e "${RED}Downloading a playlist.${NC}"
    echo "1. Download Playlist as Audio (M4A, MP3, FLAC)"
    echo "2. Download Playlist as Video (MP4, WEBM, MKV)"
    read -p "Enter your choice (1 or 2): " playlist_choice
    echo "Paste a YouTube playlist link:"
    read -p "> " playlist_link

    if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
        echo "Fetching playlist metadata..."
        
        # Extract playlist name safely
        playlist_name=$(yt-dlp --get-title "$playlist_link" 2>/dev/null | head -n 1)
        if [[ -z "$playlist_name" ]]; then
            echo -e "${RED}Failed to fetch playlist metadata. Please check the link.${NC}"
            exit 1
        fi

        playlist_name=$(sanitize_folder_name "$playlist_name")
        playlist_folder="$playlist_dir/$playlist_name"
        mkdir -p "$playlist_folder"
        echo "Playlist folder created: $playlist_folder"

        if [[ $playlist_choice == "1" ]]; then
            echo "Download Playlist as Audio (M4A, MP3, FLAC)"
            echo -e "${WHITE}Select the audio format:${NC}"
            echo -e "${WHITE}1. M4A${NC}"
            echo -e "${WHITE}2. MP3${NC}"
            echo -e "${WHITE}3. FLAC${NC}"
            read -p "Enter your choice (1, 2, or 3): " audio_format
            case $audio_format in
                1)
                    yt-dlp --yes-playlist -x --audio-format m4a -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
                    ;;
                2)
                    yt-dlp --yes-playlist -x --audio-format mp3 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
                    ;;
                3)
                    yt-dlp --yes-playlist -x --audio-format flac -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
                    ;;
                *)
                    echo -e "${RED}Invalid choice.${NC}"
                    ;;
            esac
        elif [[ $playlist_choice == "2" ]]; then
            echo "Downloading playlist as video..."
            echo -e "${WHITE}Select the video format:${NC}"
            echo -e "${WHITE}1. MP4${NC}"
            echo -e "${WHITE}2. WEBM${NC}"
            echo -e "${WHITE}3. MKV${NC}"
            read -p "Enter your choice (1, 2, or 3): " video_format
            case $video_format in
                1)
                    yt-dlp --yes-playlist -f bestvideo+bestaudio --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
                    ;;
                2)
                    yt-dlp --yes-playlist -f bestvideo+bestaudio --merge-output-format webm -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
                    ;;
                3)
                    yt-dlp --yes-playlist -f bestvideo+bestaudio --merge-output-format mkv -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
                    ;;
                *)
                    echo -e "${RED}Invalid choice.${NC}"
                    ;;
            esac
        else
            echo -e "${RED}Invalid choice.${NC}"
        fi
    else
        echo -e "${RED}Invalid playlist link.${NC}"
    fi

# Handle Channel Download (Choice 4)
elif [[ $choice == "4" ]]; then
    echo -e "${RED}Downloading YouTube channel content.${NC}"
    echo "Enter the YouTube Channel ID:"
    read -p "> " channel_id

    if [[ ! "$channel_id" =~ ^UC[a-zA-Z0-9_-]+$ ]]; then
        echo -e "${RED}Invalid Channel ID! It must start with 'UC' and contain only alphanumeric characters, dashes, or underscores.${NC}"
        exit 1
    fi

    channel_url="https://www.youtube.com/channel/$channel_id"
    channel_name=$(yt-dlp --get-filename -o "%(uploader)s" "$channel_url" 2>/dev/null)
    if [[ -z "$channel_name" ]]; then
        echo -e "${RED}Failed to fetch channel name. Please check the Channel ID.${NC}"
        exit 1
    fi
    channel_name=$(sanitize_folder_name "$channel_name")
    channel_folder="$channel_dir/$channel_name"
    mkdir -p "$channel_folder"

    echo -e "Download as:"
    echo -e "${WHITE}1. Audio (M4A, MP3, FLAC)${NC}"
    echo -e "${WHITE}2. Video (MP4, WEBM, MKV)${NC}"
    read -p "> " media_choice

    case $media_choice in
        1) 
            echo -e "${RED}Downloading audio from the channel...${NC}"
            echo -e "${WHITE}Select the audio format:${NC}"
            echo -e "${WHITE}1. M4A${NC}"
            echo -e "${WHITE}2. MP3${NC}"
            echo -e "${WHITE}3. FLAC${NC}"
            read -p "Enter your choice (1, 2, or 3): " audio_format
            case $audio_format in
                1) yt-dlp -f bestaudio --extract-audio --audio-format m4a -o "$channel_folder/%(title)s.%(ext)s" "$channel_url" ;;
                2) yt-dlp -f bestaudio --extract-audio --audio-format mp3 -o "$channel_folder/%(title)s.%(ext)s" "$channel_url" ;;
                3) yt-dlp -f bestaudio --extract-audio --audio-format flac -o "$channel_folder/%(title)s.%(ext)s" "$channel_url" ;;
                *) echo -e "${RED}Invalid audio format choice.${NC}" ;;
            esac
            ;;
        2) 
            echo -e "${RED}Downloading video from the channel...${NC}"
            echo -e "${WHITE}Select the video format:${NC}"
            echo -e "${WHITE}1. MP4${NC}"
            echo -e "${WHITE}2. WEBM${NC}"
            echo -e "${WHITE}3. MKV${NC}"
            read -p "Enter your choice (1, 2, or 3): " video_format
            case $video_format in
                1) yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o "$channel_folder/%(title)s.%(ext)s" "$channel_url" ;;
                2) yt-dlp -f bestvideo+bestaudio --merge-output-format webm -o "$channel_folder/%(title)s.%(ext)s" "$channel_url" ;;
                3) yt-dlp -f bestvideo+bestaudio --merge-output-format mkv -o "$channel_folder/%(title)s.%(ext)s" "$channel_url" ;;
                *) echo -e "${RED}Invalid video format choice.${NC}" ;;
            esac
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            ;;
    esac
else
    echo -e "${RED}Invalid option.${NC}"
fi
