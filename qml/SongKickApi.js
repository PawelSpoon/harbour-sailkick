
function request() {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            print('HEADERS_RECEIVED')
        } else if(xhr.readyState === XMLHttpRequest.DONE) {
            print('DONE')
            var json = JSON.parse(xhr.responseText.toString())
            view.model = json.items
        }
    }
    xhr.open("GET", "http://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=munich");
    xhr.send();
}

function parseFromApi(resp) {

  var events = [];

  if (resp.resultsPage.status !== "ok") {
    console.log("return value is not ok");
    return "status nok";
  }

  if (resp.resultsPage.totalEntries === 0) {
    console.log("0 values found");
    return "no entries";
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
  //var listOf = {"events" : events}
  //return listOf

}
