#!/bin/bash

# Define the output directories
audio_dir="/storage/emulated/0/Music/Songs"
video_dir="/storage/emulated/0/Videos"
mkdir -p "$audio_dir"  # Create the audio directory if it doesn't exist
mkdir -p "$video_dir"  # Create the video directory if it doesn't exist

# Welcome message
echo "YouTube Downloader Bot is running."
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
            yt-dlp -x --audio-format flac -o "$audio_dir/%(title)s.%(ext)s" "$youtube_link"
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
