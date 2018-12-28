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
    property Page mainPage

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    onStatusChanged: {
        if (status === PageStatus.Active) {
            var nextPageType
            // it concerts == main -> plan -> location -> artist
            if (trackedType === "location") {
                nextPageType = "artist"
                applicationWindow.setCurrentPage(trackedType)
                applicationWindow.updateCoverList(trackedType,trackingModel)
            }

            if (trackedType === "artist") {
                nextPageType = "concert"
                applicationWindow.setCurrentPage(trackedType)
                applicationWindow.updateCoverList(trackedType,trackingModel)
            }
            if (!priv.optionsPage) {
                if (nextPageType === "concert"){
                    priv.optionsPage = pageStack.pushAttached(Qt.resolvedUrl("PlansPage.qml"), {mainPage: root})
                    // this is just a workaround
                }
                else {
                priv.optionsPage = pageStack.pushAttached(
                    Qt.resolvedUrl("TrackedItemsPage.qml"), {mainPage: mainPage, trackedType: nextPageType})
                }
            }
        }
    }

    QtObject {
        id: priv
        property Item optionsPage
        property string nextPageToken: ""
        property variant searchParams: ({})
        property bool ignoreNextAtYBeginning: false
        property real autoLoadThreshold: 0.8
    }

    Component.onCompleted:
    {
        reloadTrackingItemsAndUpcomming()
    }

    function fillTrackingModel(title, type, skid, uid, uri)
    {
        var contains = trackingModel.contains(uid)
        if (contains[0]) console.log("contains already " + title);
//        print("adding to tracking model: " + title + ";type: " + type + ";skid: " + skid + ";uid: " + uid + "; uri:" + uri)
        trackingModel.append({"title": title, "type": type, "uid": uid, "skid": skid, "uri": uri})
    }

    function reloadTrackingItemsAndUpcomming()
    {
        trackingModel.clear()
        var trackedItems = DB.getTrackedItems(trackedType)
        for (var i=0; i< trackedItems.length; i++)
        {
           fillTrackingModel(trackedItems[i].title, trackedItems[i].type, trackedItems[i].skid, trackedItems[i].uid, trackedItems[i].uri)
        }
        console.debug(trackedType + " loaded from DB")
        //sortModel()
        applicationWindow.updateCoverList(trackedType,locationList)
    }

    property ListModel locationList : trackingModel

    function sortModel()
    {
        var n;
        var i;
        for (n=0; n < trackingModel.count; n++)
            for (i=n+1; i < trackingModel.count; i++)
            {
                if (trackingModel.get(n).title> trackingModel.get(i).title)
                {
                    trackingModel.move(i, n, 1);
                    n=0;
                }
            }
    }

    // list of all tracked locations and artists
    // this is going to be populated from db
    ListModel {
        id: trackingModel
        //ListElement {title: "Title"; type: "Type"; uid: "UID"; skid: "Skid"; uri: "Uri"}

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
        PullDownMenu {

                MenuItem {
                    text: qsTr("Manage")
                    onClicked: {
                        if (trackedType == "location") pageStack.push(Qt.resolvedUrl("EventWebViewPage.qml"),{mainPage: root, uri: "https://www.songkick.com/tracker/metro_areas", songKickId: "no songKickId", titleOf: "no titleOf" })
                        if (trackedType == "artist")   pageStack.push(Qt.resolvedUrl("EventWebViewPage.qml"),{mainPage: root, uri: "https://www.songkick.com/tracker/artists", songKickId: "no songKickId", titleOf: "no titleOf" })
                    }
                }

        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Back to top")
                onClicked: trackedItemsList.scrollToTop()
                visible: (trackedType == "artist")
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
                    anchors.verticalCenter: parent.verticalCenter
                    source: {
                        "../sk-badge-white.png"
                    }
                    height: parent.height - 10
                    width: height
                }
                Label {
                    id: titleText
                    text: title
                    anchors.left: typeIcon.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.verticalCenter : parent.verticalCenter
                    //anchors.topMargin:  Theme.paddingSmall
                    font.capitalization: Font.Capitalize
                    font.pixelSize: Theme.fontSizeMedium
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
                    text: qsTr("Open in browser")
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

