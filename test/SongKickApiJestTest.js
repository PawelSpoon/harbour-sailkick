const SongKickApi = require('./SongKickApi.js');
const XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;

const username = "spoonman72"
const type = "artist"
const page = 1

var xhr = new XMLHttpRequest();

test('getUsersUpcommingEvents returns expected events', done => {
    function onEventSuccess(type, events) {
        expect(type).toBe('artist');
        expect(events.length).toBeGreaterThanOrEqual(10);
        expect(events[0]).toBeDefined();
        done();
    }

    function onFailure(error) {
        done(error);
    }

    SongKickApi.getUsersUpcommingEvents(type, username, onEventSuccess, onFailure, xhr);
});

test('getUsersTrackedItems returns expected items', done => {
    function onTrackedItemSuccess(type, page, username, items) {
        expect(type).toBe('artist');
        expect(page).toBe(1);
        expect(username).toBe('spoonman72');
        expect(items[0]).toBeDefined();
        done();
    }

    function onFailure(error) {
        done(error);
    }

    SongKickApi.getUsersTrackedItems(type, page, username, onTrackedItemSuccess, onFailure, xhr);
});

test('getUpCommingEventsForTrackedItem returns expected items', done => {
    function onUpcommingEventsForTrackedItemSuccess(type, items) {
        expect(type).toBe('artist');
   //     expect(items[0]).toBeDefined();
        done();
    }

    function onFailure(error) {
        done(error);
    }

    //todo: works only if on tour !
    function getIdAndCallUpcommingEventsForTrackedItem(type, page, username, items) {
        // expect(items[0]).toBe('[]')
        console.log(JSON.stringify(items[1]));
        SongKickApi.getUpcommingEventsForTrackedItem(type,items[1].skid,0,onUpcommingEventsForTrackedItemSuccess, onFailure, new XMLHttpRequest());        
    }

    xhr = new XMLHttpRequest();
    SongKickApi.getUsersTrackedItems(type, 0, username, getIdAndCallUpcommingEventsForTrackedItem, onFailure, xhr);//todo: get first tracked item and put it hereinto as id
});

