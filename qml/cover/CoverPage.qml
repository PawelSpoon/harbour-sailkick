//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    id: coverPage

    property alias title: coverTitleLabel.text

    function fillModel(events)
    {
        print(events.count)
        var maxcount = 7
        if (events.count < maxcount) maxcount = events.count
        if (maxcount == 0) return
        upcommingModel.clear()
        for (var i = 0; i < maxcount; i++)
        {
            var shortTitle = events.get(i).title
            upcommingModel.append({"title": shortTitle});
        }
        upcommingModel.append({"title": ".."});

    }

    Label {
        id: coverTitleLabel
        font.pixelSize: Theme.fontSizeMedium
        color: Theme.highlightColor
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 40
        anchors.rightMargin: 20

        // anchors.topMargin: -60
        // anchors.leftMargin: 20
    }

    ListModel {
        id: upcommingModel
        ListElement { title : "Title"; type : "Type"; date: "Date"} //; venue: "Venue"; uri: "uri"}
    }

    Image {
        id: imgcover
        source: "../sk-badge-white.png"
        asynchronous: true
        opacity: 0.2
        width: parent.width * 1.15
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
    }

    Image {
        id: imgcover2
        source: "../powered-by-songkick-white.png"
        asynchronous: true
        opacity: 0.5
        width: parent.width * 0.65
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: parent.height * 0.4
        fillMode: Image.PreserveAspectFit
    }

    SilicaListView  {
        id: events
        model: upcommingModel
        width: parent.width
        anchors.fill: parent
        anchors.topMargin: 80
        anchors.leftMargin: Theme.paddingMedium

        delegate: Item {
            id: myListItem
            width: ListView.view.width
            height: 65

            BackgroundItem {
                id: contentItem
                width: parent.width

                Label {
                    id: titleText
                    text: title
                    anchors.leftMargin: Theme.paddingLarge * 2
                    anchors.verticalCenter : parent.verticalCenter
                    //anchors.topMargin:  Theme.paddingSmall
                    //font.capitalization: Font.Capitalize
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: false
                    truncationMode: TruncationMode.Fade
                    elide: Text.ElideRight
                    color: Theme.primaryColor
                }
            }
        }

    }

    CoverActionList {
        id: coverAction

/*        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
        }*/

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                console.log('nextPage triggered');
                applicationWindow.controller.moveToNextPage();
            }
        }

    }
}

