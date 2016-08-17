//
//  Forecast.swift
//  testProject
//
//  Created by Karim on 14/08/16.
//  Copyright © 2016 Karim. All rights reserved.
//

import Foundation

class Forecast {
    
    private(set) var day: Int?
    private(set) var weather: String?
    private(set) var temperature: String?
    private(set) var imageCode: String?

    init(day: Int, weather: String, temperature: String, imageCode: String) {
        self.day = day
        self.weather = weather
        self.temperature = temperature
        self.imageCode = imageCode
    }
    
    class func codeToImage(code: String) -> String {
        
        switch code {
            
        case "02d","03d","02n","03n":
            return imageIdentifier.CloudSun.rawValue
        case "04d","09d","10d","11d","04n","09n","10n","11n":
            return imageIdentifier.CloudLight.rawValue
        case "01d","01n":
            return imageIdentifier.Sun.rawValue
        case "13d","50d","13n","50n":
            return imageIdentifier.Wind.rawValue
            
        default:
            return imageIdentifier.Sun.rawValue
        }
    }
    
    class func numberToDayName(number: Int) -> String {
        
        switch number {
        case 1:
            return dayName.Sunday.rawValue
        case 2:
            return dayName.Monday.rawValue
        case 3:
            return dayName.Tuesday.rawValue
        case 4:
            return dayName.Wednesday.rawValue
        case 5:
            return dayName.Thursday.rawValue
        case 6:
            return dayName.Friday.rawValue
        case 7:
            return dayName.Saturday.rawValue
        default:
            return dayName.Monday.rawValue
        }
    }
    
    enum imageIdentifier: String {
        case Sun = "Sun"
        case Wind = "Wind_for"
        case CloudSun = "CS"
        case CloudLight = "CL"
    }
    
    enum dayName: String {
        case Sunday = "Sunday"
        case Monday = "Monday"
        case Tuesday = "Tuesday"
        case Wednesday = "Wednesday"
        case Thursday = "Thursday"
        case Friday = "Friday"
        case Saturday = "Saturday"
    }
}

class Forecasts {
    private static let sharedInstance = Forecasts()
    private var forecasts = [Forecast]()
    
    class func countForecast() -> Int {
        return sharedInstance.forecasts.count
    }
    
    class func getForecastFromIndexPath(indexPath: NSIndexPath) -> Forecast? {
        if 0 > indexPath.row || indexPath.row > sharedInstance.forecasts.count {
            return nil
        }
        return sharedInstance.forecasts[indexPath.row]
    }
    
    class func addForecasts(forecast: Forecast) {
        sharedInstance.forecasts.append(forecast)
    }
    
    class func resetForecast() {
        sharedInstance.forecasts = [Forecast]()
    }
}
