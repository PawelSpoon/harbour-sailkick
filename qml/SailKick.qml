//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: applicationWindow
    property Item mainPage: null

    initialPage: Component {
        MainPage {
            id: mainPage

            Component.onCompleted: applicationWindow.mainPage = mainPage
        }
    }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}

