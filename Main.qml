import QtQuick 2.0
import SddmComponents 2.0
import QtMultimedia 5.7

import "components"

Rectangle {

    signal syncPlaylists(string action)


    function syncPlayers(action) {

        if (action === "play") {

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

    // Timer für die Synchronisation der Position

    Timer {

        interval: 1000; // Erhöhte Intervalldauer zur Reduzierung des "Hackens"

        running: true; repeat: true

        onTriggered: {

            // Synchronisiere die Positionen der Player

            if (Math.abs(mediaplayer1.position - mediaplayer2.position) > 1000) { // 1 Sekunde Toleranz

                mediaplayer2.seek(mediaplayer1.position);

            }

        }

    }

    // Funktion, um die Playlists zu laden
    function loadPlaylists() {
        var time = parseInt(new Date().toLocaleTimeString(Qt.locale(), 'h'));
        var currentPlaylist1, currentPlaylist2;

        // Bestimme, ob Tag- oder Nachtmodus aktiv ist
        var isDayTime = time >= config.dayTimeStart && time <= config.dayTimeEnd;

        if (nsfwMode) {
            console.log("Loading NSFW videos");
            currentPlaylist1 = isDayTime ? Qt.resolvedUrl(config.bgVidDayNSFW) : Qt.resolvedUrl(config.bgVidNightNSFW);
            currentPlaylist2 = currentPlaylist1; // Beide Playlists auf dasselbe setzen
        } else {
            console.log("Loading normal videos");
            currentPlaylist1 = isDayTime ? Qt.resolvedUrl(config.bgVidDay) : Qt.resolvedUrl(config.bgVidNight);
            currentPlaylist2 = currentPlaylist1; // Beide Playlists auf dasselbe setzen
        }

        // Lade die Playlists
        playlist1.load(currentPlaylist1, 'm3u');
        playlist2.load(currentPlaylist2, 'm3u');

        // Mische die Playlists
        for (var k = 0; k < Math.ceil(Math.random() * 10); k++) {
            playlist1.shuffle();
            playlist2.shuffle();
        }

        // Lade das Hintergrundbild entsprechend der Tageszeit
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
        autoPlay: true; muted: false
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
        autoPlay: true; muted: false
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
                radius: 15 // Runde Ecken
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
                        bold: true  // Fettgedruckte Schrift
                    }
                    color: "#80000000"  // Hintergrundfarbe
                    radius: 15 // Runde Ecken
                    borderColor: "#80000000"  // Randfarbe
                    textColor: "#F8F8F8"  // Textfarbe

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            username_input_box.focus = true; // Setze den Fokus
                        }
                    }

                    onActiveFocusChanged: {
                        borderColor = activeFocus ? "#80000000" : "#80000000";  // Ändere Randfarbe
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
                radius: 15 // Runde Ecken
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

                PasswordBox {
                    id: password_input_box
                    height: parent.height
                    font: textFont.name
                    color: "#80ffffff"  // Hintergrundfarbe
                    radius: 15 // Runde Ecken
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: parent.height // this sets button width, this way its a square
                    anchors.left: password_label.right
                    anchors.leftMargin: 0
                    borderColor: "#80ffffff"  // Randfarbe
                    textColor: "#1C1C1C"  // Textfarbe
                    echoMode: TextInput.Password  // Passworteingabe als Punkte

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            password_input_box.focus = true; // Setze den Fokus
                        }
                    }

                    onActiveFocusChanged: {
                        borderColor = activeFocus ? "#80ffffff" : "#80ffffff";  // Ändere Randfarbe
                    }

                    onTextChanged: {
                        clear_passwd_button.visible = (text !== "");  // Sichtbarkeit des Clear-Buttons
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
                    radius: 15 // Runde Ecken
                    height: parent.height
                    width: parent.height
                    color: "Transparent"
                    font {
                        family: textFont.name
                        pixelSize: config.labelFontSize
                        bold: true  // Hier hinzufügen
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
                        password_input_box.text = '';  // Lösche Text
                        password_input_box.focus = true;  // Setze den Fokus
                    }
                }

                Button {
                    id: login_button
                    height: parent.height
                    color: "#80ffffff"
                    radius: 5 // Runde Ecken
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
                source: "/usr/share/sddm/themes/ALmodern/components/resources/reboot.svg"

                visible: true
                onClicked: sddm.reboot()
                KeyNavigation.backtab: login_button
                KeyNavigation.tab: shutdown_button
            }

            ImageButton {
                id: shutdown_button
                height: parent.height
                source: "/usr/share/sddm/themes/ALmodern/components/resources/shutdown.svg"
                visible: true
                onClicked: sddm.powerOff()
                KeyNavigation.backtab: reboot_button
                KeyNavigation.tab: session
            }
            // Reload-Button hinzufügen

            ImageButton {

                id: reloader_button

                height: parent.height

                source: "/usr/share/sddm/themes/ALmodern/components/resources/pornhub.svg"

                onClicked: {

                    console.log("Reload button clicked. Current nsfwMode:", nsfwMode);


                    // Stoppe den aktuellen Player

                    if (currentPlayer) {

                        currentPlayer.stop();

                    }


                    // Toggle NSFW mode und lade die passenden Videos

                    nsfwMode = !nsfwMode;

                    loadPlaylists();


                    // Starte den Timer für 5 Sekunden

                    reloadTimer.start();

                }

            }


            // Timer für das Warten vor dem Abspielen des Videos

            Timer {

                id: reloadTimer

                interval: 5000 // 5 Sekunden in Millisekunden

                repeat: false // Timer soll nur einmal ausgelöst werden

                onTriggered: {

                    currentPlayer.play(); // Starte das Video nach 5 Sekunden

                }

            }

            Component.onCompleted: {
                video1.focus = true;
                loadPlaylists(); // Dieser Aufruf bleibt gleich
            }

            // Funktion, um die Playlists zu laden
            function loadPlaylists() {
                var time = parseInt(new Date().toLocaleTimeString(Qt.locale(), 'h'));
                var currentPlaylist1, currentPlaylist2;

                // Bestimme, ob Tag- oder Nachtmodus aktiv ist
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

                // Lade die Playlists
                playlist1.load(currentPlaylist1, 'm3u');
                playlist2.load(currentPlaylist2, 'm3u');

                // Mische die Playlists
                for (var k = 0; k < Math.ceil(Math.random() * 10); k++) {
                    playlist1.shuffle();
                    playlist2.shuffle();
                }

                // Lade das Hintergrundbild entsprechend der Tageszeit
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
