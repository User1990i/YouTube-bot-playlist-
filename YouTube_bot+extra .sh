#!/bin/bash

# YouTube Downloader Bot - Version 1.13
script_version="1.13"

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
    echo "${sanitized^}"  # Capitalize the first letter and trim to 50 characters
}

# Color Scheme for Blood Red Banners, Bold Blue Headings, and White Subtext
RED='\033[0;31m'
BLUE='\033[1;34m'  # Bold blue for headings
WHITE='\033[1;37m' # Bold white for subtext
NC='\033[0m'       # No color

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
    echo -e "⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⡹⡜⠋⡾⣼⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀"
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
}

# Go Back function
go_back() {
    read -p "Press Enter to go back to the main menu."
    main_menu
}

# Main menu
main_menu() {
    clear
    show_banner
    echo -e "${WHITE}Choose an option:${NC}"
    echo -e "${BLUE}1. Download Audio (FLAC or MP3 format)${NC}"
    echo -e "${BLUE}2. Download Video (choose quality)${NC}"
    echo -e "${BLUE}3. Download Playlist (Audio or Video)${NC}"
    echo -e "${BLUE}4. Download YouTube Channel Content${NC}"
    read -p "Enter your choice (1, 2, 3, or 4): " choice

    case $choice in
    1) download_audio ;;
    2) download_video ;;
    3) download_playlist ;;
    4) download_channel ;;
    *) 
        echo -e "${RED}Invalid choice. Please try again.${NC}"
        main_menu
        ;;
    esac
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
    echo -e "${BLUE}Downloading Audio${NC}"
    echo -e "${WHITE}Choose the audio format:${NC}"
    echo -e "${WHITE}1. FLAC${NC}"
    echo -e "${WHITE}2. MP3${NC}"
    read -p "Enter your choice (1 or 2): " audio_format_choice

    case $audio_format_choice in
    1) audio_format="flac" ;;
    2) audio_format="mp3" ;;
    *) 
        echo -e "${RED}Invalid choice. Restarting...${NC}"
        download_audio
        return
        ;;
    esac

    echo -e "${WHITE}Paste a YouTube link and press Enter to download the song.${NC}"
    while true; do
        read -p "> " youtube_link
        if validate_youtube_link "$youtube_link"; then
            echo -e "${WHITE}Downloading audio in ${audio_format^^} format from the provided link...${NC}"
            yt-dlp --continue -x --audio-format "$audio_format" --audio-quality 0 -o "$audio_dir/%(title)s.%(ext)s" "$youtube_link"
            if [ $? -eq 0 ]; then
                echo -e "${WHITE}Download completed successfully!${NC}"
                echo -e "The song has been saved in: $audio_dir"
            else
                echo -e "${RED}An error occurred while downloading the song. Please try again.${NC}"
            fi
            break
        else
            echo -e "${RED}Invalid input. Please paste a valid YouTube link.${NC}"
        fi
    done
    go_back
}

# Function to download video
download_video() {
    show_banner
    echo -e "${BLUE}Downloading Video${NC}"
    echo -e "${WHITE}Available qualities: 144p, 240p, 360p, 480p, 720p, 1080p, 1440p, 2160p (4K), best${NC}"
    read -p "Enter your preferred quality (e.g., 720p, best): " quality
    echo -e "${WHITE}Would you like to include subtitles? (y/n)${NC}"
    read -p "> " include_subtitles

    if [[ $include_subtitles == "y" || $include_subtitles == "Y" ]]; then
        subtitle_flag="--write-sub --sub-lang en"
    else
        subtitle_flag=""
    fi

    echo -e "${WHITE}Paste a YouTube link and press Enter to download the video.${NC}"
    while true; do
        read -p "> " youtube_link
        if validate_youtube_link "$youtube_link"; then
            echo -e "${WHITE}Downloading video in $quality quality from the provided link...${NC}"
            yt-dlp --continue $subtitle_flag -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "$youtube_link"
            if [ $? -eq 0 ]; then
                echo -e "${WHITE}Download completed successfully!${NC}"
                echo -e "The video has been saved in: $video_dir"
            else
                echo -e "${RED}An error occurred while downloading the video. Please try again.${NC}"
            fi
            break
        else
            echo -e "${RED}Invalid input. Please paste a valid YouTube link.${NC}"
        fi
    done
    go_back
}

# Function to download playlist (continued)
download_playlist() {
    show_banner
    echo -e "${BLUE}Downloading Playlist${NC}"
    echo -e "${WHITE}Choose the type of content to download:${NC}"
    echo -e "${WHITE}1. Audio (FLAC or MP3)${NC}"
    echo -e "${WHITE}2. Video (choose quality)${NC}"
    read -p "Enter your choice (1 or 2): " playlist_choice

    if [[ $playlist_choice == "1" ]]; then
        # Audio download
        echo -e "${WHITE}Choose the audio format:${NC}"
        echo -e "${WHITE}1. FLAC${NC}"
        echo -e "${WHITE}2. MP3${NC}"
        read -p "Enter your choice (1 or 2): " audio_format_choice

        case $audio_format_choice in
        1) audio_format="flac" ;;
        2) audio_format="mp3" ;;
        *) 
            echo -e "${RED}Invalid choice. Restarting...${NC}"
            download_playlist
            return
            ;;
        esac
    elif [[ $playlist_choice == "2" ]]; then
        # Video download
        echo -e "${WHITE}Available qualities: 144p, 240p, 360p, 480p, 720p, 1080p, 1440p, 2160p (4K), best${NC}"
        read -p "Enter your preferred quality (e.g., 720p, best): " quality
        echo -e "${WHITE}Would you like to include subtitles? (y/n)${NC}"
        read -p "> " include_subtitles

        if [[ $include_subtitles == "y" || $include_subtitles == "Y" ]]; then
            subtitle_flag="--write-sub --sub-lang en"
        else
            subtitle_flag=""
        fi
    else
        echo -e "${RED}Invalid choice. Restarting...${NC}"
        download_playlist
        return
    fi

    echo -e "${WHITE}Paste a YouTube playlist link.${NC}"
    read -p "> " playlist_link

    if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
        echo -e "${WHITE}Fetching playlist metadata...${NC}"
        
        # Extract playlist name safely
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
            echo -e "${WHITE}Downloading playlist as ${audio_format^^}...${NC}"
            yt-dlp --continue --yes-playlist -x --audio-format "$audio_format" --audio-quality 0 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link" \
                2> "$playlist_folder/error_log.txt" | tee -a "$playlist_folder/download_log.txt"
        elif [[ $playlist_choice == "2" ]]; then
            echo -e "${WHITE}Downloading playlist as MP4 in $quality quality...${NC}"
            yt-dlp --continue --yes-playlist $subtitle_flag -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link" \
                2> "$playlist_folder/error_log.txt" | tee -a "$playlist_folder/download_log.txt"
        fi
    else
        echo -e "${RED}Invalid playlist link.${NC}"
        go_back
    fi
}

# Function to download channel content
download_channel() {
    show_banner
    echo -e "${BLUE}Downloading YouTube Channel Content${NC}"
    echo -e "${WHITE}Where would you like to save the downloaded content?${NC}"
    echo -e "${WHITE}1. Save Locally${NC}"
    echo -e "${WHITE}2. Backup to Cloud Storage${NC}"
    read -p "Enter your choice (1 or 2): " save_option

    if [[ $save_option == "2" ]]; then
        manage_cloud_storage
    else
        echo -e "${WHITE}Local storage selected. Content will be saved locally.${NC}"
    fi

    # Prompt for YouTube Channel ID
    retries=3
    while [[ $retries -gt 0 ]]; do
        echo -e "${BLUE}Enter the **YouTube Channel ID** (alphanumeric string starting with 'UC'):${NC}"
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
        channel_name=$(yt-dlp --get-filename -o "%(uploader)s" "$channel_url" 2>/dev/null)
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

        break
    done

    echo -e "${WHITE}Choose the type of content to download:${NC}"
    echo -e "${WHITE}1. Shorts${NC}"
    echo -e "${WHITE}2. Videos (Filter by duration)${NC}"
    echo -e "${WHITE}3. Playlists Only${NC}"
    read -p "Enter your choice (1, 2, or 3): " content_type

    case $content_type in
    1)
        # Download Shorts
        echo -e "${WHITE}Downloading Shorts from the channel...${NC}"
        yt-dlp --continue --match-filter "duration < 60" -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$channel_folder/%(title)s.%(ext)s" "$channel_url"
        ;;
    2)
        # Download Videos with duration filter
        echo -e "${WHITE}Filter videos by duration:${NC}"
        echo -e "${WHITE}1. All videos${NC}"
        echo -e "${WHITE}2. Videos longer than 1 hour${NC}"
        echo -e "${WHITE}3. Videos shorter than 30 minutes${NC}"
        read -p "Enter your choice (1, 2, or 3): " duration_filter

        case $duration_filter in
        1)
            match_filter=""
            echo -e "${WHITE}Downloading all videos from the channel...${NC}"
            ;;
        2)
            match_filter="duration > 3600"
            echo -e "${WHITE}Downloading videos longer than 1 hour from the channel...${NC}"
            ;;
        3)
            match_filter="duration < 1800"
            echo -e "${WHITE}Downloading videos shorter than 30 minutes from the channel...${NC}"
            ;;
        *)
            echo -e "${RED}Invalid choice. Restarting...${NC}"
            download_channel
            return
            ;;
        esac

        yt-dlp --continue --match-filter "$match_filter" -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$channel_folder/%(title)s.%(ext)s" "$channel_url"
        ;;
    3)
        # Download Playlists Only
        echo -e "${WHITE}Downloading playlists from the channel...${NC}"
        yt-dlp --continue --flat-playlist --yes-playlist -o "$channel_folder/%(playlist_title)s/%(title)s.%(ext)s" "$channel_url"
        ;;
    *)
        echo -e "${RED}Invalid choice. Restarting...${NC}"
        download_channel
        return
        ;;
    esac

    # If Cloud Storage backup was selected, upload content
    if [[ $save_option == "2" ]]; then
        echo -e "${WHITE}Uploading to Cloud Storage...${NC}"
        rclone copy "$channel_folder" "$remote_name:/YouTube_Channel_Backups/$channel_name" --progress
        if [ $? -eq 0 ]; then
            echo -e "${WHITE}Upload to Cloud Storage completed successfully!${NC}"
        else
            echo -e "${RED}An error occurred while uploading to Cloud Storage.${NC}"
        fi
    else
        echo -e "${WHITE}Content saved locally in: $channel_folder${NC}"
    fi

    # Confirm the download location
    echo -e "${WHITE}Content downloaded to: $channel_folder${NC}"
    go_back
}

# Function to manage cloud storage
manage_cloud_storage() {
    echo -e "${BLUE}Manage Cloud Storage:${NC}"
    echo -e "${WHITE}1. Add New Cloud Storage${NC}"
    echo -e "${WHITE}2. Delete Existing Cloud Storage${NC}"
    echo -e "${WHITE}3. Use Existing Cloud Storage${NC}"
    read -p "Enter your choice (1, 2, or 3): " cloud_choice

    case $cloud_choice in
    1)
        add_cloud_storage
        ;;
    2)
        delete_cloud_storage
        ;;
    3)
        use_existing_cloud_storage
        ;;
    *)
        echo -e "${RED}Invalid choice. Returning to the main menu.${NC}"
        go_back
        ;;
    esac
}

# Function to add new cloud storage
add_cloud_storage() {
    echo -e "${WHITE}Adding a new cloud storage...${NC}"
    echo -e "${WHITE}Which cloud storage service would you like to use?${NC}"
    echo -e "${WHITE}1. Google Drive${NC}"
    echo -e "${WHITE}2. Dropbox${NC}"
    echo -e "${WHITE}3. Other (Custom)${NC}"
    read -p "Enter your choice (1, 2, or 3): " storage_choice

    case $storage_choice in
    1) storage_type="drive" ;;
    2) storage_type="dropbox" ;;
    3) 
        echo -e "${WHITE}Enter the custom storage type (e.g., s3, onedrive):${NC}"
        read -p "> " storage_type
        ;;
    *) 
        echo -e "${RED}Invalid choice. Returning to the main menu.${NC}"
        go_back
        ;;
    esac

    echo -e "${WHITE}Enter a name for this cloud storage (e.g., google-drive):${NC}"
    read -p "> " remote_name

    echo -e "${WHITE}Setting up $remote_name as $storage_type...${NC}"
    rclone config create "$remote_name" "$storage_type"

    echo -e "${WHITE}Authentication required. Opening browser for login...${NC}"
    rclone config reconnect "$remote_name"

    echo -e "${WHITE}Cloud storage '$remote_name' added successfully!${NC}"
}

# Function to delete existing cloud storage
delete_cloud_storage() {
    echo -e "${WHITE}Deleting existing cloud storage...${NC}"
    echo -e "${WHITE}Available cloud storages:${NC}"
    rclone listremotes
    echo -e "${WHITE}Enter the name of the cloud storage to delete:${NC}"
    read -p "> " remote_name

    echo -e "${WHITE}Deleting '$remote_name'...${NC}"
    rclone config delete "$remote_name"
    echo -e "${WHITE}Cloud storage '$remote_name' deleted successfully!${NC}"
}

# Function to use existing cloud storage
use_existing_cloud_storage() {
    echo -e "${WHITE}Using existing cloud storage...${NC}"
    echo -e "${WHITE}Available cloud storages:${NC}"
    rclone listremotes
    echo -e "${WHITE}Enter the name of the cloud storage to use:${NC}"
    read -p "> " remote_name

    if rclone listremotes | grep -q "$remote_name"; then
        echo -e "${WHITE}Selected cloud storage: $remote_name${NC}"
    else
        echo -e "${RED}Cloud storage '$remote_name' not found. Please try again.${NC}"
        manage_cloud_storage
    fi
}

# Main Script Execution
main_menu
