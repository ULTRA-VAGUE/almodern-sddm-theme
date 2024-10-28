#!/bin/bash

# Note: Both user directories must be adjusted before running this script.
#
# This script performs the following actions:
# 1. Checks if there are any videos in the specified source directory.
# 2. Prompts the user for a playlist name and creates a temporary playlist file.
# 3. Adds each video from the source directory to the playlist with the appropriate path format.
# 4. Checks if the target directories for the playlist and videos exist, exiting if they do not.
# 5. Moves the created playlist and all videos to their respective Folders inside the Theme.
#
# Ensure the following directories are set correctly:
# - video_source_dir: Where the videos are located. !EDIT THIS!
# - playlist_target_dir: Where the playlist will be stored
# - video_target_dir: Where the videos will be moved

# Video source directory and playlist target directory
video_source_dir="/home/YOUR_USER/Videos/"





playlist_target_dir="/usr/share/sddm/themes/almodern-sddm-theme-main/playlists/"
video_target_dir="/usr/share/sddm/themes/almodern-sddm-theme-main/videos/"

# Check if there are videos in the source directory
if [ -z "$(ls -A "$video_source_dir")" ]; then
    echo "No videos found in the directory $video_source_dir. No playlist will be created."
    exit 0
fi

# Create the playlist in the home directory
read -p "Enter the name of the playlist file. you can choose betweeen: day | night | daynsfw | nightnsfw (without .m3u): " playlist_name
temp_playlist="$HOME/$playlist_name.m3u"

# Clear the temporary playlist to ensure it's fresh
> "$temp_playlist"

# Add videos with new paths to the playlist
for video in "$video_source_dir"*; do
    # Only add files
    if [ -f "$video" ]; then
        # Add the file with the new path
        echo "file://$video_target_dir$(basename "$video")" >> "$temp_playlist"
    fi
done

# Check if the playlist target directory exists
if [ ! -d "$playlist_target_dir" ]; then
    echo "The target directory for the playlist does not exist. Please create it or adjust the path."
    exit 1
fi

# Move the playlist to the target directory
sudo mv "$temp_playlist" "$playlist_target_dir"

# Check if the target directory for the videos exists
if [ ! -d "$video_target_dir" ]; then
    echo "The target directory for the videos does not exist. Please create it or adjust the path."
    exit 1
fi

# Move the videos to the target directory
sudo mv "$video_source_dir"* "$video_target_dir"

# Completion message
echo "The playlist was successfully created and moved to $playlist_target_dir."
echo "The videos were successfully moved to $video_target_dir."
