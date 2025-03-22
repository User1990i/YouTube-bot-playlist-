#!/bin/bash

# Function to display a colorful YTBot banner in multiple shades of red
display_banner() {
    echo -e "\e[31m██████╗ ██╗   ██╗███████╗██╗  ██╗███████╗██████╗ \e[0m"  # Dark Red
    echo -e "\e[91m██╔══██╗╚██╗ ██╔╝██╔════╝██║  ██║██╔════╝██╔══██╗\e[0m"  # Light Red
    echo -e "\e[38;5;196m██████╔╝ ╚████╔╝ █████╗  ███████║█████╗  ██████╔╝ ♥️ YTBot\e[0m"  # Bright Red
    echo -e "\e[38;5;203m██╔══██╗  ╚██╔╝  ██╔══╝  ██╔══██║██╔══╝  ██╔══██╗\e[0m"  # Salmon Red
    echo -e "\e[38;5;204m██████╔╝   ██║   ███████╗██║  ██║███████╗██║  ██║\e[0m"  # Tomato Red
    echo -e "\e[38;5;209m╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝\e[0m"  # Coral Red
    echo -e "\e[38;5;217mYouTube Downloader Bot v1.F - Welcome!\e[0m"     # Light Coral
}

# Display the banner
display_banner

# Ensure script runs from its directory
cd "$(dirname "$0")"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Trap Ctrl+C (SIGINT) to gracefully exit the bot
trap 'echo "Exiting bot..."; exit 0' SIGINT

# Ensure yt-dlp is installed
if ! command_exists yt-dlp; then
    echo "yt-dlp is not installed. Installing..."
    pkg update -y && pkg install yt-dlp -y
fi

# Function to sanitize and truncate playlist names
sanitize_name() {
    local name="$1"
    # Replace newlines, tabs, and other special characters with underscores
    name=$(echo "$name" | tr -d '\n' | tr -cd '[:alnum:]._- ')
    # Truncate the name to 50 characters
    name=$(echo "$name" | cut -c 1-50)
    echo "$name"
}

# Function to download YouTube content with sanitized file names
download_content() {
    local url=$1
    local format=$2
    local output_dir=$3
    local file_format=$4

    # Create the output directory if it doesn't exist
    mkdir -p "$output_dir"

    echo "Downloading..."
    
    # Use yt-dlp with restricted file names and truncated titles
    yt-dlp -f "$format" --restrict-filenames --parse-metadata "title:%(title).50s" -o "$output_dir/%(title)s.$file_format" "$url"
    echo "Download complete!"
}

# Function to download a playlist
download_playlist() {
    read -p "Enter playlist URL: " url

    # Extract playlist name and sanitize it
    local playlist_name=$(yt-dlp --flat-playlist --get-title "$url" | head -n 1)
    playlist_name=$(sanitize_name "$playlist_name")
    local output_dir="/storage/emulated/0/Music/Songs/$playlist_name"

    # Prompt user for format choice
    echo "Select format:"
    echo "1. FLAC (Audio)"
    echo "2. MP4 (Video)"
    read -p "Choose an option (1/2): " format_choice

    # Create the output directory
    mkdir -p "$output_dir"

    if [[ $format_choice == 1 ]]; then
        # FLAC download
        echo "Downloading playlist in FLAC format..."
        yt-dlp -f "bestaudio --extract-audio --audio-format flac" --restrict-filenames --parse-metadata "title:%(title).50s" -o "$output_dir/%(title)s.flac" "$url"

        # Prompt to merge audio
        read -p "Merge audio files into one? (Y/N): " merge_choice
        if [[ $merge_choice == "Y" || $merge_choice == "y" ]]; then
            echo "Merging audio files..."

            # Merge all FLAC files into one
            local merged_file="$output_dir/${playlist_name}_Merged.flac"
            find "$output_dir" -name "*.flac" -exec ffmpeg -i "concat:$(echo {} | paste -sd '|' -)" -c copy "$merged_file" \;

            # Delete individual singles after merging
            find "$output_dir" -name "*.flac" ! -name "*_Merged.flac" -delete

            echo "Merged audio saved as: $merged_file"
        else
            echo "Individual FLAC files saved in: $output_dir"
        fi
    elif [[ $format_choice == 2 ]]; then
        # MP4 download
        echo "Downloading playlist in MP4 format..."
        yt-dlp -f "best" --restrict-filenames --parse-metadata "title:%(title).50s" -o "$output_dir/%(title)s.mp4" "$url"
        echo "MP4 files saved in: $output_dir"
    else
        echo "Invalid option selected. Exiting..."
        return
    fi
}

# Function to check for updates
update_bot() {
    echo "Updating yt-dlp..."
    yt-dlp -U
    echo "Update complete!"
}

# Function to display menu
show_menu() {
    while true; do
        echo "YouTube Downloader Bot"
        echo "1. Download Audio (FLAC)"
        echo "2. Download Video (MP4)"
        echo "3. Download Playlist"
        echo "4. Check for Updates"
        echo "5. Exit"
        read -p "Choose an option: " choice

        case $choice in
            1) 
                read -p "Enter video URL: " url
                download_content "$url" "bestaudio --extract-audio --audio-format flac" "/storage/emulated/0/Music/Songs" "flac"
                ;;
            2) 
                read -p "Enter video URL: " url
                download_content "$url" "best" "/storage/emulated/0/Videos" "mp4"
                ;;
            3) 
                download_playlist
                ;;
            4) 
                update_bot
                ;;
            5) 
                echo "Exiting..."
                exit 0
                ;;
            *) 
                echo "Invalid option, try again."
                ;;
        esac
    done
}

# Run the menu
show_menu
