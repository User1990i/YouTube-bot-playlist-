#!/bin/bash

# YouTube Downloader Bot - Version 1.12
script_version="1.12"

# Configuration file for user preferences
config_file="$HOME/.ytdlrc"
base_dir="/storage/emulated/0/Music_Vids"

# Set default values for all configurable variables
LANGUAGE="English"
ENABLE_LOGS="false"
ALLOWED_CHARS='[:alnum:][:space:]._-'
UPDATE_URL="https://raw.githubusercontent.com/User1990i/YouTube-bot-playlist-/refs/heads/main/youtube_bot.sh"

# Load user preferences from config
if [[ -f "$config_file" ]]; then
    source "$config_file"
fi

# Set directories after sourcing config
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
channel_dir="$base_dir/Channels"
mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"

# Color Scheme (Red and White Only)
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m'  # No color

# Check for required tools
check_dependencies() {
    if ! command -v yt-dlp &>/dev/null; then
        echo -e "${RED}Error: yt-dlp is not installed. Please install it first.${NC}"
        exit 1
    fi

    if ! command -v ffmpeg &>/dev/null; then
        echo -e "${RED}Warning: ffmpeg is not installed. Some format conversions may fail.${NC}"
        read -p "Press Enter to continue..."
    fi
}

# Function to sanitize folder names
sanitize_folder_name() {
    local input="$1"
    local sanitized=$(echo "$input" | tr -cd "$ALLOWED_CHARS" | sed 's/[[:space:]]\+/_/g')
    sanitized=$(echo "$sanitized" | tr -d '\n\r' | head -c 50)
    echo "${sanitized^}"
}

# Show banner with ASCII art
show_banner() {
    clear
    echo -e "${RED}"
    # ... (keep original ASCII art) ...
    echo -e "${RED}==========================================="
    echo -e "          YouTube BOT         "
    echo -e "          Version $script_version         "
    echo -e "===========================================${NC}"
    echo -e "${WHITE}Use shortcuts:${NC}"
    echo -e "${WHITE}- Run the bot using 'YT'${NC}"
    echo -e "${WHITE}- Auto-update with 'YT --update'${NC}"
}

# ... (keep original setup_guide function but update config writing) ...

# Function to download audio (updated with array command)
download_audio() {
    show_banner
    echo -e "${WHITE}You selected to download audio.${NC}"
    echo -e "Choose format:"
    echo -e "1. FLAC (lossless)"
    echo -e "2. MP3 (compressed)"
    read -p "Enter your choice (1 or 2): " format_choice
    read -p "Set speed limit (e.g., 500K): " speed_limit
    
    while true; do
        read -p "Paste a YouTube link (or type 'exit' to go back): " youtube_link
        if [[ "$youtube_link" == "exit" ]]; then go_back; fi
        if validate_youtube_link "$youtube_link"; then
            # Build command array
            cmd=(yt-dlp -x)
            if [[ "$format_choice" == "1" ]]; then
                cmd+=(--audio-format flac)
            elif [[ "$format_choice" == "2" ]]; then
                cmd+=(--audio-format mp3)
            fi
            [[ -n "$speed_limit" ]] && cmd+=(--max-downspeed "$speed_limit")
            cmd+=(-o "$audio_dir/%(title)s.%(ext)s" "$youtube_link")
            
            echo -e "${WHITE}Starting download...${NC}"
            if [[ "$ENABLE_LOGS" == "true" ]]; then
                if command -v pv &>/dev/null; then
                    "${cmd[@]}" | pv > /dev/null 2> >(tee -a "$audio_dir/error_log.txt")
                else
                    "${cmd[@]}" > /dev/null 2> >(tee -a "$audio_dir/error_log.txt")
                fi
            else
                "${cmd[@]}" > /dev/null
            fi
            
            if [ $? -eq 0 ]; then
                echo -e "${WHITE}Download completed successfully!${NC}"
                echo "Downloaded $(date): $youtube_link" >> "$base_dir/recent.log"
            else
                echo -e "${RED}Download failed. Check logs.${NC}"
            fi
            break
        else
            echo -e "${RED}Invalid link. Try again or type 'exit'.${NC}"
        fi
    done
    go_back
}

# ... (update all other download functions similarly with array commands) ...

# Function to download playlist (updated exclude handling)
download_playlist() {
    show_banner
    echo -e "${WHITE}Downloading a playlist.${NC}"
    # ... (keep original setup) ...
    
    if [[ -n "$exclude_keywords" ]]; then
        exclude_pattern=$(echo "$exclude_keywords" | sed 's/,/|/g')
        cmd+=(--match-title "!($exclude_pattern)")
    fi
    # ... (rest of function) ...
}

# ... (update channel download function similarly) ...

# Function to customize settings (improved config handling)
customize_settings() {
    show_banner
    # ... (keep menu) ...
    
    case $setting_choice in
    1)
        echo -e "${WHITE}Enter new base directory (default: $base_dir):${NC}"
        read -p "> " new_base_dir
        if [[ -n "$new_base_dir" ]]; then
            {
                echo "BASE_DIR=\"$new_base_dir\""
                echo "LANGUAGE=\"$LANGUAGE\""
                echo "ENABLE_LOGS=\"$ENABLE_LOGS\""
                echo "ALLOWED_CHARS=\"$ALLOWED_CHARS\""
                echo "UPDATE_URL=\"$UPDATE_URL\""
            } > "$config_file"
            source "$config_file"
            audio_dir="$new_base_dir/Songs"
            video_dir="$new_base_dir/Videos"
            playlist_dir="$new_base_dir/playlists"
            channel_dir="$new_base_dir/Channels"
            mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"
        fi
        ;;
    # ... (other cases) ...
    esac
    go_back
}

# ... (keep remaining functions but update config handling) ...

# Start script with dependency check
check_dependencies
main_menu
