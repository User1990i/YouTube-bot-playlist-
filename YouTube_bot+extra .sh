#!/bin/bash

# YouTube Downloader Bot - Version 1.6
script_version="1.6"

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

# Color Scheme for YouTube Red and White
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m'  # No color

# Show banner with ASCII art
show_banner() {
    clear
    echo -e "${RED}"
    echo -e "â â¡„â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â£ â ‚"
    echo -e "â €â¢¹â¡„â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â €â¢ â¡‡â €"
    echo -e "â €â¢¸â£¿â£„â €â €â €â €â €â €â €â €â£€â£€â¡€â €â €â €â €â €â €â €â£ â£¿â¡‡â €"
    echo -e "â €â ¸â£¿â£¿â£·â£¦â£€â¡´â¢¶â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£·â£¦â£„â£´â£¾â£¿â£¿â ‡â €"
    echo -e "â €â €â¢»â£¿â£¿â£¿â£¿â£¿â¢¿â£¿â£¿â£¿â£¿â£¿â£¿â£‡â£¿â£¿â£¿â£¿â£¿â£¿â£¿â¡Ÿâ €â €"
    echo -e "â €â €â£ â£»â¡¿â ¿â¢¿â£«â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£»â£¿â£¿â£»â£¥â €â €"
    echo -e "â €â €â£¿â£¿â£¿â£¿â£¿â£¿â£¿â¡¿â£Ÿâ£¿â£¿â¢¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â¡†â €"
    echo -e "â €â ˜â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â¡¹â¡œâ ‹â¡¾â£¼â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â¡‡â €"
    echo -e "â €â €â£¿â£»â£¾â£­â£â£›â£›â£›â£›â£ƒâ£¿â£¾â£‡â£›â£›â£›â£›â£¯â£­â£·â£¿â£¿â¡‡â €"
    echo -e "â €â °â¢¿â£¿â£Žâ ™â ›â¢»â£¿â¡¿â ¿â Ÿâ£¿â£¿â¡Ÿâ ¿â ¿â£¿â¡›â ›â ‹â¢¹â£¿â¡¿â¢³â €"
    echo -e "â €â ˜â£¦â¡™â¢¿â£¦â£€â €â €â €â¢€â£¼â£¿â£¿â£³â£„â €â €â €â¢€â£ â¡¿â¢›â£¡â¡â €"
    echo -e "â €â €â ¹â£Ÿâ¢¿â£¾â£¿â£¿â£¿â£¿â£¿â£§â£¿â£¿â£§â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â£¿â¡¿â €â €"
    echo -e "â €â €â¢°â£¿â££â£¿â£­â¢¿â£¿â£±â£¶â£¿â£¿â£¿â£¿â£¿â£¿â£·â£¶â¢¹â£¿â£­â£»â£¶â£¿â£¿â €â €"
    echo -e "â €â €â ˆâ£¿â¢¿â£¿â£¿â â£¿â£¾â£›â ¿â£¿â£¿â£¿â Ÿâ£»â£¾â¡â¢¿â£¿â£¯â¡¿â¡â €â €"
    echo -e "â €â €â ¤â ¾â£Ÿâ£¿â¡â ˜â¢¨â£Ÿâ¢»â¡¿â ¾â ¿â ¾â¢¿â¡›â£¯â ˜â €â£¸â£½â¡›â ²â „â €"
    echo -e "â €â €â €â €â ˜â£¿â£§â €â ¸â ƒâ ˆâ ™â ›â ›â ‰â ˆâ â ¹â €â €â£¿â¡Ÿâ €â €â €â €"
    echo -e "â €â €â €â €â €â¢»â£¿â£¶â£€â£ â €â €â €â €â €â €â¢ â¡„â¡„â£¦â£¿â ƒâ €â €â €â €"
    echo -e "â €â €â €â €â €â ˜â£¿â£·â£»â£¿â¢·â¢¶â¢¶â¢¶â¢†â£—â¡¿â£‡â£·â£¿â¡¿â €â €â €â €â €"
    echo -e "â €â €â €â €â €â €â ˆâ »â£¿â£¿â£›â£­â£­â£­â£­â£­â£»â£¿â¡¿â ›â €â €â €â €â €â €"
    echo -e "â €â €â €â €â €â €â €â €â ˆâ »â ¿â Ÿâ ›â ›â ›â »â ¿â Ÿâ €â €â €â €â €â €â €â €"
    echo -e "${RED}==========================================="
    echo -e "          YouTube BOT         "
    echo -e "          Version 1.6         "
    echo -e "==========================================="
}

# Show banner before starting
show_banner

# Display script version
echo -e "${RED}YouTube Downloader Bot - Version $script_version${NC}"
echo "Choose an option:"
echo -e "${WHITE}1. Download Audio (FLAC format)${NC}"
echo -e "${WHITE}2. Download Video (choose quality)${NC}"
echo -e "${WHITE}3. Download Playlist (Audio or Video)${NC}"
echo -e "${WHITE}4. Download YouTube Channel Content${NC}"
read -p "Enter your choice (1, 2, 3, or 4): " choice

if [[ $choice == "3" ]]; then
    echo -e "${RED}Downloading a playlist.${NC}"
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
            echo -e "${RED}Failed to fetch playlist metadata. Please check the link.${NC}"
            exit 1
        fi

        playlist_name=$(sanitize_folder_name "$playlist_name")
        playlist_folder="$playlist_dir/$playlist_name"
        mkdir -p "$playlist_folder"
        echo "Playlist folder created: $playlist_folder"

        # Permission check before writing logs
        if [[ ! -w "$playlist_folder" ]]; then
            echo -e "${RED}Error: No write permission for $playlist_folder${NC}"
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
            echo -e "${RED}Invalid choice. Restart the bot.${NC}"
        fi
    else
        echo -e "${RED}Invalid playlist link.${NC}"
    fi
elif [[ $choice == "4" ]]; then
    echo -e "${RED}Downloading YouTube channel content.${NC}"
    # Function to download channel content
    echo -e "${WHITE}Enter the **YouTube Channel ID** (alphanumeric string starting with 'UC'):"
    
    while true; do
        read -p "> " channel_id

        # Validate Channel ID (must start with 'UC' and contain only alphanumeric characters, dashes, or underscores)
        if [[ ! "$channel_id" =~ ^UC[a-zA-Z0-9_-]+$ ]]; then
            echo -e "${RED}Invalid Channel ID! It must start with 'UC' and contain only alphanumeric characters, dashes, or underscores.${NC}"
            continue
        fi

        # Construct the channel URL using the provided Channel ID
        channel_url="https://www.youtube.com/channel/$channel_id"

        # Attempt to fetch the channel name
        channel_name=$(yt-dlp --get-filename -o "%(uploader)s" "$channel_url" 2>/dev/null)
        if [[ -z "$channel_name" ]]; then
            echo -e "${RED}Failed to fetch channel name. Please ensure the Channel ID is correct.${NC}"
            echo -e "Would you like to manually enter the channel name? (y/n)"
            read -p "> " manual_input
            if [[ "$manual_input" == "y" || "$manual_input" == "Y" ]]; then
                echo -e "Enter the channel name manually:"
                read -p "> " channel_name
                channel_name=$(sanitize_folder_name "$channel_name")
            else
                echo -e "${RED}Operation canceled. Returning to the main menu.${NC}"
                break
            fi
        else
            channel_name=$(sanitize_folder_name "$channel_name")
        fi

        # Create the channel folder
        channel_folder="$channel_dir/$channel_name"
        mkdir -p "$channel_folder"

        echo -e "Download as:"
        echo -e "${WHITE}1. Audio (FLAC format)${NC}"
        echo -e "${WHITE}2. Video (MP4 format)${NC}"
        read -p "> " media_choice

        case $media_choice in
        1) 
            echo -e "${RED}Downloading audio from the channel...${NC}"
            yt-dlp -f bestaudio --extract-audio --audio-format flac --audio-quality 0 -o "$channel_folder/%(title)s.%(ext)s" "$channel_url"
            ;;
        2) 
            echo -e "${RED}Downloading video from the channel...${NC}"
            yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o "$channel_folder/%(title)s.%(ext)s" "$channel_url"
            ;;
        *)
            echo -e "${RED}Invalid choice. Please select 1 or 2.${NC}"
            continue
            ;;
        esac

        # Confirm the download location
        echo -e "${WHITE}Content downloaded to: $channel_folder${NC}"
        break
    done
    echo -e "${WHITE}Download completed!${NC}"
else
    echo -e "${RED}Invalid choice. Restart the bot.${NC}"
fi
