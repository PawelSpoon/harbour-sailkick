//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Persistance.js" as DB
import "../common"

// shows all tracked items of one type,
// click on one will open trackedItemPage
SilicaFlickable {

    id: page
    property string trackedType : "location"

    anchors.fill: parent

    // anchors.topMargin: Theme.paddingMedium

    // value of search..
    property string searchString
    onSearchStringChanged: {
        if (searchField === '') {
           refresh();
        }
        filterPage(searchString)
    }

    // the interface method
    function refresh()
    {
        console.log('refreshing tracing items page ' + trackedType)
        searchString = '';
        trackingModel.clear()
        var trackedItems = DB.getTrackedItems(trackedType)
        for (var i=0; i< trackedItems.length; i++)
        {
           fillTrackingModel(trackedItems[i].title, trackedItems[i].type, trackedItems[i].skid, trackedItems[i].uid, trackedItems[i].uri, trackedItems[i].body)
        }
    }

    function getCoverPageModel()
    {
        return trackingModel
    }

    function filterPage(nameLike)
    {
        trackingModel.clear()
        var trackedItems = DB.getFilteredTrackedItems(trackedType, nameLike)
        for (var i=0; i< trackedItems.length; i++)
        {
           fillTrackingModel(trackedItems[i].title, trackedItems[i].type, trackedItems[i].skid, trackedItems[i].uid, trackedItems[i].uri, trackedItems[i].body)
        }
        console.debug(trackedItems.length + " " + trackedType + " loaded from DB")
    }

    Column {
        id: headerContainer
        width: parent.width

        SearchField {
            id: searchField
            width: parent.width
            opacity: 1

            Binding {
                target: page
                property: "searchString"
                value: searchField.text.toLowerCase().trim()
            }
        }
    }


/*    QtObject {
        id: priv
        property Item optionsPage
        property string nextPageToken: ""
        property variant searchParams: ({})
        property bool ignoreNextAtYBeginning: false
        property real autoLoadThreshold: 0.8
    }*/

    Component.onCompleted:
    {
        console.log("trackeditemspage onCompleted")
        refresh()
    }

    function fillTrackingModel(title, type, skid, uid, uri, body)
    {
        var contains = trackingModel.contains(uid)
        if (contains[0]) console.log("contains already " + title);
        trackingModel.append({"title": title, "type": type, "uid": uid, "skid": skid, "uri": uri, "body": body})
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

        function contains(uid) {
            for (var i=0; i<count; i++) {
                if (get(i).uid === uid)  {
                    return [true, i];
                }
            }
            return [false, i];
        }
    }

    SilicaListView {

        id: trackedItemsList
        anchors.fill: parent
        contentHeight: parent.height
        contentWidth: parent.width
        anchors.topMargin: headerContainer.height

        model: trackingModel
        clip: true

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
                    //console.log("onClicked:" + index + " " + trackedItemsList.currentIndex)
                    var current = trackingModel.get(trackedItemsList.currentIndex)
                    //console.log(trackedItemsList.currentItem)
                    //console.log(current.title + " " + current.type + " " + current.skid)
                    pageStack.push(Qt.resolvedUrl("TrackedItemPage.qml"), { type: current.type,
                            songKickId: current.skid,
                            titleOf: current.title,
                            imageUrl: current.body.imageUrl }) //todo: make safe
                }

                onPressAndHold: {
                    trackedItemsList.currentIndex = index

                    console.log("on press: trackendItemsList " + trackedItemsList.currentIndex)
                    console.log("on press: trackingModel.objectName  " + trackingModel.objectName)
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

                Label {
                    id: onTour
                    text: "" // not available
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.verticalCenter : parent.verticalCenter
                    font.capitalization: Font.SmallCaps
                    font.pixelSize: Theme.fontSizeMedium
                    truncationMode: TruncationMode.Elide
                    elide: Text.ElideRight
                    color: Theme.highlightColor
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
                        console.log('')
                        console.log(trackingModel.currentIndex)
                        Qt.openUrlExternally(trackingModel.get(trackedItemsList.currentIndex).uri)

                    }
                }
            }
        }
    }
}
