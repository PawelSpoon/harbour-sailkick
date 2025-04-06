import QtQuick 2.0
import io.thp.pyotherside 1.5

Item {
    id: root

    // indicates communication with server
    property bool loading: false
    // Login/Auth Signale
    signal loginSuccess()
    signal loginFailed()
    // generic signal for failures
    signal actionFailed(string action)
    signal actionError(string action, string error)
    // signal for data loading success
    signal plansSuccess()
    signal concertsSuccess()
    signal artistsSuccess()
    signal locationsSuccess()

    property bool logedIn: false
    //property string artistsResults
    property var userPlansResults
    property var userConcertsResults
    // will finally go into db
    property var userArtistsResults
    property var userLocationsResults
    

    Python {
        id: pythonSkApi

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('.'))

            // Debug handler
            setHandler('debug', function(message) {
                console.log("Python:", message)
            })

            // Login Handler
            setHandler('login_success', function() {
                console.log("login_success")
                root.logedIn = true
                root.loginSuccess()
            })
            setHandler('login_failed', function() {
                console.log("login_failed")
                root.logedIn = false
                root.loginFailed()
            })
            setHandler('action_failed', function(action) {
                console.log("action_failed:", action)
                root.actionFailed(action)
            })
            setHandler('action_error', function(action,error) {
                console.log("action_error:", action, error)
                root.actionError(action, error)
            })
            // Response Loading started
            setHandler('loadingStarted', function() {
                root.loading = true
            })
            // Response Loading finished
            setHandler('loadingFinished', function() {
                root.loading = false
            })
            // Data handlers
            setHandler('plans_success', function(plans) {
                console.log("plans_success")
                userPlansResults = plans
                console.log(plans.length)
                root.plansSuccess()
            })
            setHandler('concerts_success', function(events) {
                console.log("concerts_success")
                userConcertsResults = events
                console.log(events.length)
                root.concertsSuccess()
            })
            setHandler('artists_success', function(events) {
                console.log("artists_success")
                userArtistsResults = events
                console.log(events.length)
                root.artistsSuccess()
            })                  
            setHandler('locations_success', function(events) {
                console.log("locations_success")
                userLocationsResults = events
                console.log(events.length)
                root.locationsSuccess()
            })   

            importModule('songkick_bridge', function() {
                console.log("songkick bridge module imported successfully")
            })
        }

    }

    onLoginSuccess: {
        //loginTrue = true
    }

    onLoginFailed: {
        /*loginTrue = false
        if (authManager) {
            authManager.clearTokens()
        }*/
    }


    // Function to call Python function for login
    function logIn(username, pwd) {
        console.log("logIn")
        pythonSkApi.call('songkick_bridge.Bridge.logIn', [username, pwd])
    }

    // Function to get user plans
    function getUserPlansAsync() {
        console.log("getUserPlans")
        pythonSkApi.call('songkick_bridge.Bridge.getUserPlans', [])
    }
    // Function to get user plans
    function getUserConcertsAsync() {
        console.log("getUserConcerts")
        pythonSkApi.call('songkick_bridge.Bridge.getUserConcerts', [])
    }
    // Function to get user plans
    function getUserTrackedItems(type) {
        console.log("getUserTrackedItems: " + type)
        if (type === "artist") {
            pythonSkApi.call('songkick_bridge.Bridge.getUserTrackedArtists', [])
        } else if (type === "location") {
            pythonSkApi.call('songkick_bridge.Bridge.getUserTrackedLocations', [])
        } else {
            console.log("Unknown type: " + type)            
        }
    }
}
