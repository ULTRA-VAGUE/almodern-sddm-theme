# 🎨 ALmodern SDDM | Dynamic Video Backgrounds and Built in Video Swicher! 
A Modern Theme following apple's design philosophy with a 🔥 twist.
The **ALmodern SDDM Theme**  allows you to play your chosen videos randomly, utilizing different playlists based on the time of day.
The theme differentiates between day and night, where night is defined as the period between **7 PM and 7 AM** (configured in 24-hour format).
It is possible to tweak the settings for more time differentiation.

## 📦 Dependencies

To ensure the theme functions correctly, you need to install the following dependencies:

- **Phonon GStreamer backend for Qt5**
- **GStreamer FFmpeg Plugin**
- **GStreamer Plugins Good**

### How to install them | Various Distros

- **Arch Linux**:
  ```bash
  sudo pacman -S gst-libav phonon-qt5-gstreamer gst-plugins-good qt5-quickcontrols qt5-graphicaleffects qt5-multimedia
- **Gentoo**: 
  Add the following USE flags to your configuration:
```bash
media-libs/gst-plugins-good
USE="alsa gstreamer qml widgets"
dev-qt/qtmultimedia
USE="widgets"
dev-qt/qtquickcontrols
dev-qt/qtgraphicaleffects
USE="gstreamer"
media-libs/phonon
```
Optionally, you can install:
```bash
media-plugins/gst-plugins-openh264
media-plugins/gst-plugins-libde265
```
- **Kubuntu**:
```bash 
sudo apt install gstreamer1.0-libav phonon4qt5-backend-gstreamer gstreamer1.0-plugins-good qml-module-qtquick-controls qml-module-qtgraphicaleffects qml-module-qtmultimedia qt5-default
```
-**Lubuntu 22.04:**:
```bash 
sudo apt-get install gstreamer1.0-libav qml-module-qtmultimedia libqt5multimedia5-plugins
```
-**Debian 12 (LXQt)**:
```bash
sudo apt-get install gstreamer1.0-libav qml-module-qtmultimedia libqt5multimedia5-plugins
```
-**Fedora 36 (LXQt spin)**:
```bash 
sudo dnf install git qt5-qtgraphicaleffects qt5-qtquickcontrols gstreamer1-libav
```
*Ensure you set up the RPM Fusion Repo first to get the gstreamer1-libav package.*


### OTHER DISTROS HAVE NOT BEEN TESTED



## 🛠️ Configuration Steps

**Clone the Repo**
```bash
git clone https://github.com/3ximus/aerial-sddm-theme
sudo mv aerial-sddm-theme /usr/share/sddm/themes
```

**Move the Theme to the correct Directory**
```bash
sudo mv ALmodern-sddm-theme /usr/share/sddm/themes
```
*Note: Super user privileges are required to move files into this directory.*


### 🎥 Installing Background Videos



1. Use high-quality sources like pexels.com or download videos using yt-dlp.

2. Move the downloaded videos to:
   /home/YOUR_USER/Videos/
3. Install the Provided Apple Fonts from within the Folder or provide your own Font Family in theme.conf.user

4. Modify playlistcreator.sh:

   4.1 Open playlistcreator.sh with a text editor and edit YOUR-USER.
   4.2 Run playlistcreator.sh (ensure you don’t have any unwanted videos in the Video Folder beforehand).
   4.3 Name the playlist files according to the naming convention:
       **day** | **Night** | **daynsfw** | **nightnsfw**
       

## ✅ Completion

Once completed, the playlistcreator should move your downloaded videos into the theme folder, create playlists based on the number of videos in the Video folder, and leave you satisfied! 😊

### UI Elements

