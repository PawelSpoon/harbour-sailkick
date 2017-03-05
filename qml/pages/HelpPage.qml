//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../common"

Page {
    id: helpPage

    property alias text: helpTextLabel.text

    allowedOrientations: applicationWindow.orientationSetting

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeaderExtended {
                title: "SailKick"
                subTitle: qsTr("a native SongKick client")
                subTitleOpacity: 0.5
                subTitleBottomMargin: helpPage.orientation & Orientation.PortraitMask ? Theme.paddingSmall : 0
            }

            SilicaLabel {
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                text: qsTr("Help")
            }

            SilicaLabel {
                id: helpTextLabel
                linkColor: Theme.highlightColor
            }
        }
    }
}
