//
//  Today.swift
//  testProject
//
//  Created by Karim on 14/08/16.
//  Copyright © 2016 Karim. All rights reserved.
//

import Foundation

class Today {
    
    private(set) var rainProbability: String
    private(set) var precipitation: String
    private(set) var pressure: String
    private(set) var wind: String
    private(set) var direction: String
    private(set) var weather: String
    private(set) var imageCode: String

    init() {
        self.rainProbability = ""
        self.precipitation = ""
        self.pressure = ""
        self.wind = ""
        self.direction = ""
        self.weather = ""
        self.imageCode = ""
    }
    
    init(rainProbability: String, precipitation: String, pressure: String, wind: String, direction: String,
         weather: String, imageCode: String) {
        self.rainProbability = rainProbability
        self.precipitation = precipitation
        self.pressure = pressure
        self.wind = wind
        self.direction = direction
        self.weather = weather
        self.imageCode = imageCode
    }
    
    class func codeToImage(code: String) -> String {
        
        switch code {
            
        case "02d","03d","02n","03n":
            return imageIdentifier.Cloudy.rawValue
        case "04d","09d","10d","11d","04n","09n","10n","11n":
            return imageIdentifier.Lightning.rawValue
        case "01d","01n":
            return imageIdentifier.Sun.rawValue
        case "13d","50d","13n","50n":
            return imageIdentifier.Wind.rawValue
            
        default:
            return imageIdentifier.Sun.rawValue
        }
    }
    
   class func degreesToDirection(degress :Double) -> String {
        
        switch degress {
        case 0...33.75:
            return directionIdentifier.N.rawValue
        case 33.75...78.75:
            return directionIdentifier.NE.rawValue
        case 78.75...123.75:
            return directionIdentifier.E.rawValue
        case 123.25...168.75:
            return directionIdentifier.SE.rawValue
        case 168.75...213.75:
            return directionIdentifier.S.rawValue
        case 213.75...258.75:
            return directionIdentifier.SW.rawValue
        case 258.75...303.75:
            return directionIdentifier.W.rawValue
        case 303.75...348.75:
            return directionIdentifier.NW.rawValue
        default:
            return directionIdentifier.N.rawValue
        }
    }

    enum directionIdentifier: String {
        case N = "N"
        case NE = "NE"
        case E = "E"
        case SE = "SE"
        case S = "S"
        case SW = "SW"
        case W = "W"
        case NW = "NW"
    }
    
    enum imageIdentifier: String {
        case Sun = "Sun_Big"
        case Wind = "WInd_Big"
        case Lightning = "Lightning_Big"
        case Cloudy = "Cloudy_Big"
    }
}


