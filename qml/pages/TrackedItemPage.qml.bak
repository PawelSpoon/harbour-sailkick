//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Persistance.js" as DB
import "../SongKickApi.js" as API
import "../common"

// shows all upcomming events of one item
// this can be artist / location / venue

Page {
    id: trackedItemPage
    property string type : "location"
    property string songKickId
    property string titleOf
    property int page : 0

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All


    function reloadUpCommingModel()
    {
        upcommingModel.clear()
        API.getUpcommingEventsForTrackedItem(type, songKickId, page, fillUpCommingModelForOneTrackingEntry)
    }

    function fillUpCommingModelForOneTrackingEntry(type, events)
    {
        print('number of events: ' +  events.length)
        for (var i = 0; i < events.length; i++)
        {
            // metroAreaName is obviously wrong ..
            upcommingModel.append({"title": events[i].name, "type": events[i].metroAreaName, "venue": events[i].venueName ,"date": events[i].date, "uri" : events[i].uri })
        }
    }


    Component.onCompleted:
    {
        reloadUpCommingModel()
    }


    property ListModel locationList : trackingModel

    // list of all tracked locations and artists
    // this is going to be populated from db
    ListModel {
        id: trackingModel
        ListElement {title: "Title"; type: "Type"; uid: "UID"; skid: "Skid"}

        function contains(uid) {
            for (var i=0; i<count; i++) {
                if (get(i).uid === uid)  {
                    return [true, i];
                }
            }
            return [false, i];
        }
    }


    // list of all upcomming events based on tracked locations and artists
    // this list is going to be populated from songkick webpage
    ListModel {
        id: upcommingModel
        ListElement { title : "Title"; type : "Type"; date: "Date"; venue: "Venue"; uri: "uri"}
    }

    ListElement {
        id: upcommingModelElement
        property string title
        property string type
        property string skid
        property string date
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaListView {
        id: upcommingList
        anchors.fill: parent
        model: upcommingModel

        header: PageHeader {
            title: titleOf
        }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {

            MenuItem {
                text: qsTr("Refresh")
                onClicked: reloadUpCommingModel()
            }
            /*MenuItem {
                text: qsTr("Artists")
                onClicked: pageStack.push(Qt.resolvedUrl("ArtistsPage.qml"), {mainPage: root})
            }
            MenuItem {
                text: qsTr("Locations")
                onClicked: pageStack.push(Qt.resolvedUrl("LocationPage.qml"), {mainPage: root})
            }
            /*MenuItem {
                text: qsTr("Plans")
                onClicked: pageStack.push(Qt.resolvedUrl("LocationPage.qml"), {mainPage: root})
            }*/
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Load more")
                //onClicked: upcommingList.scrollToTop()
            }
            MenuItem {
                text: qsTr("Help") // will show help page (could be on Settings page instead)
                onClicked: pageStack.push(Qt.resolvedUrl("HelpMainPage.qml"))
            }
        }

        ViewPlaceholder {
            enabled: trackingModel.count === 0 // show placeholder text when no locations/artists are tracked
            text: qsTr("Add an artist, metro area or venue to your tracking list in Settings")
        }

        // try to have sections by date
        section {
            property: "date"
            criteria: ViewSection.FullString
            delegate: Rectangle {
                color: Theme.highlightColor
                opacity: 0.4
                width: parent.width
                height: childrenRect.height + 10
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    text: section
                }
            }
        }

        delegate: Item {
            id: myListItem
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            property int myIndex: index
            property Item contextMenu

            width: ListView.view.width
            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height


            BackgroundItem {
                id: contentItem

                width: parent.width

                onPressAndHold: {
                    upcommingList.currentIndex = index

                    print("on press: upcomminglist " + upcommingList.currentIndex)
                    print("on press: upcommingModelElement.Name  " + upcommingModelElement.objectName)
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(mainPage.locationList)
                    contextMenu.show(myListItem)
                }

                Image {
                    id: typeIcon
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingSmall
                    source: {
                        /*if (type === "location") "image://theme/icon-l-copy"
                        else "image://theme/icon-m-levels"*/
                        "../sk-badge-white.png"
                    }
                    height: parent.height
                    width: height
                }
                Label {
                    id: titleText
                    text: title
                    anchors.left: typeIcon.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: parent.top //.verticalCenter : parent.verticalCenter
                    anchors.topMargin:  Theme.paddingSmall
                    font.capitalization: Font.Capitalize
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Elide
                    elide: Text.ElideRight
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: locationText
                    text: type
                    anchors.left: typeIcon.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: titleText.bottom
                    anchors.topMargin: Theme.paddingSmall
                    font.capitalization: Font.MixedCase
                    font.pixelSize: Theme.fontSizeTiny
                    truncationMode: TruncationMode.Elide
                    elide: Text.ElideRight
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: dateText
                    text: venue
                    anchors.left: typeIcon.right
                    anchors.leftMargin: 100
                    anchors.top: locationText.top
                    anchors.topMargin: 0
                    font.capitalization: Font.MixedCase
                    font.pixelSize: Theme.fontSizeTiny
                    font.italic: true
                    truncationMode: TruncationMode.Elide
                    elide: Text.ElideRight
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                }
            }

        }

        Component {
            id: contextMenuComponent
            ContextMenu {
                id: menu
                MenuItem {
                    text: "Open in browser"
                    onClicked: {
                        print ('')
                        print(upcommingList.currentIndex)
                        Qt.openUrlExternally(upcommingModel.get(upcommingList.currentIndex).uri)

                    }
                }
            }
        }
    }
}

