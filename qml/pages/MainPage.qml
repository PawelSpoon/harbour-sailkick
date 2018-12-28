//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Persistance.js" as DB
import "../SongKickApi.js" as API
import "../common"



Page {
    id: root

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    function clearTrackingModel()
    {
        trackingModel.clear(); // this deletes the dummy entry that i use to have a 'typed' model
    }


    function fillTrackingModel(title, type, skid, uid, uri)
    {
        var contains = trackingModel.contains(uid)
        if (contains[0]) console.log("contains already " + title);
        print("adding to tracking model: " + title + " " + type + " " + skid + " " + uid + " " + uri)
        trackingModel.append({"title": title, "type": type, "uid": uid, "skid": skid, "uri": uri})
    }


    function updateTrackingItemsInDb(type, page, username, items)
    {

        print('number of items: ' +  items.length)
        //clearTrackingModel();

        var count = items.length
        for (var i = 0; i < count; i++) {
          var currentItem = items[i];
          print('storing: ' +  currentItem.title)
          DB.setTrackingEntry(type,currentItem.uid, currentItem.title,currentItem.skid,currentItem.uri)
        }
        print ('number of items: ' + items.length)

        if (items.length === 50) {
            API.getUsersTrackedItems(type,page+1,username, updateTrackingItemsInDb)
        }
        else
        {
          //clearTrackingModel()
          var trackedItems = DB.getTrackedItems("location")
          for (i=0; i< trackedItems.length; i++)
          {
             fillTrackingModel(trackedItems[i].title, trackedItems[i].type, trackedItems[i].skid, trackedItems[i].uid, trackedItems[i].uri)
          }
          console.debug("locations loaded")
          trackedItems = DB.getTrackedItems("venue")
          for (i=0; i< trackedItems.length; i++)
          {
             fillTrackingModel(trackedItems[i].title, trackedItems[i].type, trackedItems[i].skid, trackedItems[i].uid, trackedItems[i].uri)
          }
          console.log("venue loaded")
          trackedItems = DB.getTrackedItems("artist")
          for (i=0; i< trackedItems.length; i++)
          {
             fillTrackingModel(trackedItems[i].title, trackedItems[i].type, trackedItems[i].skid, trackedItems[i].uid, trackedItems[i].uri)
          }
          console.log("artist loaded")

        }
    }

    // adds one entry into trackingModel and persists it in db
    // location and artist are planned to be supported, currently in two separated tables (join? them)
    function addEntry(title, type, skid, uid)
    {
        var contains = trackingModel.contains(uid)
        if (!contains[0]) {
          var newUid = DB.getUniqueId();
          trackingModel.append({"title": title, "type": type, "uid": newUid, "skid": skid})
          DB.setTrackingEntry(type,newUid,title,skid,"some text")
          console.log("added to list")
          fillUpCommingModelForAllItemsInTrackingModel()
        }
    }

    function updateEntry(title, type, skid, uid)
    {
        var contains = trackingModel.contains(uid)
        if (contains[0]) {
          DB.setTrackingEntry(type,uid,title,skid,"some text")
          console.log("added to list")
          fillUpCommingModelForAllItemsInTrackingModel()
        }
    }

    function getEntryDetails(type, uid)
    {
        return DB.getTrackedItem(type,uid);
    }

    // remove a single entry from trackingModel and db
    function removeEntry(title, type, uid, index)
    {
        DB.removeTrackingEntry(type,title,uid)
        //mainPage.locationList.remove(index) //this works
        trackingModel.remove(index) // this is nicer
    }

    function cleanDb()
    {
        DB.removeAllTrackingEntries("Type") // just in case the dummy item was stored to db
        DB.removeAllTrackingEntries("location")
        DB.removeAllTrackingEntries("artist")
        DB.removeAllTrackingEntries("venue")
        trackingModel.clear()
        fillUpCommingModelForAllItemsInTrackingModel()
    }

    function fillUpCommingModelForAllItemsInTrackingModel()
    {
        upcomingModel.clear()
        API.getUsersUpcommingEvents("artist",DB.getUser().name,fillUpCommingModelForOneTrackingEntry)
    }

    function dateWithDay(datum)
    {
        var date = new Date(datum);
        return date.toLocaleDateString();
    }

    function fillUpCommingModelForOneTrackingEntry(type, events)
    {
        print('number of events: ' +  events.length)
        for (var i = 0; i < events.length; i++)
        {
            //artistName           
            var shortTitle = events[i].name
            var pos = shortTitle.indexOf(" at ");
            if (pos > 1) shortTitle = events[i].name.substr(0,pos)
            upcomingModel.append({"title": shortTitle, "type": events[i].metroAreaName, "venue": events[i].venueName ,"date": dateWithDay(events[i].date), "uri" : events[i].uri })
        }
        sortModel()
        applicationWindow.updateCoverList('Concerts', upcomingModel)
    }


    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached(
                    Qt.resolvedUrl("TrackedItemsPage.qml"), {mainPage: root, trackedType: "location"})
            applicationWindow.setCurrentPage('Concerts')
            applicationWindow.updateCoverList('Concerts', upcomingModel)
        }
    }

    Component.onCompleted:
    {
        clearTrackingModel();
        DB.initialize();
        reloadTrackingItemsAndUpcomming()
    }

    function reloadTrackingItemsAndUpcomming()
    {
        clearTrackingModel();
        console.debug("db initilized")
        //DB.getLocations();
        DB.getTrackedItems("location")
        console.debug("locations loaded")
        DB.getTrackedItems("venue")
        console.log("venue loaded")
        DB.getTrackedItems("artist")
        console.log("artist loaded")
        fillUpCommingModelForAllItemsInTrackingModel()
    }


    function sortModel()
    {
        print("sorting")
        for(var i=0; i<upcomingModel.count; i++)
        {
            for(var j=0; j<i; j++)
            {
                if(upcomingModel.get(i).date === upcomingModel.get(j).date)
                   upcomingModel.move(i,j,1)
                //break
            }
        }
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
        id: upcomingModel
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
        model: upcomingModel

        header: PageHeader {
            title: qsTr("Concerts")
        }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"), {mainPage: root})
            }
            MenuItem {
                text: qsTr("Get tracked items from songkick")
                onClicked:
                {
                    DB.removeAllTrackingEntries("Type")
                    DB.removeAllTrackingEntries("artist")
                    DB.removeAllTrackingEntries("location")
                    var user = DB.getUser()
                    API.getUsersTrackedItems("artist",1, user.name, updateTrackingItemsInDb)
                    API.getUsersTrackedItems("location",1,user.name, updateTrackingItemsInDb)
                    // does not work due to async behaviour of getUsersTrac...
                    // would need to wait here, but how long ?
                    /*pageStack.popAttached()
                    pageStack.pushAttached(
                            Qt.resolvedUrl("TrackedItemsPage.qml"), {mainPage: root, trackedType: "location"})*/
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: fillUpCommingModelForAllItemsInTrackingModel()
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Help") // will show help page (could be on Settings page instead)
                onClicked: pageStack.push(Qt.resolvedUrl("HelpMainPage.qml"))
            }
            /*MenuItem {
                text: qsTr("About") // will show about page
            }*/
        }

        ViewPlaceholder {
            enabled: upcomingModel.count === 0 // show placeholder text when no locations/artists are tracked
            text: qsTr("You have no upcomming concerts in your calendar")
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
                onClicked: {
                    upcommingList.currentIndex = index
                    print(upcommingList.currentIndex)
                    var current = upcomingModel.get(upcommingList.currentIndex)
                    pageStack.push(Qt.resolvedUrl("EventPage.qml"),{mainPage: root, uri: current.uri})
                }

                onPressAndHold: {
                    upcommingList.currentIndex = index
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(mainPage.locationList)
                    contextMenu.show(myListItem)
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
                MenuItem {
                    text: qsTr("Open in browser")
                    onClicked: {
                        print ('')
                        print(upcommingList.currentIndex)
                        Qt.openUrlExternally(upcomingModel.get(upcommingList.currentIndex).uri)

                    }
                }
                MenuItem {
                    text: qsTr("Share")
                    onClicked: {
                        print(upcommingList.currentIndex)
                        var current = upcomingModel.get(upcommingList.currentIndex)
                        pageStack.push(Qt.resolvedUrl("ShareWithPage.qml"), {destroyOnPop:true, mainPage: mainPage, sharedName: "My plans", sharedContent: current.uri, sharedType:"text/x-url" })
                    }
                }
            }
        }
    }
}

