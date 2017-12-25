//
//  ColonySQLiteDAO.swift
//  MennoMaps
//
//  Created by João Dyck on 2017-12-11.
//  Copyright © 2017 João Dyck. All rights reserved.
//

import Foundation
import SQLite3

class ColonySQLiteDAO: ColonyAbstractDAO {
    
    private static var sharedInstance: ColonySQLiteDAO?
    private var fileURL: URL!
    var db: OpaquePointer?
    var colonies = [String:ColonyModel]()
    
    init(){
        //the database file
        self.fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("MennoMapsDatabase.sqlite")
        
        //opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        /*if sqlite3_exec(db, "DROP TABLE IF EXISTS Colony", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error deleting table: \(errmsg)")
        }*/
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Colony (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, color INT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        self.loadAllObjects(snapshot: nil)
    }
    
    func saveColonies(withColoniesList list: [String:ColonyModel]) {
        var insertColonies = [String:ColonyModel]()
        var updateColonies = [String:ColonyModel]()
        for colony in list.values{
            let col = colonies[colony.name]
            if col == nil{
                insertColonies[colony.name] = colony
            } else {
                updateColonies[colony.name] = colony
            }
        }
        self.insertColonies(list: insertColonies)
        self.updateColonies(list: updateColonies)
    }

    func insertColonies(list: [String:ColonyModel]){
        let insertStatementString = "INSERT INTO Colony (id, name, color) VALUES (?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        for colony in list.values{
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(insertStatement, 1, colony.idColony)
                sqlite3_bind_text(insertStatement, 2, colony.name, -1, nil)
                sqlite3_bind_double(insertStatement, 3, Double(colony.color))
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    
                } else {
                    
                }
            } else {
                print("INSERT statement could not be prepared.")
            }
            sqlite3_finalize(insertStatement)
        }
    }
    
    func updateColonies(list: [String:ColonyModel]){
        let updateStatementString = "UPDATE Colony SET id = ?, name = ?, color = ? WHERE id = ?;"
        var updateStatement: OpaquePointer? = nil
        for colony in list.values{
            if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(updateStatement, 1, colony.idColony)
                sqlite3_bind_text(updateStatement, 2, colony.name, -1, nil)
                sqlite3_bind_double(updateStatement, 3, Double(colony.color))
                sqlite3_bind_int(updateStatement, 4, colony.idColony)
                if sqlite3_step(updateStatement) == SQLITE_DONE {
                    
                } else {
                    
                }
            } else {
                print("UPDATE statement could not be prepared.")
            }
            sqlite3_finalize(updateStatement)
        }
    }
    
    func findColony(byName name: String) -> ColonyModel! {
        return self.colonies[name]
    }
    
    func loadAllObjects(snapshot: Any?) {
        let selectStatementString = "SELECT * FROM Colony"
        var selectStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK{
            print("Query Result:")
            while (sqlite3_step(selectStatement) == SQLITE_ROW) {
                let colony = ColonyModel.init(withSQLRow: selectStatement)
                self.colonies[colony.name] = colony
            }
        } else {
            print("SELECT statement could not be prepared")
        }
    }
    
    class func shared() -> ColonySQLiteDAO! {
        if(sharedInstance == nil){
            sharedInstance = ColonySQLiteDAO.init()
        }
        return sharedInstance
    }
}
