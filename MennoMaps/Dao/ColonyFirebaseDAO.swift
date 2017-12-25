//
//  ColonyDAO.swift
//  MennoMaps
//
//  Created by João Dyck on 2017-12-08.
//  Copyright © 2017 João Dyck. All rights reserved.
//

import Foundation
import Firebase

class ColonyFirebaseDAO: ColonyAbstractDAO {
    
    var ref: DatabaseReference!
    var firebaseObserver: DataLoadObserver?
    var currentColor: Float=0
    
    private static var sharedInstance: ColonyFirebaseDAO?
    static var id: Int32 = 1
    var colonies = [String:ColonyModel]()
    
    private init(){
        ref = Database.database().reference().child("prd/Colony")
        ref.observe(.value) { snapshot in
            self.loadAllObjects(snapshot: snapshot)
        }
    }
    
    func findColony(byName name: String) -> ColonyModel!{
        var ret: ColonyModel?
        let saveName: String
        if (name.isEmpty){
            saveName = "No name"
        } else {
            saveName = name
        }
        let firebaseName = saveName.replacingOccurrences(of: ".", with: "")
        
        ret = colonies[firebaseName]
        if(ret == nil){
            ret = ColonyModel(withName: firebaseName)
            ret?.color = self.findColor()
            ret?.idColony = ColonyFirebaseDAO.id
            ColonyFirebaseDAO.id = ColonyFirebaseDAO.id + 1
            colonies[firebaseName] = ret
        }
        return ret
    }
    
    private func findColor() -> Float!{
        currentColor = currentColor + 31
        if(currentColor > 360){
            currentColor = currentColor - 360
        }
        return currentColor
    }
    
    func loadAllObjects(snapshot: Any?) {
        
        for child in (snapshot as AnyObject).children.allObjects as! [DataSnapshot] {
            let colony = ColonyModel(withDataSnapshot: child)
            colony.idColony = ColonyFirebaseDAO.id
            colonies[colony.name] = colony
            ColonyFirebaseDAO.id = ColonyFirebaseDAO.id + 1
        }
        let sqliteDao = ColonySQLiteDAO.shared()
        sqliteDao?.saveColonies(withColoniesList: colonies)
        //sqliteDao.
        self.firebaseObserver?.loadFinished()
    }
    
    class func shared() -> ColonyFirebaseDAO! {
        if(sharedInstance == nil){
            sharedInstance = ColonyFirebaseDAO.init()
        }
        return sharedInstance
    }
    
    func saveColonies(withColoniesList list: [String:ColonyModel]) {
        
    }

    
}
