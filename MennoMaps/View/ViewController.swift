//
//  ViewController.swift
//  MennoMaps
//
//  Created by João Dyck on 2017-12-02.
//  Copyright © 2017 João Dyck. All rights reserved.
//

import UIKit
import MapKit

class CustomMKPointAnnotation: MKPointAnnotation{
    open var village: VillageModel!
}

class ViewController: UIViewController, MKMapViewDelegate, DataLoadObserver{
    
    @IBOutlet weak var mapView: MKMapView!
    private var villageDAO: VillageAbstractDAO!
    private var colonyDAO: ColonyAbstractDAO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.colonyDAO = ColonyDAOFactory.shared().buildColonyDAOInstance()
        self.villageDAO = VillageDAOFactory.shared().buildVillageDAOInstance()
        self.villageDAO.addObserver(observer: self)
    }
    
    func loadFinished(){
        let villageList = villageDAO.listVillages()
        var lat = 0.0
        var lon = 0.0
        var totalVillage = 0.0
        for village in villageList!{
            lat = lat + village.latitude
            lon = lon + village.longitude
            totalVillage = totalVillage + 1
            let annotation = CustomMKPointAnnotation()
            let location = CLLocationCoordinate2D(latitude: village.latitude,
                                                  longitude: village.longitude)
            annotation.coordinate = location
            annotation.title = village.name
            annotation.subtitle = village.getSnipet()
            annotation.village = village
            mapView.addAnnotation(annotation)
        }
        if(totalVillage != 0){
            lat = lat / totalVillage
            lon = lon / totalVillage
        }
        
        let location = CLLocationCoordinate2D(latitude: lat,
                                              longitude: lon)
        
        
        let span = MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        let test = MKClusterAnnotation(memberAnnotations: memberAnnotations)
        /*var title: String = ""
        for annotation in memberAnnotations {
            let _customAnnotation = annotation as? CustomMKPointAnnotation
            title += _customAnnotation!.village.name
        }*/
        test.title = "Test"
        test.subtitle = nil
        
        return test
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as? MKMarkerAnnotationView
        if annotation is CustomMKPointAnnotation{
            let _customAnnotation = annotation as! CustomMKPointAnnotation
            let hueColor = CGFloat(_customAnnotation.village.hueColor / 1000)
            let color = UIColor.init(hue: hueColor, saturation: 1, brightness: 1, alpha: 0.5)
            annotationView!.clusteringIdentifier = "village"
            annotationView?.markerTintColor = color
        }
        return annotationView
    }
}
