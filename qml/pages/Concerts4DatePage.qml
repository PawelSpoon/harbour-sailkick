//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import Sailfish.Share 1.0
// DB should not be needed here !!
import "../Persistance.js" as DB
import "../SongKickApi.js" as API
import "../common"


Page {
    id: root
    anchors.fill: parent

    SilicaFlickable {
        id: flick
        anchors.fill: parent

        function clearTrackingModel()
        {
            trackingModel.clear(); // this deletes the dummy entry that i use to have a 'typed' model
        }

        // the interface method
        function refresh()
        {
            console.log('refreshing concerts page')
            fillUpCommingModelForAllItemsInTrackingModel();
        }

        function fillUpCommingModelForAllItemsInTrackingModel(minDate,maxDate)
        {
            upcomingModel.clear()
            console.log("minDate:" + minDate)
            API.getEventsInUsersAreasForDate(minDate,"",fillUpCommingModelForOneTrackingEntry)
            //API.getUsersUpcommingEvents("artist", DB.getUser().name, fillUpCommingModelForOneTrackingEntry)
        }

        PullDownMenu {
            MenuItem {
                id: refreshMenuItem
                text: qsTr("Refresh")
                onClicked: flick.refresh()
            }
            MenuItem {
                id: minDateMenuItem
                text: qsTr("Choose from date")

                onClicked: {
                    //todo: if text already set put it to new Date()
                    var dialog = pageStack.push(pickerComponent, {
                        date: new Date( )
                    })
                    dialog.accepted.connect(function() {
                        minDateMenuItem.text = dialog.dateText
                        var skDateText = dialog.year
                        var month = dialog.month
                        if (month < 10) {
                            skDateText = skDateText + "-0" + month
                        } else {
                            skDateText = skDateText + "-" + month
                        }
                        var day = dialog.day
                        if (day < 10) {
                            skDateText = skDateText + "-0" + day
                        } else {
                            skDateText = skDateText + "-" +day
                        }
                        flick.fillUpCommingModelForAllItemsInTrackingModel(skDateText)
                    })
                }
                Component {
                    id: pickerComponent
                    DatePickerDialog {}
                }
            }
        }

        function getCoverPageModel()
        {
            return upcomingModel
        }

        function dateWithDay(datum)
        {
            var date = new Date(datum);
            return date.toLocaleDateString();
        }


        function fillUpCommingModelForOneTrackingEntry(events)
        {
            console.log('number of events: ' +  events.length)
            for (var i = 0; i < events.length; i++)
            {
                //artistName
                var shortTitle = events[i].name
                var pos = shortTitle.indexOf(" at ");
                if (pos > 1) shortTitle = events[i].name.substr(0,pos)
                var strArtistId = ''
                if (events[i].artistId) strArtistId = events[i].artistId.toString()
                upcomingModel.append({"title": shortTitle, "type": events[i].metroAreaName, "venue": events[i].venueName ,"date": dateWithDay(events[i].date), "uri" : events[i].uri , "attendance": events[i].attendance, "artist": events[i].artistName, "artistId": strArtistId, "skid": events[i].skid})
            }
            sortModel()
            applicationWindow.controller.setCurrentPage('concert')
            applicationWindow.controller.updateCoverList('concert', upcomingModel)
        }


        Component.onCompleted:
        {
            fillUpCommingModelForAllItemsInTrackingModel("")
        }

        function sortModel()
        {
            console.log("sorting")
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
            ListElement { title : "Title"; type : "Type"; date: "Date"; venue: "Venue"; uri: "uri"; attendance:"attendance"; artist: "artist"; artistId: "artistId"}
        }

        ListElement {
            id: upcommingModelElement
            property string title
            property string type
            property string skid
            property string date
            property string attendance
        }

        // To enable PullDownMenu, place our content in a SilicaFlickable
        SilicaListView {
            id: upcommingList
            anchors.fill: parent
            model: upcomingModel

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
                        // console.log(upcommingList.currentIndex)
                        var current = upcomingModel.get(upcommingList.currentIndex)
                        pageStack.push(Qt.resolvedUrl("EventPage.qml"),{ uri: current.uri })
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
                            if (attendance === "im_going")
                                "../sk-badge-white.png"  // -pink not working
                            else
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
                        text: qsTr("Open artists page")
                        onClicked: {
                            var item = upcomingModel.get(upcommingList.currentIndex);
                            console.log(JSON.stringify(item))
                            if (item.artistId)
                               applicationWindow.controller.openTrackedItemPageOnTop('artist', item.artistId, item.title)
                            else
                                console.log("no artist id")
                        }
                    }
                    MenuItem {
                        text: qsTr("Open in browser")
                        onClicked: {
                            Qt.openUrlExternally(upcomingModel.get(upcommingList.currentIndex).uri)
                        }
                    }
                    MenuItem {
                        text: qsTr("Copy");
                        onClicked: {
                            var clip = upcomingModel.get(upcommingList.currentIndex).uri;
                            Clipboard.text = clip;
                            notification.body = clip;
                            notification.publish();
                        }
                    }
                }
            }
        }
    }
}


