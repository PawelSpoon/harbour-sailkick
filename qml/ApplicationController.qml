import QtQuick 2.0
// import Sailfish.Silica 1.0

import "AppController.js" as Helper
import "pages"
import "Persistance.js" as DB
import "SongKickApi.js" as API


Item {

    id: applicationController
    property string currentPage: 'plan'

    // array of registered pages
    property variant pages: []
    // *********************************************************************
    // this generic part could be moved to some class
    // motication: all pages have same interface
    // call i.e.refresh(), doAccept() etc on current page / on  all ..

    // == registerPage with controller
    // qt framework seems to destroy pages per need
    // pages array does contain an 'null' / Type Error as page
    // consequently page registers itself on each component.oncompleted
    // and this method overrides the page pointer
    function addPage(name1, page1) {
        if (getCurrentPageView(name1) === null) {
            console.log('addPage: ' + name1);
            pages.push( { name: name1, page: page1});
            return;
        }
        console.log('no need to push, already there, lets replace')
        pages[getCurrentPageIndex(name1)].page = page1
    }

    // get the index of page in pages[]
    // returns -1 when not found
    function getCurrentPageIndex(currentPage)
    {
        console.log("getCurrentPageView: " + currentPage)
        var count = pages.length
        console.log("number of pages: " + count)
        for (var i = 0; i < count; i++) {
            console.log(pages[i].name)
            if (currentPage === pages[i].name) {
                console.log('found at index: ' + i )
                return i;
            }
        }
        console.log("page not found: " + currentPage)
        return -1;
    }

    // returns the page from pages[]
    // returns null when not found
    function getCurrentPageView(currentPage)
    {
        var index = getCurrentPageIndex(currentPage);
        if (index === -1) {
            console.log("page not found: " + currentPage)
            return null;
        }
        return pages[index].page
    }

    // app specific
    // updates cover page
    // updates menues
    function setCurrentPage(pageName) {
        console.log("setCurrentPage: " + pageName)
        currentPage = pageName
        applicationWindow.cover.setTitle(pageName);
        showMyMenues(pageName)
        updateCoverList(pageName, getCurrentPageView(pageName).getCoverPageModel())
    }

    // app specific
    // refreshes all pages
    function refreshAll()
    {
        var count = pages.length
        for (var i = 0; i < count; i++) {
          var currentItem = pages[i].page;
          if (currentItem === null) return;
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

    function updateCoverList(pageName, model) {
        if (currentPage !== pageName) return
        if (model === null) {
            console.log('try to reload model')
            model = getCurrentPageView(pageName).getCoverPageModel()
        }
        coverPage.fillModel(model)
    }

    // app specific
    // shows / hides menu based on current page
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
