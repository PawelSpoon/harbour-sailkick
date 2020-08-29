// main page hosting tab1View

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import "../Persistance.js" as DB
import "../SongKickApi.js" as API
import "."

Page  {
    id: tabsPage
    anchors.fill: parent
    allowedOrientations: defaultAllowedOrientations

    // these dummy translations are there to make cover title localized
    property string transPlans : qsTr('plan');
    property string transConcerts : qsTr('concert');
    property string transLocations : qsTr('location');
    property string transArtist : qsTr('artist');

    function menuManageVisible(visible) {
        menuManage.visible = visible
    }

    function moveToTab(index)
    {
        console.log(index)
        tabs.moveTo(index)
        if (index < 2) {
            menuManageVisible(false);
        }
        else {
            menuManageVisible(true);
        }
    }

    // should be moved to db or api, is api callback ..
    function updateTrackingItemsInDb(type, page, username, items)
    {
        print('number of items: ' +  items.length)

        var count = items.length
        for (var i = 0; i < count; i++) {
          var currentItem = items[i];
          print('storing: ' +  currentItem.title)
          DB.setTrackingEntry(type,currentItem.uid, currentItem.title,currentItem.skid,currentItem.uri,currentItem.body)
        }
        print ('number of items: ' + items.length)

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

        Component.onCompleted: {
            DB.initialize();
        }

        TabView {
            id: tabs
            anchors.fill: parent

            header: Column {
                width: parent.width

                TabButtonRow {
                    Repeater {
                        model: [
                            "plan",
                            "concert",
                            "location",
                            "artist"
                        ]

                        TabButton {
                            onClicked: {
                                tabs.moveTo(model.index)
                                applicationWindow.controller.setCurrentPage(modelData)
                                console.log(modelData)
                                //todo: howto pass the proper list ?
                                applicationWindow.controller.updateCoverList(modelData, null)
                            }

                            title: qsTr(modelData)
                            tabIndex: model.index
                        }
                    }
                }
            }

            model: [plansTab, concertsTab, locationsTab, artistsTab]

            //property variant plansRefresh // can not assign to a read-only property wenn als function definiert
            /*property variant toBeRefreshed: []
            function addRefresh(r) {
                toBeRefreshed.push(r);
            }*/

            Component {
                id: plansTab
                TabItem{
                    PlansPage {
                        id: plansPage
                        anchors.fill: parent
                    }
                    Component.onCompleted: {
                        applicationWindow.controller.addPage('plan', plansPage);
                    }
                }
            }
            Component {
                id: concertsTab
                TabItem {
                    ConcertsPage {
                       id: concertsPage
                    }
                    Component.onCompleted: {
                        applicationWindow.controller.addPage('concert', concertsPage);
                    }
                }
            }
            Component {
                id: locationsTab
                TabItem {
                    TrackedItemsPage {
                        id: locationsPage
                        trackedType: "location"
                    }
                    Component.onCompleted: {
                        applicationWindow.controller.addPage('location', locationsPage);
                    }
                }
            }
            Component {
                id: artistsTab
                TabItem {
                    TrackedItemsPage {
                        id: artistsPage
                        trackedType: "artist"
                    }
                    Component.onCompleted: {
                        applicationWindow.controller.addPage('artist', artistsPage);
                    }
                }
            }
        }
        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
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
                text: qsTr("Get tracked items from songkick")
                onClicked:
                {
                    applicationWindow.controller.getTrackingItemsFromSongKick(null)
                }
            }
            MenuItem {
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

    }
}
