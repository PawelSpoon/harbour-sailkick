import QtQuick 2.0
// import Sailfish.Silica 1.0

import "AppController.js" as Helper
import "pages"
import "Persistance.js" as DB
import "SongKickApi.js" as API


Item {

    id: applicationController
    property string currentPage: 'plan'

    // array of pages
    property variant pages: []
    function addPage(name1, page1) {
        pages.push( { name: name1, page: page1});
    }

    function refreshAll()
    {
        var count = pages.length
        for (var i = 0; i < count; i++) {
          var currentItem = pages[i].page;
          currentItem.refresh();
        }
    }

    function openManagePage()
    {
        if (currentPage == "location") pageStack.push(Qt.resolvedUrl("pages/WebViewPage.qml"),{ uri: "https://www.songkick.com/tracker/metro_areas", songKickId: "no songKickId", titleOf: "no titleOf" })
        if (currentPage == "artist")   pageStack.push(Qt.resolvedUrl("pages/WebViewPage.qml"),{ uri: "https://www.songkick.com/tracker/artists", songKickId: "no songKickId", titleOf: "no titleOf" })
    }

    function openSettingsPage()
    {
        pageStack.push(Qt.resolvedUrl("pages/SettingsPage.qml"), { })
    }

    function setCurrentPage(pageName) {
        currentPage = pageName
        applicationWindow.cover.title = qsTr(pageName)
        showMyMenues(pageName)
        updateCoverList(pageName, getCurrentPageView(pageName))
    }

    function getCurrentPageView(currentPage)
    {
        var count = pages.length
        for (var i = 0; i < count; i++) {
            if (currentPage === pages[i].name) return pages[i].page
        }
        return null;
    }

    function updateCoverList(pageName, model) {
        if (currentPage !== pageName) return
        if (model === null) return
        coverPage.fillModel(model)
    }

    function showMyMenues(page)
    {
        if (page==='location')
        {
            applicationWindow.mainPage.menuManageVisible(true);
        }
        else if (page === 'artist')
        {
            applicationWindow.mainPage.menuManageVisible(true);
        }
        else {
            applicationWindow.mainPage.menuManageVisible(false);
        }
    }

    // the next function of cover of the caroussell
    function moveToNextPage()
    {
        // something with currentIndex would be cooler
       console.log('Controller::moveNextPage');
       if (currentPage === "plan") {
           applicationWindow.mainPage.moveToTab(1);
           setCurrentPage('concert')
       }
       else if (currentPage === "concert") {
           applicationWindow.mainPage.moveToTab(2);
           setCurrentPage('location')
       }
       else if (currentPage === "location") {
           applicationWindow.mainPage.moveToTab(3);
           setCurrentPage('artist')
       }
       else if (currentPage === "artist") {
           applicationWindow.mainPage.moveToTab(0);
           setCurrentPage('plan')
       }
       else {
           console.log("dont know where to naviage from here: " + currentPage);
       }
    }

    // clean stored tracking itmes and get fresh from songkick
    // all views do not pass user, only in settings dialog, before you store the user back to db
    // you can already trigger an get-items-call
    function getTrackingItemsFromSongKick(user) {
        if (user === null)
            user = DB.getUser().name
        DB.removeAllTrackingEntries("Type")
        DB.removeAllTrackingEntries("artist")
        DB.removeAllTrackingEntries("location")
        API.getUsersTrackedItems("artist",1,user, updateTrackingItemsInDb)
        API.getUsersTrackedItems("location",1,user, updateTrackingItemsInDb)
    }


    // callback of getUsersTrackedItems
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
            API.getUsersTrackedItems(type,page+1,username, updateTrackingItemsInDb)
        }

    }

}
