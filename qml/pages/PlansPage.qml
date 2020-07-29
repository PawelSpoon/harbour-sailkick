//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Persistance.js" as DB
import "../SongKickApi.js" as API
import "../common"




Page {
    id: plans

    property string im_going : qsTr("im_going")
    property string i_might_go : qsTr("i_might_go")

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    function dateWithDay(datum)
    {
        var date = new Date(datum);
        return date.toLocaleDateString();
    }

    function fillUpCommingModelForAllItemsInTrackingModel()
    {
        upcomingModel.clear()
        API.getUsersUpcommingEvents("attendance", DB.getUser().name, online, offline)
    }

    function offline(type, events)
    {
        //get from db and show
    }

    function online(type, events)
    {
        // save to db then show.
        fillUpCommingModelForOneTrackingEntry(type, events);
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
            print(shortTitle + " " + events[i].attendance)
            upcomingModel.append({"title": shortTitle, "type": events[i].metroAreaName, "venue": events[i].venueName ,"date": dateWithDay(events[i].date), "uri" : events[i].uri, "attendance": events[i].attendance })
            //todo: store to db
        }
        sortModel()
        applicationWindow.updateCoverList('plans', upcomingModel)
    }


    onStatusChanged: {
        if (status === PageStatus.Active) {
            applicationWindow.setCurrentPage('plans')
            pageStack.pushAttached(Qt.resolvedUrl("MainPage.qml"))
            // during the inital startup the list won't be ready yet, but for a later swipe back to this page.
            // this location is correct. thats why i check for the count, assuming that this reflects
            // that list is ready
            if (upcomingModel.count > 0) applicationWindow.updateCoverList('plans', upcomingModel)
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
       fillUpCommingModelForAllItemsInTrackingModel();
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

    // list of all upcomming events based on tracked locations and artists
    // this list is going to be populated from songkick webpage
    ListModel {
        id: upcomingModel
        ListElement { title : "Title"; type : "Type"; date: "Date"; venue: "Venue"; uri: "uri"; attendance:"attendance"}
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

        header: PageHeader {
            title: qsTr("Plans")
        }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
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
                    // plans page does not have a link to mainpage yet, for that mainpage would need
                    pageStack.push(Qt.resolvedUrl("EventPage.qml"),{ uri: current.uri }) // with mainPage null open in browser will not work
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
                    text:  {
                        if (attendance === "im_going") {im_going} else {i_might_go }
                    }
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
                        pageStack.push(Qt.resolvedUrl("ShareWithPage.qml"), {destroyOnPop:true, sharedName: "My plans", sharedContent: current.uri, sharedType:"text/x-url" })
                    }
                }
            }
        }
    }
}

