.pragma library

// constant for undefined, used in conversions to avoid nulls
var undefined = "undefined"

// convert a SongKick event to a SailKick event
// https://www.songkick.com/developer/response-objects#event-object
function convertEvent(apiEvent) {

    var skEvent = {};
    skEvent.id = apiEvent.id || undefined;
    skEvent.uri = apiEvent.uri || undefined;
    skEvent.name = apiEvent.displayName || undefined;
    skEvent.displayName = apiEvent.displayName || undefined; //todo: stop using this
    skEvent.type = apiEvent.type || undefined;
    skEvent.date = (apiEvent.start && apiEvent.start.date) || undefined;
    skEvent.time = (apiEvent.start && apiEvent.start.time) || undefined;
  
    if (apiEvent.venue) {
      skEvent.venueId = apiEvent.venue.id || undefined;
      skEvent.venueName = apiEvent.venue.displayName || undefined;
      skEvent.venueWebSite = apiEvent.venue.website || undefined;
      skEvent.street = apiEvent.venue.street || undefined;
      skEvent.zip = apiEvent.venue.zip || undefined;
      skEvent.city = (apiEvent.venue.metroArea && apiEvent.venue.metroArea.displayName) || undefined;
      skEvent.country = (apiEvent.venue.city && apiEvent.venue.city.country && apiEvent.venue.city.country.displayName) || undefined;
      skEvent.lat = apiEvent.venue.lat || undefined;
      skEvent.lng = apiEvent.venue.lng || undefined;
      skEvent.metroAreaId = apiEvent.venue.metroArea.id || undefined;
      skEvent.metroAreaName = apiEvent.venue.metroArea.displayName || undefined;
    }
  
    skEvent.body = apiEvent || {};
      
    var artists = [];
    var performances = apiEvent.performance || [];
    
    for (var aC = 0; aC < performances.length; aC++) {
      var currAc = {};
      var performance = performances[aC];
      currAc["displayName"] = performance && performance.displayName || undefined;
      currAc["name"] = performance && performance.displayName || undefined;
      currAc["id"] = performance && performance.artist && performance.artist.id || undefined;
      artists[aC] = currAc;
    }
    skEvent.artists = artists;
    // shortcuts for the first artist
    //skEvent.artist = artists[0] && artists[0].displayName || undefined;
    //skEvent.artistId = artists[0] && artists[0].id || undefined;
    return skEvent;
}

// convert a SongKick event to a SailKick event
// https://www.songkick.com/developer/upcoming-events-for-user
/*         "calendarEntry": [
          {
            "reason": {
              "trackedArtist": [Artist Object, Artist Object],
              "attendance": "i_might_go|im_going"
            },
            "event": { Event Object }
          } */
function convertCalendarEntry(apiCalEntry) {
    // this takes care about the nulls  in event object
    var skEvent = convertEvent(apiCalEntry.event);
    var skCalEntry = {};
    // copy events to calendar entry
    // todo: it might be better to return the event object + the reason
    // would simplify the rest of code incl. ui
    // console.log(JSON.stringify(skEvent));
    skCalEntry.id = skEvent.id || undefined;
    skCalEntry.name = skEvent.name || undefined;
    skCalEntry.uri = skEvent.uri || undefined;
    skCalEntry.date = skEvent.date || undefined;
    skCalEntry.time = skEvent.time || undefined;
    skCalEntry.artistId = skEvent.artists[0] && skEvent.artists[0].id || undefined;
    skCalEntry.artistName = skEvent.artists[0] && skEvent.artists[0].name || undefined;
    skCalEntry.venueId = skEvent.venueId || undefined;
    skCalEntry.venueName = skEvent.venueName || undefined;
    skCalEntry.metroAreaId = skEvent.metroAreaId || undefined;
    skCalEntry.metroAreaName = skEvent.metroAreaName || undefined;
    // this is the only ..
    skCalEntry.attendance = apiCalEntry.reason && apiCalEntry.reason.attendance || undefined;    
    return skCalEntry;
}

//{"resultsPage":
//{"status":"ok",
//"results":{"metroArea":[
//{"lat":47.0667,"lng":15.45,"country":{"displayName":"Austria"},"uri":"http://www.songkick.com/metro_areas/26766-austria-graz?utm_source=14198&utm_medium=partner","displayName":"Graz","id":26766},
//{"lat":50.0833,"lng":14.4667,"country":{"displayName":"Czech Republic"},"uri":"http://www.songkick.com/metro_areas/28425-czech-republic-prague?utm_source=14198&utm_medium=partner","displayName":"Prague","id":28425},
//{"lat":48.2,"lng":16.3667,"country":{"displayName":"Austria"},"uri":"http://www.songkick.com/metro_areas/26771-austria-vienna?utm_source=14198&utm_medium=partner","displayName":"Vienna","id":26771}
//]},
//"perPage":50,"page":1,"totalEntries":3}}
function convertTrackedItemsResponse(type,resp) {

  var trackedItems = [];
  var errorEvent;

  if (resp.resultsPage.status !== "ok") {
    console.log("return value is not ok");
    errorEvent = {id:0, uri:"", name:"resultPage.status not ok", date: "", time: "", venueId: 1, venueName: "undefined"}
    trackedItems.push(errorEvent)
    return trackedItems
  }

  if (resp.resultsPage.totalEntries === 0) {
    console.log("0 values found");
    return trackedItems
  }

  var items = resp.resultsPage.totalEntries;

  if (items > resp.resultsPage.perPage) { items = resp.resultsPage.perPage; }

  for (var i = 0; i < items; i++) {
    var currentItem
    if (type === "location") currentItem = resp.resultsPage.results.metroArea[i];
    if (type === "artist")  currentItem = resp.resultsPage.results.artist[i];

    if (currentItem === null || currentItem === undefined) break;
    var trackId = currentItem.id;
    var trackName = currentItem.displayName;
    var eventi = {type: type, uid: trackId + "-" + trackName, title: trackName, skid: trackId + "-" + trackName, txt: currentItem.uri, uri: currentItem.uri, body: currentItem }

    trackedItems.push(eventi);
    // console.log('pushed ' + type + ": " +  eventi.title + "; uri: " + eventi.uri + ' body:' + eventi.body)
  }
  console.log('number of ' + type + '(s): ' + trackedItems.length)

  return trackedItems
}
