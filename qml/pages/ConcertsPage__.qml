//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import Sailfish.Share 1.0
// DB should not be needed here !!
import "../Persistance.js" as DB
import "../SongKickApi.js" as API
import "../common"


EventListView {
    id: eventListView
    anchors.fill: parent
    anchors.topMargin: Theme.paddingMedium
    anchors.bottomMargin: Theme.paddingMedium
    resultsProperty: skApi.userConcertsResults
    apiCall: skApi.getUserConcertsAsync

    property var mainPage: null // this is the main page that contains the pageStack
    property var controller: null // this is the controller that contains the API calls

    property string type: "concerts"
    property string title: qsTr("Concerts")
    property string iconName: "sk-concerts.png"

    function refresh()
    {
        console.log('refreshing concerts page')
        eventListView.model.clear()
        skApi.getUserConcertsAsync()
     }

    Component.onCompleted:
    {
       skApi.getUserConcertsAsync();
    }

    Connections {
        target: skApi
        onConcertsSuccess: {
            // Handle received plans
            console.log("Concerts received, filling model")
            eventListView.upcomingModel.clear()
            eventListView.fillUpCommingModelForOneTrackingEntry(listType, skApi.userConcertsResults)
        }
    }
}
