//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

Dialog {
    id: shareWith
    property Page mainPage
    property string sharedName
    property string sharedContent
    property string sharedType
    property string defaultType : "text/x-url"

    DialogHeader {
        id: header
        acceptText: qsTr("Done")
        cancelText: qsTr("Discard")
    }

    ShareMethodList {
        id: shareMethodList
        anchors.top: header.bottom
        width: parent.width
/*        header: PageHeader {
            title: qsTr("Share with")
        }*/

        content: {
            "name": sharedName,
            "data": sharedContent,
            "type": "text/x-url",
            "status" : sharedContent,
            "linkTitle": sharedName
        }
        filter: defaultType // filter share plugins based on mime type

        ViewPlaceholder {
            enabled: shareMethodList.count == 0
            text: "No sharing plugins installed which can share that mime type!"
        }
    }

    Component.onDestruction: {

    }

/*    onAccepted: {
        print("on accepted")
        pageStack.pop()
    }

    onRejected: {
      print("on rejected")
      pageStack.pop()
    }*/

    onVisibleChanged: {
        pageStack.pop()
    }


}
