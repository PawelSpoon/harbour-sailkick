// encapsulates songkick api
// all get methods do require a callback method

var apiKey = "apikey=io09K9l3ebJxmxe2"
var songKickUri = "http://api.songkick.com/api/3.0"

// sends a upcomming events to songkick (tracked artists in users metro areas)
// returns paginated areas
// in: type: "artist" / "area"
//     username: "username"
//     callback: callback function that accepts string, event[]
function getUsersUpcommingEvents(type,username, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            print('HEADERS_RECEIVED')
        } else if(xhr.readyState === XMLHttpRequest.DONE) {
            print('DONE')
            var json = JSON.parse(xhr.responseText.toString())
            var events = API.convertUpcommingEventsResponse(json)
            callback(type, events)
        }
    }
    xhr.open("GET", songKickUri + "/users/" + username + "/calendar.json?reason=tracked_artist?" + apiKey);
    xhr.send();
}

// sends a users - tracked request to songkick
// returns paginated areas
// in: type: "artist" / "area"
//     username: "username"
//     callback: callback function that accepts string, event[]
function getUsersTrackedItems(type,username, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            print('HEADERS_RECEIVED')
        } else if(xhr.readyState === XMLHttpRequest.DONE) {
            print('DONE')
            var json = JSON.parse(xhr.responseText.toString())
            var events = API.convertCalendarResponse(json) //todo: replace with correct convertMethod
            callback(type, events)
        }
    }
    var queryType
    if (type === "artist") queryType = "artists"
    if (type === "location") queryType = "metro_areas"
    xhr.open("GET", songKickUri + "/users/" + username + "/" + queryType +  "/tracked.json?" + apiKey);
    xhr.send();
}

// sends a calendar request to songkick
// returns events
// in: type: "artist" / "area" / "venue"
//     id: id of artist / area.. "23355-radiohead"
//     callback: callback function that accepts string, event[]
function getUpcommingEventsForTrackedItem(type,id, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            print('HEADERS_RECEIVED')
        } else if(xhr.readyState === XMLHttpRequest.DONE) {
            print('DONE')
            var json = JSON.parse(xhr.responseText.toString())
            var events = API.convertUpcommingEventsResponse(json)
            callback(type, events)
        }
    }
    var queryType
    if (type === "artist") queryType = "artists"
    if (type === "location") queryType = "metro_areas"
    if (type === "venue") queryType = "venues"
    var query = "/" + queryType + "/" + id
    var url = songKickUri + query + "/calendar.json?" + apiKey;
    print(url)
    xhr.open("GET", url);

    xhr.send();
}

// this function converts a calendar response (artist/metro-area/venue)
// into event model
// in: json response
// out: array of events
// failure: will return one event with message in case of failure
//          will return empty array when no results found
/*
{ "resultsPage": {
      "status": "ok",
      "page": 1,
      "totalEntries": 1,
      "perPage": 50,
      "results": {
        "calendarEntry": [
          {"reason": {
              "trackedArtist": [ARTIST, ARTIST],
              "attendance": "i_might_go|im_going”
           },
           "event": {EVENT}
          }]
      }
  } }
  */
function convertCalendarResponse(resp) {

  var calendarEntries = [];
  var errorEvent

  if (resp.resultsPage.status !== "ok") {
    console.log("return value is not ok");
    errorEvent = {id:0, uri:"", name:"resultPage.status not ok", date: "", time: "", venueId: 1, venueName: "undefined"}
    calendarEntries.push(errorEvent)
    return calendarEntries
  }

  if (resp.resultsPage.totalEntries === 0) {
    console.log("0 values found");
    return calendarEntries
  }

  var items = resp.resultsPage.totalEntries;

  if (items > resp.resultsPage.perPage) { items = resp.resultsPage.perPage; }

  for (var i = 0; i < items; i++) {
    var currentCalEntry = resp.resultsPage.results.calendarEntry[i];
    var reason = currentCalEntry.reason; //
    var artist = reason.trackedArtist // an array ?
    var attendance = reason.attendance;
    var event = currentCalEntry.event; // is an event
    var eventId = event.id;
    var eventUri = event.uri;
    var eventName = event.displayName;
    var eventDate = event.start.date;
    var eventTime = event.start.time;

    var venueId = event.venue.id;
    var venueName = event.venue.displayName;
    var metroAreaId = event.venue.metroArea.id;
    var metroAreaName = event.venue.metroArea.displayName;
    var artistId = event.performance[0].id;
    var artistName = event.performance[0].displayName;

    //todo: correct class etc.
    var eventi = {id:eventId, uri:eventUri, name:eventName, date: eventDate, time: eventTime, venueId: venueId, venueName: venueName}

    calendarEntries.push(eventi);
    print('pushed: ' +  eventi.name)
  }
  print ('number of items: ' + events.length)
  return calendarEntries
}

// this function converts a users upcomming events
// into event model
// in: json response
// out: array of events
// failure: will return one event with message in case of failure
//          will return empty array when no results found
function convertUpcommingEventsResponse(resp) {

  var events = [];
  var errorEvent

  if (resp.resultsPage.status !== "ok") {
    console.log("return value is not ok");
    errorEvent = {id:0, uri:"", name:"resultPage.status not ok", date: "", time: "", venueId: 1, venueName: "undefined"}
    events.push(errorEvent)
    return events
  }

  if (resp.resultsPage.totalEntries === 0) {
    console.log("0 values found");
    return events
  }

  var items = resp.resultsPage.totalEntries;

  if (items > resp.resultsPage.perPage) { items = resp.resultsPage.perPage; }

  for (var i = 0; i < items; i++) {
    var currentEvent = resp.resultsPage.results.event[i];
    var eventId = currentEvent.id;
    var eventUri = currentEvent.uri;
    var eventName = currentEvent.displayName;
    var eventDate = currentEvent.start.date;
    var eventTime = currentEvent.start.time;

    var venueId = currentEvent.venue.id;
    var venueName = currentEvent.venue.displayName;
    var metroAreaId = currentEvent.venue.metroArea.id;
    var metroAreaName = currentEvent.venue.metroArea.displayName;
    var artistId = currentEvent.performance[0].id;
    var artistName = currentEvent.performance[0].displayName;
    var eventi = {id:eventId, uri:eventUri, name:eventName, date: eventDate, time: eventTime, venueId: venueId, venueName: venueName}

    events.push(eventi);
    print('pushed: ' +  eventi.name)

  }
  print ('number of items: ' + events.length)
  return events
}

