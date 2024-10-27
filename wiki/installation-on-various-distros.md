### How to install on Various Distros

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
