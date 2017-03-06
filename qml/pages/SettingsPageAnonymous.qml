//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: settings

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    property MainPage mainPage: null


    SilicaListView {
        id: listView
        model: mainPage.locationList
        anchors.fill: parent
        PullDownMenu {
            MenuItem {
                text: qsTr("Delete all")
                onClicked: mainPage.cleanDb()
            }

            MenuItem {
                text: qsTr("Add artist")
                onClicked: pageStack.push(Qt.resolvedUrl("EditEntryDialog.qml"), {mainPage: settings.mainPage, entryType: "artist", createNewEntry: true, entryId: "0"})
            }

            MenuItem {
                text: qsTr("Add venue")
                onClicked: pageStack.push(Qt.resolvedUrl("EditEntryDialog.qml"), {mainPage: settings.mainPage, entryType: "venue", createNewEntry: true, entryId: "0"})
            }

            MenuItem {
                text: qsTr("Add metro area")
                onClicked: pageStack.push(Qt.resolvedUrl("EditEntryDialog.qml"), {mainPage: settings.mainPage, entryType: "location", createNewEntry: true, entryId: "0"})
            }

        }
        header: PageHeader {
            title: qsTr("Settings")
        }

        VerticalScrollDecorator {}

        delegate: Item {
            id: myListItem
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            property int myIndex: index
            property Item contextMenu

            width: ListView.view.width
            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            function remove() {
                var removal = removalComponent.createObject(myListItem)
                ListView.remove.connect(removal.deleteAnimation.start)
                removal.execute(contentItem, "Deleting", function() { mainPage.removeEntry(title,type,uid,index); } )
            }

            BackgroundItem {
                id: contentItem

                width: parent.width
                onPressAndHold: {
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(mainPage.locationList)
                    contextMenu.show(myListItem)
                }
                onClicked: {
                    //console.log("Clicked " + title)
                    pageStack.push(Qt.resolvedUrl("EditEntryDialog.qml"), {origTitle: title, entryId: uid, entryType: type, mainPage: settings.mainPage} )
                    //console.debug("Text:" + DB.getText(title,uid))
                }
                Image {
                    id: typeIcon
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingSmall
                    source: {
                        if (type === "location") "image://theme/icon-l-copy"
                        else "image://theme/icon-m-levels"
                    }
                    height: parent.height
                    width: height
                }
                Label {
                    text: title
                    anchors.left: typeIcon.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    font.capitalization: Font.Capitalize
                    truncationMode: TruncationMode.Elide
                    elide: Text.ElideRight
                    color: contentItem.down || menuOpen ? Theme.highlightColor : Theme.primaryColor
                }
            }

            Component {
                id: contextMenuComponent
                ContextMenu {
                    id: menu
                    MenuItem {
                        text: "Delete"
                        onClicked: {
                            menu.parent.remove();
                        }
                    }
                }
            }

            Component {
                id: removalComponent
                RemorseItem {
                    property QtObject deleteAnimation: SequentialAnimation {
                        PropertyAction { target: myListItem; property: "ListView.delayRemove"; value: true }
                        NumberAnimation {
                            target: myListItem
                            properties: "height,opacity"; to: 0; duration: 300
                            easing.type: Easing.InOutQuad
                        }
                        PropertyAction { target: myListItem; property: "ListView.delayRemove"; value: false }
                    }
                    onCanceled: destroy()
                }
            }
        }

    }
}
