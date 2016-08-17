//
//  ForecastTableViewCell.swift
//  testProject
//
//  Created by Karim on 14/08/16.
//  Copyright © 2016 Karim. All rights reserved.
//

import UIKit

let semiBoldFont = UIFont(name: "ProximaNova-Semibold", size: 18)
let lightFont = UIFont(name: "ProximaNova-Semibold", size: 30)
let regularFont = UIFont(name: "ProximaNova-Semibold", size: 18)

class ForecastTableViewCell: UITableViewCell {

    @IBOutlet var weatherImage: UIImageView!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dayLabel.font = semiBoldFont
        weatherLabel.font = regularFont
        temperatureLabel.font = lightFont
    }

    func updateCell(forecast: Forecast?) {
     
        if let forecast = forecast,
            let day = forecast.day,
            let weather = forecast.weather,
            let temperature = forecast.temperature,
            let imageCode = forecast.imageCode {
            
                dayLabel.text = Forecast.numberToDayName(day)
                weatherLabel.text = weather
                temperatureLabel.text = String(temperature)
                weatherImage.image = UIImage(named: Forecast.codeToImage(imageCode))
        }
        else {
            dayLabel.text = "Unknown"
            weatherLabel.text = "Unknown"
            temperatureLabel.text = "Unknown"
            weatherImage.image = nil
        }
    }
}

