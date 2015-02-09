/*
 * Copyright (C) 2013, 2014, 2015 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Martin Borho <martin@borho.net>
 */
import QtQuick.LocalStorage 2.0
import QtQuick 2.3

Item {
    property var db: null

    function openDB() {
        if(db !== null) return;

        db = LocalStorage.openDatabaseSync("com.ubuntu.weather", "", "Default Ubuntu weather app", 100000);

        if (db.version === "") {
            db.changeVersion("", "0.1",
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Locations(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT, date TEXT)');
                    console.log('Database created');
                });
            // reopen database with new version number
            db = LocalStorage.openDatabaseSync("com.ubuntu.weather", "", "Default Ubuntu weather app", 100000);
        }

        if(db.version === "0.1") {
            db.changeVersion("0.1", "0.2",
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(key TEXT UNIQUE, value TEXT)');
                    console.log('Settings table added, Database upgraded to v0.2');
                });
            // reopen database with new version number
            db = LocalStorage.openDatabaseSync("com.ubuntu.weather", "", "Default Ubuntu weather app", 100000);
        }

        if(db.version === "0.2") {
            db.changeVersion("0.2", "0.3",
                function(tx) {
                    tx.executeSql('DELETE FROM Locations WHERE 1');
                    console.log('Removed old locations, Database upgraded to v0.3');
                });
        }

        if (!settings.migrated) {  // TODO: remove check once dropping table
            try {  // attempt to read the old settings
                var oldSettings = {};

                // Load old settings
                db.readTransaction( function(tx) {
                    var rs = tx.executeSql("SELECT * FROM settings")

                    for(var i = 0; i < rs.rows.length; i++) {
                        var row = rs.rows.item(i);
                        oldSettings[row.key] = row.value;
                    }
                });

                console.debug("Migrating old data:", JSON.stringify(oldSettings))

                // Move to new Settings API
                settings.migrated = true
                settings.precip_units = oldSettings["precip_units"]
                settings.service = oldSettings["service"]
                settings.units = oldSettings["units"]
                settings.wind_units = oldSettings["wind_units"]
            } catch (e) {  // likely table did not exist
                console.debug("No old data to migrate.")
                settings.migrated = true
            }
        }

        /*
          TODO: uncomment when reboot is ready to replace existing app
        db.transaction( function(tx) {
            tx.executeSql("DROP TABLE IF EXISTS settings")
        });
        */
    }

    function insertLocation(data) {
        openDB();
        var res;
        db.transaction( function(tx){
            var r = tx.executeSql('INSERT INTO Locations(data, date) VALUES(?, ?)', [JSON.stringify(data), new Date().getTime()]);
            res = r.insertId;
        });
        return res;
    }

    function updateLocation(dbId, data) {
        openDB();
        db.transaction( function(tx){
            var r = tx.executeSql('UPDATE Locations SET data = ?, date=? WHERE id = ?', [JSON.stringify(data), new Date().getTime(), dbId])
        });
    }

    function getLocations(callback) {
        openDB();
        db.readTransaction(
            function(tx){
                var locations = [];
                var rs = tx.executeSql('SELECT * FROM Locations');
                for(var i = 0; i < rs.rows.length; i++) {
                    var row = rs.rows.item(i),
                        locData = JSON.parse(row.data);
                    locData["updated"] = parseInt(row.date, 10);
                    locData["db"] = {id: row.id, updated: new Date(parseInt(row.date, 10))};
                    locations.push(locData);
                }
                callback(locations);
            }
        );
    }

    function clearLocation(location_id) {
        openDB();
        db.transaction(function(tx){
            tx.executeSql('DELETE FROM Locations WHERE id = ?', [location_id]);
        });
    }

    function clearDB() { // for dev purposes
        openDB();
        db.transaction(function(tx){
            tx.executeSql('DELETE FROM Locations WHERE 1');
        });
    }
}
