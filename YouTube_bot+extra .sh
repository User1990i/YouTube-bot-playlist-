#!/bin/bash

# GitHub Repository
REPO_URL="https://raw.githubusercontent.com/User1990i/YouTube-bot-playlist-/main/YouTube_bot.sh"
SCRIPT_PATH="$HOME/youtube_bot.sh"

# Function to check and update the bot
update_bot() {
    echo "Checking for updates..."
    curl -s -o /tmp/latest_youtube_bot.sh "$REPO_URL"

    if [ $? -eq 0 ]; then
        if ! cmp -s /tmp/latest_youtube_bot.sh "$SCRIPT_PATH"; then
            echo "A new update is available!"
            read -p "Do you want to update? (y/n): " update_choice
            if [[ "$update_choice" == "y" ]]; then
                mv /tmp/latest_youtube_bot.sh "$SCRIPT_PATH"
                chmod +x "$SCRIPT_PATH"
                echo "Update complete! Restarting the bot..."
                exec bash "$SCRIPT_PATH"  # Restart bot after update
            fi
        else
            echo "You already have the latest version."
        fi
    else
        echo "Failed to check for updates. Running the bot..."
    fi
}

# Run the update function
update_bot

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
            echo "Paste the YouTube playlist link and press Enter."
            
            while true; do
                read -p "> " playlist_link
                if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
                    playlist_name=$(yt-dlp --print "%(playlist_title)s" "$playlist_link" | head -n 1 | sed 's/ /_/g')
                    output_dir="/storage/emulated/0/Music/Playlists/$playlist_name"
                    mkdir -p "$output_dir"

                    echo "Downloading playlist as FLAC audio..."
                    yt-dlp -x --audio-format flac -o "$output_dir/%(title)s.%(ext)s" "$playlist_link"
                    
                    if [ $? -eq 0 ]; then
                        echo "Playlist download complete! Saved in: $output_dir"
                        echo "Do you want to merge all downloaded audio files into a single file?"
                        echo "1. Yes (Merge into one FLAC file)"
                        echo "2. No (Keep as separate files)"
                        read -p "Enter your choice (1 or 2): " merge_choice

                        if [[ $merge_choice == "1" ]]; then
                            merged_file="$output_dir/Merged_Playlist.flac"
                            ffmpeg -y -i "concat:$(ls "$output_dir"/*.flac | tr '\n' '|' | sed 's/|$//')" -acodec copy "$merged_file"
                            echo "Merge complete! Saved as: $merged_file"
                        else
                            echo "Keeping individual files."
                        fi
                    else
                        echo "Error downloading the playlist."
                    fi
                else
                    echo "Invalid playlist link."
                fi
            done

        elif [[ $playlist_choice == "2" ]]; then
            echo "Paste the YouTube playlist link and press Enter."
            
            while true; do
                read -p "> " playlist_link
                if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
                    playlist_name=$(yt-dlp --print "%(playlist_title)s" "$playlist_link" | head -n 1 | sed 's/ /_/g')
                    output_dir="/storage/emulated/0/Videos/Playlists/$playlist_name"
                    mkdir -p "$output_dir"

                    echo "Downloading playlist videos..."
                    yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$output_dir/%(title)s.%(ext)s" "$playlist_link"
                    
                    if [ $? -eq 0 ]; then
                        echo "Playlist download complete! Saved in: $output_dir"
                    else
                        echo "Error downloading the playlist."
                    fi
                else
                    echo "Invalid playlist link."
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
