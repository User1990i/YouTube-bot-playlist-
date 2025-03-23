if [[ $playlist_choice == "1" ]]; then
            echo -e "${GREEN}Downloading playlist '$playlist_name' as audio in FLAC format...${NC}"
            yt-dlp --yes-playlist -x --audio-format flac -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Playlist download completed successfully!${NC}"
                echo -e "The songs have been saved in: $playlist_folder"
            else
                echo -e "${RED}An error occurred while downloading the playlist. Please try again.${NC}"
            fi
            go_back
        elif [[ $playlist_choice == "2" ]]; then
            echo -e "${GREEN}Downloading playlist '$playlist_name' as video in MP4 format...${NC}"
            yt-dlp --yes-playlist -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$playlist_folder/%(title)s.%(ext)s" "$playlist_link"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Playlist download completed successfully!${NC}"
                echo -e "The videos have been saved in: $playlist_folder"
            else
                echo -e "${RED}An error occurred while downloading the playlist. Please try again.${NC}"
            fi
            go_back
        else
            echo -e "${RED}Invalid choice. Please restart the bot and enter 1 or 2.${NC}"
        fi
    else
        echo -e "${RED}Invalid input. Please paste a valid YouTube playlist link.${NC}"
    fi
}

# Start the bot
main_menu
