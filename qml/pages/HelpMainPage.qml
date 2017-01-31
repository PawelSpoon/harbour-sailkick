/***************************************************************************
**
** Copyright (C) 2017 Jan Sturm (pawel@ich-habe-fertig.com)
** All rights reserved.
**
** This file is part of SailKick.
**
** SailKick is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** SailKick is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with ownKeepass. If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

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
PushUpMenu Top will navigate to first item in list.
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
")
}
