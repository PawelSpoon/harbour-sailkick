//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0
import Sailfish.WebView.Popups 1.0
import "../common"

//Page
Dialog {
    id: trackedItemDetailsPage
    property string uri
    property string agent: "Mozilla/5.0 (Linux; Android 4.4; Nexus 4 Build/KRT16H) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36"

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
//        contentWidth: parent.width
//        contentHeight: parent.height

        WebView {
            id: webView
            anchors.fill: parent
            opacity: 1
            //contentWidth : 600
            //settings.defaultFontSize: Theme.fontSizeMedium
            url: "http://www.google.com"
            //scale: 1.5 // does scale but that is not good
            httpUserAgent: "Mozilla/5.0 (Mobile; rv:78.0) Gecko/78.0"
                        + " Firefox/78.0"

            property variant devicePixelRatio: {//1.5
                console.log(Screen.width)
                if (Screen.width <= 540) return 1.5;
                else if (Screen.width > 540 && Screen.width <= 768) return 2.0;
                else if (Screen.width > 768) return 3.0;
            }

            /*experimental.customLayoutWidth: trackedItemDetailsPage.width / devicePixelRatio
            experimental.deviceWidth: trackedItemDetailsPage.width / devicePixelRatio
            experimental.overview: true

            // Helps rendering websites that are only optimized for desktop
            experimental.preferredMinimumContentsWidth: 980*/
        }
    }

    Component.onCompleted: {
       webView.url = uri
       webView.reload()
       webView.experimental.evaluateJavaScript(
                    "document.querySelector(\"meta[name=viewport]\").setAttribute('content', 'width=device-width, initial-scale=1.0');");

    }

    onAccepted: {
        Qt.openUrlExternally(uri)
    }


    function enableDesktopScaling() {
        webview.experimental.evaluateJavaScript(
                    "document.querySelector(\"meta[name=viewport]\").setAttribute('content', 'width=device-width, initial-scale=1.0');");
    }

}
