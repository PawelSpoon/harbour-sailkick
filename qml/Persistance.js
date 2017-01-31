//config.js
.import QtQuick.LocalStorage 2.0 as LS
// First, let's create a short helper function to get the database connection
function getDatabase() {
    return LS.LocalStorage.openDatabaseSync("SailKick", "1.0", "StorageDatabase", 100000);
}

// We want a unique id for notes
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

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    // Create the settings table if it doesn't already exist
                    // If the table exists, this is skipped
                    tx.executeSql('CREATE TABLE IF NOT EXISTS tracked(uid LONGVARCHAR UNIQUE, title TEXT, type TEXT, skid TEXT, txt TEXT)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS user(uid LONGVARCHAR UNIQUE, title TEXT,pwd TEXT)');
                });
}

function setUser(title,txt)
{
    // title: represents user name, this is needed for songkick queries
    // txt: optional
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
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT DISTINCT title,txt FROM user;');
        for (var i = 0; i < rs.rows.length; i++) {
            root.addLocation(rs.rows.item(i).title,rs.rows.item(i).uid)
            console.debug("get user:" + rs.rows.item(i).title + " with id:" + rs.rows.item(i).uid)
        }
    })
}

// This function is used to write notes into the database
function setTrackingEntry(type,uid,title,skid,txt) {
    // title: name representing the title of the location
    // txt: optional description
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO tracked VALUES (?,?,?,?,?);', [uid,title,type,skid,txt]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Saved to database: uid:" + uid + ", title:" + title + ", type:"+ type);
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
function getTrackedItem(type,uid)
{
    var db = getDatabase();
    var respath="";
    var sql = "SELECT DISTINCT uid, title, type, skid, txt from tracked where type='" + type + "' and uid='" + uid + "' ;";
    var detail;
    db.transaction(function(tx) {
        var rs = tx.executeSql(sql);
        detail = [rs.rows.item(0).title,rs.rows.item(0).type,rs.rows.item(0).skid,rs.rows.item(0).ui]
    })
    return detail;
}

function getTrackedItems(type)
{
    var db = getDatabase();
    var respath="";
    var sql = "SELECT DISTINCT uid, title, type, skid, txt from tracked where type='" + type + "';";
    db.transaction(function(tx) {
        var rs = tx.executeSql(sql);
        for (var i = 0; i < rs.rows.length; i++) {
            root.fillTrackingModel(rs.rows.item(i).title,rs.rows.item(i).type,rs.rows.item(i).skid,rs.rows.item(i).uid)
            console.debug("get " + type + ": " + rs.rows.item(i).title + " with id:" + rs.rows.item(i).uid)
        }
    })
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
