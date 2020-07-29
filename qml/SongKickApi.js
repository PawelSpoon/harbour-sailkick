.import "Persistance.js" as DB

// encapsulates songkick api
// all get methods do require a callback method

var apiKey = "apikey="
var songKickUri = "https://api.songkick.com/api/3.0"

// sends a upcomming events to songkick (tracked artists in users metro areas) == users calendar
// returns paginated areas
// in: type: "artist" / "attendance"
//     username: "username"
//     callback: callback function that accepts string, event[]
function getUsersUpcommingEvents(type,username, onSuccess, onFailure) {
  var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            print('HEADERS_RECEIVED')
        } else if(xhr.readyState === XMLHttpRequest.DONE) {
          print('DONE')
          if (xhr.status === 200) {
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
    print(songKickUri + "/users/" + username + "/calendar.json?reason=" + queryType + "&" + apiKey + DB.getRandom())
    xhr.open("GET", songKickUri + "/users/" + username + "/calendar.json?reason=" + queryType + "&" + apiKey + DB.getRandom());
    xhr.send();
}

// sends a users - tracked request to songkick
// returns paginated areas
// in: type: "artist" / "area"
//     username: "username"
//     callback: callback function that accepts string, event[]
function getUsersTrackedItems(type, page, username, onSuccess, onFailure) {
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
          print('HEADERS_RECEIVED');
      } else if(xhr.readyState === XMLHttpRequest.DONE) {
          print('DONE')
          if (xhr.status === 200) {
             var json = JSON.parse(xhr.responseText.toString())
             var items = convertTrackedItemsResponse(type,json)
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
    print(songKickUri + "/users/" + username + "/" + queryType +  "/tracked.json?" + apiKey + DB.getRandom())
    xhr.open("GET", songKickUri + "/users/" + username + "/" + queryType +  "/tracked.json?" + apiKey + DB.getRandom() + "&page=" + page);

    xhr.send();
}



// sends a calendar request to songkick
// returns events
// in: type: "artist" / "area" / "venue"
//     id: id of artist / area.. "23355-radiohead"
//     callback: callback function that accepts string, event[]
function getUpcommingEventsForTrackedItem(type,id,page,callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            print('HEADERS_RECEIVED')
        } else if(xhr.readyState === XMLHttpRequest.DONE) {
            print('DONE')
            var json = JSON.parse(xhr.responseText.toString())
            var events = convertUpcommingEventsResponse(json)
            callback(type,events)
        }
    }
    var queryType
    if (type === "artist") queryType = "artists"
    if (type === "location") queryType = "metro_areas"
    if (type === "venue") queryType = "venues"
    var query = "/" + queryType + "/" + id
    var url = songKickUri + query + "/calendar.json?" + apiKey + DB.getRandom();
    if (page > 0) url = url + "&page=" + (page + 1)
    print(url)
    xhr.open("GET", url);

    xhr.send();
}

// gets the details for one event
// https://api.songkick.com/api/3.0/events/{event_id}.json?apikey={your_api_key}
function getEvent(id, callback)
{
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        console.log('receiving')
        //console.log(xhr);
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            print('HEADERS_RECEIVED');
        } else if(xhr.readyState === XMLHttpRequest.DONE) {
            print('DONE')
            console.log(xhr.responseText);
            var json = JSON.parse(xhr.responseText.toString());
            var event = convertEventResponse(json);
            callback(event);
        }
    }
    print(songKickUri + "/events/" + id + ".json?" + apiKey + DB.getRandom());
    xhr.open("GET", songKickUri + "/events/" + id + ".json?" + apiKey + DB.getRandom());

    xhr.send();

}

// gets the tracking status of event
function getEventTrackingInfo(id, callback)
{
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        console.log('receiving')
        //console.log(xhr);
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            print('HEADERS_RECEIVED');
        } else if(xhr.readyState === XMLHttpRequest.DONE) {
            print('DONE')
            console.log(xhr.responseText);
            var json = JSON.parse(xhr.responseText.toString());
            if (json.resultsPage.status === "ok" ) {
                print(json.resultsPage.results.tracking.attendance)
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
    print(songKickUri + "/users/" + userName + "/trackings/event:"+ id + ".json?" + apiKey + DB.getRandom());
    xhr.open("GET", songKickUri + "/users/" + userName + "/trackings/event:"+ id + ".json?" + apiKey + DB.getRandom());
    // if no tracking, it will return: {"resultsPage":{"status":"error","error":{"message":"Tracking not found"}}}
    // if tracking, then it will return: "resultsPage":{"status":"ok","results":{"tracking":{"username":"spoonman72","id":"event:36081339","createdAt":"2019-02-27T01:18:50+0000","attendance":"i_might_go"}}}}
    xhr.send();
}

function getArtistTrackingInfo(id, callback)
{
    //https://api.songkick.com/api/3.0/users/{username}/trackings/artist:{artist_id}.json?apikey={your_api_key}

}

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
    var eventi = {id:eventId, uri:eventUri, name:eventName, artist: artist, metroAreaName: metroAreaName, date: eventDate, time: eventTime, venueId: venueId, venueName: venueName, attendance: attendance}

    calendarEntries.push(eventi);
    print('pushed: ' +  eventi.name)
  }
  print ('number of items: ' + calendarEntries.length)
  return calendarEntries
}

// this function converts a artists/areas upcomming events
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
    if (currentEvent === null && currentEvent === undefined) {
         break;
    }
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
    var eventi = {id:eventId, uri:eventUri, name:eventName, date: eventDate, time: eventTime, venueId: venueId, venueName: venueName, metroAreaId:metroAreaId, metroAreaName: metroAreaName}

    events.push(eventi);
    print('pushed: ' +  eventi.name)

  }
  print ('number of items: ' + events.length)
  return events
}

//{ "resultsPage": {
//      "status": "ok",
//      "page": 1,
//      "totalEntries": 1,
//      "perPage": 50,
//      "results": {
//        "calendarEntry": [
//          {"reason": {
//              "trackedArtist": [ARTIST, ARTIST],
//              "attendance": "i_might_go|im_goin"�
//           },
//           "event": {EVENT}
//          }]
//      }
//  } }

/*// this function converts a users upcomming calendar
// into event model
// in: json response
// out: array of events
// failure: will return one event with message in case of failure
//          will return empty array when no results found
function convertUsersCalendarResponse(resp) {

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
    var eventi = {id:eventId, uri:eventUri, name:eventName, date: eventDate, time: eventTime, venueId: venueId, venueName: venueName, metroAreaId:metroAreaId, metroAreaName: metroAreaName}

    events.push(eventi);
    print('pushed: ' +  eventi.name)

  }
  print ('number of items: ' + events.length)
  return events
}*/

//{"resultsPage":
//{"status":"ok",
//"results":{"metroArea":[
//{"lat":47.0667,"lng":15.45,"country":{"displayName":"Austria"},"uri":"http://www.songkick.com/metro_areas/26766-austria-graz?utm_source=14198&utm_medium=partner","displayName":"Graz","id":26766},
//{"lat":50.0833,"lng":14.4667,"country":{"displayName":"Czech Republic"},"uri":"http://www.songkick.com/metro_areas/28425-czech-republic-prague?utm_source=14198&utm_medium=partner","displayName":"Prague","id":28425},
//{"lat":48.2,"lng":16.3667,"country":{"displayName":"Austria"},"uri":"http://www.songkick.com/metro_areas/26771-austria-vienna?utm_source=14198&utm_medium=partner","displayName":"Vienna","id":26771}
//]},
//"perPage":50,"page":1,"totalEntries":3}}
function convertTrackedItemsResponse(type,resp) {

    print('called for type: ' + type)

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
      print('pushed ' + type + ": " +  eventi.title + "; uri: " + eventi.uri + ' body:' + eventi.body)
    }
    print ('number of ' + type + '(s): ' + trackedItems.length)

    return trackedItems
}


function convertEventResponse(resp)
{
    var eventi = {};

    if (resp.resultsPage.status !== "ok") {
      console.log("return value is not ok");
      eventi = {id:0, uri:"", name:"resultPage.status not ok", date: "", time: "", venueId: 1, venueName: "undefined"}
      return eventi;
    }

    eventi.displayName = resp.resultsPage.results.event.displayName;
    eventi.type = resp.resultsPage.results.event.type;
    eventi.dateTime = resp.resultsPage.results.event.start.date;
    eventi.time = "";
    if (resp.resultsPage.results.event.start.time !== null) {
       eventi.time = resp.resultsPage.results.event.start.time;
    }
    eventi.venue = resp.resultsPage.results.event.venue.displayName;
    eventi.venueWebSite = resp.resultsPage.results.event.venue.website;
    eventi.street = resp.resultsPage.results.event.venue.street;
    eventi.zip = resp.resultsPage.results.event.venue.zip;
    eventi.city = resp.resultsPage.results.event.venue.metroArea.displayName;
    eventi.country = resp.resultsPage.results.event.venue.city.country.displayName;
    eventi.lat = resp.resultsPage.results.event.venue.lat;
    eventi.lng = resp.resultsPage.results.event.venue.lng;
    eventi.body = resp.resultsPage.results.event;
    var artists = [];
    print("length:" + resp.resultsPage.results.event.performance.length)
    for (var aC = 0; aC < resp.resultsPage.results.event.performance.length; aC++)
    {
        var currAc = {};
        currAc["displayName"] = resp.resultsPage.results.event.performance[aC].displayName;
        // currAc["startTime"] = resp.resultsPage.results.event.performance[aC].startTime;
        artists[aC] = currAc;
    }
    eventi.artists = artists;
    return eventi;
}
