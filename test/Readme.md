# this is a copy from watchlist but it seems to run on ubuntu

## ubuntu installs
### qml-module-qtquick-localstorage
### qml-module-qttest

# my way
i did try to do it with jest, but failed
then i did try it with node but failed too
i made node working, use node to convert files and to execute a method.
but i was not a real test, just a method execution, see SongKickApiTest.js
(i will check it in, but no use it)
then i reworked the test for jest: SongKickApiJestTest.js

## how to execute
#from \test execute 'node .\run-node-test.js'
#this will convert the source files and store them into dist
#will copy the test files into dist (and maybe still execute a method)
#*then run* npm test

## how to execute in 2025 :)
npm pre-test   should create a dist folder and copy files into it
npm test       should execute the tests
- after each change in source you need to run pre-test to copy the files there


## installation
install npm
npm install --save-dev jest // jest testing framework
npm install --save-dev babel-jest @babel/preset-env // may not be needed: would do a preconversion, but i guess not for me
npm install xmlhttprequest  // xmlhttprequest for invoking calls

## obstacles
fight with async copying
fight with old js not supporting modules
had to move httprequest as opt param of method to support injection

