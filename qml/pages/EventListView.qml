//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import Sailfish.Share 1.0
import "../Persistance.js" as DB
import "../common"

// shoould be a component for concerts and plans
// if only i could

SilicaListView {
    id: plans
    anchors.fill: parent
    contentHeight: parent.height
    contentWidth: parent.width

    property string im_going : qsTr("Going")
    property string i_might_go : qsTr("Interested")
    property string listType : 'plans'

    // the interface method
    function refresh()
    {
        skApi.getUserPlansAsync()
    }

    // to show plans on cover
    function getCoverPageModel()
    {
        return upcomingModel
    }

    //todo: move to helper and reuse
    // adds day in week to date
    // or i do concert the whole page to a component
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
            console.log(JSON.stringify(events[i]))
            //artistName           
            var shortTitle = events[i].name
            var pos = shortTitle.indexOf(" at ");
            if (pos > 1) shortTitle = events[i].name.substr(0,pos)
            var strArtistId = ''
            if (events[i].artistId) strArtistId = events[i].artistId.toString()
            upcomingModel.append({"title": shortTitle, "type": events[i].metroAreaName, "venue": events[i].venueName ,"date": dateWithDay(events[i].date), 
            "startTime": events[i].startTime , "uri" : events[i].eventUrl, "attendance": events[i].attendance,
             "artist": events[i].artistName, "artistId": strArtistId, "artists": events[i].artists, "skid": events[i].skid,
             "street": events[i].venueStreetAddress, "city": events[i].venueCity, "postalCode": events[i].venuePostalCode})
            console.log("added to model: " + JSON.stringify(upcomingModel.get(upcomingModel.count-1)))
        }
        sortModel()
        applicationWindow.controller.setCurrentPage(type)
        applicationWindow.controller.updateCoverList(type, upcomingModel)
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
       //skApi.getUserPlansAsync();
    }

    Connections {
        target: skApi
        onPlansSuccess: {
            // Handle received plans
            console.log("Plans received, filling model")
            upcomingModel.clear()
            fillUpCommingModelForOneTrackingEntry(listType, skApi.userPlansResults)
        }
        onActionFailed: {
            if (action === "plans") {
                // Handle plans failure
                console.log("Failed to get " + action)
            }
        }
        onActionError: {
            if (action === "plans") {
                console.error("Error during " + action + " :", error)
            }
        }        
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
        property string venue
        property string street
        property string city
        property string uri
    }

    // yet another try to get that multilingual but failing
    function setTrackingInfo(info)
    {
        console.log(info);
        if (info === 'Interested') {
            return applicationWindow.imightgo
        }
       return applicationWindow.imgoing
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
                    pageStack.push(Qt.resolvedUrl("EventPage.qml"),{ uri: current.uri ,
                                       name: current.title ,
                                       type: current.type ,
                                       date: current.date ,
                                       startTime: current.startTime ,
                                       artists: current.artists ,
                                       venue: current.venue ,
                                       street: current.street ,
                                       city: current.city ,
                                       postalCode: current.postalCode,
                                       attendance: current.attendance })
                    //pageStack.push(Qt.resolvedUrl("EventWebViewPage.qml"),{mainPage: mainPage, uri: current.uri})
                }

                onPressAndHold: {
                    upcommingList.currentIndex = index
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(upcommingList)
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
                        if (attendance === 'im_going')
                            "../sk-badge-pink.png"  // -pink not working
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
                Label {
                    id: planText
                    text:  setTrackingInfo(attendance)
                    anchors.right: parent.right//typeIcon.right
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.top: dateText.bottom
                    anchors.topMargin: 0//Theme.paddingSmall
                    font.capitalization: Font.AllUppercase
                    font.bold: true
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
                /*MenuItem {
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
                }*/
            }
        }
    }
}


