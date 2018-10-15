//
//  ViewController.swift
//  MennoMaps
//
//  Created by João Dyck on 2017-12-02.
//  Copyright © 2017 João Dyck. All rights reserved.
//

import UIKit
import MapKit

class VillageMKPointAnnotation: MKPointAnnotation{
    open var village: VillageModel!
}

class ViewController: UIViewController, MKMapViewDelegate, DataLoadObserver{
    
    @IBOutlet weak var mapView: MKMapView!
    private var villageDAO: VillageAbstractDAO!
    private var colonyDAO: ColonyAbstractDAO!
    private var selectedVillage: VillageModel!
    
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
            let annotation = VillageMKPointAnnotation()
            let location = CLLocationCoordinate2D(latitude: village.latitude,
                                                  longitude: village.longitude)
            annotation.coordinate = location
            annotation.title = village.name
            
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
        var title: String = ""
        var total = 0
        for annotation in memberAnnotations {
            let _customAnnotation = annotation as? VillageMKPointAnnotation
            title += _customAnnotation!.village.name
            total = total + 1
        }
        test.title = String(format: "Total Villages: %d", total)
        test.subtitle = ""
        return test
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let marker = annotation as? VillageMKPointAnnotation{
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: marker) as? MKMarkerAnnotationView
            if annotation is VillageMKPointAnnotation{
                let _customAnnotation = annotation as! VillageMKPointAnnotation
                let hueColor = CGFloat(_customAnnotation.village.hueColor / 1000)
                let color = UIColor.init(hue: hueColor, saturation: 1, brightness: 1, alpha: 0.5)
                annotationView!.clusteringIdentifier = "village"
                annotationView?.markerTintColor = color
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            return annotationView
        }else {
            return nil
        }
    }
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView){
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if view.annotation is VillageMKPointAnnotation{
            let annotation = view.annotation as? VillageMKPointAnnotation
            self.selectedVillage = annotation!.village
            performSegue(withIdentifier: "toVillageInfo", sender: self)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toVillageInfo") {
            if let vc = segue.destination as? VillageInfoViewController {
                vc.village = self.selectedVillage
            }
        }
    }
    
    @IBAction func backToViewController(_ segue: UIStoryboardSegue) {
    }
    
}
