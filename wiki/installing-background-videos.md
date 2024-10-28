### Using Your Own Background Videos



1. Use high-quality sources like [pexels.com](https://www.pexels.com) or download videos using [yt-dlp](https://github.com/yt-dlp/yt-dlp)

2. Move the downloaded videos to:
```bash
   /home/YOUR_USER/Videos/
```
3. Install the Provided Apple Fonts from within the Folder or provide your own Font Family in **theme.conf.user**

4. Modify **playlistcreator.sh**:

   4.1 Open playlistcreator.sh with a text editor and edit **YOUR-USER**

   4.2 Run playlistcreator.sh *(ensure you don’t have any unwanted videos in the Video Folder beforehand)*

   4.3 Name the playlist files according to the naming convention:
       **day** | **night** | **daynsfw** | **nightnsfw**

Once completed, the playlistcreator should move your downloaded videos into the theme folder, create playlists based on the number of videos in the Video folder, and leave you satisfied! 😊



#### If you want to add your videos manually, just move  your videos into the themes own video folder.
then edit the playlist.m3u files with any text editor you like, and add your videos by pasting their path on a new line. e.g
```bash
file:///usr/share/sddm/themes/almodern-sddm-theme-main/videos/example_daytime.webm
file:///usr/share/sddm/themes/almodern-sddm-theme-main/videos/another_example_4_daytime.mp4
```       
