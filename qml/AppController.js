.import "Persistance.js" as DB
.import "SongKickApi.js" as API

// should be the controller for the whole app
// so all the code from MainPage that is related to data should go here in sooner or later
// no page should access DB nor API directly
// but i think currently its pretty obsolete

var cb1

// public functions area
// get's users tracked locations or artists from web and stores them thanks to db
// idea is that when async call is done, we call cb1 callback too.
// idea is also that this function handles the offline mode.
function updateTrackingItems(type, callback)
{
    // var x = new Promise()
    //                      ("artist", getUserName(), success, failure) where success would update db, failure do nothing
    API.getUsersTrackedItems(type, 1, getUserName(), updateTrackingItemsInDb, showError);
    cb1 = callback;
}

function getPlans()
{

}

function getConcerts()
{

}

function getLocations()
{

}

function getArtists()
{

}

// private functions area
function getUserName()
{
    return DB.getUser().name;
}

function showError()
{
   console.log("api called failed")
}


function updateTrackingItemsInDb(type, page, username, items)
{
    // i am cleaning now as i do expect a successfull
    if (page === 1) {DB.removeAllTrackingEntries(type)};
    console.log('number of items: ' +  items.length)

    var count = items.length
    for (var i = 0; i < count; i++) {
      var currentItem = items[i];
      console.log('storing: ' +  currentItem.title)
      DB.setTrackingEntry(type,currentItem.uid, currentItem.title,currentItem.skid,currentItem.uri,currentItem.body)
    }

    if (items.length === 50) { // this could be handled better via total number of pages in response !!
        // load next page
        API.getUsersTrackedItems(type, page+1, username, updateTrackingItemsInDb)
    }
    else
    {
        // here could be the callback activation for async...
        cb1();
    }
}
