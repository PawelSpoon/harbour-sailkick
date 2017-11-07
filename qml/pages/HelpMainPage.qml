//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0

HelpPage {
    text: qsTr("This is a native SongKick application.<br><br>\
\
<h2>General Navigation</h2>
This app nearly implements an carousel. Starting with Plans page you can swipe to Concerts, Locations, Artists back to Plans.
Click on an item in Locations or Artist page to view all corresponding events. Swipe back to return to main carousel.
Click on an event to open the event details page. Swipe back to return or forward to open event in Browser.
PressAndHold on an event will open a menu where you can again open event in Browser or share it.

<h2>Plans</h2>
This page shows all events that you have marked either as 'i am going' or 'track event'.

<h2>Concerts</h2>
This page shows the upcoming events of your favorite artists in your favorite area(s). <br>
Click on an item will open the details page.<br>
PressAndHold on an item will open the event in browser on songkick.com.<br>
PullDownMenu 'Refresh' will refresh the content. <br>
PullDownMenu 'Settings' will open 'Settings' page. <br>
PushUpMenu Help did open this help page. <br>
PushUpMenu About will open general Info page. [not implemented] <br>
You can switch between Concerts, Locations, Artists, Plans page with an swipe.<br>
<h2>Settings Page</h2>
This page allows to do enter your songkick username. password is currently not needed.<br>
songkick.com still supports http, so at least your username might be sent plain over the wire. This app is using https, but your browser might not.
Consider this when creating the account and setting username and password. <br>
PullDownMenu 'Get tracked items..' will load your tracked artists, areas .. from songkick.com and store locally.<br>
When ever you manage your tracked items on the web, you need to update the locally stored with 'Get tracked items ..'<br>
<h2>Locations</h2>
Shows all your favorite locations. Click on any to see the upcoming events.<br>
<h2>Artists</h2>
Shows all your favorite artists. Click on any to see his/her/their upcoming events.<br>
<h2>Artist/Area event page</h2>
PullDownMenu 'Refresh' will refresh the content. <br>
PushUpMenu 'Load more' will load the next 50 [not implemented]<br>
Click on an item will open it in webview within the application. You will need to log in once in the webview.
PushAndHold on an item will open it in web external browser<br>
<h2>One last comment</h2>
songkick.com provides only a read-only api.
so all the managing of your account: favorite artists / venues etc. has to happen in an webview.
")
}
