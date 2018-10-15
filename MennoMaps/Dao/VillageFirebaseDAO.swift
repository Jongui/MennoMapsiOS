//
//  VillageDAO.swift
//  MennoMaps
//
//  Created by João Dyck on 2017-12-06.
//  Copyright © 2017 João Dyck. All rights reserved.
//

import Foundation
import Firebase

class VillageFirebaseDAO: VillageAbstractDAO {
    
    var ref: DatabaseReference!
    var firebaseObserver: DataLoadObserver!
    private var finishObserveFirebase: Bool?
    
    private static var sharedInstance: VillageFirebaseDAO?
    var villageList = [Int:VillageModel]()
    
    private init(){
        ref = Database.database().reference().child("prd/Village")
        self.finishObserveFirebase = false
        ref.observe(.value) { snapshot in
            self.finishObserveFirebase = true
            self.loadAllObjects(snapshot: snapshot)
        }
    }
    
    func findVillage(byIdVillage idVillage: Int) -> VillageModel! {
        return villageList[idVillage]
    }
    
    func addObserver(observer: Any!) {
        firebaseObserver = observer as? DataLoadObserver
    }
    func saveVillages(withVillageList list: [Int : VillageModel]) {
        
    }
    
    func listVillages() -> [VillageModel]! {
        return Array(villageList.values)
    }
    
    func loadAllObjects(snapshot: Any?){
        if !finishObserveFirebase!{
          return
        }
        for child in (snapshot as AnyObject).children.allObjects as! [DataSnapshot] {
            let village = VillageModel(withChildNode: child)
            villageList[village.idVillage] = village
            
        }
        let sqliteDao = VillageSQLiteDAO.shared()
        sqliteDao?.saveVillages(withVillageList: villageList)
        if(self.firebaseObserver != nil){
            self.firebaseObserver.loadFinished()
        }
    }
    
    class func shared() -> VillageFirebaseDAO! {
        if(sharedInstance == nil){
            sharedInstance = VillageFirebaseDAO.init()
        }
        return sharedInstance
    }
}
