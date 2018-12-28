//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"


ApplicationWindow
{
    id: applicationWindow
    property string currentPage: 'Plans'
    property Item mainPage: null

    function setCurrentPage(pageName) {
        currentPage = pageName
        coverPage.title = qsTr(pageName)
    }

    function updateCoverList(pageName, model) {
        if (currentPage != pageName) return
        coverPage.fillModel(model)
    }

    initialPage: Component {
        /*MainPage {
            id: mainPage
            Component.onCompleted: {
               applicationWindow.mainPage = mainPage

            }
        }*/
        PlansPage {
            id:plansPage
            Component.onCompleted: {
                applicationWindow.mainPage = plansPage
                currentPage = 'Plans'
            }
        }

    }

    CoverPage {
        id: coverPage
        title: ''
        Component.onCompleted:  {
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

