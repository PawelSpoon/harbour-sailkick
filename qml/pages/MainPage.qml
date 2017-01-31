//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Persistance.js" as DB
import "../ResponseConverter.js" as Convert
import "../common"



Page {
    id: root

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    function clearTrackingModel()
    {
        trackingModel.clear(); // this deletes the dummy entry that i use to have a 'typed' model
    }

    // this method is called only from DB.getLocations
    // not nice, i took this over from noto application
    function fillTrackingModel(title, type, skid, uid)
    {
        var contains = trackingModel.contains(uid)
        if (contains[0]) console.log("contains already " + title);
        trackingModel.append({"title": title, "type": type, "uid": uid, "skid": skid})
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
          fillUpCommingModel()
        }
    }

    function updateEntry(title, type, skid, uid)
    {
        var contains = trackingModel.contains(uid)
        if (contains[0]) {
          DB.setTrackingEntry(type,uid,title,skid,"some text")
          console.log("added to list")
          fillUpCommingModel()
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
        //fillTrackingModel()
    }

    function cleanDb()
    {
        DB.removeAllTrackingEntries("location")
        DB.removeAllTrackingEntries("artist")
        DB.removeAllTrackingEntries("venue")
        fillUpCommingModel()
    }

    function fillUpCommingModel()
    {
        upcommingModel.clear()
        for (var i = 0; i <= trackingModel.count; i++)
        {
            for (var j = 1; j < 3; j++)
            {
                upcommingModel.append({"title": trackingModel.get(i).title + j, "date": "2017-03-0"+j.toString(), "type": trackingModel.get(i).type, "uri" : "https:\\www.google.com" })
            }
        }
    }

    Component.onCompleted:
    {
        clearTrackingModel();
        DB.initialize();
        console.debug("db initilized")
        //DB.getLocations();
        DB.getTrackedItems("location")
        console.debug("locations loaded")
        DB.getTrackedItems("venue")
        console.log("venue loaded")
        DB.getTrackedItems("artist")
        console.log("artist loaded")
        fillUpCommingModel();
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
        ListElement { title : "Title"; type : "Type"; date: "Date"; uri: "uri"}
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
            title: qsTr("Upcomming Events")
        }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"), {mainPage: root})
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: fillUpCommingModel()
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Top") // will scroll to top
                onClicked: upcommingList.scrollToTop()
            }
            MenuItem {
                text: qsTr("Help") // will show help page (could be on Settings page instead)
                onClicked: pageStack.push(Qt.resolvedUrl("HelpMainPage.qml"))
            }
            MenuItem {
                text: qsTr("About") // will show about page
            }
        }

        ViewPlaceholder {
            enabled: trackingModel.count === 0 // show placeholder text when no locations/artists are tracked
            text: qsTr("Add an artist, metro area or venue to your tracking list in Settings")
        }

        // try to have sections by date
        /*section {
            property: "date"
            criteria: ViewSection.FullString
            delegate: Rectangle {
                color: "#b0dfb0"
                width: parent.width
                height: childrenRect.height + 4
                Text { anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 16
                    font.bold: true
                    text: section
                }
            }
        }*/

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
                        else*/ "image://theme/icon-m-levels"
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
                    font.pixelSize: 36
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
                    font.pixelSize: 18
                    truncationMode: TruncationMode.Elide
                    elide: Text.ElideRight
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: dateText
                    text: date
                    anchors.left: typeIcon.right
                    anchors.leftMargin: 100
                    anchors.top: locationText.top
                    anchors.topMargin: 0
                    font.capitalization: Font.MixedCase
                    font.pixelSize: 18
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
                        Qt.openUrlExternally("http://www.songkick.com")
                        //QDesktopService.openUrl(QUrl("https:\\www.google.com", QUrl.TolerantMode));
                    }
                }
            }
        }
    }
}

