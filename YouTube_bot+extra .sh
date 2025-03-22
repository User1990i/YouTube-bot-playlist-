#!/bin/bash

# Welcome message
echo "Welcome to the YouTube Bot Installer!"
echo "This script will install all required dependencies and create the YouTube bot script."

# Step 1: Update and upgrade Termux packages
echo "Updating and upgrading Termux packages..."
pkg update && pkg upgrade -y

# Step 2: Install required tools
echo "Installing dependencies..."
pkg install -y python ffmpeg termux-api git curl

# Step 3: Install yt-dlp using pip
echo "Installing yt-dlp..."
pip install yt-dlp

# Step 4: Create the YouTube bot script
echo "Creating the YouTube bot script..."
cat << 'EOF' > ~/youtube_bot.sh
#!/bin/bash

# Define the output directories
base_dir="/storage/emulated/0/Music & Vids"
audio_dir="$base_dir/Songs"
video_dir="$base_dir/Videos"
playlist_dir="$base_dir/playlists"
mkdir -p "$audio_dir"  # Create the audio directory if it doesn't exist
mkdir -p "$video_dir"  # Create the video directory if it doesn't exist
mkdir -p "$playlist_dir"  # Create the playlists directory if it doesn't exist

# Function to sanitize folder names
sanitize_folder_name() {
    local input="$1"
    # Remove duplicate lines
    local sanitized=$(echo "$input" | awk '!seen[$0]++')
    # Replace special characters with underscores
    sanitized=$(echo "$sanitized" | tr -cd '[:alnum:][:space:]._-/' | sed 's/[[:space:]]\+/_/g')
    # Trim to a maximum length of 50 characters
    sanitized=${sanitized:0:50}
    echo "$sanitized"
}

# Welcome message
echo "YouTube Downloader Bot is running."
echo "Choose an option:"
echo "1. Download Audio (FLAC format)"
echo "2. Download Video (choose quality)"
echo "3. Download Playlist (Audio or Video)"
read -p "Enter your choice (1, 2, or 3): " choice

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
elif [[ $choice == "3" ]]; then
    echo "You selected to download a playlist."
    echo "Choose an option:"
    echo "1. Download Playlist as Audio (FLAC format)"
    echo "2. Download Playlist as Video (MP4 format)"
    read -p "Enter your choice (1 or 2): " playlist_choice
    echo "Paste a YouTube playlist link and press Enter to download the playlist."
    read -p "> " playlist_link
    # Check if the input is a valid YouTube playlist link
    if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
        echo "Fetching playlist metadata. Please wait..."
        # Extract the playlist name
        playlist_name=$(yt-dlp --get-filename -o "%(playlist_title)s" "$playlist_link")
        # Sanitize the playlist name
        playlist_name=$(sanitize_folder_name "$playlist_name")
        playlist_folder="$playlist_dir/$playlist_name"
        mkdir -p "$playlist_folder"
        echo "Playlist folder created: $playlist_folder"
        if [[ $playlist_choice == "1" ]]; then
            echo "Downloading playlist '$playlist_name' as audio in FLAC format..."
            # Download each item in the playlist individually
            yt-dlp --yes-playlist -x --audio-format flac -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
            if [ $? -eq 0 ]; then
                echo "Playlist download completed successfully!"
                echo "The songs have been saved in: $playlist_folder"
            else
                echo "An error occurred while downloading the playlist. Please try again."
            fi
        elif [[ $playlist_choice == "2" ]]; then
            echo "Downloading playlist '$playlist_name' as video in MP4 format..."
            # Download each item in the playlist individually
            yt-dlp --yes-playlist -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
            if [ $? -eq 0 ]; then
                echo "Playlist download completed successfully!"
                echo "The videos have been saved in: $playlist_folder"
            else
                echo "An error occurred while downloading the playlist. Please try again."
            fi
        else
            echo "Invalid choice. Please restart the bot and enter 1 or 2."
        fi
    else
        echo "Invalid input. Please paste a valid YouTube playlist link."
    fi
else
    echo "Invalid choice. Please restart the bot and enter 1, 2, or 3."
fi
EOF

# Step 5: Make the bot script executable
echo "Making the bot script executable..."
chmod +x ~/youtube_bot.sh

# Step 6: Add the bot to .bashrc for easy access
echo "Adding the bot to .bashrc..."
if ! grep -q "alias youtube-bot" ~/.bashrc; then
    echo 'alias youtube-bot="~/youtube_bot.sh"' >> ~/.bashrc
fi

# Step 7: Reload .bashrc
echo "Reloading .bashrc..."
source ~/.bashrc

# Step 8: Grant storage permissions
echo "Granting storage permissions..."
termux-setup-storage

# Completion message
echo "Installation complete!"
echo "You can now run the bot by typing 'youtube-bot' in Termux."
