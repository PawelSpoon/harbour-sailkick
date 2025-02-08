.import "Persistance.js" as DB
.import "SongKickApiConversion.js" as Conv

// encapsulates songkick api
// all get methods do require a callback method

var apiKey = "apikey="
var songKickUri = "https://api.songkick.com/api/3.0"
var HEADERS_RECEIVED = 2;
var DONE = 4;
var OK = 200;

// sends a upcomming events to songkick (tracked artists in users metro areas) == users calendar
// returns paginated areas
// in: type: "artist" / "attendance"
//     username: "username"
//     callback: callback function that accepts string, event[]
// used in: ConcertsPage.qml, PlansPage.qml
function getUsersUpcommingEvents(type,username, onSuccess, onFailure, xhr) {
    if (!xhr) xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === HEADERS_RECEIVED) {
            console.log('HEADERS_RECEIVED')
        } else if(xhr.readyState === DONE) {
            console.log('DONE')
            if (xhr.status === OK) {
               var json = JSON.parse(xhr.responseText.toString())
               var events = convertCalendarResponse(json)
               onSuccess(type, events)
            }
            else
            {
               onFailure(type)
              // i.e. load the first page from db == failure callback
            }
        }
    }
    var queryType
    if (type === "artist") queryType = "tracked_artist"
    if (type === "attendance") queryType = "attendance"
    console.log(songKickUri + "/users/" + username + "/calendar.json?reason=" + queryType + "&" + apiKey + DB.getRandom())
    xhr.open("GET", songKickUri + "/users/" + username + "/calendar.json?reason=" + queryType + "&" + apiKey + DB.getRandom());
    xhr.send();
}

// sends a users - tracked request to songkick
// returns paginated areas
// in: type: "artist" / "area"
//     username: "username"
//     callback: callback function that accepts string, event[]
// used in: AppController.qml, ApplicationContent.qml, TabedMainPage.qml
function getUsersTrackedItems(type, page, username, onSuccess, onFailure, xhr) {
    if (!xhr) xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === HEADERS_RECEIVED) {
            console.log('HEADERS_RECEIVED');
        } else if(xhr.readyState === DONE) {
            console.log('DONE')
            if (xhr.status === OK) {
               var json = JSON.parse(xhr.responseText.toString())
//             console.log(xhr.responseText.toString())
               var items = Conv.convertTrackedItemsResponse(type,json)
               onSuccess(type,page,username,items)
            }
            else {
                onFailure(type)
            }
        }
    }
    var queryType
    if (type === "artist") queryType = "artists"
    if (type === "location") queryType = "metro_areas"
    console.log(songKickUri + "/users/" + username + "/" + queryType +  "/tracked.json?" + apiKey + DB.getRandom())
    xhr.open("GET", songKickUri + "/users/" + username + "/" + queryType +  "/tracked.json?" + apiKey + DB.getRandom() + "&page=" + page);

    xhr.send();
}



// sends a calendar request to songkick
// returns events
// in: type: "artist" / "area" / "venue"
//     id: id of artist / area.. "23355-radiohead"
//     page: page number (0 based, but songkick will have it 1 based)
//     callback: callback function that accepts string, event[]
// used in: TrackedItemsPage.qml
function getUpcommingEventsForTrackedItem(type,id,page,onSuccess, onFailure, xhr) {
    if (!xhr) xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === HEADERS_RECEIVED) {
            console.log('HEADERS_RECEIVED')
        } else if(xhr.readyState === DONE) {
            console.log('DONE')
            if (xhr.status === OK) {
              var json = JSON.parse(xhr.responseText.toString())
              var events = convertUpcommingEventsResponse(json)
              onSuccess(type,events)
            }
            else { onFailure(type)}
        }
    }
    var queryType
    if (type === "artist") queryType = "artists"
    if (type === "location") queryType = "metro_areas"
    if (type === "venue") queryType = "venues"
    var query = "/" + queryType + "/" + id
    var url = songKickUri + query + "/calendar.json?" + apiKey + DB.getRandom();
    if (page > 0) url = url + "&page=" + (page + 1)
    console.log(url)
    xhr.open("GET", url);

    xhr.send();
}

// gets the details for one event
// https://api.songkick.com/api/3.0/events/{event_id}.json?apikey={your_api_key}
// used in: EventPage.qml
function getEvent(id, callback)
{
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        console.log('receiving')
        //console.log(xhr);
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            console.log('HEADERS_RECEIVED');
        } else if(xhr.readyState === XMLHttpRequest.DONE) {
            console.log('DONE')
            //bconsole.log(xhr.responseText);
            var json = JSON.parse(xhr.responseText.toString());
            var event = convertEventResponse(json);
            callback(event);
        }
    }
    // console.log(songKickUri + "/events/" + id + ".json?" + apiKey + DB.getRandom());
    xhr.open("GET", songKickUri + "/events/" + id + ".json?" + apiKey + DB.getRandom());

    xhr.send();

}

// gets the tracking status of event
// used in: EventPage.qml
function getEventTrackingInfo(id, callback)
{
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        console.log('receiving')
        //console.log(xhr);
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            console.log('HEADERS_RECEIVED');
        } else if(xhr.readyState === XMLHttpRequest.DONE) {
            console.log('DONE')
            console.log(xhr.responseText);
            var json = JSON.parse(xhr.responseText.toString());
            if (json.resultsPage.status === "ok" ) {
                console.log(json.resultsPage.results.tracking.attendance)
                callback(json.resultsPage.results.tracking.attendance)
                return;
            }
            else
            {
                callback("");
                return;
            }
        }
    }
    var userName = DB.getUser().name
    // https://api.songkick.com/api/3.0/users/{username}/trackings/event:{event_id}.json?apikey={your_api_key}
    console.log(songKickUri + "/users/" + userName + "/trackings/event:"+ id + ".json?" + apiKey + DB.getRandom());
    xhr.open("GET", songKickUri + "/users/" + userName + "/trackings/event:"+ id + ".json?" + apiKey + DB.getRandom());
    // if no tracking, it will return: {"resultsPage":{"status":"error","error":{"message":"Tracking not found"}}}
    // if tracking, then it will return: "resultsPage":{"status":"ok","results":{"tracking":{"username":"spoonman72","id":"event:36081339","createdAt":"2019-02-27T01:18:50+0000","attendance":"i_might_go"}}}}
    xhr.send();
}

// not implemented
function getArtistTrackingInfo(id, callback)
{
    //https://api.songkick.com/api/3.0/users/{username}/trackings/artist:{artist_id}.json?apikey={your_api_key}

}

// not implemented
function getVenueTrackingInfo(id, callback)
{
    // https://api.songkick.com/api/3.0/users/{username}/trackings/metro_area:{metro_area_id}.json?apikey={your_api_key}
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
              "attendance": "i_might_go|im_going"
           },
           "event": {EVENT}
          }]
      }
  } }
  */
// used in: SongKicApi.js-> getUsersUpcommingEvents
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
    var eventi = Conv.convertCalendarEntry(resp.resultsPage.results.calendarEntry[i])
 
    /*var venueId = event.venue.id;
    var venueName = event.venue.displayName;
    var metroAreaId = event.venue.metroArea.id;
    var metroAreaName = event.venue.metroArea.displayName;
    var artistId = event.performance[0].id;
    var artistName = event.performance[0].displayName;

    //todo: correct class etc.
    var eventi = {id:eventId, uri:eventUri, name:eventName, artist: artist, metroAreaName: metroAreaName, date: eventDate, time: eventTime, venueId: venueId, venueName: venueName, attendance: attendance}
*/
    calendarEntries.push(eventi);
  }
  console.log('number of items: ' + calendarEntries.length)
  return calendarEntries
}

// this function converts a artists/areas upcomming events
// into event model
// in: json response
// out: array of events
// failure: will return one event with message in case of failure
//          will return empty array when no results found
// used in: SongKicApi.js-> getUpcommingEventsForTrackedItem
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

  var itemCount = resp.resultsPage.totalEntries;

  // reset to perPage if totalEntries more then perPage
  if (itemCount > resp.resultsPage.perPage) { itemCount = resp.resultsPage.perPage; }
  
  // this can happen when requested page points to an empty one cause there are not enough totalEntries
  if (resp.resultsPage.results.event === null || resp.resultsPage.results.event === undefined) {
    console.log("results is empty json");
    return events
  }

  for (var i = 0; i < itemCount; i++) {
    var currentEvent = resp.resultsPage.results.event[i];
    if (currentEvent === null && currentEvent === undefined) {
      console.log("currentEvent is empty json");
      break;
    }
    var skEvent = Conv.convertEvent(currentEvent);
    var artistId = "undefined", artistName = "undefined";
    if (Array.isArray(skEvent.artists) && skEvent.artists.length > 0) {
        artistId = skEvent.artists[0].id;
        artistName = skEvent.artists[0].name;
    }
    var eventi = {id:skEvent.id, uri:skEvent.uri, name:skEvent.name, date: skEvent.date, 
      time: skEvent.time, venueId: skEvent.venueId, venueName: skEvent.venueName, 
      metroAreaId:skEvent.metroAreaId, metroAreaName: skEvent.metroAreaName,
      artistId: artistId, artistName: artistName}

    events.push(eventi);
  }
  console.log('number of items: ' + events.length)
  return events
}


// used in: SongKickApi.js-> getEvent
function convertEventResponse(resp)
{
  var eventi = {};

  if (resp.resultsPage.status !== "ok") {
    console.log("return value is not ok");
    eventi = {id:0, uri:"", name:"resultPage.status not ok", date: "", time: "", venueId: 1, venueName: "undefined", artistId: 1, artistName: "undefined"}
    return eventi;
  }

  return Conv.convertEvent(resp.resultsPage.results.event)

}


// region for new method to return all events in a date
// xhr is just a di for test purposes
function getUpcommingEventsForDateRecursive(min_date, max_date, overAllSuccess, metroAreas, metroAreaIndex, resultingEvents, onFailure,xhr) {
  if (!xhr) xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
      if (xhr.readyState === HEADERS_RECEIVED) {
          console.log('HEADERS_RECEIVED')
      } else if(xhr.readyState === DONE) {
          console.log('DONE')
          if (xhr.status === OK) {
            var json = JSON.parse(xhr.responseText.toString())
            var events = convertUpcommingEventsResponse(json)
            // increase by one
            resultingEvents = resultingEvents.concat(events)
            metroAreaIndex++;
            if (metroAreaIndex < metroAreas.length) {
              // you need a new request as each request can be sent only once ! recursion will not work in test, had to remove xhr)
              getUpcommingEventsForDateRecursive(min_date,max_date,overAllSuccess, metroAreas, metroAreaIndex, resultingEvents, onFailure)
            }
            else {
                console.log("calling overAllSuccess")
                overAllSuccess(resultingEvents)
            }
          }
          else {
              console.log("calling on failure")
              overAllSuccess(resultingEvents)
          } // war onFailure
      }
  }
  var queryType = "metro_areas"
  var metroAreaId = metroAreas[metroAreaIndex].skid// did work in test .uri
  var query = "/" + queryType + "/" + metroAreaId
  var url = songKickUri + query + "/calendar.json?" + apiKey + DB.getRandom()
  if (min_date !== "") {
     url = url + "&min_date=" + min_date;
  }
  if (max_date !== "") {
      url = url + "&max_date=" + max_date;
  }

  console.log(url)
  xhr.open("GET", url);

  xhr.send();
}

// this is the public to-be-called method
// min_date	Optional	A date in the form YYYY-MM-DD.
// max_date	Optional	A date in the form YYYY-MM-DD.
// xhr is just di for testing, will not be passed in production
function getEventsInUsersAreasForDate(min_date,max_date,finalCallback,onFailure,xhr)
{
  var resultingEvents = []
  // get areas
  var type = "location"
  var metroAreaIndex = 0
  var metroAreas = DB.getTrackedItems(type)
  var metroAreaLength = metroAreas.length
  if (metroAreaLength === 0) {
    // return home with nothing
    console.log('no tracked items, returning')
    finalCallback(resultingEvents)
  }
  // already converts the result to event, xhr is just for test
  getUpcommingEventsForDateRecursive(min_date, max_date, finalCallback, metroAreas, metroAreaIndex, resultingEvents, onFailure,xhr)
}
