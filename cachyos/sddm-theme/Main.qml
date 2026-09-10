import QtQuick 2.15

Rectangle {
    id: root

    width: 1920
    height: 1080
    color: palette.background

    QtObject {
        id: palette
        property color background: "#12131c"
        property color surface: "#1b1d29"
        property color foreground: "#dae4ec"
        property color muted: "#8b93a7"
        property color accent: "#73d1ff"
        property color error: "#ffb4ab"
    }

    function loadPalette() {
        var xhr = new XMLHttpRequest()
        try {
            xhr.open("GET", "file:///var/lib/sddm-noctalia/colors.json", false)
            xhr.send()
            if (xhr.responseText.length === 0)
                return
            var c = JSON.parse(xhr.responseText)
            if (c.background) palette.background = c.background
            if (c.surface)    palette.surface    = c.surface
            if (c.foreground) palette.foreground = c.foreground
            if (c.muted)      palette.muted      = c.muted
            if (c.accent)     palette.accent     = c.accent
            if (c.error)      palette.error      = c.error
        } catch (e) {
        }
    }

    property string userName: ""

    Repeater {
        model: userModel
        Item {
            Component.onCompleted: {
                if (root.userName.length === 0)
                    root.userName = model.name || model.realName || ""
            }
        }
    }

    Component.onCompleted: {
        loadPalette()
        if (userModel.lastUser)
            userName = userModel.lastUser
        if (username.text.length > 0)
            password.forceActiveFocus()
        else
            username.forceActiveFocus()
    }

    Image {
        anchors.fill: parent
        source: config.background || ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.35) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.65) }
        }
    }

    Column {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.16
        spacing: 4

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clockTimer.now, "HH:mm")
            color: "#ffffff"
            font.pixelSize: 92
            font.weight: Font.Light
            font.family: config.font || "sans-serif"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clockTimer.now, "dddd, d MMMM")
            color: Qt.rgba(1, 1, 1, 0.72)
            font.pixelSize: 20
            font.family: config.font || "sans-serif"
        }
    }

    Timer {
        id: clockTimer
        property var now: new Date()
        interval: 1000
        running: true
        repeat: true
        onTriggered: now = new Date()
    }

    Rectangle {
        id: card
        width: 380
        height: 250
        radius: 18
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: clock.bottom
        anchors.topMargin: 64
        color: Qt.rgba(palette.surface.r, palette.surface.g, palette.surface.b, 0.82)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)

        Column {
            anchors.centerIn: parent
            width: parent.width - 56
            spacing: 16

            Rectangle {
                width: parent.width
                height: 44
                radius: 10
                color: Qt.rgba(0, 0, 0, 0.28)
                border.width: 1
                border.color: username.activeFocus ? palette.accent
                                                   : Qt.rgba(1, 1, 1, 0.10)

                TextInput {
                    id: username
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    text: root.userName
                    color: palette.foreground
                    font.pixelSize: 16
                    font.family: config.font || "sans-serif"
                    selectByMouse: true
                    enabled: !busy
                    KeyNavigation.tab: password

                    onAccepted: password.forceActiveFocus()

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Username"
                        color: palette.muted
                        font: username.font
                        visible: username.text.length === 0 && !username.activeFocus
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 44
                radius: 10
                color: Qt.rgba(0, 0, 0, 0.28)
                border.width: 1
                border.color: password.activeFocus ? palette.accent
                                                   : Qt.rgba(1, 1, 1, 0.10)

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    color: palette.foreground
                    font.pixelSize: 16
                    font.family: config.font || "sans-serif"
                    selectByMouse: true
                    enabled: !busy
                    KeyNavigation.tab: username

                    onAccepted: root.attemptLogin()

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Password"
                        color: palette.muted
                        font: password.font
                        visible: password.text.length === 0 && !password.activeFocus
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 42
                radius: 10
                color: loginHover.containsMouse ? Qt.lighter(palette.accent, 1.12)
                                                : palette.accent
                opacity: busy ? 0.6 : 1

                Text {
                    anchors.centerIn: parent
                    text: busy ? "Signing in…" : "Log in"
                    color: palette.background
                    font.pixelSize: 15
                    font.family: config.font || "sans-serif"
                }

                MouseArea {
                    id: loginHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.attemptLogin()
                }
            }

            Text {
                id: message
                anchors.horizontalCenter: parent.horizontalCenter
                text: ""
                color: palette.error
                font.pixelSize: 13
                font.family: config.font || "sans-serif"
                opacity: text.length > 0 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }
    }

    property bool busy: false

    function attemptLogin() {
        if (busy)
            return
        if (username.text.length === 0) {
            message.text = "Enter a username"
            username.forceActiveFocus()
            return
        }
        if (password.text.length === 0) {
            password.forceActiveFocus()
            return
        }
        busy = true
        message.text = ""
        sddm.login(username.text, password.text, sessionModel.lastIndex)
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            root.busy = false
            message.text = "Incorrect password"
            password.text = ""
            password.forceActiveFocus()
        }

        function onLoginSucceeded() {
            message.text = ""
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28
        spacing: 10

        Repeater {
            model: ["suspend", "reboot", "poweroff"]

            Rectangle {
                visible: modelData === "suspend" ? sddm.canSuspend
                       : modelData === "reboot"  ? sddm.canReboot
                                                 : sddm.canPowerOff
                width: label.width + 32
                height: 36
                radius: 18
                color: hover.containsMouse ? Qt.rgba(1, 1, 1, 0.18)
                                           : Qt.rgba(1, 1, 1, 0.09)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.10)

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: modelData === "suspend" ? "Suspend"
                        : modelData === "reboot"  ? "Restart"
                                                  : "Shutdown"
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.family: config.font || "sans-serif"
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData === "suspend") sddm.suspend()
                        else if (modelData === "reboot") sddm.reboot()
                        else sddm.powerOff()
                    }
                }
            }
        }
    }
}
