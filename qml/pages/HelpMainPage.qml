//<license>

import QtQuick 2.0
import Sailfish.Silica 1.0

HelpPage {
    text: qsTr("This is a native SongKick application.<br><br>\
\
<h2>Main Page</h2>
This page shows the upcomming events for selected artists, venues, metro areas. <br>
Click on an item will open the details page [not implemented]
PressAndHold on an item will open the event on songkick.com in browser [not implemented]<br>
PullDownMenu Refresh will refresh it's contect.
PullDownMenu Settings will open settings page.
PushUpMenu Load more will load the next 50 items.
PushUpMenu Help did open this help page.
PushUpMenu About will open general Info page [not implemented]
<h2>Settings Page</h2>
This page allows you to define who you want to track. <br>
Use the various PushUpMenu's to add an artist / venue or metro area.
Click on an item opens the edit page where you can change some details.
PushAndHold on an item allows you to delete a single item.
<h2></h2>
A browse mechanism is currently not implemented. You have to define the name and the SongKick id manually.
For this, open SongKick.com, search for the artist / venue / metro area and open it. The inspect the url to get the id.
i.e.:
https://www.songkick.com/artists/253846-radiohead
<br>
You will need to provide your username. this is needed to allow usage of SongKick API. \
<br><br>")
}
