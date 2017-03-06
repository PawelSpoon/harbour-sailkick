//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    Image {
        id: imgcover
        source: "../sk-badge-white.png"
        asynchronous: true
        opacity: 0.1
        width: parent.width * 1.15
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
    }

    Image {
        id: imgcover2
        source: "../powered-by-songkick-white.png"
        asynchronous: true
        opacity: 0.5
        width: parent.width * 0.65
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: parent.height * 0.2
        fillMode: Image.PreserveAspectFit
    }

    /*Label {
        id: label
        anchors.centerIn: parent
        text: qsTr("SailKick")
    }*/

    CoverActionList {
        id: coverAction

        /*CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
        }*/

    }
}

