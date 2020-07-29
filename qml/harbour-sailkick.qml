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
    property string currentPage: 'plans'
    property Item mainPage: null
    property ApplicationController controller: myController

    // these dummy translations are there to make cover title localized
    property string transPlans : qsTr('plans');
    property string transConcerts : qsTr('concerts');
    property string transLocations : qsTr('location');
    property string transArtist : qsTr('artist');

    ApplicationController {
        id: myController
    }

    function setCurrentPage(pageName) {
        currentPage = pageName
        coverPage.title = qsTr(pageName)
    }

    function updateCoverList(pageName, model) {
        if (currentPage !== pageName) return
        coverPage.fillModel(model)
    }

    // bring this page to front
    function moveToPage(pageName)
    {
        if (pageName === "plans") {
            pageStack.push(Qt.resolvedUrl("pages/PlansPage.qml"), {mainPage: mainPage})
            applicationWindow.setCurrentPage('plans')
        }
        else if (pageName === "concerts") {
            pageStack.push(Qt.resolvedUrl("pages/MainPage.qml"), {mainPage: mainPage, trackedType: "location"})
            applicationWindow.setCurrentPage('concerts')
        }
        else if (pageName === "location") {
            pageStack.push(Qt.resolvedUrl("pages/TrackedItemsPage.qml"), {mainPage: mainPage, trackedType: "location"})
            applicationWindow.setCurrentPage('location')
        }
        else if (pageName === "artist") {
            pageStack.push(Qt.resolvedUrl("pages/TrackedItemsPage.qml"), {mainPage: mainPage, trackedType: "artist"})
            applicationWindow.setCurrentPage('artist')
        }
        else  {
            console.log("what to do with: " + pageName);
        }
    }

    // the next function of cover of the caroussell
    function moveToNextPage()
    {
       console.log('Controller::moveNextPage');
       if (currentPage === "plans") {
           moveToPage("concerts");
       }
       else if (currentPage === "concerts") {
           moveToPage("location");
       }
       else if (currentPage === "location") {
           moveToPage("artist");
       }
       else if (currentPage === "artist") {
           moveToPage("plans");
       }
       else {
           console.log("dont know where to naviage from here: " + currentPage);
       }
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

