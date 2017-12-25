//
//  Village.swift
//  MennoMaps
//
//  Created by João Dyck on 2017-12-02.
//  Copyright © 2017 João Dyck. All rights reserved.
//

import Foundation
import Firebase
import SQLite3

class VillageModel {
    var idVillage: Int!
    var name: String!
    var colonyGroup: String!
    var country: String!
    var uri: String!
    var latitude: Double!
    var longitude: Double!
    var hueColor: Float!
    var idColony: Int!
    var source: String!
    
    init(withChildNode child: DataSnapshot){
        let villageObject = child.value as? [String: AnyObject]
        self.name = villageObject?["Name"] as? String
        self.colonyGroup = villageObject?["Kolonie"] as? String
        self.country = villageObject?["Land"] as? String
        self.uri = villageObject?["Link"] as? String
        self.latitude = villageObject?["Latitude"] as? Double
        self.longitude = villageObject?["Longitude"] as? Double
        self.idVillage = Int(child.key)
        self.source = villageObject?["Source"] as? String
        let colony = ColonyDAOFactory.shared().buildColonyDAOInstance().findColony(byName: self.colonyGroup)
        self.hueColor = colony?.color
        self.idColony = Int(colony!.idColony)
    }
    
    init(withSQLRow selectStatement: OpaquePointer?){
        //idVillage INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, colonyGroup TEXT, country TEXT, latitude NUMBER, longitude NUMBER, hueColor NUMBER, idColony NUMBER, source TEXT
        self.idVillage = Int(sqlite3_column_int(selectStatement, 0))
        self.name = String(cString: sqlite3_column_text(selectStatement, 1))
        self.colonyGroup = String(cString: sqlite3_column_text(selectStatement, 2))
        self.country = String(cString: sqlite3_column_text(selectStatement, 3))
        self.latitude = Double(sqlite3_column_double(selectStatement, 4))
        self.longitude = Double(sqlite3_column_double(selectStatement, 5))
        self.hueColor = Float(sqlite3_column_double(selectStatement, 6))
        self.idColony = Int(sqlite3_column_int(selectStatement, 7))
        self.source = String(cString: sqlite3_column_text(selectStatement, 8))
    }
    
    func getSnipet() -> String {
        let snipet = "Kolonie: \(colonyGroup!) \nLatitude: \(latitude!) \nLongitude: \(longitude!) \nSource: \(source!)"
        return snipet
    }
    
}
