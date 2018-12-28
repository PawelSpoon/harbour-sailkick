//<license>

import QtWebKit 3.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Persistance.js" as DB
import "../SongKickApi.js" as API

import "../common"

Dialog {

    id: eventPage
    // property to pass root page
    property MainPage mainPage: null
    property string uri

    allowedOrientations: applicationWindow.orientationSetting


    SilicaFlickable {

        anchors.fill: parent
        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        DialogHeader {
            acceptText: qsTr("Open in browser")
            cancelText: qsTr(" ")
        }

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.

        Column {
            id: column
            width: eventPage.width
        /*Image {
            anchors.horizontalCenter: parent.horizontalCenter
            height: 240 * Theme.pixelRatio;
            fillMode: Image.PreserveAspectFit
            //antialiasing: true
            // source: player.cover
        }*/

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
            id: eventType
            anchors.left: parent.left; anchors.right: parent.right // wrapping
            anchors.leftMargin: 16; anchors.rightMargin: 16
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
            text: "type"
        }

        Label {
            id: city
            anchors.left: parent.left; anchors.right: parent.right // wrapping
            anchors.leftMargin: 16; anchors.rightMargin: 16
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeMedium
            text: "city"
        }

        Label {
            id: venue
            anchors.left: parent.left; anchors.right: parent.right // wrapping
            anchors.leftMargin: 16; anchors.rightMargin: 16
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            text: "venue"
        }
        Label {
            id: dist2
            height: 100
            text: "  "
        }
        Label {
            id: artist
            anchors.left: parent.left; anchors.right: parent.right // wrapping
            anchors.leftMargin: 16; anchors.rightMargin: 16
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeLarge
            text: "artist"
        }
        Label {
            id: dateTime
            anchors.left: parent.left; anchors.right: parent.right // wrapping
            anchors.leftMargin: 16; anchors.rightMargin: 16
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            text: "date-time"
        }

        Label {
            id: startTime
            anchors.left: parent.left; anchors.right: parent.right // wrapping
            anchors.leftMargin: 16; anchors.rightMargin: 16
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            // text: "start-time"
        }
        }


        /*PullDownMenu {
            MenuItem {
                text: qsTr("Open in browser")
                onClicked: Qt.openUrlExternally(uri)
            }
        }*/
    }


    Component.onCompleted: {

        console.log(uri);
        var eventId;
        var startPos;
        var endPos;
        if (uri.indexOf('/festivals/') > 0) {
          // extract id between which is located between /id/ and ?something
          // http://www.songkick.com/festivals/288543-synergy/id/36362974-synergy-festival-2018?utm_
          startPos = uri.lastIndexOf("/id/");
          endPos = uri.lastIndexOf("?");
          console.log(startPos+4)
          console.log(endPos)
          eventId = uri.substring(startPos+4,endPos)
          console.log(eventId);
        } else {
            // extract id between which is located between /id/ and ?something
            // http://www.songkick.com/concerts/33520769-john-garcia-at-juz-explosiv?utm_source=141
            startPos = uri.lastIndexOf("/concerts/");
            endPos = uri.lastIndexOf("?");
            eventId = uri.substring(startPos+10,endPos)
            console.log(eventId);
        }

        API.getEvent(eventId,fillPage);
    }


    function fillPage(event)
    {
        console.log('fillPage')

        eventName.text = event.displayName;
        eventType.text = event.type;
        dateTime.text = event.dateTime;
            /*if (event.start.datetime !== null) {
               startTime.text = event.start.datetime;
            }*/
        venue.text = event.venue;
        city.text = event.city;
        artist.text = event.artist;
    }

    onAccepted: {
        Qt.openUrlExternally(uri)
    }

}

