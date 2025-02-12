// main page hosting tab1View

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Persistance.js" as DB
import "../SongKickApi.js" as API
import "."

Page  {
    id: tabsPage
    // anchors.fill: parent
    objectName: mainPageName

    allowedOrientations: defaultAllowedOrientations

    // these dummy translations are there to make cover title localized
    property string transPlans : qsTr('plan');
    property string transConcerts : qsTr('concert');
    property string transLocations : qsTr('location');
    property string transArtist : qsTr('artist');

    function menuManageVisible(visible) {
        menuManage.visible = visible
        menuGetTracked.visible = visible
    }

    function menuGotoDateVisible(visible) {
        menuConcertsGoToDate.visible = visible
    }

    function moveToNext()
    {
        console.log(viewsSlideshow.currentIndex)

        if (viewsSlideshow.currentIndex < 2) {
            menuManageVisible(false);
        }
        else {
            menuManageVisible(true);
        }

        if (viewsSlideshow.currentIndex === 3) {
            viewsSlideshow.currentIndex = 0;
            return
        }
        viewsSlideshow.currentIndex ++;
    }

    // should be moved to db or api, is api callback ..
    function updateTrackingItemsInDb(type, page, username, items)
    {
        console.log('number of items: ' +  items.length)

        var count = items.length
        for (var i = 0; i < count; i++) {
          var currentItem = items[i];
          console.log('storing: ' +  currentItem.title)
          DB.setTrackingEntry(type,currentItem.uid, currentItem.title,currentItem.skid,currentItem.uri,currentItem.body)
        }
        console.log('number of items: ' + items.length)

        if (items.length === 50) {
            API.getUsersTrackedItems(type,page+1,username, tabsPage.updateTrackingItemsInDb)
        }
        else
        {/*
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
             fillTrackingModel(trackedItems[i].title, trackedItems[i].type, trackedItems[i].skid, trackedItems[i].uid, trackedItems[i].uri, trackedItems[i].body)
          }
          console.log("artist loaded")
*/
        }
    }

    SilicaFlickable {

        id: flick
        anchors.fill: parent
        contentHeight: parent.height
        contentWidth: parent.width

        PullDownMenu {
            MenuItem {
                id: menuSettings
                text: qsTr("Settings")
                onClicked: myController.openSettingsPage()
            }
            MenuItem {
                id: menuManage
                text: qsTr("Manage")
                visible: false
                onClicked: {
                    myController.openManagePage()
               }
            }
            MenuItem {
                id: menuGetTracked
                text: qsTr("Get tracked items from songkick")
                onClicked:
                {
                    applicationWindow.controller.getTrackingItemsFromSongKick(null)
                }
            }
            MenuItem {
                id: menuConcertsGoToDate
                text: qsTr("Open concerts in my areas page")
                visible: false
                onClicked: {
                    applicationWindow.controller.openConcertsForDatePage();
                }
            }
            MenuItem {
                id: menuRefresh
                text: qsTr("Refresh")
                //todo: call this on the correct tab
                onClicked: {
                    applicationWindow.controller.refreshAll();
                }
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

        Component.onCompleted: {
            DB.initialize();
        }

        SlideshowView {
            id: viewsSlideshow
            anchors.fill: parent
            itemWidth: width
            clip: true
            model: VisualItemModel {
                Loader {
                    id: planContent
                    property int index: index // makes attached property available from outside
                    width: viewsSlideshow.width; height: viewsSlideshow.height
                    source: Qt.resolvedUrl("PlansPage.qml")
                    onSourceChanged: {
                        applicationWindow.controller.addPage('plan', planContent.item)
                    }
                }
                Loader {
                    id: concertContent
                    width: viewsSlideshow.width; height: viewsSlideshow.height
                    source: Qt.resolvedUrl("ConcertsPage.qml")
                    onSourceChanged: {
                         applicationWindow.controller.addPage('concert', concertContent.item)
                    }
                    //asynchronous: true
                }
                Loader {
                    id: locationContent
                    width: viewsSlideshow.width; height: viewsSlideshow.height
                    source: Qt.resolvedUrl("TrackedItemsPage.qml")
                    onSourceChanged:
                    {
                        locationContent.item.trackedType = "location"
                        locationContent.item.refresh()
                        applicationWindow.controller.addPage('location', locationContent.item)
                    }
                }
                Loader {
                    id: artistContent
                    width: viewsSlideshow.width; height: viewsSlideshow.height
                    source: Qt.resolvedUrl("TrackedItemsPage.qml")
                    onSourceChanged: {
                        artistContent.item.trackedType = "artist"
                        artistContent.item.refresh()
                        applicationWindow.controller.addPage('artist', artistContent.item)
                    }
                    /*onLoaded: {
                        artistContent.item.trackedType = "artist"
                        artistContent.item.refresh()
                    }*/
                }
            }

            // interactive: useCloud
            onCurrentIndexChanged: {
                tabBar.currentSelection = currentIndex
                if (currentIndex === 0)  applicationWindow.controller.setCurrentPage('plan')
                if (currentIndex === 1)  applicationWindow.controller.setCurrentPage('concert')
                if (currentIndex === 2)  applicationWindow.controller.setCurrentPage('location')
                if (currentIndex === 3)  applicationWindow.controller.setCurrentPage('artist')

                /*if (currentIndex === dictView.index && pageStack.currentPage.objectName === mainPageName) {
                    dictView.item.focusSearchField();
                }*/
            }

            currentIndex: tabBar.currentSelection
            // Component.onCompleted: if (currentIndex === dictView.index) dictView.item.focusSearchField()

            Connections {
                target: tabBar
                onCurrentSelectionChanged: {
                    if (viewsSlideshow.currentIndex !== tabBar.currentSelection) {
                        viewsSlideshow.positionViewAtIndex(tabBar.currentSelection, PathView.SnapPosition);
                    }
                }
            }
        }

    }
}
