//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"
import "common"

// also servers a page-controller, all main page transitions are handled via this
ApplicationWindow
{
    id: applicationWindow
    property Item mainPage: null
    property ApplicationController controller: myController

    // these dummy translations are there to make cover title localized
    property string transPlans : qsTr('plan');
    property string transConcerts : qsTr('concert');
    property string transLocations : qsTr('location');
    property string transArtist : qsTr('artist');

    ApplicationController {
        id: myController
    }

    initialPage: Component {
        TabedMainPage {
            id: tabedMainPage
            Component.onCompleted: {
                applicationWindow.mainPage = tabedMainPage
                myController.setCurrentPage('plan')
            }
        }
    }

    CoverPage {
        id: coverPage
        title: ''
        Component.onCompleted:  {
            if (applicationWindow.controller === null)  {
                console.log("null")}
            applicationWindow.cover = coverPage
        }
    }

    allowedOrientations: defaultAllowedOrientations

    Component.onCompleted: {
    }

    onApplicationActiveChanged: {
        // Application goes into background or returns to active focus again
        if (applicationActive) {

        } else {

        }
    }
}

