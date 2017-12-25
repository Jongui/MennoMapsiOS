//
//  VillageSQLiteDAO.swift
//  MennoMaps
//
//  Created by João Dyck on 2017-12-13.
//  Copyright © 2017 João Dyck. All rights reserved.
//

import Foundation
import SQLite3

class VillageSQLiteDAO: VillageAbstractDAO {
    
    var villageList = [Int:VillageModel]()
    private var fileURL: URL!
    var db: OpaquePointer?
    var dataLoadObserver: DataLoadObserver?
    
    private static var sharedInstance: VillageSQLiteDAO?
    
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
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Village (idVillage INTEGER PRIMARY KEY, name TEXT, colonyGroup TEXT, country TEXT, latitude NUMBER, longitude NUMBER, hueColor NUMBER, idColony NUMBER, source TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        } else {
            print("Table Village created")
        }
        
        self.loadAllObjects(snapshot: nil)
    }
    
    func listVillages() -> [VillageModel]! {
        return Array(villageList.values)
    }
    
    func findVillage(byIdVillage idVillage: Int) -> VillageModel! {
        return villageList[idVillage]
    }
    
    func addObserver(observer: Any!) {
        self.dataLoadObserver = observer as? DataLoadObserver
        if self.villageList.count > 0{
            self.dataLoadObserver?.loadFinished()
        }
    }
    func saveVillages(withVillageList list: [Int : VillageModel]) {
        var insertVillages = [Int : VillageModel]()
        var updateVillages = [Int : VillageModel]()
        for village in list.values {
            let vil = self.villageList[village.idVillage]
            if vil == nil {
                insertVillages[village.idVillage] = village
            } else {
                updateVillages[village.idVillage] = village
            }
        }
        self.insertVillages(list: insertVillages)
        self.updateVillages(list: updateVillages)
        
    }
    
    func insertVillages(list: [Int : VillageModel]){
        let insertStatementString = "INSERT INTO Village (idVillage, name, colonyGroup, country, latitude, longitude, hueColor, idColony, source) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
        
        let listValues = list.values
        for village in listValues{
            var insertStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(insertStatement, 1, Int32(village.idVillage))
                let name: NSString = village.name! as NSString
                sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
                let colonyGroup: NSString = village.colonyGroup! as NSString
                sqlite3_bind_text(insertStatement, 3, colonyGroup.utf8String, -1, nil)
                let country: NSString = village.country! as NSString
                sqlite3_bind_text(insertStatement, 4, country.utf8String, -1, nil)
                sqlite3_bind_double(insertStatement, 5, village.latitude)
                sqlite3_bind_double(insertStatement, 6, village.longitude)
                sqlite3_bind_double(insertStatement, 7, Double(village.hueColor))
                sqlite3_bind_int(insertStatement, 8, Int32(village.idColony))
                sqlite3_bind_text(insertStatement, 9, village.source, -1, nil)
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    
                } else {
                    
                }
            } else {
                
            }
            sqlite3_finalize(insertStatement)
        }
    }
    
    func updateVillages(list: [Int : VillageModel]){
        let updateStatementString = "UPDATE Village SET name = ?, colonyGroup = ?, country = ?, latitude = ?, longitude = ?, hueColor = ?, idColony = ?, source = ? WHERE idVillage = ?;"
        var updateStatement: OpaquePointer? = nil
        let listValues = list.values
        for village in listValues{
            if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
                let name: NSString = village.name! as NSString
                sqlite3_bind_text(updateStatement, 1, name.utf8String, -1, nil)
                let colonyGroup: NSString = village.colonyGroup! as NSString
                sqlite3_bind_text(updateStatement, 2, colonyGroup.utf8String, -1, nil)
                let country: NSString = village.country! as NSString
                sqlite3_bind_text(updateStatement, 3, country.utf8String, -1, nil)
                sqlite3_bind_double(updateStatement, 4, village.latitude)
                sqlite3_bind_double(updateStatement, 5, village.longitude)
                sqlite3_bind_double(updateStatement, 6, Double(village.hueColor))
                sqlite3_bind_int(updateStatement, 7, Int32(village.idColony))
                sqlite3_bind_text(updateStatement, 8, village.source, -1, nil)
                sqlite3_bind_int(updateStatement, 9, Int32(village.idVillage))
                
                //sqlite3_bind_double(insertStatement, 3, Double(colony.color))
                if sqlite3_step(updateStatement) == SQLITE_DONE {
                    
                } else {
                    
                }
            } else {
                
            }
            sqlite3_finalize(updateStatement)
        }
    }
    
    func loadAllObjects(snapshot: Any?) {
        let selectStatementString = "SELECT idVillage, name, colonyGroup, country, latitude, longitude, hueColor, idColony, source FROM Village"
        var selectStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, selectStatementString, -1, &selectStatement, nil) == SQLITE_OK{
            print("Query Result:")
            while (sqlite3_step(selectStatement) == SQLITE_ROW) {
                let village = VillageModel(withSQLRow: selectStatement)
                self.villageList[village.idVillage] = village
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        if self.dataLoadObserver != nil{
            self.dataLoadObserver?.loadFinished()
        }
    }
    
    class func shared() -> VillageSQLiteDAO! {
        if(sharedInstance == nil){
            sharedInstance = VillageSQLiteDAO.init()
        }
        return sharedInstance
    }
}
