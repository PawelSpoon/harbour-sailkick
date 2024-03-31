const exp = require('constants');
const SongKickApi = require('./SongKickApiConversion.js');
const XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;
const fs = require('fs');

const username = "spoonman72"
const type = "artist"
const page = 1

// var xhr = new XMLHttpRequest();

test('convertEvent returns expected events', done => {
    /*function onEventSuccess(type, events) {
        expect(type).toBe('artist');
        expect(events.length).toBeGreaterThanOrEqual(10);
        expect(events[0]).toBeDefined();
        expect(events[0].skid).toBeDefined();
        expect(events[0].name).toBeDefined();
        expect(events[0].uri).toBeDefined();
        expect(events[0].date).toBeDefined();
        done();
    }*/

    function onFailure(error) {
        done(error);
    }
    // Read the file
    var data = fs.readFileSync('./dist/eventResponse.json', 'utf8');
    var apiEvent = JSON.parse(data).resultsPage.results.event; // event is not an array
    console.log(apiEvent)
    // act
    var skEvent = SongKickApi.convertEvent(apiEvent);
    // assert
    expect(skEvent).toBeDefined();
    expect(skEvent.id).toBeDefined();
    expect(skEvent.name).toBeDefined();
    expect(skEvent.displayName).toBeDefined();
    expect(skEvent.type).toBeDefined();
    expect(skEvent.type).toBe('Concert');
    expect(skEvent.uri).toBeDefined();
    expect(skEvent.date).toBeDefined();
    expect(skEvent.venueName).toBeDefined();
    expect(skEvent.venueId).toBeDefined();
    expect(skEvent.street).toBeDefined();
    expect(skEvent.metroAreaName).toBeDefined();
    expect(skEvent.metroAreaId).toBeDefined();
    expect(skEvent.artists).toBeDefined();
    expect(skEvent.artists).toBeInstanceOf(Array);
    expect(skEvent.artists[0]).toBeDefined();
    expect(skEvent.artists[0].id).toBeDefined();
    expect(skEvent.artists[0].displayName).toBeDefined();
    expect(skEvent.artists[0].name).toBeDefined();
    done();
});

test('convertCalendarEntry returns expected events', done => {
    /*function onEventSuccess(type, events) {
        expect(type).toBe('artist');
        expect(events.length).toBeGreaterThanOrEqual(10);
        expect(events[0]).toBeDefined();
        expect(events[0].skid).toBeDefined();
        expect(events[0].name).toBeDefined();
        expect(events[0].uri).toBeDefined();
        expect(events[0].date).toBeDefined();
        done();
    }*/

    function onFailure(error) {
        done(error);
    }
    // Read the file
    var data = fs.readFileSync('./dist/calendarResponse.json', 'utf8');
    var apiCalEntries = JSON.parse(data).resultsPage.results.calendarEntry; // an array

    // get the first event and test
    // act
    var skCalEntry = SongKickApi.convertCalendarEntry(apiCalEntries[0]);
    // assert
    console.log(skCalEntry);
    expect(skCalEntry).toBeDefined();
    expect(skCalEntry.id).toBeDefined();
    expect(skCalEntry.name).toBeDefined();
//    expect(skCalEntry.type).toBeDefined();
//    expect(skCalEntry.type).toBe('Concert');
    expect(skCalEntry.uri).toBeDefined();
    expect(skCalEntry.date).toBeDefined();
    expect(skCalEntry.venueName).toBeDefined();
    expect(skCalEntry.venueId).toBeDefined();
    expect(skCalEntry.metroAreaName).toBeDefined();
    expect(skCalEntry.metroAreaId).toBeDefined();
    expect(skCalEntry.artistName).toBeDefined();
    expect(skCalEntry.artistId).toBeDefined();
    done();
});

// i need an event test where artist is not defined in perfomrance ?
