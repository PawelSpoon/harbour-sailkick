//<license>

import QtWebKit 3.0
import QtQuick 2.0
import Sailfish.Silica 1.0

import "../common"

//Page
Dialog {
    id: trackedItemDetailsPage
    // property to pass root page
    property MainPage mainPage: null
    property string uri

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: parent.height

        /*PushUpMenu {
            MenuItem {
                text: qsTr("Open in browser")
                onClicked: Qt.openUrlExternally(uri)
            }
        }*/
        WebView {
            id: webView
            anchors.fill: parent
            opacity: 1
            contentWidth : 600
            //settings.defaultFontSize: Theme.fontSizeMedium
            url: "http://www.google.com"
            //scale: 2 // does scale but that is not good
        }
    }

    Component.onCompleted: {
       webView.url = uri
       webView.reload()
    }

    onAccepted: {
        Qt.openUrlExternally(uri)
    }

}
