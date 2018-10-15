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
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblColonyGroup: UILabel!
    @IBOutlet weak var lblLatitude: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let hueColor = CGFloat(self.village.hueColor / 1000)
        let color = UIColor.init(hue: hueColor, saturation: 1, brightness: 1, alpha: 0.5)
        headerView.backgroundColor = color
        var textColor = village.hueColor * 4 / 2;
        if textColor > 360 {
            textColor = textColor - 360
        }
        let labelColor = UIColor.init(hue: CGFloat(textColor), saturation: 1, brightness: 1, alpha: 0.5)
        lblName.text = village.name
        lblName.textColor = labelColor
        let locale = NSLocale.current
        let text = locale.localizedString(forRegionCode: village.country)
        lblCountry.text = text
        lblCountry.textColor = labelColor
        let fileName = village.country.lowercased() + ".png"
        let image = UIImage.init(named: fileName)
        imgFlag.image = image
        
        lblColonyGroup.text = village.colonyGroup
        lblLatitude.text = String(format:"%f", village.latitude)
        lblLongitude.text = String(format:"%f", village.longitude)
        
    }
    
}
