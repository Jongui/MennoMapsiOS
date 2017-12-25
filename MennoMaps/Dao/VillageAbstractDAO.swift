//
//  VillageAbstractDAO.swift
//  MennoMaps
//
//  Created by João Dyck on 2017-12-13.
//  Copyright © 2017 João Dyck. All rights reserved.
//

import Foundation

protocol VillageAbstractDAO : AbstractDAO{
    func listVillages() -> [VillageModel]!
    func findVillage(byIdVillage idVillage: Int) -> VillageModel!
    func saveVillages(withVillageList list: [Int:VillageModel])
    func addObserver(observer: Any!)
}

class VillageDAOFactory {
    private static var sharedInstance: VillageDAOFactory?
    
    private init(){
        
    }
    
    func buildVillageDAOInstance() -> VillageAbstractDAO {
        var ret: VillageAbstractDAO
        if(Reachability.isConnectedToNetwork()){
            ret = VillageFirebaseDAO.shared()
        } else {
            ret = VillageSQLiteDAO.shared()
        }
        return ret
    }
    
    class func shared() -> VillageDAOFactory! {
        if(sharedInstance == nil){
            sharedInstance = VillageDAOFactory.init()
        }
        return sharedInstance
    }
}
