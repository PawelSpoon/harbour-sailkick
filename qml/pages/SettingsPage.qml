/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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
