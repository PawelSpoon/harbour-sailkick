//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0

HelpPage {
    text: qsTr("This is a native SongKick application.<br><br>\
\
<h2>Concerts</h2>
This page shows the upcoming events of your favorite artists in your area(s). <br>
Click on an item will open the details page [not implemented] <br>
PressAndHold on an item will open the event in browser on songkick.com.<br>
PullDownMenu 'Locations' will open 'Locations' page with all your tracked locations. <br>
PullDonwMenu 'Artists' will open 'Artists' page with all your favorite artists. <br>
PullDownMenu 'Refresh' will refresh the content. <br>
PullDownMenu 'Settings' will open 'Settings' page. <br>
PushUpMenu Help did open this help page. <br>
PushUpMenu About will open general Info page [not implemented] <br>
<h2>Settings Page</h2>
This page allows to do enter your songkick username. password is currently not needed.<br>
songkick.com still supports http, so at least your username might be sent plain over the wire. This app is using https, but your browser might not.
Consider this when creating the account and setting username and password. <br>
PullDownMenu 'Get tracked items..' will load your tracked artists, areas .. from songkick.com and store locally.<br>
<h2>Locations</h2>
Shows all your favorite locations. Click on any to see the upcoming events.<br>
<h2>Artists</h2>
Shows all your favorite artists. Click on any to see his/her/their upcoming events.<br>
<h2>Artist/Area event page</h2>
PullDownMenu 'Refresh' will refresh the content. <br>
PushUpMenu 'Load more' will load the next 50 [not implemented]<br>
PushAndHold on an item will open it in browser on songkick.com<br>
<h2>One last comment</h2>
songkick.com provides only a read-only api.
so all the managing of your account: favorite artists / venues etc. has to happen in browser.
I will extend the app in future to support a webcontrol but this will remain a web experience.
")
}
