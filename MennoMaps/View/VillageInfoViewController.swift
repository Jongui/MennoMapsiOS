//
//  VillageInfoViewViewController.swift
//  MennoMaps
//
//  Created by João Dyck on 2018-10-15.
//  Copyright © 2018 João Dyck. All rights reserved.
//

import UIKit

class VillageInfoViewController: UIViewController {

    var village: VillageModel!
    @IBOutlet weak var lblColonyGroup: UILabel!
    @IBOutlet weak var lblLatitude: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtCountry: UILabel!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var txtColonyGroup: UILabel!
    @IBOutlet weak var txtLatitude: UILabel!
    @IBOutlet weak var txtLongitude: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildTxtFields()
        self.buildLabels()
        
    }
    
    private func buildTxtFields(){
        let hueColor = CGFloat(self.village.hueColor / 1000)
        let color = UIColor.init(hue: hueColor, saturation: 1, brightness: 1, alpha: 0.5)
        headerView.backgroundColor = color
        var textColor = village.hueColor * 4 / 2;
        if textColor > 360 {
            textColor = textColor - 360
        }
        let labelColor = UIColor.init(hue: CGFloat(textColor), saturation: 1, brightness: 1, alpha: 0.5)
        txtName.text = village.name
        txtName.textColor = labelColor
        let locale = NSLocale.current
        let text = locale.localizedString(forRegionCode: village.country)
        txtCountry.text = text
        txtCountry.textColor = labelColor
        let fileName = village.country.lowercased() + ".png"
        let image = UIImage.init(named: fileName)
        imgFlag.image = image
        
        let decimalFormatter = NumberFormatter()
        decimalFormatter.usesGroupingSeparator = true
        decimalFormatter.numberStyle = .decimal
        // localize to your grouping and decimal separator
        decimalFormatter.locale = Locale.current
        
        txtColonyGroup.text = village.colonyGroup
        txtLatitude.text = decimalFormatter.string(from: village.latitude as NSNumber)
        txtLongitude.text = decimalFormatter.string(from: village.longitude as NSNumber)
    }
    
    private func buildLabels(){
        lblColonyGroup.text = NSLocalizedString("lblColonyGroup", comment: "Colony Group")
        lblLongitude.text = NSLocalizedString("lblLongitude", comment: "Longitude")
        lblLatitude.text = NSLocalizedString("lblLatitude", comment: "Latitude")
        lblDescription.text = NSLocalizedString("lblDescription", comment: "Description")
    }
    
}
