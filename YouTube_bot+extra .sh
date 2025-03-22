#!/bin/bash

# Function for clear screen
clear_screen() {
    clear
}

# YouTube Banner
banner() {
    clear_screen
    echo -e "\e[1;31m"  # YouTube Red
    echo "  YYYYYYY   OOOOO   U   U  TTTTTTT  U   U  BBBBB   EEEEE"
    echo "    YYY     O   O   U   U    TTT    U   U  B    B  E    "
    echo "    YYY     O   O   U   U    TTT    U   U  BBBBB   EEEE "
    echo "    YYY     O   O   U   U    TTT    U   U  B    B  E    "
    echo "    YYY     O   O   U   U    TTT    U   U  BBBBB   EEEEE"
    echo -e "\e[0m"  # Reset the color to default
    echo -e "\e[1;31m YouTube BOT stable build v1 \e[0m"
    echo -e "\e[1;34m =========================================== \e[0m"
    echo -e "\e[1;32m 1. Download Audio (FLAC format) \e[0m"
    echo -e "\e[1;33m 2. Download Video (choose quality) \e[0m"
    echo -e "\e[1;36m 3. Download Playlist (Audio or Video) \e[0m"
    echo -e "\e[1;34m =========================================== \e[0m"
}

# Show back navigation option
back_navigation() {
    echo -e "\e[1;35m-------------------------------------------\e[0m"
    echo -e "\e[1;33m Press [B] to go back to the main menu.\e[0m"
    read -p "> " back_choice
    if [[ $back_choice == "B" || $back_choice == "b" ]]; then
        main_menu
    else
        echo -e "\e[1;31mInvalid option. Press [B] to go back.\e[0m"
        back_navigation
    fi
}

# Download audio function
download_audio() {
    echo -e "\e[1;32mYou selected to download audio in FLAC format.\e[0m"
    echo -e "\e[1;33mPaste a YouTube link and press Enter to download the song.\e[0m"
    while true; do
        read -p "> " youtube_link
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo -e "\e[1;31mDownloading audio in FLAC format...\e[0m"
            yt-dlp -x --audio-format flac -o "/storage/emulated/0/Music_Vids/Songs/%(title)s.%(ext)s" "$youtube_link"
            if [ $? -eq 0 ]; then
                echo -e "\e[1;32mDownload completed!\e[0m"
            else
                echo -e "\e[1;31mAn error occurred. Please try again.\e[0m"
            fi
            back_navigation
            break
        else
            echo -e "\e[1;31mInvalid link. Please paste a valid YouTube link.\e[0m"
        fi
    done
}

# Download video function
download_video() {
    echo -e "\e[1;34mYou selected to download video. Choose a quality:\e[0m"
    echo -e "\e[1;32mAvailable qualities: 144p, 240p, 360p, 480p, 720p, 1080p, 1440p, 2160p (4K), best\e[0m"
    read -p "Enter your preferred quality: " quality
    echo -e "\e[1;33mPaste a YouTube link and press Enter to download the video.\e[0m"
    while true; do
        read -p "> " youtube_link
        if [[ $youtube_link == *"youtube.com"* || $youtube_link == *"youtu.be"* ]]; then
            echo -e "\e[1;31mDownloading video in $quality quality...\e[0m"
            yt-dlp -f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]" --merge-output-format mp4 -o "/storage/emulated/0/Music_Vids/Videos/%(title)s.%(ext)s" "$youtube_link"
            if [ $? -eq 0 ]; then
                echo -e "\e[1;32mDownload completed!\e[0m"
            else
                echo -e "\e[1;31mAn error occurred. Please try again.\e[0m"
            fi
            back_navigation
            break
        else
            echo -e "\e[1;31mInvalid link. Please paste a valid YouTube link.\e[0m"
        fi
    done
}

# Download playlist function
download_playlist() {
    echo -e "\e[1;34mYou selected to download a playlist.\e[0m"
    echo -e "\e[1;32mChoose an option:\e[0m"
    echo -e "\e[1;36m1. Download Playlist as Audio (FLAC format)\e[0m"
    echo -e "\e[1;33m2. Download Playlist as Video (MP4 format)\e[0m"
    read -p "Enter your choice (1 or 2): " playlist_choice
    echo -e "\e[1;33mPaste a YouTube playlist link and press Enter to download the playlist.\e[0m"
    read -p "> " playlist_link
    if [[ $playlist_link == *"youtube.com/playlist"* ]]; then
        echo -e "\e[1;31mFetching playlist metadata...\e[0m"
        playlist_name=$(yt-dlp --get-filename -o "%(playlist_title)s" "$playlist_link")
        playlist_folder="/storage/emulated/0/Music_Vids/playlists/$playlist_name"
        mkdir -p "$playlist_folder"
        echo -e "\e[1;32mPlaylist folder created: $playlist_folder\e[0m"
        if [[ $playlist_choice == "1" ]]; then
            echo -e "\e[1;31mDownloading playlist as audio in FLAC format...\e[0m"
            yt-dlp --yes-playlist -x --audio-format flac -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
            if [ $? -eq 0 ]; then
                echo -e "\e[1;32mPlaylist download completed!\e[0m"
            else
                echo -e "\e[1;31mAn error occurred. Please try again.\e[0m"
            fi
        elif [[ $playlist_choice == "2" ]]; then
            echo -e "\e[1;31mDownloading playlist as video in MP4 format...\e[0m"
            yt-dlp --yes-playlist -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
            if [ $? -eq 0 ]; then
                echo -e "\e[1;32mPlaylist download completed!\e[0m"
            else
                echo -e "\e[1;31mAn error occurred. Please try again.\e[0m"
            fi
        else
            echo -e "\e[1;31mInvalid choice. Please try again.\e[0m"
        fi
        back_navigation
    else
        echo -e "\e[1;31mInvalid link. Please paste a valid YouTube playlist link.\e[0m"
    fi
}

# Main menu function
main_menu() {
    banner
    read -p "Enter your choice (1, 2, or 3): " choice
    case $choice in
        1) download_audio ;;
        2) download_video ;;
        3) download_playlist ;;
        *) echo -e "\e[1;31mInvalid choice. Please try again.\e[0m" ;;
    esac
}

# Run the bot
main_menu
