//<license>

import QtQuick 2.0
import Nemo.Notifications 1.0
import Sailfish.Silica 1.0
import Sailfish.Share 1.0
import "../Persistance.js" as DB
import "../common"

// shows all upcomming events of one item
// this can be artist / location / venue

Page {

    id: trackedItemPage
    property string type : "location"
    property string songKickId
    property string titleOf
    property string imageUrl : "image://theme/icon-m-media-artists"
    property int page : 1
    property string startDate : ""
    property bool lockDate : false

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    function onError()
    {
        console.log("Error in loading upcomming events")
    }

    function reloadUpCommingModel(next)
    {
        if (next)
            page = page+1
        if (!next)
          upcommingModel.clear()
        console.log(type, songKickId, page, startDate)
        skApi.getTrackedItemEventsAsync(type, songKickId, page, startDate)
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
            console.log(events[i])
            var shortTitle = events[i].name
            var image = imageUrl
            if (type === "artist") img = events[i].artistImageUrl
            // most of the attr are for the detail page
            upcommingModel.append({"title": shortTitle,
             "type": events[i].metroAreaName,
             "venueName": events[i].venueName,
             "date": dateWithDay(events[i].date),
             "uri" : events[i].eventUrl,
             "name": events[i].name,  
             "metroAreaName": events[i].metroAreaName,
             "startTime": events[i].startTime,
             "venueStreet": events[i].venueStreet,
             "venueCity": events[i].venueCity,
             "attendance" : events[i].attendance,
             "venuePostalCode":events[i].venuePostalCode,
             "artistName": events[i].artistName,
             "imageUrl": image })
             /*"skid": events[i].skid             
             })*/
        }
        applicationWindow.controller.updateCoverList(titleOf,upcommingModel)
    }


    Component.onCompleted:
    {
        reloadUpCommingModel(false)
        coverImage.source = imageUrl
        // applicationWindow.controller.setCurrentPage(titleOf)
        applicationWindow.controller.updateCoverList(titleOf,upcommingModel)
    }

    Connections {
        target: skApi
        onTrackedItemSuccess: {
            // Handle received plans
            console.log("Item received, filling model")
            //trackingModel.clear()
            fillUpCommingModelForOneTrackingEntry(type, skApi.userTrackedItemResults)
        }
    }    


    // list of all upcomming events based on tracked locations and artists
    // this list is going to be populated from songkick webpage
    ListModel {
        id: upcommingModel
        // ListElement { title : "Title"; name :"Name" ; type : "Type"; date: "Date"; venue: "Venue"; uri: "uri"; artistId: "artistId"; skid: "Skid"}
    }

    ListElement {
        id: upcommingModelElement
        property string title
        property string name
        property string type
        property string skid
        property string date
        property string artistId
        property string artistName
        property string artistImageUrl
        property string metroAreaName
        property string venueName
        property string uri
        property string startTime
        property string venueStreet
        property string venueCity
        property string attendance
        property string venuePostalCode
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height

        PullDownMenu {
            MenuItem {
                id: minDateButton
                text: qsTr("Choose from date")

                onClicked: {
                    //todo: if text already set put it to new Date()
                    // a previous load more might have increased the page
                    page = 1
                    var dialog = pageStack.push(pickerComponent, {
                        date: new Date( )
                    })
                    dialog.accepted.connect(function() {
                        minDateButton.text = dialog.dateText
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
                        startDate = skDateText
                        reloadUpCommingModel(false)
                    })
                }
                Component {
                    id: pickerComponent
                    DatePickerDialog {}
                }
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Load more")
                enabled: true//((upcommingModel.count % 50) != 0)
                onClicked: {
                    upcommingList.currentIndex = ((page * 50) -1)
                    reloadUpCommingModel(true) // as page > 1, it will not empty view
                }
            }
        }

        Column {
            id: col
            width: trackedItemPage.width
            PageHeader {
                id: header
                title: titleOf
            }

           Rectangle {
                visible: true
                height: coverImage.height
                width: parent.width
                //anchors.top: coverImage.top
                color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
                opacity: 1
                z: 199
                Image {
                    id: coverImage
                    width: parent.width/3
                    height: width
                    fillMode: Image.PreserveAspectFit
                    source: imageUrl
                    anchors.leftMargin: Theme.paddingMedium
                    z: 200
                }
                Label {
                    id: startDateText
                    anchors.left: coverImage.right
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.verticalCenter: coverImage.verticalCenter
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    text: startDate
                    color: Theme.primaryColor
                    z: 200
                }
                IconButton {
                    id: lockDateButton
                    anchors.left: startDateText.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.verticalCenter: coverImage.verticalCenter
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                    visible: startDateText.text != ""
                    icon.source: lockDate? "image://theme/icon-s-secure" : "image://theme/icon-s-outline-secure"
                    onClicked: {
                        if (lockDate) {
                            lockDate = false
                        } else {
                            lockDate = true
                            // this might not be neede if i load the page value into dialog always
                            minDateButton.text = startDateText.text
                        }
                        /*if (albumData) {
                            playlistManager.clearPlayList()
                            playlistManager.playAlbum(albumId, true) // start playing immediately
                        }*/
                    }
                }
           }
           Separator {
               width: parent.width
               color: Theme.primaryColor
               horizontalAlignment: Qt.AlignHCenter
           }

                // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
                SilicaListView {

                    id: upcommingList
                    //anchors.fill: parent
                    width: parent.width
                    height: trackedItemPage.height - coverImage.height - header.height
                    //contentHeight: height- 2* coverImage.height
                    topMargin: Theme.paddingMedium

                    model: upcommingModel
                    z: -1
                    clip: true

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
                                console.log(JSON.stringify(current))
                                pageStack.push(Qt.resolvedUrl("EventPage.qml"),{
                                    uri: current.uri,
                                    name: current.artistName,
                                    type: type,
                                    date: current.date,
                                    startTime: current.startTime,
                                    venue: current.venueName,
                                    street: current.venueStreet,
                                    city: current.venueCity,
                                    attendance : current.attendance,
                                    postalCode : current.postalCode,
                                    artistImageUrl  : current.artistImageUrl
                                    })
                            }
                                // pageStack.push(Qt.resolvedUrl("EventWebViewPage.qml"),{ uri: current.uri, songKickId: current.skid, titleOf: current.title })

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
                                text: name
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
                                text: venueName
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
                        }
                    }

           }
        } // Column
    }
}
