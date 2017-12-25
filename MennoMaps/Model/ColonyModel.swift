//
//  ColonyModel.swift
//  MennoMaps
//
//  Created by João Dyck on 2017-12-08.
//  Copyright © 2017 João Dyck. All rights reserved.
//

import Foundation
import Firebase
import SQLite3

class ColonyModel : AbstractModel {
    var idColony: Int32!
    var name: String!
    var color: Float!
    
    init(withName name: String){
        self.name = name
    }
    
    init(withDataSnapshot child: DataSnapshot){
        let colonyObject = child.value as? [String: AnyObject]
        let idString = child.key
        print(idString)
        self.name = child.key
        self.color = colonyObject?["color"] as? Float
    }
    
    init(withSQLRow selectStatement: OpaquePointer?){
        self.idColony = sqlite3_column_int(selectStatement, 0)
        
        let queryResultCol1 = sqlite3_column_text(selectStatement, 1)
        self.name = String(cString: queryResultCol1!)
        
        let queryResultCol2 = sqlite3_column_double(selectStatement, 2)
        self.color = Float(queryResultCol2)
        
    }
}
