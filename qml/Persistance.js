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
    var dbVersion = getDBVersion(db);
    console.log("db version: " + dbVersion);
    dbVersion = v_2_0(db,dbVersion);
    dbVersion = v_2_2(db,dbVersion);
    dbVersion = v_2_3(db,dbVersion);
}

// creates version table if not there and returns the dbversion
// 0 if fresh install
function getDBVersion(db)
{
    var rs;
    db.transaction(
        function(tx) {
            // Create the version table if it doesn't already exist
            tx.executeSql('CREATE TABLE IF NOT EXISTS version(version dec(5,2) DEFAULT 0.0)');
            rs = tx.executeSql('SELECT DISTINCT version FROM version;');
        });
    // not records => fresh install
    if (rs.rows.length === 0 ) {
        console.log("no version record -> fresh install, return 0");
        return 0;
    }
    // record but a string => pre
    // recreate version table with 2.2 as decimal
    console.log("found version: " + rs.rows.item(0).version);
    if (rs.rows.item(0).version === "2.2") {
        console.log("found version: 2.2 as string -> recreate table as 2.2");
        db.transaction(
            function(tx) {
                tx.executeSql('DROP TABLE IF EXISTS version');
                tx.executeSql('CREATE TABLE IF NOT EXISTS version(version dec(5,2) DEFAULT 0.0)');
                tx.executeSql('INSERT OR REPLACE INTO version values (?);', 2.2 );             
            });
        return 2.2;
    }
    // final model with version as decimal and incremental intalls
    return rs.rows.item(0).version;
}

function v_2_0(db, version)
{
    if (version < 2.0) {
        console.log("installing version 2.0");
        db.transaction(
        function(tx) {
            tx.executeSql('DELETE FROM version');
            tx.executeSql('INSERT OR REPLACE INTO version values (?);', 2.0);
            tx.executeSql('CREATE TABLE IF NOT EXISTS tracked(uid LONGVARCHAR UNIQUE, title TEXT, type TEXT, skid TEXT, txt TEXT, body TEXT)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS user(uid LONGVARCHAR UNIQUE, title TEXT,pwd TEXT)');
        });
    }
    return 2.0;
}

// persistance 2.2:
// recreate 
function v_2_2(db, version)
{
  if (version === 2.0) {
    console.log("installing version 2.2");
    db.transaction(
        function(tx) {
            tx.executeSql('DELETE FROM version');
            tx.executeSql('INSERT OR REPLACE INTO version values (?);', 2.2);
        });      
  }
  return 2.2;
}

// persistance 2.3:
// add table for api-calls
function v_2_3(db, version)
{
    if (version === 2.2) {
    console.log("installing version 2.3");
    db.transaction(
        function(tx) {
            tx.executeSql('DELETE FROM version');
            tx.executeSql('INSERT OR REPLACE INTO version values (?);', 2.3);
            tx.executeSql('CREATE TABLE IF NOT EXISTS response(uri TEXT, page TEXT, skid TEXT, body TEXT)');
        });
    }
    return 2.3;
}

function getRandom()
{
    return "123456"
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
