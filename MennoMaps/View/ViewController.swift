//
//  ViewController.swift
//  MennoMaps
//
//  Created by João Dyck on 2017-12-02.
//  Copyright © 2017 João Dyck. All rights reserved.
//

import UIKit

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var village: VillageModel!
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}

class ViewController: UIViewController, DataLoadObserver, GMUClusterManagerDelegate,
    GMSMapViewDelegate, GMUClusterRendererDelegate {

    private var mapView: GMSMapView!
    private var kmlParser: GMUKMLParser!
    //private var renderer: GMUGeometryRenderer!
    private var villageDAO: VillageAbstractDAO!
    private var colonyDAO: ColonyAbstractDAO!
    private var clusterManager: GMUClusterManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 1)
        
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = mapView
        self.colonyDAO = ColonyDAOFactory.shared().buildColonyDAOInstance()
        self.villageDAO = VillageDAOFactory.shared().buildVillageDAOInstance()
        self.villageDAO.addObserver(observer: self)
        /* Assume that <Google-Maps-iOS-Utils/GMUGeometryRenderer.h> and
         <Google-Maps-iOS-Utils/GMUKMLParser.h> are in the bridging-header file.
 
         let path = Bundle.main.path(forResource: "file", ofType: "kml")
         let url = URL(fileURLWithPath: path!)
         kmlParser = GMUKMLParser(url: url)
         kmlParser.parse()
         
         renderer = GMUGeometryRenderer(map: mapView,
         geometries: kmlParser.placemarks,
         styles: kmlParser.styles)
         
         renderer.render()*/
    }

    func loadFinished(){
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        self.clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)
        renderer.delegate = self
        let villageList = villageDAO.listVillages()
        var lat = 0.0
        var lon = 0.0
        var totalVillage = 0.0
        for village in villageList!{
            /*let position = CLLocationCoordinate2D(latitude: village.latitude, longitude: village.longitude)
            let marker = GMSMarker(position: position)
            marker.title = village.name
            marker.snippet = village.getSnipet()
            marker.map = mapView
            let hueColor = CGFloat(village.hueColor / 1000)
            let color = UIColor.init(hue: hueColor, saturation: 1, brightness: 1, alpha: 0.5)
            marker.icon = GMSMarker.markerImage(with: color)*/
            lat = lat + village.latitude
            lon = lon + village.longitude
            totalVillage = totalVillage + 1
            let item =
                POIItem(position: CLLocationCoordinate2DMake(village.latitude, village.longitude), name: village.name)
            item.village = village
            self.clusterManager.add(item)
        }
        if(totalVillage != 0){
            lat = lat / totalVillage
            lon = lon / totalVillage
        }
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 1)
        mapView.camera = camera
        self.clusterManager.cluster()
        self.clusterManager.setDelegate(self, mapDelegate: self)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - GMUClusterManagerDelegate
    //clusterManager:(GMUClusterManager *)clusterManager didTapCluster:(id<GMUCluster>)cluster;
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
    
    // MARK: - GMUMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            let hueColor = CGFloat(poiItem.village.hueColor / 1000)
            let color = UIColor.init(hue: hueColor, saturation: 1, brightness: 1, alpha: 0.5)
            marker.icon = GMSMarker.markerImage(with: color)
            marker.title = poiItem.village.name
            marker.snippet = poiItem.village.getSnipet()
        }
        return false
    }

    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")
    }
    
    func renderer(_ renderer: GMUClusterRenderer,  willRenderMarker marker: GMSMarker) {
        if let poiItem = marker.userData as? POIItem {
            let hueColor = CGFloat(poiItem.village.hueColor / 1000)
            let color = UIColor.init(hue: hueColor, saturation: 1, brightness: 1, alpha: 0.5)
            marker.icon = GMSMarker.markerImage(with: color)
            marker.title = poiItem.village.name
            marker.snippet = poiItem.village.getSnipet()
        } /*else if let cluster = marker.userData as? GMUCluster {
            let totalItems = CGFloat(cluster.items.count)
            var avgColor = CGFloat(0.0)
            for clusterItem in cluster.items{
                let poiItem = clusterItem as! POIItem
                let itmColor = CGFloat(poiItem.village.hueColor)
                avgColor += itmColor
            }
            if totalItems != 0{
                avgColor = avgColor / totalItems
            }
            let color = UIColor.init(hue: avgColor, saturation: 1, brightness: 1, alpha: 0.5)
            marker.icon = GMSMarker.markerImage(with: color)
            marker.title = self.findColoniesCountries(cluster: cluster)
            marker.snippet = self.listColoniesNames(cluster: cluster)
        }*/
    }
    
    func findColoniesCountries(cluster: GMUCluster) -> String {
        var ret = ""
        var countriesNames = [String:String]()
        for clusterItem in cluster.items{
            let poiItem = clusterItem as! POIItem
            countriesNames[poiItem.village.country] = poiItem.name
        }
        for key in countriesNames.keys{
            if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: key) {
                // Country name was found
                ret += name
            } else {
                // Country name cannot be found
                ret += key
            }
            
            ret += ", "
        }
        return ret
    }
    
    func listColoniesNames(cluster: GMUCluster) -> String{
        var ret = ""
        for clusterItem in cluster.items{
            let poiItem = clusterItem as! POIItem
            ret += poiItem.village.name
            ret += ", "
        }
        return ret;
    }
}

