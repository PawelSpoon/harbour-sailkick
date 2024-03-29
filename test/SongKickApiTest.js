// test.js
const SongKickApi = require('./SongKickApi.js');
const assert = require('assert');
const XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;

const username = "spoonman72"
const type = "artist"
const page = 1

function onEventSuccess(type, events) {
    console.log(type);
    console.log(events[0]);
}

function onFailure(error) {
    console.log(error);
}

function onTrackedItemSuccess(type,page,username,items) {
    console.log(type);
    console.log(page);
    console.log(username);
    console.log(items[0]);
}

var xhr = new XMLHttpRequest();

SongKickApi.getUsersUpcommingEvents(type,username, onEventSuccess, onFailure, xhr)

SongKickApi.getUsersTrackedItems(type, page, username, onTrackedItemSuccess, onFailure, xhr)

/*
const it = (desc, fn) => {
  try {
    fn();
    console.log('\x1b[32m%s\x1b[0m', `\u2714 ${desc}`);
  } catch (error) {
    console.log('\n');
    console.log('\x1b[31m%s\x1b[0m', `\u2718 ${desc}`);
    console.error(error);
  }
};

it('should return the sum of two numbers', () => {
  assert.strictEqual(main.sum(5, 10), 15);
});*/