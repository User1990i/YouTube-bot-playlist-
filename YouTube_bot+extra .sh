#!/bin/bash

# Welcome message
echo "Welcome to the YouTube Bot Installer & Downloader!"
echo "This script will install required dependencies and set up the bot."

# Step 1: Update and upgrade Termux packages
echo "Updating and upgrading Termux packages..."
pkg update && pkg upgrade -y

# Step 2: Install required tools
echo "Installing dependencies..."
pkg install -y python ffmpeg termux-api git curl nano

# Step 3: Install yt-dlp
echo "Installing yt-dlp..."
pip install yt-dlp

# Step 4: Grant storage permissions
echo "Granting storage permissions..."
termux-setup-storage

# Define output directories
audio_dir="/storage/emulated/0/Music/Songs"
video_dir="/storage/emulated/0/Videos"
playlist_audio_dir="/storage/emulated/0/Music/Playlists"
playlist_video_dir="/storage/emulated/0/Videos/Playlists"
mkdir -p "$audio_dir" "$video_dir" "$playlist_audio_dir" "$playlist_video_dir"

# Step 5: Set up alias for easy access
echo "Setting up alias for easy access..."
if ! grep -q "alias youtube-bot" ~/.bashrc; then
    echo 'alias youtube-bot="bash ~/youtube_bot.sh"' >> ~/.bashrc
fi

# Step 6: Configure CTRL + Y to start the bot
echo "Configuring CTRL + Y key binding..."
mkdir -p ~/.termux
echo "extra-keys = [['CTRL', 'ALT', 'ESC', 'TAB', 'Y']]" > ~/.termux/termux.properties

if ! grep -q 'bind "\C-y":"youtube-bot\n"' ~/.bashrc; then
    echo 'bind "\C-y":"youtube-bot\n"' >> ~/.bashrc
fi

# Step 7: Reload Termux settings
echo "Reloading Termux settings..."
termux-reload-settings
source ~/.bashrc

# Completion message
echo "Installation complete!"
echo "Now you can start the bot by typing 'youtube-bot' or pressing CTRL + Y in Termux."

# ---- YouTube Bot Functionality ----
while true; do
    echo "YouTube Downloader Bot is running."
    echo "Choose an option:"
    echo "1. Download Audio (FLAC format)"
    echo "2. Download Video (choose quality)"
    echo "3. Download Playlist"
    echo "4. Exit"
    read -p "Enter your choice (1, 2, 3, or 4): " choice

    if [[ $choice == "3" ]]; then
        echo "You selected to download a playlist."
        echo "Choose an option:"
        echo "1. Download as Songs (FLAC)"
        echo "2. Download as Videos (MP4)"
        read -p "Enter your choice (1 or 2): " playlist_choice

        if [[ $playlist_choice == "1" ]]; then
            echo "You selected to download the playlist as FLAC audio."
            echo "Paste the YouTube playlist link and press Enter."
            
            while true; do
                read -p "> " playlist_link
                if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
                    playlist_name=$(yt-dlp --print "%(playlist_title)s" "$playlist_link" | head -n 1 | sed 's/ /_/g')
                    output_dir="$playlist_audio_dir/$playlist_name"
                    mkdir -p "$output_dir"

                    echo "Downloading playlist as FLAC audio..."
                    yt-dlp -x --audio-format flac --ffmpeg-location $(which ffmpeg) -o "$output_dir/%(title)s.%(ext)s" "$playlist_link"
                    
                    if [ $? -eq 0 ]; then
                        echo "Playlist download complete! Saved in: $output_dir"

                        # Ask if user wants to merge audio
                        echo "Do you want to merge all downloaded audio files into a single file?"
                        echo "1. Yes (Merge into one FLAC file)"
                        echo "2. No (Keep as separate files)"
                        read -p "Enter your choice (1 or 2): " merge_choice

                        if [[ $merge_choice == "1" ]]; then
                            echo "Merging all audio files into one..."
                            merged_file="$output_dir/Merged_Playlist.flac"
                            ffmpeg -y -i "concat:$(ls "$output_dir"/*.flac | tr '\n' '|' | sed 's/|$//')" -acodec copy "$merged_file"

                            if [ $? -eq 0 ]; then
                                echo "Merge complete! Saved as: $merged_file"
                            else
                                echo "Error merging the files."
                            fi
                        else
                            echo "Keeping individual files."
                        fi
                    else
                        echo "Error downloading the playlist. Try again."
                    fi
                else
                    echo "Invalid input. Please paste a valid YouTube playlist link."
                fi
            done

        elif [[ $playlist_choice == "2" ]]; then
            echo "You selected to download the playlist as Videos."
            echo "Paste the YouTube playlist link and press Enter."
            
            while true; do
                read -p "> " playlist_link
                if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
                    playlist_name=$(yt-dlp --print "%(playlist_title)s" "$playlist_link" | head -n 1 | sed 's/ /_/g')
                    output_dir="$playlist_video_dir/$playlist_name"
                    mkdir -p "$output_dir"

                    echo "Downloading playlist videos..."
                    yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$output_dir/%(title)s.%(ext)s" "$playlist_link"
                    
                    if [ $? -eq 0 ]; then
                        echo "Playlist download complete! Saved in: $output_dir"
                    else
                        echo "Error downloading the playlist. Try again."
                    fi
                else
                    echo "Invalid input. Please paste a valid YouTube playlist link."
                fi
            done

        else
            echo "Invalid choice. Returning to the main menu."
        fi

    elif [[ $choice == "4" ]]; then
        echo "Exiting YouTube Bot. Goodbye!"
        exit 0
    else
        echo "Invalid choice. Please enter 1, 2, 3, or 4."
    fi
done
