import QtQuick 2.0
// import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5

import "AppController.js" as Helper
import "pages"
import "Persistance.js" as DB
import "SongKickApi.js" as API


Item {

    id: applicationController
    property string currentPage: 'plan'
    property bool logEnabled : false

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
            log('addPage: ' + name1);
            pages.push( { name: name1, page: page1});
            return;
        }
        log('no need to push, already there, lets replace')
        pages[getCurrentPageIndex(name1)].page = page1
    }

    // get the index of page in pages[]
    // returns -1 when not found
    function getCurrentPageIndex(currentPage)
    {
        //todo: this should work only for plans, concerts, locations, artists
        //      whenever i pass a city or an artist or an event it will show page not found
        log("getCurrentPageView: " + currentPage)
        var count = pages.length
        log("number of pages: " + count)
        for (var i = 0; i < count; i++) {
            log(pages[i].name)
            if (currentPage === pages[i].name) {
                log('found at index: ' + i )
                return i;
            }
        }
        error("page not found: " + currentPage)
        return -1;
    }

    function error(message) {
        console.error(message)
    }

    function log(messsage)
    {
        if (logEnabled) console.log(messsage)
    }

    // returns the page from pages[]
    // returns null when not found
    function getCurrentPageView(currentPage)
    {
        var index = getCurrentPageIndex(currentPage);
        if (index === -1) {
            error("page not found: " + currentPage)
            return null;
        }
        var pg = pages[index].page;
        if (pg === null) error('page attribute is null')
        return pages[index].page
    }

    // app specific
    // updates cover page
    // updates menues
    function setCurrentPage(pageName) {
        log("setCurrentPage: " + pageName)
        currentPage = pageName
        applicationWindow.cover.setTitle(pageName);
        showMyMenues(pageName)
        var page = getCurrentPageView(pageName)
        if (page === null) {
            error('no page found for: ' + pageName)
            return
        }
        updateCoverList(pageName, page.getCoverPageModel())
    }

    // opens the artist or location page on top of the carousell
    function openTrackedItemPageOnTop(type, trackedItemId, trackedItemName) {
        log(type, trackedItemId)
        pageStack.push(Qt.resolvedUrl("pages/TrackedItemPage.qml"), { type: type, songKickId: trackedItemId, titleOf: trackedItemName })
    }

    // app specific
    // refreshes all pages
    function refreshAll()
    {
        var count = pages.length
        for (var i = 0; i < count; i++) {
          var currentItem = pages[i].page;
          if (currentItem === null) return;
          log(currentItem);
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

    function openConcertsForDatePage()
    {
        pageStack.push(Qt.resolvedUrl("pages/Concerts4DatePage.qml"), { })
    }

    function updateCoverList(pageName, model) {
        if (currentPage !== pageName) return
        if (model === null) {
            log('try to reload model')
            model = getCurrentPageView(pageName).getCoverPageModel()
        }
        coverPage.fillModel(model)
    }

    // app specific
    // shows / hides menu based on current page
    function showMyMenues(page)
    {
        applicationWindow.mainPage.menuGotoDateVisible(false);
        applicationWindow.mainPage.menuManageVisible(false);
        if (page==='location')
        {
            applicationWindow.mainPage.menuManageVisible(true);
        }
        if (page === 'artist')
        {
            applicationWindow.mainPage.menuManageVisible(true);
        }
        if (page==='concert')
        {
            applicationWindow.mainPage.menuGotoDateVisible(true);
        }
    }

    // the next function of cover of the caroussell
    function moveToNextPage()
    {
        applicationWindow.mainPage.moveToNext()
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
        log('number of items: ' +  items.length)

        var count = items.length
        for (var i = 0; i < count; i++) {
          var currentItem = items[i];
          log('storing: ' +  currentItem.title)
          DB.setTrackingEntry(type,currentItem.uid, currentItem.title,currentItem.skid,currentItem.uri,currentItem.body)
        }
        log('number of items: ' + items.length)

        if (items.length === 50) {
            API.getUsersTrackedItems(type,page+1,username, updateTrackingItemsInDb)
        }
    }

    function logIn()
    {
        var user = DB.getUser()
        if (user === null) {
            error("no user found")
            return
        }
        var userName = user.name
        var pwd = DB.getUser().password
        skApi.logIn(userName,pwd)
    }

}
