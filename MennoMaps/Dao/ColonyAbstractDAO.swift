//
//  ColonyAbstractDAO.swift
//  MennoMaps
//
//  Created by João Dyck on 2017-12-11.
//  Copyright © 2017 João Dyck. All rights reserved.
//

import Foundation

protocol ColonyAbstractDAO : AbstractDAO{
    func findColony(byName name: String) -> ColonyModel!
    func saveColonies(withColoniesList list: [String:ColonyModel])
}

class ColonyDAOFactory {
    private static var sharedInstance: ColonyDAOFactory?
    
    private init(){
        
    }
    
    func buildColonyDAOInstance() -> ColonyAbstractDAO {
        var ret: ColonyAbstractDAO
        if(Reachability.isConnectedToNetwork()){
            ret = ColonyFirebaseDAO.shared()
        } else {
            ret = ColonySQLiteDAO.shared()
        }
        return ret
    }
    
    class func shared() -> ColonyDAOFactory! {
        if(sharedInstance == nil){
            sharedInstance = ColonyDAOFactory.init()
        }
        return sharedInstance
    }
}
