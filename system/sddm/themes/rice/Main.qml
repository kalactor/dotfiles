import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080

    property int sessionIndex: session.index

    // Palette (matches the wallust output used on 2026-11-13)
    readonly property color bg:        "#232829"
    readonly property color fg:        "#D3E4E5"
    readonly property color accent:    "#117C62"
    readonly property color accentAlt: "#127E86"
    readonly property color muted:     "#809292"
    readonly property color fieldBg:   "#484E4F"
    readonly property color danger:    "#E06C75"

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        onLoginSucceeded: {
            errorMessage.color = root.accentAlt
            errorMessage.text = textConstants.loginSucceeded
        }
        onLoginFailed: {
            password.text = ""
            errorMessage.color = root.danger
            errorMessage.text = textConstants.loginFailed
        }
        onInformationMessage: {
            errorMessage.color = root.danger
            errorMessage.text = message
        }
    }

    Background {
        anchors.fill: parent
        source: Qt.resolvedUrl("background.jpg")
        fillMode: Image.PreserveAspectCrop
    }

    // Darken the wallpaper so the card and clock stay readable
    Rectangle {
        anchors.fill: parent
        color: root.bg
        opacity: 0.55
    }

    // Clock, top-left
    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 64
        spacing: 6

        Text {
            id: clockText
            color: root.fg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 64
            font.bold: true
            text: Qt.formatTime(new Date(), "HH:mm")
        }

        Text {
            id: dateText
            color: root.muted
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
            text: Qt.formatDate(new Date(), "dddd, dd MMMM")
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                clockText.text = Qt.formatTime(new Date(), "HH:mm")
                dateText.text = Qt.formatDate(new Date(), "dddd, dd MMMM")
            }
        }
    }

    // Login card
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 400
        height: content.implicitHeight + 64
        radius: 24
        color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.90)
        border.width: 1
        border.color: root.accent

        Column {
            id: content
            anchors.centerIn: parent
            width: parent.width - 64
            spacing: 14

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.fg
                text: "Welcome back"
                font.family: "Inter"
                font.pixelSize: 26
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.muted
                text: sddm.hostName
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
            }

            Text {
                color: root.muted
                text: textConstants.userName
                font.family: "Inter"
                font.pixelSize: 12
                font.bold: true
            }

            TextBox {
                id: name
                width: parent.width
                height: 42
                text: userModel.lastUser
                color: root.fieldBg
                textColor: root.fg
                borderColor: root.muted
                focusColor: root.accent
                hoverColor: root.accentAlt
                radius: 10
                font.family: "Inter"
                font.pixelSize: 14

                KeyNavigation.tab: password
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(name.text, password.text, sessionIndex)
                        event.accepted = true
                    }
                }
            }

            Text {
                color: root.muted
                text: textConstants.password
                font.family: "Inter"
                font.pixelSize: 12
                font.bold: true
            }

            PasswordBox {
                id: password
                width: parent.width
                height: 42
                color: root.fieldBg
                textColor: root.fg
                borderColor: root.muted
                focusColor: root.accent
                hoverColor: root.accentAlt
                radius: 10
                font.family: "Inter"
                font.pixelSize: 14

                KeyNavigation.tab: session
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(name.text, password.text, sessionIndex)
                        event.accepted = true
                    }
                }
            }

            Text {
                color: root.muted
                text: textConstants.session
                font.family: "Inter"
                font.pixelSize: 12
                font.bold: true
            }

            ComboBox {
                id: session
                width: parent.width
                height: 38
                color: root.fieldBg
                borderColor: root.muted
                focusColor: root.accent
                hoverColor: root.accentAlt
                textColor: root.fg
                menuColor: root.bg
                arrowColor: root.fieldBg
                arrowIcon: Qt.resolvedUrl("angle-down.png")
                font.family: "Inter"
                font.pixelSize: 13

                model: sessionModel
                index: sessionModel.lastIndex

                KeyNavigation.tab: loginButton
            }

            Text {
                id: errorMessage
                width: parent.width
                color: root.muted
                text: textConstants.prompt
                font.family: "Inter"
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Button {
                    id: loginButton
                    width: 132
                    height: 40
                    text: textConstants.login
                    color: root.accent
                    activeColor: root.accentAlt
                    pressedColor: root.muted
                    textColor: root.bg
                    borderColor: root.accent
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.bold: true

                    KeyNavigation.tab: rebootButton
                    onClicked: sddm.login(name.text, password.text, sessionIndex)
                }

                Button {
                    id: rebootButton
                    width: 96
                    height: 40
                    text: textConstants.reboot
                    color: root.fieldBg
                    activeColor: root.accentAlt
                    pressedColor: root.accent
                    textColor: root.fg
                    borderColor: root.muted
                    font.family: "Inter"
                    font.pixelSize: 13

                    KeyNavigation.tab: shutdownButton
                    onClicked: sddm.reboot()
                }

                Button {
                    id: shutdownButton
                    width: 96
                    height: 40
                    text: textConstants.shutdown
                    color: root.fieldBg
                    activeColor: root.danger
                    pressedColor: root.danger
                    textColor: root.fg
                    borderColor: root.muted
                    font.family: "Inter"
                    font.pixelSize: 13

                    KeyNavigation.tab: name
                    onClicked: sddm.powerOff()
                }
            }
        }
    }

    Component.onCompleted: {
        if (name.text === "")
            name.focus = true
        else
            password.focus = true
    }
}
