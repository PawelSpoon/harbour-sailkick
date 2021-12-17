//Persistance.js
//originated from Noto
//datamodel: one table to hold tracked artists, venues, metroareas, these can be differentiated by type column
//one table to hold one entry: username
// tracked table: title == name, type == artist / location, skid == song kick id, txt == song kick uri

.import QtQuick.LocalStorage 2.0 as LS

// First, let's create a short helper function to get the database connection
function getDatabase() {
    return LS.LocalStorage.openDatabaseSync("SailKick", "1.0", "StorageDatabase", 100000);
}

// returns a unique id based on date-time
function getUniqueId()
{
     var dateObject = new Date();
     var uniqueId =
          dateObject.getFullYear() + '' +
          dateObject.getMonth() + '' +
          dateObject.getDate() + '' +
          dateObject.getTime();

     return uniqueId;
};

// At the start of the application, this creates tables if not already there
function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    // Create the settings table if it doesn't already exist
                    tx.executeSql('CREATE TABLE IF NOT EXISTS version(version TEXT)');
                    var rs = tx.executeSql('SELECT DISTINCT version FROM version;');
                    console.log (rs.rows.length)
                    if (rs.rows.length === 0 || rs.rows.item(0).version !== "2.2") { console.log('drop and recreate tracked table'); tx.executeSql('DROP TABLE IF EXISTS tracked') };
                    tx.executeSql('DELETE FROM version');
                    tx.executeSql('INSERT OR REPLACE INTO version values (?);', '2.2');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS tracked(uid LONGVARCHAR UNIQUE, title TEXT, type TEXT, skid TEXT, txt TEXT, body TEXT)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS user(uid LONGVARCHAR UNIQUE, title TEXT,pwd TEXT)');
                });
}

function getRandom()
{
    return "12345678"
}

function setUser(title,txt)
{
    // title: represents user name, this is needed for songkick queries
    // txt: represents password
    // there will be only one user in the db >> uid = hardcoded 1
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO user VALUES (?,?,?);', [1,title,txt]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Saved to database");
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

function getUser()
{
    var db = getDatabase();
    var respath="";
    console.log("getUser called")
    var user
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT DISTINCT title,pwd FROM user;');
        for (var i = 0; i < rs.rows.length; i++) {
            //root.addLocation(rs.rows.item(i).title,rs.rows.item(i).uid)
            console.debug("get user:" + rs.rows.item(i).title + " with pwd:" + rs.rows.item(i).pwd);
            user = {"name": rs.rows.item(i).title, "pwd":rs.rows.item(i).pwd}
            break;
        }
    })
    return user;
}

// This function is used to saved tracked entries into the database, new and existing ones
function setTrackingEntry(type,uid,title,skid,uri,body) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO tracked VALUES (?,?,?,?,?,?);', [uid,title,type,skid,uri,JSON.stringify(body)]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Saved to database: uid:" + uid + ", title:" + title + ", type:"+ type); // + ", body: " + JSON.stringify(body));
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );

    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to retrieve a tracked items from the database
/*function getTrackedItem(type,uid)
{
    var db = getDatabase();
    var respath="";
    var sql = "SELECT DISTINCT uid, title, type, skid, txt, body from tracked where type='" + type + "' and uid='" + uid + "' ;";
    var detail;
    db.transaction(function(tx) {
        var rs = tx.executeSql(sql);
        detail = [rs.rows.item(0).title,rs.rows.item(0).type,rs.rows.item(0).skid,rs.rows.item(0).uid,JSON.parse(rs.rows.item(0).body)]
    })
    return detail;
}*/

//this should return a list
function getTrackedItems(type)
{
    var trackedItems = []
    var db = getDatabase();
    var respath="";
    var sql = "SELECT DISTINCT uid, title, type, skid, txt, body from tracked where type='" + type + "' order by upper(title);";
    db.transaction(function(tx) {
        var rs = tx.executeSql(sql);
        for (var i = 0; i < rs.rows.length; i++) {
            var trackedItem = {title: rs.rows.item(i).title, type: rs.rows.item(i).type, skid: rs.rows.item(i).skid, uid: rs.rows.item(i).uid, uri: rs.rows.item(i).txt, body: JSON.parse(rs.rows.item(i).body)}
            console.debug("get " + type + ": " + rs.rows.item(i).title + " with id:" + rs.rows.item(i).uid); //  + " and body: " + rs.rows.item(i).body);
            trackedItems.push(trackedItem)
        }
    })
    return trackedItems
}

//this should return a list
function getFilteredTrackedItems(type, nameLike)
{
    console.log('getFiltered  ..')
    var trackedItems = []
    var db = getDatabase(); //UPPER(name) like '%" + itemName + "%'"
    var respath="";
    var sql = "SELECT DISTINCT uid, title, type, skid, txt, body from tracked where type='" + type
            + "'and UPPER(title) LIKE '%" + nameLike + "%' order by upper(title);";
    db.transaction(function(tx) {
        var rs = tx.executeSql(sql);
        for (var i = 0; i < rs.rows.length; i++) {
            var trackedItem = {title: rs.rows.item(i).title, type: rs.rows.item(i).type, skid: rs.rows.item(i).skid, uid: rs.rows.item(i).uid, uri: rs.rows.item(i).txt, body: JSON.parse(rs.rows.item(i).body)}
            console.debug("get " + type + ": " + rs.rows.item(i).title + " with id:" + rs.rows.item(i).uid); //  + " and body: " + rs.rows.item(i).body);
            trackedItems.push(trackedItem)
        }
    })
    return trackedItems
}

// This function is used to remove a location or todo from the database
function removeTrackingEntry(type,title,uid) {
    var db = getDatabase();
    var respath="";
    //console.debug("Removing Note: " + uid)
     db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM tracked WHERE title=?;' , [title]);
     })
}

// This is a debug function to clean the whole table
function removeAllTrackingEntries(type) {
    var db = getDatabase();
    var respath="";
    var sql = "DELETE FROM tracked WHERE type='" + type + "'";
    console.debug("executing: " + sql)
        db.transaction(function(tx) {
            var rs = tx.executeSql(sql);
        })
}
