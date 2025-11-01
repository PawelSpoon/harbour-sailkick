//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import "../Persistance.js" as DB

import "../common"

Dialog {

    id: eventPage

    property alias name: eventName.text
    property alias type: eventType.text
    property alias date: date.text
    property alias startTime: startTime.text
    property alias venue: venueLabel.text
    property alias street: street.text
    property alias city: city.text
    property string attendance
    property string postalCode
    property string uri
    property string headers
    property string artistImageUrl
    property var artists // array of strings
    property string im_going : qsTr("Going")
    property string i_might_go : qsTr("Interested")

    allowedOrientations: Orientation.All


    SilicaFlickable {

        anchors.fill: parent
        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Webview")
                onClicked: pageStack.push(Qt.resolvedUrl("WebViewPage.qml"), {mainPage: root, uri: uri, headers: headers})
            }
        }

        DialogHeader {
            acceptText: qsTr("Open in browser")
            cancelText: qsTr(" ")
        }

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Notification {
            id: notification
            summary: qsTr("Copied to clipboard")
        }

        Column {
            id: column
            width: eventPage.width

            Label {
                id: dist
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                anchors.leftMargin: 16; anchors.rightMargin: 16
                horizontalAlignment: Text.AlignHCenter
                height: 200
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraLarge
                text: qsTr("  ")
                color: Theme.highlightColor
            }

            Label {
                id: eventName
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                anchors.leftMargin: 16; anchors.rightMargin: 16
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeLarge
                text: qsTr("Event name")
                color: Theme.highlightColor
            }

            Label {
                id: date
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                anchors.leftMargin: 16; anchors.rightMargin: 16
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Date unknown")
            }

            Label {
                id: startTime
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                anchors.leftMargin: 16; anchors.rightMargin: 16
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Start time unknown")
            }

            Label {
                id: eventType
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                anchors.leftMargin: 16; anchors.rightMargin: 16
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "" // Concert, Festival, etc.
            }

            Label {
                id: dist2
                height: 100
                text: "  "
            }

            SectionHeader {
                text: qsTr("Venue")
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                anchors.leftMargin: 16; anchors.rightMargin: 16
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeLarge
            }

            Button {
                id: cpAddress
                anchors.horizontalCenter: parent.horizontalCenter;
                // text: qsTr('copy')
                onClicked: {
                    var clip = venueLabel.text;
                    if (street.text !== 'street') { clip += ", " + street.text };
                    if (city.text !== 'city') { clip += ", " + city.text };
                    Clipboard.text = clip;
                    notification.body = clip;
                    notification.publish()
                }
                width: 120
                height: 120
                // text: qsTr("copy")
                Image {
                    source: "image://theme/icon-s-clipboard";
                    height: parent.height
                    width: parent.height
                }

            }

            Label {
                id: venueLabel
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                anchors.leftMargin: 16; anchors.rightMargin: 16
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeMedium
                text: "venue"
            }

            Label {
                id: street
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                anchors.leftMargin: 16; anchors.rightMargin: 16
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                text: "street"
            }

            Label {
                id: city
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                anchors.leftMargin: 16; anchors.rightMargin: 16
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                text: "city"
            }

            Label {
                id: dist3
                height: 100
                text: "  "
            }

            ListModel {
                id: artistsModel
                ListElement {displayName: "Name"; skid: "Skid"}

            }

            SectionHeader {
                       id: allPerformer
                       anchors.left: parent.left; anchors.right: parent.right // wrapping
                       anchors.leftMargin: 16; anchors.rightMargin: 16
                       horizontalAlignment: Text.AlignHCenter
                       wrapMode: Text.Wrap
                       font.pixelSize: Theme.fontSizeLarge
                       text: qsTr("Performer(s)")
            }

            Button {
               width: 120
               height: 120
               anchors.horizontalCenter: parent.horizontalCenter;
               onClicked: {
                   Clipboard.text = artistsModel.get(0).displayName;
                   notification.body = artistsModel.get(0).displayName;
                   notification.publish()
               }
               // text: qsTr("copy")
               Image {
                   source: "image://theme/icon-s-clipboard";
                   height: parent.height
                   width: parent.height
               }
            }


            Repeater {
                    model: artistsModel

                    delegate: Label {
                        text: displayName
                        anchors.left: parent.left; anchors.right: parent.right // wrapping
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                    }
            }

            Label {
                id: dist4
                height: 100
                text: "  "
            }

            Label {
                id: attendanceLabel
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                anchors.leftMargin: 16; anchors.rightMargin: 16
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeLarge
                text: "attendance"
                color: Theme.highlightColor
            }
        }
    }


    Component.onCompleted: {
        setTrackingInfo()
        if (artistsModel.count > 0) {
            artistsModel.clear()
        }
        if (artists == undefined) return
        var artistArray = artists.split(";")
        if (true) {
            for (var i=0; i<artistArray.length; i++)
            {
                var artist = artistArray[i]
                artist = artist.trim()
                artistsModel.append({displayName: artist});
            }
        } else {
            console.log("No artists found")
            artistsModel.append({displayName: "No artists found"});
        }
        console.log("EventPage - headers",headers)
    }

    function setTrackingInfo()
    {
      attendanceLabel.text = qsTr(attendance);
    }

    onAccepted: {
        Qt.openUrlExternally(uri)
    }

}
