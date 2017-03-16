//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Persistance.js" as DB
import "../SongKickApi.js" as API
import "../common"

// shows all tracked items of one type,
// click on one will open trackedItemPage

Page {
    id: trackedItemsPage
    property string trackedType : "location"

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    Component.onCompleted:
    {
        reloadTrackingItemsAndUpcomming()
    }

    function fillTrackingModel(title, type, skid, uid)
    {
        var contains = trackingModel.contains(uid)
        if (contains[0]) console.log("contains already " + title);
        print("adding to tracking model: " + title + " " + type + " " + skid + " " + uid)
        trackingModel.append({"title": title, "type": type, "uid": uid, "skid": skid})
    }

    function reloadTrackingItemsAndUpcomming()
    {
        trackingModel.clear()
        var trackedItems = DB.getTrackedItems(trackedType)
        for (var i=0; i< trackedItems.length; i++)
        {
           fillTrackingModel(trackedItems[i].title, trackedItems[i].type, trackedItems[i].skid, trackedItems[i].uid)
        }
        console.debug(trackedType + " loaded from DB")
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


    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaListView {
        id: trackedItemsList
        anchors.fill: parent
        model: trackingModel

        header: PageHeader {
            title: {
                //todo: if type then text for location / artist / venue
                if (trackedType == "location") qsTr("Your locations")
                if (trackedType == "artist") qsTr("Your artists")
                if (trackedType == "venue") qsTr("Your venues")
            }
        }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        /*PullDownMenu {

        }*/

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
            text: qsTr("You are not tracking any ...")
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

                onClicked: {
                    trackedItemsList.currentIndex = index
                    print(trackingModel.currentIndex)
                    var current = trackingModel.get(trackedItemsList.currentIndex)
                    pageStack.push(Qt.resolvedUrl("TrackedItemPage.qml"), {mainPage: root, type: current.type, songKickId: current.skid, titleOf: current.title })
                }

                onPressAndHold: {
                    trackedItemsList.currentIndex = index

                    print("on press: trackendItemsList " + trackedItemsList.currentIndex)
                    print("on press: trackingModel.objectName  " + trackingModel.objectName)
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
                        print(trackingModel.currentIndex)
                        Qt.openUrlExternally(trackingModel.get(trackedItemsList.currentIndex).uri)

                    }
                }
            }
        }
    }
}

