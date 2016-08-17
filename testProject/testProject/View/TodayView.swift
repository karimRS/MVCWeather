//
//  TodayView.swift
//  testProject
//
//  Created by Karim on 15/08/16.
//  Copyright © 2016 Karim. All rights reserved.
//

import UIKit

let semiBoldLittleFont = UIFont(name: "ProximaNova-Semibold", size: 15)
let semiBoldBigFont = UIFont(name: "ProximaNova-Semibold", size: 19)
let RegularFont = UIFont(name: "ProximaNova-Regular", size: 25)

class TodayView: UIView {
    
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var precipitationLabel: UILabel!
    @IBOutlet var rainprobabilityLabel: UILabel!
    @IBOutlet var windLabel: UILabel!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var shareButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        cityNameLabel.font = semiBoldBigFont
        weatherLabel.font = regularFont
        pressureLabel.font = semiBoldLittleFont
        pressureLabel.adjustsFontSizeToFitWidth = true
        rainprobabilityLabel.font = semiBoldLittleFont
        precipitationLabel.font = semiBoldLittleFont
        windLabel.font = semiBoldLittleFont
        directionLabel.font = semiBoldLittleFont
        shareButton.titleLabel!.font = semiBoldBigFont
    }
    
    func updateTodayElements(today: Today){
        
        weatherLabel.text = today.weather
        pressureLabel.text = String(today.pressure)
        precipitationLabel.text = String(today.precipitation)
        windLabel.text = String(today.wind)
        rainprobabilityLabel.text = String(today.rainProbability)
        directionLabel.text = today.direction
        mainImage.image = UIImage(named: Today.codeToImage(today.imageCode))
    }
    
    func updateLocationsElements(locality: String, country: String) {
        
        cityNameLabel.text = locality + ", " + country
    }
}


