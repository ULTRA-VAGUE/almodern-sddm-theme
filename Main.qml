// Theme start
import QtQuick 2.0
import SddmComponents 2.0
import QtMultimedia 5.7

import "components"

Rectangle {

    signal syncPlaylists(string action)

    property bool muteVideos: config.muteVideos === "true"  // Read mute state from config

    function syncPlayers(action) {

        if (action === "play") {

            // Mute the other player when one is played

            if (currentPlayer === mediaplayer1) {

                mediaplayer2.muted = true; // Mute player 2

            } else {

                mediaplayer1.muted = true; // Mute player 1

            }



            mediaplayer1.play();

            mediaplayer2.play();

        } else if (action === "pause") {

            mediaplayer1.pause();

            mediaplayer2.pause();

        } else if (action === "stop") {

            mediaplayer1.stop();

            mediaplayer2.stop();

        }

    }


    Connections {

        target: this

        function onSyncPlaylists(action) {

            syncPlayers(action);

        }

    }

    // Timer for syncing the Position of 2 or more players

    Timer {

        interval: 1000; // Increased Interval to reduce possible stutter

        running: true; repeat: true

        onTriggered: {

            // Syncing Player Position

            if (Math.abs(mediaplayer1.position - mediaplayer2.position) > 1000) { // 1 Sekunde Toleranz

                mediaplayer2.seek(mediaplayer1.position);

            }

        }

    }

    // Function for Loading the Playlists
    function loadPlaylists() {
        var time = parseInt(new Date().toLocaleTimeString(Qt.locale(), 'h'));
        var currentPlaylist1, currentPlaylist2;

        // Define whether Day or Night is Used
        var isDayTime = time >= config.dayTimeStart && time <= config.dayTimeEnd;

        if (nsfwMode) {
            console.log("Loading NSFW videos");
            currentPlaylist1 = isDayTime ? Qt.resolvedUrl(config.bgVidDayNSFW) : Qt.resolvedUrl(config.bgVidNightNSFW);
            currentPlaylist2 = currentPlaylist1;
        } else {
            console.log("Loading normal videos");
            currentPlaylist1 = isDayTime ? Qt.resolvedUrl(config.bgVidDay) : Qt.resolvedUrl(config.bgVidNight);
            currentPlaylist2 = currentPlaylist1;
        }

        // Loading the Playlists
        playlist1.load(currentPlaylist1, 'm3u');
        playlist2.load(currentPlaylist2, 'm3u');

        // Randomizing the Videos
        for (var k = 0; k < Math.ceil(Math.random() * 10); k++) {
            playlist1.shuffle();
            playlist2.shuffle();
        }

        // Loading BG Image depending on Time of Day [Deprecated]
        if (isDayTime && config.bgImgDay !== null) {
            var fileType = config.bgImgDay.substring(config.bgImgDay.lastIndexOf(".") + 1);
            if (fileType === "gif") {
                animatedGIF1.source = config.bgImgDay;
            } else {
                image1.source = config.bgImgDay;
            }
        } else if (!isDayTime && config.bgImgNight !== null) {
            var fileType = config.bgImgNight.substring(config.bgImgNight.lastIndexOf(".") + 1);
            if (fileType === "gif") {
                animatedGIF1.source = config.bgImgNight;
            } else {
                image1.source = config.bgImgNight;
            }
        }

        if (config.showLoginButton == "false") {
            login_button.visible = false;
            password_input_box.anchors.rightMargin = 0;
            clear_passwd_button.anchors.rightMargin = 0;
        }
        clear_passwd_button.visible = false;
    }

    // Function to update mute state based on config
    function updateMuteState() {

        // Read from config and apply to the current player

        if (currentPlayer === mediaplayer1) {

            mediaplayer1.muted = (config.muteVideos === "true");

            mediaplayer2.muted = true; // Mute the second player

        } else {

            mediaplayer2.muted = (config.muteVideos === "true");

            mediaplayer1.muted = true; // Mute the first player

        }

    }

    // Main Container
    id: container

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index
    property bool nsfwMode: false

    // Inherited from SDDMComponents
    TextConstants {
        id: textConstants
    }

    // Set SDDM actions
    Connections {
        target: sddm
        function onLoginSucceeded() {
        }

        function onLoginFailed() {
            error_message.color = config.errorMsgFontColor
            error_message.text = textConstants.loginFailed
        }
    }

    // Set Font
    FontLoader {
        id: textFont; name: config.displayFont
    }

    // Background Fill
    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    // Set Background Image
    Image {
        id: image1
        anchors.fill: parent
        //source: config.background
        fillMode: Image.PreserveAspectCrop
    }

    // Set Animated GIF Background Image
    AnimatedImage {
        id: animatedGIF1
        anchors.fill: parent
        fillMode: AnimatedImage.PreserveAspectCrop
    }

    // Set Background Video1
    MediaPlayer {
        id: mediaplayer1
        autoPlay: true; muted: muteVideos
        playlist: Playlist {
            id: playlist1
            playbackMode: Playlist.Random
            onLoaded: { mediaplayer1.play() }
        }
    }

    VideoOutput {
        id: video1
        fillMode: VideoOutput.PreserveAspectCrop
        anchors.fill: parent; source: mediaplayer1
        MouseArea {
            id: mouseArea1
            anchors.fill: parent;
            //onPressed: {playlist1.shuffle(); playlist1.next();}
            onPressed: {
                fader1.state = fader1.state == "off" ? "on" : "off" ;
                if (config.autofocusInput == "true") {
                    if (username_input_box.text == "")
                        username_input_box.focus = true
                    else
                        password_input_box.focus = true
                }
            }
        }
        Keys.onPressed: {
            fader1.state = "on";
            if (username_input_box.text == "")
                username_input_box.focus = true
            else
                password_input_box.focus = true
        }
    }
    WallpaperFader {
        id: fader1
        visible: true
        anchors.fill: parent
        state: "off"
        source: video1
        mainStack: login_container
        footer: login_container
    }

    // Set Background Video2
    MediaPlayer {
        id: mediaplayer2
        autoPlay: true; muted: muteVideos
        playlist: Playlist {
            id: playlist2; playbackMode: Playlist.Random
        }
    }

    VideoOutput {
        id: video2
        fillMode: VideoOutput.PreserveAspectCrop
        anchors.fill: parent; source: mediaplayer2
        opacity: 0
        MouseArea {
            id: mouseArea2
            enabled: false
            anchors.fill: parent;
            onPressed: {
                fader1.state = fader1.state == "off" ? "on" : "off" ;
                if (config.autofocusInput == "true") {
                    if (username_input_box.text == "")
                        username_input_box.focus = true
                    else
                        password_input_box.focus = true
                }
            }
        }
        Behavior on opacity {
            enabled: true
            NumberAnimation { easing.type: Easing.InOutQuad; duration: 3000 }
        }
        Keys.onPressed: {
            fader2.state = "on";
            if (username_input_box.text == "")
                username_input_box.focus = true
            else
                password_input_box.focus = true
        }
    }

    WallpaperFader {
        id: fader2
        visible: true
        anchors.fill: parent
        state: "off"
        source: video2
        mainStack: login_container
        footer: login_container
    }

    property MediaPlayer currentPlayer: mediaplayer1

    // Timer event to handle fade between videos

    Timer {

        interval: 1000;

        running: true; repeat: true

        onTriggered: {

            if (currentPlayer.duration != -1 && currentPlayer.position > currentPlayer.duration - 10000) { // pre load the 2nd player

                if (video2.opacity == 0) { // toggle opacity

                    mediaplayer2.play();

                } else {

                    mediaplayer1.play();

                }

            }

            if (currentPlayer.duration != -1 && currentPlayer.position > currentPlayer.duration - 3000) { // initiate transition

                if (video2.opacity == 0) { // toggle opacity

                    mouseArea1.enabled = false;

                    currentPlayer = mediaplayer2;

                    video2.opacity = 1; // Make the second video visible

                    triggerTimer.start();

                    mouseArea2.enabled = true;

                } else {

                    mouseArea2.enabled = false;

                    currentPlayer = mediaplayer1;

                    video2.opacity = 0; // Fade out the second video

                    triggerTimer.start();

                    mouseArea1.enabled = true;

                }

            }

        }

    }


    // Timer to stop the video after fade

    Timer {

        id: triggerTimer

        interval: 4000; running: false; repeat: false

        onTriggered: {

            if (video2.opacity == 1) {

                mediaplayer1.stop(); // Stop the first player if the second is visible

            } else {

                mediaplayer2.stop(); // Stop the second player if the first is visible

            }

        }
    }



    // Clock and Login Area
    Rectangle {
        id: rectangle
        anchors.fill: parent
        color: "transparent"

        Column {
            id: clock
            property date dateTime: new Date()
            property color color: config.clockFontColor
            y: parent.height * config.relativePositionY - clock.height / 2
            x: parent.width * config.relativePositionX - clock.width / 2

            Timer {
                interval: 100; running: true; repeat: true;
                onTriggered: clock.dateTime = new Date()
            }

            Text {
                id: time
                anchors.horizontalCenter: parent.horizontalCenter
                color: clock.color
                text : Qt.formatTime(clock.dateTime, config.timeFormat || "hh:mm")
                font.pointSize: config.clockFontSize
                font.family: textFont.name
            }

            Text {
                id: date
                anchors.horizontalCenter: parent.horizontalCenter
                color: clock.color
                text : Qt.formatDate(clock.dateTime, config.dateFormat || "dddd, dd MMMM yyyy")
                font.family: textFont.name
                font.pointSize: config.dateFontSize
            }
        }


        Rectangle {
            id: login_container
            y: clock.y + clock.height + 30
            width: clock.width
            height: parent.height * 0.08
            color: "Transparent"
            anchors.left: clock.left

            Rectangle {
                id: username_row
                height: parent.height * 0.36
                color: "#25000000"
                radius: 15
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                transformOrigin: Item.Center
                anchors.margins: 10

                Text {
                    id: username_label
                    width: 0
                    height: parent.height * 0.66
                    horizontalAlignment: Text.AlignLeft
                    font.family: textFont.name
                    font.bold: true
                    font.pixelSize: config.labelFontSize
                    color: config.labelFontColor
                    text: ""
                    anchors.verticalCenter: parent.verticalCenter
                }
                // Username Box Settings
                TextBox {
                    id: username_input_box
                    height: parent.height
                    text: userModel.lastUser
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: username_label.right
                    anchors.leftMargin: config.usernameLeftMargin
                    anchors.right: parent.right
                    anchors.rightMargin: config.usernameRightMargin
                    font {
                        family: textFont.name
                        pixelSize: config.labelFontSize
                        bold: true
                    }
                    color: "#80000000"
                    radius: 15
                    borderColor: "#80000000"
                    textColor: "#F8F8F8"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            username_input_box.focus = true;
                        }
                    }

                    onActiveFocusChanged: {
                        borderColor = activeFocus ? "#80000000" : "#80000000";
                    }

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(username_input_box.text, password_input_box.text, session.index);
                            event.accepted = true;
                        }
                    }

                    KeyNavigation.backtab: password_input_box
                    KeyNavigation.tab: password_input_box
                }
            }


            Rectangle {
                id: password_row
                y: username_row.height + 10
                height: parent.height * 0.36
                color: "#25000000"
                radius: 15
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: password_label
                    width: 0
                    text: ""
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.family: textFont.name
                    font.bold: true
                    font.pixelSize: config.labelFontSize
                    color: config.labelFontColor
                }
                //Settings for the Password Box
                PasswordBox {
                    id: password_input_box
                    height: parent.height
                    font: textFont.name
                    color: "#80ffffff"
                    radius: 15
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: parent.height // this sets button width, this way its a square
                    anchors.left: password_label.right
                    anchors.leftMargin: 0
                    borderColor: "#80ffffff"
                    textColor: "#1C1C1C"
                    echoMode: TextInput.Password

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            password_input_box.focus = true;
                        }
                    }

                    onActiveFocusChanged: {
                        borderColor = activeFocus ? "#80ffffff" : "#80ffffff";
                    }

                    onTextChanged: {
                        clear_passwd_button.visible = (text !== "");
                    }

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(username_input_box.text, password_input_box.text, session.index);
                            event.accepted = true;
                        }
                    }

                    KeyNavigation.backtab: username_input_box
                    KeyNavigation.tab: login_button
                }

                Button {
                    id: clear_passwd_button
                    radius: 15
                    height: parent.height
                    width: parent.height
                    color: "Transparent"
                    font {
                        family: textFont.name
                        pixelSize: config.labelFontSize
                        bold: true
                    }
                    text: "🗑️"
                    textColor: "black"

                    border.color: "Transparent"

                    border.width: 0
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.leftMargin: 0
                    anchors.rightMargin: 30

                    disabledColor: "Transparent"

                    activeColor: "Transparent"

                    pressedColor: "Transparent"


                    onClicked: {
                        password_input_box.text = '';
                        password_input_box.focus = true;
                    }
                }

                Button {
                    id: login_button
                    height: parent.height
                    color: "#80ffffff"
                    radius: 5
                    text: "🔑"
                    border.color: "Transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: password_input_box.right
                    anchors.right: parent.right
                    disabledColor: "Transparent"
                    activeColor: "Transparent"
                    pressedColor: "Transparent"
                    textColor: config.labelFontColor
                    font: textFont.name

                    onClicked: sddm.login(username_input_box.text, password_input_box.text, session.index)

                    KeyNavigation.backtab: password_input_box
                    KeyNavigation.tab: reboot_button
                }

                Text {
                    id: error_message
                    height: parent.height
                    font.family: textFont.name
                    font.pixelSize: config.errorMsgFontSize
                    anchors.top: password_input_box.bottom
                    anchors.left: password_input_box.left
                    anchors.leftMargin: 0
                }
            }
        }
    }


    // Top Bar
    Rectangle {
        id: actionBar
        width: 225
        radius: 15
        height: 22
        anchors.top: parent.top;
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#80000000"
        visible: config.showTopBar != "false"

        Row {
            id: row_left
            anchors.left: parent.left
            anchors.margins: 5
            height: parent.height
            spacing: 10

            ComboBox {
                id: session
                width: 145
                height: 30

                anchors.verticalCenter: parent.verticalCenter
                color: "Transparent"
                arrowColor: "Transparent"
                textColor: "White"
                borderColor: "Transparent"
                hoverColor: "Black"
                font.family: textFont.name
                font.bold: true
                font.pixelSize: config.actionBarFontSize

                model: sessionModel
                index: sessionModel.lastIndex

                KeyNavigation.backtab: shutdown_button
                KeyNavigation.tab: password_input_box
            }

        }

        Row {
            id: row_right
            height: parent.height
            anchors.right: parent.right
            anchors.margins: 5
            spacing: 10

            ImageButton {
                id: reboot_button
                height: parent.height
                source: "/usr/share/sddm/themes/almodern-sddm-theme-main/components/resources/reboot.svg"

                visible: true
                onClicked: sddm.reboot()
                KeyNavigation.backtab: login_button
                KeyNavigation.tab: shutdown_button
            }

            ImageButton {
                id: shutdown_button
                height: parent.height
                source: "/usr/share/sddm/themes/almodern-sddm-theme-main/components/resources/shutdown.svg"
                visible: true
                onClicked: sddm.powerOff()
                KeyNavigation.backtab: reboot_button
                KeyNavigation.tab: session
            }

            ImageButton {

                id: reloader_button

                height: parent.height

                source: "/usr/share/sddm/themes/almodern-sddm-theme-main/components/resources/pornhub.svg"

                onClicked: {

                    console.log("Reload button clicked. Current nsfwMode:", nsfwMode);



                    if (currentPlayer) {

                        currentPlayer.stop();

                    }




                    nsfwMode = !nsfwMode;

                    loadPlaylists();



                    reloadTimer.start();

                }

            }




            Timer {

                id: reloadTimer

                interval: 5000

                repeat: false

                onTriggered: {

                    currentPlayer.play();

                }

            }

            // Call updateMuteState when the configuration changes
            Connections {
                target: config
                function onMuteVideosChanged() {
                    updateMuteState(); // Update mute state when config changes
                }
            }

            Component.onCompleted: {
                video1.focus = true;
                loadPlaylists(); // Dieser Aufruf bleibt gleich
                updateMuteState(); // Ensure the mute state is applied initially
            }

            // Loading the Playlists
            function loadPlaylists() {
                var time = parseInt(new Date().toLocaleTimeString(Qt.locale(), 'h'));
                var currentPlaylist1, currentPlaylist2;

                // Day or Night Time detection
                var isDayTime = time >= config.dayTimeStart && time < config.dayTimeEnd; // Beachte das "<" für die Endzeit

                if (nsfwMode) {
                    console.log("Loading NSFW videos");
                    currentPlaylist1 = isDayTime ? Qt.resolvedUrl(config.bgVidDayNSFW) : Qt.resolvedUrl(config.bgVidNightNSFW);
                    currentPlaylist2 = currentPlaylist1; // Beide Playlists auf dasselbe setzen
                } else {
                    console.log("Loading normal videos");
                    currentPlaylist1 = isDayTime ? Qt.resolvedUrl(config.bgVidDay) : Qt.resolvedUrl(config.bgVidNight);
                    currentPlaylist2 = currentPlaylist1; // Beide Playlists auf dasselbe setzen
                }


                playlist1.load(currentPlaylist1, 'm3u');
                playlist2.load(currentPlaylist2, 'm3u');


                for (var k = 0; k < Math.ceil(Math.random() * 10); k++) {
                    playlist1.shuffle();
                    playlist2.shuffle();
                }


                if (isDayTime && config.bgImgDay !== null) {
                    var fileType = config.bgImgDay.substring(config.bgImgDay.lastIndexOf(".") + 1);
                    if (fileType === "gif") {
                        animatedGIF1.source = config.bgImgDay;
                    } else {
                        image1.source = config.bgImgDay;
                    }
                } else if (!isDayTime && config.bgImgNight !== null) {
                    var fileType = config.bgImgNight.substring(config.bgImgNight.lastIndexOf(".") + 1);
                    if (fileType === "gif") {
                        animatedGIF1.source = config.bgImgNight;
                    } else {
                        image1.source = config.bgImgNight;
                    }
                }

                if (config.showLoginButton == "false") {
                    login_button.visible = false;
                    password_input_box.anchors.rightMargin = 0;
                    clear_passwd_button.anchors.rightMargin = 0;
                }
                clear_passwd_button.visible = false;
            }
        }
    }
}
