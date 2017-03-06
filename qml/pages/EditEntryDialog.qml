//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../common"

Dialog {
    id: editEntryDialog
    // property to pass root page
    property MainPage mainPage: null
    // UID of the entry to be edited
    property string entryId: ""
    // type of entry: location, artist, venue
    property string entryType: ""

    property bool createNewEntry: false

    // The following properties are used to check if text of any entry detail was changed. If so,
    // set cover page accordingly to signal the user unsaved changes
    property string origTitle: ""
    property string origSongKickId: ""
    property string origComment: ""
    property bool titleChanged: false
    property bool songKickIdChanged: false
    property bool commentChanged: false

    function calculateLabel()
    {
        var labelText = editEntryDialog.createNewEntry ? "Create new " + entryType : "Edit " + entryType
        labelText = qsTr(labelText)
        return labelText
    }

    function setTextFields(values) {
        entryTitleTextField.text = origTitle = values[0]
        entrySongKickIdTextField.text = origSongKickId = values[1]
        //entryUsernameTextField.text = origUsername = values[2]
        //entryPasswordTextField.text = entryVerifyPasswordTextField.text = origPassword = values[3]
        entryCommentTextField.text = origComment = values[2]
    }

    // This function should be called when any text is changed to check if the
    // cover page state needs to be updated
    function updateCoverState() {
        if (titleChanged || songKickIdChanged || commentChanged) {
            applicationWindow.cover.state = "UNSAVED_CHANGES"
        } else {
            applicationWindow.cover.state = "ENTRY_VIEW"
        }
    }

    // forbit page navigation if title is not set and password is not verified
    canNavigateForward: !entryTitleTextField.errorHighlight && !entrySongKickIdTextField.errorHighlight
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

            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: qsTr("Discard")
            }

            SilicaLabel {
                text: calculateLabel()
            }

            TextField {
                id: entryTitleTextField
                width: parent.width
                inputMethodHints: Qt.ImhSensitiveData
                label: qsTr("Title")
                text: ""
                placeholderText: qsTr("Set title (mandatory)")
                errorHighlight: text.length === 0
                EnterKey.enabled: !errorHighlight
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: entrySongKickIdTextField.focus = true
                onTextChanged: {
                    editEntryDialog.titleChanged =
                            (editEntryDialog.origTitle !== text ? true : false)
                    editEntryDialog.updateCoverState()
                }
                focusOutBehavior: -1 // This doesn't let the eye button steal focus
            }

            TextField {
                id: entrySongKickIdTextField
                width: parent.width
                inputMethodHints: Qt.ImhDigitsOnly
                label: qsTr("SongKick Id")
                text: ""
                placeholderText: qsTr("Set SongKick Id")
                EnterKey.enabled: !errorHighlight
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: entryUsernameTextField.focus = true
                onTextChanged: {
                    editEntryDialog.songKickIdChanged =
                            (editEntryDialog.origSongKickId !== text ? true : false)
                    editEntryDialog.updateCoverState()
                }
                focusOutBehavior: -1
            }

            TextArea {
                id: entryCommentTextField
                width: parent.width
                label: qsTr("Comment")
                text: ""
                placeholderText: qsTr("Set comment")
                onTextChanged: {
                    editEntryDialog.commentChanged =
                            (editEntryDialog.origComment !== text ? true : false)
                    editEntryDialog.updateCoverState()
                }
                focusOutBehavior: -1
            }
        }
    }

    Component.onCompleted: {
        if (!createNewEntry) {
            // read data from current object
            //title,type,skid,uid
            var details = mainPage.getEntryDetails(entryType,entryId);
            //title,songkickid,txt
            var values = [details[0],details[2],""];
            setTextFields(values);
        }
        entryTitleTextField.focus = true
    }
    Component.onDestruction: {

    }

    // user wants to save new entry data
    onAccepted: {
        if (createNewEntry)
           mainPage.addEntry(entryTitleTextField.text,entryType,entrySongKickIdTextField.text, entryId);
        else
            mainPage.updateEntry(entryTitleTextField.text,entryType,entrySongKickIdTextField.text, entryId);
    }
    // user has rejected editing entry data, check if there are unsaved details
    onRejected: {
        // no need for saving if input fields are invalid
        if (canNavigateForward) {
            // ?!
        }
    }
}
