#!/bin/bash

# YouTube Downloader Bot - Version 1.8
script_version="1.8"

# Define output directories (No spaces in paths)
base_dir="/storage/emulated/0/Music_Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
channel_dir="$base_dir/Channels"
mkdir -p "$audio_dir" "$video_dir" "$playlist_dir" "$channel_dir"  # Create necessary directories

# Color Scheme for YouTube Red and White
RED='\033[0;31m'
WHITE='\033[1;37m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No color

# Function to sanitize folder names
sanitize_folder_name() {
    local input="$1"
    # Remove unwanted characters, including newlines and spaces
    local sanitized=$(echo "$input" | tr -cd '[:alnum:][:space:]._-' | sed 's/[[:space:]]\+/_/g')
    # Replace any newline or carriage return with an underscore
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
    echo -e "${WHITE}Use shortcuts:${NC}"
    echo -e "${WHITE}- Run the bot using 'YT'${NC}"
    echo -e "${WHITE}- Auto-update with 'YT --update'${NC}"
}

# Setup Guide
setup_guide() {
    echo -e "${YELLOW}Welcome to the setup guide for the YouTube Downloader Bot.${NC}"
    echo -e "${WHITE}Follow these steps to configure the bot for easier use:${NC}"
    echo -e "${BLUE}1. Save this script as 'youtube_bot.sh' in your home directory:${NC}"
    echo -e "${WHITE}   mv /path/to/your/script/youtube_bot.sh ~/youtube_bot.sh${NC}"
    echo -e "${BLUE}2. Make the script executable:${NC}"
    echo -e "${WHITE}   chmod +x ~/youtube_bot.sh${NC}"
    echo -e "${BLUE}3. Create a shortcut for the bot:${NC}"
    echo -e "${WHITE}   For Termux:${NC}"
    echo -e "${WHITE}      ln -s ~/youtube_bot.sh /data/data/com.termux/files/usr/bin/YT${NC}"
    echo -e "${WHITE}   For Linux:${NC}"
    echo -e "${WHITE}      sudo ln -s ~/youtube_bot.sh /usr/local/bin/YT${NC}"
    echo -e "${BLUE}4. Test the shortcut:${NC}"
    echo -e "${WHITE}   Run 'YT' to start the bot.${NC}"
    echo -e "${BLUE}5. Optional: Add a Termux widget shortcut:${NC}"
    echo -e "${WHITE}   Install Termux:Widget from the Play Store or F-Droid.${NC}"
    echo -e "${WHITE}   Create a file named 'YT' in ~/.shortcuts/:${NC}"
    echo -e "${WHITE}      mkdir -p ~/.shortcuts && echo '~/youtube_bot.sh' > ~/.shortcuts/YT${NC}"
    echo -e "${WHITE}   Make it executable:${NC}"
    echo -e "${WHITE}      chmod +x ~/.shortcuts/YT${NC}"
    echo -e "${BLUE}6. Use the auto-update feature:${NC}"
    echo -e "${WHITE}   Run 'YT --update' to fetch the latest version of the bot.${NC}"
    echo -e "${YELLOW}Setup complete! You can now use the bot easily.${NC}"
    read -p "Press Enter to continue."
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
    echo -e "${YELLOW}Checking for updates...${NC}"
    curl -o ~/youtube_bot.sh "https://raw.githubusercontent.com/User1990i/YouTube-bot-playlist-/refs/heads/main/YouTube_bot%2Bextra%20.sh" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        chmod +x ~/youtube_bot.sh
        echo -e "${GREEN}Update successful! Restarting the bot...${NC}"
        bash ~/youtube_bot.sh
        exit 0
    else
        echo -e "${RED}Failed to update. Please check your internet connection.${NC}"
    fi
}

# Main menu
main_menu() {
    clear
    show_banner
    echo -e "${WHITE}Choose an option:${NC}"
    echo -e "${RED}1. Download Audio (FLAC format)${NC}"
    echo -e "${RED}2. Download Video (choose quality)${NC}"
    echo -e "${RED}3. Download Playlist (Audio or Video)${NC}"
    echo -e "${RED}4. Download YouTube Channel Content${NC}"
    echo -e "${RED}5. Exit${NC}"
    echo -e "${RED}6. Setup Guide (For New Users)${NC}"
    read -p "Enter your choice (1, 2, 3, 4, 5, or 6): " choice

    case $choice in
    1) download_audio ;;
    2) download_video ;;
    3) download_playlist ;;
    4) download_channel ;;
    5) exit_bot ;;
    6) setup_guide ;;
    *) 
        echo -e "${RED}Invalid choice. Please try again.${NC}"
        main_menu
        ;;
    esac
}

# Rest of the script remains unchanged...
