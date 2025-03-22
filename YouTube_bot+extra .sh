#!/bin/bash

# Define color codes
RED='\033[1;31m'
NC='\033[0m' # No Color

# Display banner
echo -e "${RED}"
echo "############################################################"
echo "#                                                          #"
echo "#      ██╗   ██╗████████╗     ██████╗  ██████╗ ████████╗    #"
echo "#      ██║   ██║╚══██╔══╝     ██╔══██╗██╔═══██╗╚══██╔══╝    #"
echo "#      ██║   ██║   ██║        ██████╔╝██║   ██║   ██║       #"
echo "#      ██║   ██║   ██║        ██╔══██╗██║   ██║   ██║       #"
echo "#      ╚██████╔╝   ██║        ██████╔╝╚██████╔╝   ██║       #"
echo "#       ╚═════╝    ╚═╝        ╚═════╝  ╚═════╝    ╚═╝       #"
echo "#                                                          #"
echo "############################################################"
echo -e "${NC}"

# Welcome message
echo "Welcome to the YouTube Bot Installer!"
echo "This script will install the bot and all required dependencies."

# Step 1: Update and upgrade Termux packages
echo "Updating and upgrading Termux packages..."
pkg update && pkg upgrade -y

# Step 2: Install required tools
echo "Installing dependencies..."
pkg install -y python ffmpeg termux-api git curl

# Step 3: Install yt-dlp
echo "Installing yt-dlp..."
pip install yt-dlp

# Step 4: Define the output directories
audio_dir="/storage/emulated/0/Music/Songs"
video_dir="/storage/emulated/0/Videos"
mkdir -p "$audio_dir"  # Create the audio directory if it doesn't exist
mkdir -p "$video_dir"  # Create the video directory if it doesn't exist

# Step 5: Download the bot script
echo "Downloading the YouTube bot script..."
curl -o ~/youtube_bot.sh https://raw.githubusercontent.com/User1990i/YouTube-bot/main/youtube_bot.sh

# Step 6: Make the bot script executable
echo "Making the bot script executable..."
chmod +x ~/youtube_bot.sh

# Step 7: Add the bot to .bashrc for easy access
echo "Adding the bot to .bashrc..."
if ! grep -q "alias youtube-bot" ~/.bashrc; then
    echo 'alias youtube-bot="~/youtube_bot.sh"' >> ~/.bashrc
fi

# Step 8: Reload .bashrc
echo "Reloading .bashrc..."
source ~/.bashrc

# Step 9: Grant storage permissions
echo "Granting storage permissions..."
termux-setup-storage

# Completion message
echo "Installation complete!"
echo "You can now run the bot by typing 'youtube-bot' in Termux."

# Start YouTube Bot
echo -e "${RED}YouTube Downloader Bot is running.${NC}"
echo "Choose an option:"
echo "1. Download Audio (FLAC format)"
echo "2. Download Video (choose quality)"
read -p "Enter your choice (1 or 2): " choice

# Check the user's choice
if [[ $choice == "1" ]]; then
    echo "You selected to download audio in FLAC format."
    echo "Paste a YouTube link and press Enter to download the song."

    # Infinite loop for audio downloads
    while true; do
        read -p "> " youtube_link

        # Check if the input is a valid YouTube link
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo "Downloading audio in FLAC format from the provided link..."
            
            # Download the audio using yt-dlp
            yt-dlp -x --audio-format flac --ffmpeg-location $(which ffmpeg) -o "$audio_dir/%(title)s.%(ext)s" "$youtube_link"
            
            # Check if the download was successful
            if [ $? -eq 0 ]; then
                echo "Download completed successfully!"
                echo "The song has been saved in: $audio_dir"
            else
                echo "An error occurred while downloading the song. Please try again."
            fi
        else
            echo "Invalid input. Please paste a valid YouTube link."
        fi
    done

elif [[ $choice == "2" ]]; then
    echo "You selected to download video. Choose a quality:"
    echo "Available qualities: 144p, 240p, 360p, 480p, 720p, 1080p, 1440p, 2160p (4K), best"
    read -p "Enter your preferred quality (e.g., 720p, 1080p, best): " quality

    echo "Paste a YouTube link and press Enter to download the video."
    
    # Infinite loop for video downloads
    while true; do
        read -p "> " youtube_link

        # Check if the input is a valid YouTube link
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo "Downloading video in $quality quality from the provided link..."
            
            # Download the video using yt-dlp
            yt-dlp -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" --merge-output-format mp4 -o "$video_dir/%(title)s.%(ext)s" "$youtube_link"
            
            # Check if the download was successful
            if [ $? -eq 0 ]; then
                echo "Download completed successfully!"
                echo "The video has been saved in: $video_dir"
            else
                echo "An error occurred while downloading the video. Please try again."
            fi
        else
            echo "Invalid input. Please paste a valid YouTube link."
        fi
    done

else
    echo "Invalid choice. Please restart the bot and enter 1 or 2."
fi
