//<license>

import QtQuick 2.0
import Nemo.Notifications 1.0
import Sailfish.Silica 1.0
import Sailfish.Share 1.0
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
        if (page == 0)
          upcommingModel.clear()
        API.getUpcommingEventsForTrackedItem(type, songKickId, page, fillUpCommingModelForOneTrackingEntry)
    }

    function dateWithDay(datum)
    {
        var date = new Date(datum);
        return date.toLocaleDateString();
    }

    function fillUpCommingModelForOneTrackingEntry(type, events)
    {
        console.log('number of events: ' +  events.length)
        for (var i = 0; i < events.length; i++)
        {
            var shortTitle = events[i].name
            var pos = shortTitle.indexOf(" at ");
            if (pos > 1) shortTitle = shortTitle.substr(0,pos)
              upcommingModel.append({"title": shortTitle, "type": events[i].metroAreaName, "venue": events[i].venueName ,"date": dateWithDay(events[i].date), "uri" : events[i].uri })
        }
        applicationWindow.controller.updateCoverList(titleOf,upcommingModel)
    }


    Component.onCompleted:
    {
        reloadUpCommingModel()
        applicationWindow.controller.setCurrentPage(titleOf)
        applicationWindow.controller.updateCoverList(titleOf,upcommingModel)
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

    SilicaListView {

        id: upcommingList
        anchors.fill: parent
        anchors.topMargin: Theme.paddingSmall
        model: upcommingModel

        header: PageHeader {
            title: titleOf
        }
        
        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView

        PushUpMenu {
            MenuItem {
                text: qsTr("Load more")
                enabled: true//((upcommingModel.count % 50) != 0)
                onClicked: {
                    page = page + 1
                    upcommingList.currentIndex = ((page * 50) -1)
                    reloadUpCommingModel() // as page > 1, it will not empty view
                }
            }
        }

        ViewPlaceholder {
            enabled: upcommingModel.count === 0 // show placeholder when no items in ...
            text: qsTr("Seems there are no events planed")
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
                    id: childrenRect
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
                height: titleText.height + locationText.height + dateText.height + Theme.paddingMedium

                onPressAndHold: {
                    upcommingList.currentIndex = index
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(mainPage.locationList)
                    contextMenu.show(myListItem)
                }

                onClicked: {
                    upcommingList.currentIndex = index
                    console.log(upcommingList.currentIndex)
                    var current = upcommingModel.get(upcommingList.currentIndex)
                     pageStack.push(Qt.resolvedUrl("EventPage.qml"),{ uri: current.uri })
                    // pageStack.push(Qt.resolvedUrl("EventWebViewPage.qml"),{ uri: current.uri, songKickId: current.skid, titleOf: current.title })
                }

                Image {
                    id: typeIcon
                    anchors.left: parent.left
                    //anchors.verticalCenter: parent.verticalCenter
                    anchors.top: titleText.top
                    anchors.topMargin: Theme.paddingMedium
                    anchors.leftMargin: Theme.paddingSmall
                    source: {
                        "../sk-badge-white.png"
                    }
                    height: 0.8 * (titleText.height + locationText.height + dateText.height)
                    width: height
                }
                Label {
                    id: titleText
                    text: title
                    anchors.left: typeIcon.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: parent.top
                    //anchors.topMargin:  Theme.paddingSmall
                    font.capitalization: Font.Capitalize
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Elide
                    elide: Text.ElideRight
                    width: parent.width - typeIcon.width
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: dateText
                    text: venue
                    anchors.left: typeIcon.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: titleText.bottom
                    anchors.topMargin: 0
                    font.capitalization: Font.MixedCase
                    font.pixelSize: Theme.fontSizeTiny
                    font.italic: true
                    truncationMode: TruncationMode.Elide
                    elide: Text.ElideRight
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: locationText
                    text: type
                    anchors.left: typeIcon.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: dateText.bottom
                    anchors.topMargin: 0//Theme.paddingSmall
                    font.capitalization: Font.MixedCase
                    font.pixelSize: Theme.fontSizeTiny
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
                Notification {
                    id: notification
                    summary: qsTr("Copied to clipboard")
                }
                MenuItem {
                    text: qsTr("Open in browser")
                    onClicked: {
                        Qt.openUrlExternally(upcommingModel.get(upcommingList.currentIndex).uri)

                    }
                }
                /*MenuItem {
                    text: qsTr("Open in web view")
                    onClicked: {
                        console.log(upcommingList.currentIndex)
                        var current = upcommingModel.get(upcommingList.currentIndex)
                        pageStack.push(Qt.resolvedUrl("EventWebViewPage.qml"),{mainPage: mainPage, uri: current.uri})
                    }
                }*/
                MenuItem {
                    text: qsTr("Copy")
                    onClicked: {
                        var clip = upcommingModel.get(upcommingList.currentIndex).uri;
                        Clipboard.text = clip;
                        notification.body = clip;
                        notification.publish()
                    }
                }
                MenuItem {
                    text: qsTr("Share")
                    ShareAction {
                         id:shareAction
                         mimeType: "text/xml"
                         title: qsTr("Share event")
                    }
                    // icon: con-m-share
                    onClicked: {
                        console.log(upcommingList.currentIndex)
                        var mimeType = "text/x-url";
                        var current = upcomingModel.get(upcommingList.currentIndex)
                        var he = {}
                        he.data = current.uri
                        he.type = mimeType
                        he["linkTitle"] = current.uri // works in email body
                        //he["shareText"] = current.uri // does not work
                        shareAction.mimeType = mimeType
                        shareAction.resources = [he]
                        shareAction.trigger()
                    }
                }
            }
        }
    }
}

