#!/bin/bash

# YouTube Downloader Bot - Version 1.10
script_version="1.10"

# Configuration file for user preferences
config_file="$HOME/.ytdlrc"
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
channel_dir="$base_dir/Channels"
mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"  # Create necessary directories

# Color Scheme (Red and White Only)
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m'  # No color

# Load user preferences from config
if [[ -f "$config_file" ]]; then
    source "$config_file"
fi

# Function to sanitize folder names
sanitize_folder_name() {
    local input="$1"
    # Allow custom characters via config (default: alphanumeric, spaces, ._-)
    local allowed_chars=${ALLOWED_CHARS:-'[:alnum:][:space:]._-'}
    local sanitized=$(echo "$input" | tr -cd "$allowed_chars" | sed 's/[[:space:]]\+/_/g')
    sanitized=$(echo "$sanitized" | tr -d '\n\r')
    echo "${sanitized^}"  # Capitalize the first letter and trim to 50 characters
}

# Show banner with ASCII art
show_banner() {
    clear
    echo -e "${RED}"
    echo -e "⠐⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠂"
    echo -e "⠀⢹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡇⠀"
    echo -e "⠀⢸⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⣠⣿⡇⠀"
    echo -e "⠀⠸⣿⣿⣷⣦⣀⡴⢶⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣄⣴⣾⣿⣿⠇⠀"
    echo -e "⠀⠀⢻⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣇⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀"
    echo -e "⠀⠀⣠⣻⡿⠿⢿⣫⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⣻⣥⠀⠀"
    echo -e "⠀⠀⣿⣿⣿⣿⣿⣿⣿⡿⣟⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀"
    echo -e "⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⡹⡜⠋⡾⣼⣿⣿⣿⣿⣿⣿⣿⡇⠀"
    echo -e "⠀⠀⣿⣻⣾⣭⣝⣛⣛⣛⣛⣃⣿⣾⣇⣛⣛⣛⣛⣯⣭⣷⣿⣿⡇⠀"
    echo -e "⠀⠰⢿⣿⣎⠙⠛⢻⣿⡿⠿⠟⣿⣿⡟⠿⠿⣿⡛⠛⠋⢹⣿⡿⢳⠀"
    echo -e "⠀⠘⣦⡙⢿⣦⣀⠀⠀⠀⢀⣼⣿⣿⣳⣄⠀⠀⠀⢀⣠⡿⢛⣡⡏⠀"
    echo -e "⠀⠀⠹⣟⢿⣾⣿⣿⣿⣿⣿⣧⣿⣿⣧⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀"
    echo -e "⠀⠀⢰⣿⣣⣿⣭⢿⣿⣱⣶⣿⣿⣿⣿⣿⣿⣷⣶⢹⣿⣭⣻⣶⣿⣿⠀⠀"
    echo -e "⠀⠀⠈⣿⢿⣿⣿⠏⣿⣾⣛⠿⣿⣿⣿⠟⣻⣾⡏⢿⣿⣯⡿⡏⠀⠀"
    echo -e "⠀⠀⠤⠾⣟⣿⡁⠘⢨⣟⢻⡿⠾⠿⠾⢿⡛⣯⠘⠀⣸⣽⡛⠲⠄⠀"
    echo -e "⠀⠀⠀⠀⠘⣿⣧⠀⠸⠃⠈⠙⠛⠛⠉⠈⠁⠹⠀⠀⣿⡟⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⢻⣿⣶⣀⣠⠀⠀⠀⠀⠀⠀⢠⡄⡄⣦⣿⠃⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠘⣿⣷⣻⣿⢷⢶⢶⢶⢆⣗⡿⣇⣷⣿⡿⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣛⣭⣭⣭⣭⣭⣻⣿⡿⠛⠀⠀⠀⠀⠀⠀"
    echo -e "⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⠟⠛⠛⠛⠻⠿⠟⠀⠀⠀⠀⠀⠀⠀⠀"
    echo -e "${RED}==========================================="
    echo -e "          YouTube BOT         "
    echo -e "          Version $script_version         "
    echo -e "===========================================${NC}"
    echo -e "${WHITE}Use shortcuts:${NC}"
    echo -e "${WHITE}- Run the bot using 'YT'${NC}"
    echo -e "${WHITE}- Auto-update with 'YT --update'${NC}"
}

# Setup Guide with Customizations
setup_guide() {
    echo -e "${RED}Welcome to the setup guide for the YouTube Downloader Bot.${NC}"
    echo -e "${WHITE}Follow these steps to customize your bot:${NC}"
    
    # Language selection
    echo -e "${WHITE}1. Choose your language:${NC}"
    select lang in "English" "Portuguese"; do
        case $lang in
            "English") echo "LANGUAGE=English" >> "$config_file"; break;;
            "Portuguese") echo "LANGUAGE=Portuguese" >> "$config_file"; break;;
        esac
    done
    
    # Output directories
    read -p "Enter base directory (default: $base_dir): " base_dir_input
    base_dir=${base_dir_input:-$base_dir}
    echo "BASE_DIR=\"$base_dir\"" >> "$config_file"
    audio_dir="$base_dir/Songs"
    video_dir="$base_dir/Videos"
    playlist_dir="$base_dir/playlists"
    channel_dir="$base_dir/Channels"
    mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"
    
    # Logging preference
    echo -e "${WHITE}Enable logging? (y/n)${NC}"
    read -p "> " enable_logs
    if [[ "$enable_logs" == "y" ]]; then
        echo "ENABLE_LOGS=true" >> "$config_file"
    else
        echo "ENABLE_LOGS=false" >> "$config_file"
    fi
    
    # Update source customization
    echo -e "${WHITE}Set custom auto-update URL (default: GitHub):${NC}"
    read -p "> " update_url
    if [[ -n "$update_url" ]]; then
        echo "UPDATE_URL=\"$update_url\"" >> "$config_file"
    fi
    
    # Add YT command to bashrc
    echo -e "${WHITE}Add 'YT' command to bashrc? (y/n)${NC}"
    read -p "> " add_to_bashrc
    if [[ "$add_to_bashrc" == "y" ]]; then
        echo "alias YT='bash ~/youtube_bot.sh'" >> "$HOME/.bashrc"
        source "$HOME/.bashrc"
        echo -e "${GREEN}YT command added to bashrc!${NC}"
    fi
    
    echo -e "${RED}Setup complete! You can now use the bot easily.${NC}"
    read -p "Press Enter to continue."
    main_menu
}

# Go Back function
go_back() {
    read -p "Press Enter to go back to the main menu."
    main_menu
}

# Exit function
exit_bot() {
    echo -e "${RED}Exiting the bot. Goodbye!${NC}"
    exit 0
}

# Auto-update feature
auto_update() {
    update_url=${UPDATE_URL:-"https://raw.githubusercontent.com/User1990i/YouTube-bot-playlist-/refs/heads/main/YouTube_bot%2Bextra%20.sh"}
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
            # Build command with optional flags
            cmd="yt-dlp -x"
            if [[ "$format_choice" == "1" ]]; then cmd+=" --audio-format flac"; fi
            if [[ "$format_choice" == "2" ]]; then cmd+=" --audio-format mp3"; fi
            if [[ -n "$speed_limit" ]]; then cmd+=" --max-downspeed $speed_limit"; fi
            cmd+=" -o \"$audio_dir/%(title)s.%(ext)s\" \"$youtube_link\""
            
            echo -e "${WHITE}Starting download...${NC}"
            if [[ "$ENABLE_LOGS" == "true" ]]; then
                eval "$cmd" | pv > /dev/null 2> >(tee -a "$audio_dir/error_log.txt")
            else
                eval "$cmd" | pv > /dev/null
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

# Function to download video
download_video() {
    show_banner
    echo -e "${WHITE}You selected to download video.${NC}"
    echo -e "Available qualities: 144p, 240p, 360p, 480p, 720p, 1080p, 1440p, 2160p (4K), best, worst"
    read -p "Enter quality (e.g., 720p): " quality
    read -p "Download subtitles? (y/n): " subtitles
    read -p "Set speed limit (e.g., 1M): " speed_limit
    
    while true; do
        read -p "Paste a YouTube link (or type 'exit' to go back): " youtube_link
        if [[ "$youtube_link" == "exit" ]]; then go_back; fi
        if validate_youtube_link "$youtube_link"; then
            # Build command with optional flags
            cmd="yt-dlp -f \"bestvideo[height<=$quality]+bestaudio/best[height<=$quality]\""
            if [[ "$subtitles" == "y" ]]; then cmd+=" --write-sub --sub-lang en"; fi
            if [[ -n "$speed_limit" ]]; then cmd+=" --max-downspeed $speed_limit"; fi
            cmd+=" --merge-output-format mp4 -o \"$video_dir/%(title)s.%(ext)s\" \"$youtube_link\""
            
            echo -e "${WHITE}Starting download...${NC}"
            if [[ "$ENABLE_LOGS" == "true" ]]; then
                eval "$cmd" | pv > /dev/null 2> >(tee -a "$video_dir/error_log.txt")
            else
                eval "$cmd" | pv > /dev/null
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

# Function to download playlist
download_playlist() {
    show_banner
    echo -e "${WHITE}Downloading a playlist.${NC}"
    echo "1. Download Playlist as Audio (FLAC/MP3)"
    echo "2. Download Playlist as Video (MP4)"
    read -p "Enter your choice (1 or 2): " playlist_choice
    read -p "Exclude keywords (comma-separated): " exclude_keywords
    read -p "Set speed limit (e.g., 2M): " speed_limit
    echo -e "Paste a YouTube playlist link (or type 'exit' to go back):"
    read -p "> " playlist_link
    
    if [[ "$playlist_link" == "exit" ]]; then go_back; fi
    
    # Validate playlist link
    if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
        # Fetch metadata
        playlist_name=$(yt-dlp --get-title "$playlist_link" 2>/dev/null | head -n 1)
        if [[ -z "$playlist_name" ]]; then
            echo -e "${RED}Failed to fetch playlist metadata. Please check the link.${NC}"
            go_back
        fi
        playlist_name=$(sanitize_folder_name "$playlist_name")
        playlist_folder="$playlist_dir/$playlist_name"
        mkdir -p "$playlist_folder"
        echo -e "${WHITE}Playlist folder created: $playlist_folder${NC}"
        
        # Permission check before writing logs
        if [[ ! -w "$playlist_folder" ]]; then
            echo -e "${RED}Error: No write permission for $playlist_folder${NC}"
            go_back
        fi
        
        if [[ $playlist_choice == "1" ]]; then
            echo -e "Choose format:"
            echo -e "1. FLAC (lossless)"
            echo -e "2. MP3 (compressed)"
            read -p "Enter your choice (1 or 2): " audio_format_choice
            if [[ "$audio_format_choice" == "1" ]]; then
                cmd="yt-dlp --yes-playlist -x --audio-format flac"
            elif [[ "$audio_format_choice" == "2" ]]; then
                cmd="yt-dlp --yes-playlist -x --audio-format mp3"
            else
                echo -e "${RED}Invalid choice. Restart the bot.${NC}"
                go_back
            fi
        elif [[ $playlist_choice == "2" ]]; then
            cmd="yt-dlp --yes-playlist -f \"bestvideo+bestaudio/best\" --merge-output-format mp4"
        else
            echo -e "${RED}Invalid choice. Restart the bot.${NC}"
            go_back
        fi
        if [[ -n "$exclude_keywords" ]]; then cmd+=" --match-title \"!$exclude_keywords\""; fi
        if [[ -n "$speed_limit" ]]; then cmd+=" --max-downspeed $speed_limit"; fi
        cmd+=" -o \"$playlist_folder/%(title)s.%(ext)s\" \"$playlist_link\""
        
        echo -e "${WHITE}Starting playlist download...${NC}"
        if [[ "$ENABLE_LOGS" == "true" ]]; then
            eval "$cmd" | pv > /dev/null 2> >(tee -a "$playlist_folder/error_log.txt")
        else
            eval "$cmd" | pv > /dev/null
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "${WHITE}Playlist downloaded successfully!${NC}"
        else
            echo -e "${RED}Download failed. Check logs.${NC}"
        fi
    else
        echo -e "${RED}Invalid playlist link.${NC}"
        go_back
    fi
}

# Function to download channel content
download_channel() {
    show_banner
    echo -e "${WHITE}Downloading YouTube channel content.${NC}"
    echo -e "${WHITE}Enter the **YouTube Channel ID** (alphanumeric string starting with 'UC'):${NC}"
    retries=3
    while [[ $retries -gt 0 ]]; do
        read -p "> " channel_id
        # Validate Channel ID (must start with 'UC' and contain only alphanumeric characters, dashes, or underscores)
        if [[ ! "$channel_id" =~ ^UC[a-zA-Z0-9_-]+$ ]]; then
            ((retries--))
            echo -e "${RED}Invalid Channel ID. $retries attempts remaining.${NC}"
            continue
        fi
        # Construct the channel URL using the provided Channel ID
        channel_url="https://www.youtube.com/channel/$channel_id"
        # Attempt to fetch the channel name
        channel_name=$(yt-dlp --get-uploader "$channel_url" 2>/dev/null)
        if [[ -z "$channel_name" ]]; then
            echo -e "${RED}Failed to fetch channel name. Please ensure the Channel ID is correct.${NC}"
            echo -e "${WHITE}Would you like to manually enter the channel name? (y/n)${NC}"
            read -p "> " manual_input
            if [[ "$manual_input" == "y" || "$manual_input" == "Y" ]]; then
                echo -e "${WHITE}Enter the channel name manually:${NC}"
                read -p "> " channel_name
                channel_name=$(sanitize_folder_name "$channel_name")
            else
                echo -e "${RED}Operation canceled. Returning to the main menu.${NC}"
                go_back
            fi
        else
            channel_name=$(sanitize_folder_name "$channel_name")
        fi
        # Create the channel folder
        channel_folder="$channel_dir/$channel_name"
        mkdir -p "$channel_folder"
        echo -e "${WHITE}Channel folder created: $channel_folder${NC}"
        echo -e "Download as:"
        echo -e "1. Audio (FLAC/MP3)"
        echo -e "2. Video (MP4)"
        read -p "> " media_choice
        case $media_choice in
        1) 
            echo -e "Choose format:"
            echo -e "1. FLAC (lossless)"
            echo -e "2. MP3 (compressed)"
            read -p "Enter your choice (1 or 2): " audio_format_choice
            if [[ "$audio_format_choice" == "1" ]]; then
                cmd="yt-dlp -f bestaudio --extract-audio --audio-format flac"
            elif [[ "$audio_format_choice" == "2" ]]; then
                cmd="yt-dlp -f bestaudio --extract-audio --audio-format mp3"
            else
                echo -e "${RED}Invalid choice. Restart the bot.${NC}"
                go_back
            fi
            ;;
        2) 
            cmd="yt-dlp -f bestvideo+bestaudio --merge-output-format mp4"
            ;;
        *)
            echo -e "${RED}Invalid choice. Please select 1 or 2.${NC}"
            continue
            ;;
        esac
        read -p "Exclude keywords (comma-separated): " exclude
        read -p "Set speed limit (e.g., 1M): " speed
        if [[ -n "$exclude" ]]; then cmd+=" --match-title \"!$exclude\""; fi
        if [[ -n "$speed" ]]; then cmd+=" --max-downspeed $speed"; fi
        cmd+=" -o \"$channel_folder/%(title)s.%(ext)s\" \"$channel_url\""
        
        echo -e "${WHITE}Starting channel download...${NC}"
        if [[ "$ENABLE_LOGS" == "true" ]]; then
            eval "$cmd" | pv > /dev/null 2> >(tee -a "$channel_folder/error_log.txt")
        else
            eval "$cmd" | pv > /dev/null
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "${WHITE}Content downloaded to: $channel_folder${NC}"
        else
            echo -e "${RED}Download failed. Check logs.${NC}"
        fi
        break
    done
    go_back
}

# Function to view recent downloads
view_recent() {
    recent_log="$base_dir/recent.log"
    if [[ -f "$recent_log" ]]; then
        echo -e "${WHITE}Recent downloads:${NC}"
        cat "$recent_log"
    else
        echo -e "${RED}No recent downloads found.${NC}"
    fi
    go_back
}

# Function to handle help/shortcuts
help_menu() {
    echo -e "${WHITE}Bot Shortcuts:${NC}"
    echo -e "- Run the bot with 'YT'"
    echo -e "- Auto-update using 'YT --update'"
    echo -e "- Use 'exit' to quit at any prompt"
    echo -e "\n${WHITE}Features:${NC}"
    echo -e "- Download subtitles alongside videos"
    echo -e "- Set download speed limits"
    echo -e "- Exclude keywords from downloads"
    go_back
}

# Function to customize bot settings
customize_settings() {
    show_banner
    echo -e "${WHITE}Customize Bot Settings:${NC}"
    echo -e "1. Change Base Directory"
    echo -e "2. Enable/Disable Logging"
    echo -e "3. Set Allowed Characters for Folder Names"
    echo -e "4. Change Auto-Update URL"
    echo -e "5. Go Back"
    read -p "Enter your choice (1-5): " setting_choice
    case $setting_choice in
    1)
        echo -e "${WHITE}Enter new base directory (default: $base_dir):${NC}"
        read -p "> " new_base_dir
        if [[ -n "$new_base_dir" ]]; then
            echo "BASE_DIR=\"$new_base_dir\"" > "$config_file"
            audio_dir="$new_base_dir/Songs"
            video_dir="$new_base_dir/Videos"
            playlist_dir="$new_base_dir/playlists"
            channel_dir="$new_base_dir/Channels"
            mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"
            echo -e "${GREEN}Base directory updated to: $new_base_dir${NC}"
        fi
        ;;
    2)
        echo -e "${WHITE}Enable logging? (y/n):${NC}"
        read -p "> " enable_logs
        if [[ "$enable_logs" == "y" ]]; then
            echo "ENABLE_LOGS=true" >> "$config_file"
            echo -e "${GREEN}Logging enabled.${NC}"
        else
            echo "ENABLE_LOGS=false" >> "$config_file"
            echo -e "${GREEN}Logging disabled.${NC}"
        fi
        ;;
    3)
        echo -e "${WHITE}Set allowed characters for folder names (default: [:alnum:][:space:]._-):${NC}"
        read -p "> " allowed_chars
        if [[ -n "$allowed_chars" ]]; then
            echo "ALLOWED_CHARS=\"$allowed_chars\"" >> "$config_file"
            echo -e "${GREEN}Allowed characters updated.${NC}"
        fi
        ;;
    4)
        echo -e "${WHITE}Set custom auto-update URL (default: GitHub):${NC}"
        read -p "> " update_url
        if [[ -n "$update_url" ]]; then
            echo "UPDATE_URL=\"$update_url\"" >> "$config_file"
            echo -e "${GREEN}Auto-update URL updated.${NC}"
        fi
        ;;
    5)
        go_back
        ;;
    *)
        echo -e "${RED}Invalid choice. Please try again.${NC}"
        customize_settings
        ;;
    esac
    go_back
}

# Main menu
main_menu() {
    clear
    show_banner
    echo -e "${WHITE}Choose an option:${NC}"
    echo -e "1. Download Audio (FLAC/MP3)"
    echo -e "2. Download Video (choose quality)"
    echo -e "3. Download Playlist (Audio/Video)"
    echo -e "4. Download YouTube Channel Content"
    echo -e "5. Recent Downloads"
    echo -e "6. Customize Bot Settings"
    echo -e "7. Help/Shortcuts"
    echo -e "8. Exit"
    read -p "Enter your choice (1-8): " choice

    case $choice in
    1) download_audio ;;
    2) download_video ;;
    3) download_playlist ;;
    4) download_channel ;;
    5) view_recent ;;
    6) setup_guide ;;
    7) help_menu ;;
    8) exit_bot ;;
    *) 
        echo -e "${RED}Invalid choice. Please try again.${NC}"
        main_menu
        ;;
    esac
}

# Check for command-line arguments
if [[ "$1" == "--update" ]]; then
    auto_update
elif [[ "$1" == "--help" ]]; then
    help_menu
    exit 0
fi

# Start script
main_menu
