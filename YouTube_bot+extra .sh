#!/bin/bash
# YouTube Downloader Bot - Version 1.12

script_version="1.13"

# Configuration file for user preferences
config_file="$HOME/.ytdlrc"
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
channel_dir="$base_dir/Channels"

# Ensure necessary directories exist
mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"

# Color Scheme
RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
NC='\033[0m'  # No color

# Load user preferences from config
if [[ -f "$config_file" ]]; then
    source "$config_file"
fi

# Function to sanitize folder names
sanitize_folder_name() {
    local input="$1"
    local allowed_chars=${ALLOWED_CHARS:-'[:alnum:][:space:]._-'}
    local sanitized=$(echo "$input" | tr -cd "$allowed_chars" | sed 's/[[:space:]]\+/_/g')
    sanitized=$(echo "$sanitized" | tr -d '\n\r')
    echo "${sanitized^}" | cut -c1-50  # Capitalize first letter and trim to 50 characters
}

# Function to display the banner
show_banner() {
    clear
    echo -e "${RED}==========================================="
    echo -e "          YouTube BOT - Version $script_version"
    echo -e "===========================================${NC}"
    echo -e "${WHITE}Use shortcuts:${NC}"
    echo -e "${WHITE}- Run the bot using 'YT'${NC}"
    echo -e "${WHITE}- Auto-update with 'YT --update'${NC}"
}

# Function to check for updates
auto_update() {
    update_url=${UPDATE_URL:-"https://raw.githubusercontent.com/User1990i/YouTube-bot-playlist-/refs/heads/main/youtube_bot.sh"}
    echo -e "${RED}Checking for updates...${NC}"
    curl -o ~/youtube_bot.sh "$update_url" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        chmod +x ~/youtube_bot.sh
        echo -e "${WHITE}Update successful! Restarting...${NC}"
        exec ~/youtube_bot.sh
    else
        echo -e "${RED}Failed to update. Check your URL or connection.${NC}"
    fi
}

# Function to validate YouTube links
validate_youtube_link() {
    local link="$1"
    if [[ $link == *"youtube.com"* || $link == *"youtu.be"* ]]; then
        return 0  # Valid link
    else
        return 1  # Invalid link
    fi
}

# Function to download audio
download_audio() {
    show_banner
    echo -e "${WHITE}Downloading audio...${NC}"
    echo -e "1. FLAC (lossless)"
    echo -e "2. MP3 (compressed)"
    read -p "Enter your choice (1 or 2): " format_choice
    read -p "Set speed limit (e.g., 500K): " speed_limit

    while true; do
        read -p "Paste a YouTube link (or type 'exit' to cancel): " youtube_link
        if [[ "$youtube_link" == "exit" ]]; then return; fi
        if validate_youtube_link "$youtube_link"; then
            cmd="yt-dlp -x"
            [[ "$format_choice" == "1" ]] && cmd+=" --audio-format flac"
            [[ "$format_choice" == "2" ]] && cmd+=" --audio-format mp3"
            [[ -n "$speed_limit" ]] && cmd+=" --max-downspeed $speed_limit"
            cmd+=" -o \"$audio_dir/%(title)s.%(ext)s\" \"$youtube_link\""
            echo -e "${WHITE}Starting download...${NC}"
            eval "$cmd"
            break
        else
            echo -e "${RED}Invalid link. Try again.${NC}"
        fi
    done
}

# Function to download video
download_video() {
    show_banner
    echo -e "${WHITE}Downloading video...${NC}"
    echo -e "Available qualities: 144p, 240p, 360p, 480p, 720p, 1080p, best"
    read -p "Enter quality (e.g., 720p): " quality
    read -p "Download subtitles? (y/n): " subtitles
    read -p "Set speed limit (e.g., 1M): " speed_limit

    while true; do
        read -p "Paste a YouTube link (or type 'exit' to cancel): " youtube_link
        if [[ "$youtube_link" == "exit" ]]; then return; fi
        if validate_youtube_link "$youtube_link"; then
            cmd="yt-dlp -f \"bestvideo[height<=$quality]+bestaudio/best[height<=$quality]\""
            [[ "$subtitles" == "y" ]] && cmd+=" --write-sub --sub-lang en"
            [[ -n "$speed_limit" ]] && cmd+=" --max-downspeed $speed_limit"
            cmd+=" --merge-output-format mp4 -o \"$video_dir/%(title)s.%(ext)s\" \"$youtube_link\""
            echo -e "${WHITE}Starting download...${NC}"
            eval "$cmd"
            break
        else
            echo -e "${RED}Invalid link. Try again.${NC}"
        fi
    done
}

# Function to download playlist
download_playlist() {
    show_banner
    echo -e "${WHITE}Downloading a playlist...${NC}"
    echo "1. Download as Audio (FLAC/MP3)"
    echo "2. Download as Video (MP4)"
    read -p "Enter your choice (1 or 2): " playlist_choice
    echo -e "Paste a YouTube playlist link (or type 'exit' to cancel):"
    read -p "> " playlist_link

    [[ "$playlist_link" == "exit" ]] && return

    if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
        playlist_name=$(yt-dlp --get-title "$playlist_link" 2>/dev/null | head -n 1)
        playlist_name=$(sanitize_folder_name "$playlist_name")
        playlist_folder="$playlist_dir/$playlist_name"
        mkdir -p "$playlist_folder"

        if [[ $playlist_choice == "1" ]]; then
            echo -e "1. FLAC (lossless)"
            echo -e "2. MP3 (compressed)"
            read -p "Enter format choice (1 or 2): " audio_format_choice
            [[ "$audio_format_choice" == "1" ]] && cmd="yt-dlp --yes-playlist -x --audio-format flac"
            [[ "$audio_format_choice" == "2" ]] && cmd="yt-dlp --yes-playlist -x --audio-format mp3"
        elif [[ $playlist_choice == "2" ]]; then
            cmd="yt-dlp --yes-playlist -f \"bestvideo+bestaudio/best\" --merge-output-format mp4"
        else
            echo -e "${RED}Invalid choice.${NC}"
            return
        fi

        cmd+=" -o \"$playlist_folder/%(title)s.%(ext)s\" \"$playlist_link\""
        echo -e "${WHITE}Starting playlist download...${NC}"
        eval "$cmd"
    else
        echo -e "${RED}Invalid playlist link.${NC}"
    fi
}

# Main menu
main_menu() {
    show_banner
    echo "1. Download Audio"
    echo "2. Download Video"
    echo "3. Download Playlist"
    echo "4. Check for Updates"
    echo "5. Exit"
    read -p "Choose an option: " choice
    case $choice in
        1) download_audio ;;
        2) download_video ;;
        3) download_playlist ;;
        4) auto_update ;;
        5) exit ;;
        *) echo -e "${RED}Invalid choice!${NC}" ;;
    esac
}

# Start the bot
main_menu
