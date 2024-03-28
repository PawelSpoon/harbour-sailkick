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
    skEvent.dateTime = (apiEvent.start && apiEvent.start.date) || undefined;
    skEvent.time = (apiEvent.start && apiEvent.start.time) || undefined;
    skEvent.dateTime = apiEvent.start.date;
  
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
      artists[aC] = currAc;
    }
    skEvent.artists = artists;
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
    skCalEntry.id = skEvent.id;
    skCalEntry.name = skEvent.name;
    skCalEntry.uri = skEvent.uri;
    skCalEntry.date = skEvent.dateTime;
    skCalEntry.time = skEvent.time;
    // this contains why it is suggested, including the artist, not sure what is better to use
    skCalEntry.artist = apiCalEntry.reason && apiCalEntry.reason.trackedArtist && apiCalEntry.reason.trackedArtist[0] && apiCalEntry.reason.trackedArtist[0].displayName || undefined;
    // skCalEntry.artistId = skEvent.artists[0].id;//todo: this might not exist yet
    // skCalEntry.artist = skEvent.artists[0].displayName;
    skCalEntry.attendance = apiCalEntry.reason && apiCalEntry.reason.attendance || undefined;
    skCalEntry.venueId = skEvent.venueId;
    skCalEntry.venueName = skEvent.venueName;
    //skCalEntry.metroAreaId = skEvent.metroAreaId;
    skCalEntry.metroAreaName = skEvent.metroAreaName;
    
    return skCalEntry;
}