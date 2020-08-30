//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"
import "common"
import "sf-docked-tab-bar"

// also servers a page-controller, all main page transitions are handled via this
ApplicationWindow
{
    id: applicationWindow
    property Item mainPage: null
    property ApplicationController controller: myController

    // from tab sample
    property alias tabBar: _tabBar
    readonly property string mainPageName: "TabedMainPageX"

    ApplicationController {
        id: myController
    }

    initialPage: Component {
        TabedMainPageX {
            id: tabedMainPage
            Component.onCompleted: {
                applicationWindow.mainPage = tabedMainPage
                myController.setCurrentPage('plan')
            }
        }
    }

    DockedTabBar {
        id: _tabBar
        enabledOnPage: "TabedMainPageX"
        currentSelection: 0

        DockedTabButton {
            icon.source: "image://theme/icon-m-favorite"
            label: qsTr("Plan")
            fontSize: Theme.fontSizeTiny
        }
        DockedTabButton {
            icon.source: "image://theme/icon-m-file-audio"
            label: qsTr("Concerts")
            fontSize: Theme.fontSizeTiny
        }
        DockedTabButton {
            icon.source: "image://theme/icon-m-whereami"
            label: qsTr("Locations")
            fontSize: Theme.fontSizeTiny
        }
        DockedTabButton {
            icon.source: "image://theme/icon-m-media-artists"
            label: qsTr("Artists")
            fontSize: Theme.fontSizeTiny
        }
    }

    CoverPage {
        id: coverPage
        //title: ''
        Component.onCompleted:  {
            if (applicationWindow.controller === null)  {
                console.log("controller is null")}
            coverPage.setTitle('');
            applicationWindow.cover = coverPage
        }
    }

    allowedOrientations: Orientation.All

    Component.onCompleted: {
    }

    /*onApplicationActiveChanged: {
        // Application goes into background or returns to active focus again
        if (applicationActive) {

        } else {

        }
    }*/
}

