//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../common"
import "../Persistance.js" as DB
import "../SongKickApi.js" as API

//Page {
Dialog {
    id: settings

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    property MainPage mainPage: null

    SilicaFlickable{

        id: settingsFlickable
        onActiveFocusChanged: print(activeFocus)
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        PullDownMenu {
            /*MenuItem {
                text: qsTr("Anonymous settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPageAnonymous.qml"), {mainPage: settings.mainPage})
            }*/
            MenuItem {
                text: qsTr("Get tracked items from songkick")
                onClicked: {                
                    API.getUsersTrackedItems("artist",entrySongKickUserName.text, settings.mainPage.updateTrackingItemsInDb)
                    API.getUsersTrackedItems("location",entrySongKickUserName.text, settings.mainPage.updateTrackingItemsInDb)
                    //settings.mainPage.reloadTrackingItemsAndUpcomming() happens before responses are back due to async
                }
            }
        }


        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: qsTr("Discard")
            }

            SilicaLabel {
                text: qsTr("Songkick credentials")
                font.pixelSize: Theme.fontSizeLarge
            }

            TextField {
                id: entrySongKickUserName
                width: parent.width
                inputMethodHints: Qt.ImhSensitiveData
                label: qsTr("Songkick Username")
                text: ""
                placeholderText: qsTr("set username (mandatory)")
                errorHighlight: text.length === 0
                EnterKey.enabled: !errorHighlight
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                font.capitalization: Font.MixedCase
                /*EnterKey.onClicked: entrySongKickPassWord.focus = true
                onTextChanged: {
                editEntryDialog.titleChanged =
                        (editEntryDialog.origTitle !== text ? true : false)
                editEntryDialog.updateCoverState()
            }
                //focusOutBehavior: -1 // This doesn't let the eye button steal focus*/
            }

            /*TextField {
                id: entrySongKickPassWord
                width: parent.width
                inputMethodHints: Qt.ImhSensitiveData
                label: qsTr("Songkick Password")
                text: ""
                placeholderText: qsTr("Set password")
                errorHighlight: text.length === -1 // not mandatory
                EnterKey.enabled: !errorHighlight
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: entryUsernameTextField.focus = true
                /*onTextChanged: {
                editEntryDialog.songKickIdChanged =
                        (editEntryDialog.origSongKickId !== text ? true : false)
                editEntryDialog.updateCoverState()
            }
                //focusOutBehavior: -1
            }*/

            Label {
                id: helpText
                anchors.horizontalCenter: parent.horizontalCenter
                //anchors.left : entrySongKickUserName.left
                //anchors.leftMargin: entrySongKickUserName.anchors.leftMargin
                width: entrySongKickUserName.width - 100
                text: "Username is needed to retrieve
your tracked items
from songkick.com.
Password is currently not needed.
If you do not have a
Songkick account yet,
please create one.
When ever you modify your
tracking items on songkick.com,
sync them using
'Get tracked items ..'
pulldown menu"
            }

        }
    }

    Component.onCompleted: {
        var user = DB.getUser();
        entrySongKickUserName.text = user.name;
        //entrySongKickPassWord.text = user.pwd;
        //entryTitleTextField.focus = true
    }

    Component.onDestruction: {

    }
    // user wants to save settings
    // tracking items get saved via EditEntryDialog
    // this will only save user and password
    onAccepted: {
        DB.setUser(entrySongKickUserName.text, "");
    }
    // user has rejected editing entry data, check if there are unsaved details
    onRejected: {
        // no need for saving if input fields are invalid
        if (canNavigateForward) {
            // ?!
        }
    }
}
