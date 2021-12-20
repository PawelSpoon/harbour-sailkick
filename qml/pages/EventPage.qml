//<license>

import QtWebKit 3.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import "../Persistance.js" as DB
import "../SongKickApi.js" as API

import "../common"

Dialog {

    id: eventPage

    property string uri
    property string im_going : qsTr("im_going")
    property string i_might_go : qsTr("i_might_go")

    allowedOrientations: Orientation.All


    SilicaFlickable {

        anchors.fill: parent
        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Webview")
                onClicked: pageStack.push(Qt.resolvedUrl("WebViewPage.qml"), {mainPage: root, uri: uri})
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
                text: "start-time"
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
                    var clip = venue.text;
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
                id: venue
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
                id: attendance
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
        API.getEventTrackingInfo(eventId, setTrackingInfo);
    }


    function setTrackingInfo(info)
    {
      attendance.text = qsTr(info);
    }

    function fillPage(event)
    {
        console.log('fillPage')
        var s1 = event.displayName.lastIndexOf(" at ");

        eventName.text = event.displayName.substring(0,s1);
        eventType.text = event.type;
        dateTime.text = event.dateTime;
        if (event.time !== "") {
           startTime.text = event.time;
        }
        venue.text = event.venue;
        street.text = event.street
        city.text = event.zip + ' ' + event.city;
        artistsModel.clear();
        for (var aC=0; aC < event.artists.length; aC++)
        {
            artistsModel.append(event.artists[aC]);
        }
        // artist.text = event.artists[0].displayName;
    }

    onAccepted: {
        Qt.openUrlExternally(uri)
    }

}
