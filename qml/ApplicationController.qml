import QtQuick 2.0
// import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5
import "pages"
import "Persistance.js" as DB



Item {

    id: applicationController
    property string currentPage: 'plan'
    property bool logEnabled : false
    property string calDate : ""

    signal trackedItemsReloaded(string type)

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
        console.log("setCurrentPage: " + pageName)
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
        console.log("refreshAll")
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

    // clean stored tracking items and get fresh from songkick
    // DB now also stores meta data for the items, therefore we do not want to clear db
    // just to get fresh data
    function getTrackingItemsFromSongKick(reset) {
        if (reset) {
            DB.removeAllTrackingEntries("Type")
            DB.removeAllTrackingEntries("artist")
            DB.removeAllTrackingEntries("location")
        }
        skApi.getUserTrackedItemsAsync("location")
        skApi.getUserTrackedItemsAsync("artist",1)       
    }

    // called from tracked-item-page to keep the date across items    
    function setLockdate(locked) {
        console.log("setLockdate: " + locked)
        applicationController.calDate = locked
    }

    function getLockdate() {
        return applicationController.calDate
    }

    Connections {
        target: skApi
        onLocationsSuccess: {
            console.log("Locations received, filling model")
            //todo: pagination is not working yet
            updateTrackingItemsInDb('location', 1, "username", skApi.userLocationsResults)
        }
        onArtistsSuccess: {
            console.log("Artist received, filling model, page: " + page)
            //todo: pagination is not working yet
            updateTrackingItemsInDb('artist', page, "username", skApi.userArtistsResults)
        }        
        onActionFailed: {
            if (action === "locations") {
                // Handle plans failure
                console.log("Failed to get " + action)
            }
        }
        onActionError: {
            if (action === "locations") {
                console.error("Error during " + action + " :", error)
            }
        } 
        onTrackedItemMeta: {//(type, id, meta) {
            if (type == "location") return
            // console.log("onTrackedItemMeta: " + id + ", meta: " + JSON.stringify(meta))
            var tIs = DB.getTrackedItems(type)
            for (var i=0; i < tIs.length; i++) {
                var ti = tIs[i]
                if (ti.skid === id) {
                    var body = ti.body
                    // not needed and will currently not be returned by meta service
                    // body = updateBodyWithImageUrl(body, ti.imageUrl)
                    body = updateBodyWithTourInfo(body, meta.onTour)
                    // console.log("found item: " + ti.title + " " + ti.id + " " + ti.uid + " " + ti.uri + " " + JSON.stringify(ti.body))  
                    DB.setTrackingEntry(type,ti.skid, ti.title, ti.skid, ti.uri, body) // .id should be correct but seams not
                    break;
                }
            }

        }       
    }

    // callback of getUsersTrackedItems
    function updateTrackingItemsInDb(type, page, username, items)
    {
        log('number of items: ' +  items.length)

        var count = items.length
        for (var i = 0; i < count; i++) {
          var currentItem = items[i];
          if (i=== 0) {
            console.log('first item: ' + currentItem.title + " " + currentItem.id + " " + currentItem.uid + " " + currentItem.uri + " " + currentItem.body)
          }
          //type,uid,title,skid,uri,body
          //DB.setTrackingEntry(type,currentItem.id, currentItem.name, currentItem.id,currentItem.url, { "imageUrl" : currentItem.image_url })
          DB.upsertTrackingEntry(type, currentItem.id, currentItem.name, currentItem.id, currentItem.url, { "imageUrl" : currentItem.image_url })
        }
        log('number of items: ' + items.length)

        if (items.length === 50) {
            console.log("more items to come, get next page, current page: " + page)
            skApi.getUserTrackedItemsAsync(type, parseInt(page)+1)
        }
        else {
            applicationController.trackedItemsReloaded(type)
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

    // tourinfo: 0 -unknown, 1 - no, 2 -ontour
    function tourInfo_toInt(tourInfo) {
        if (tourInfo === null) return 0
        if (tourInfo === false) return 1
        if (tourInfo === true)  return 2
        return 0    
    }
    function tourInfo_toBool(tourInfo) {
        if (tourInfo === null) return false
        if (tourInfo === 0) return false
        if (tourInfo === 1) return false
        if (tourInfo === 2) return true
        return false    
    }
    function getLocalizedTrackInfo(tourInfo)
    {
        if (tourInfo === null) return ""
        if (tourInfo === undefined) return ""
        if (tourInfo === 0) return ""
        if (tourInfo === 1) return "-"
        if (tourInfo === 2) return qsTr("on tour")
        console.log("should not be here: getLocalizedTrackInfo: " + tourInfo)
        return ""
    }

    function convertBodyTourInfo(body)
    {
        body['onTour'] = tourInfo_toInt(body['onTour'])
        return body
    }
    function updateBodyWithTourInfo(body, tourInfo)
    {
        if (body === null) return { 'onTour': tourInfo }
        body['onTour'] = tourInfo
        return body
    }
    function updateBodyWithImageUrl(body, imageUrl)
    {
        if (imageUrl === null ||imageUrl === undefined) return body
        if (body === null || body == undefined) return { 'imageUrl': imageUrl }
        body['imageUrl'] = imageUrl
        return body
    }
}
