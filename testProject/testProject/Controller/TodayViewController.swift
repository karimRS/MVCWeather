//
//  TodayViewController.swift
//  testProject
//
//  Created by Karim on 14/08/16.
//  Copyright © 2016 Karim. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SystemConfiguration

enum loadingContentXibIdentifier: String{
    case Normal = "LoadingContents"
}

class TodayViewController: UIViewController {
    
    var today: Today?
    let locationManager = CLLocationManager()
    var located = false
    
    var loadingView: UIView!
    var loadingImg: UIImageView!
    var hideView: UIView!


    var todayView: TodayView {
        return view as! TodayView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpAnimations()
        locationService()
    }
    
    override func viewDidAppear(animated: Bool) {
        //Check connection
        if isConnectedToNetwork() == false {
            
            self.loadingView.hidden = true
            self.loadingImg.layer.removeAllAnimations()
            self.loadingImg.transform = CGAffineTransformMakeRotation(CGFloat(0.0))
            self.showOKAlert("No internet access 🤕")
        }
        
        //Check permits
        if !checkPermission() {
            showSettingsAlert()
        }
    }
}

//MARK: LocationManager

extension TodayViewController: CLLocationManagerDelegate {
    
    func locationService(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count != 0 {
                let pm = placemarks![0] as CLPlacemark
                self.locationManager.stopUpdatingLocation()
                self.todayView.updateLocationsElements(pm.locality!, country: pm.country!)
                
                if self.located == false {
                    self.getJSON(pm.locality!)
                    self.located = true
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(pm.locality, forKey: "city")
                    defaults.setObject(locations[0].coordinate.latitude, forKey: "latitude")
                    defaults.setObject(locations[0].coordinate.longitude, forKey: "longitude")
                    
                }
                
            } else {
                print("Problem with the data received from geocoder")
                self.located = false
            }
        })
    }
}

//MARK: Request

extension TodayViewController {
    
    func getJSON(city :String){
        
        Alamofire.request(
            .GET,
            "http://api.openweathermap.org/data/2.5/weather",
            parameters: ["q": city, "units": "metric", "APPID":"22172aaeb2713aa034a86f9fb3149ce3"]).responseJSON{ response in
                
                switch response.result {
                case .Success(let data):
                    
                    let json = JSON(data)
                    self.today = self.parseTodayJSON(json)
                    self.todayView.updateTodayElements(self.today!)

                    
                    //Saving in usersdefaults
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(json["weather"][0]["main"].stringValue, forKey: "weather")
                    
                    self.stopAnimating()
                    
                case .Failure(let error):
                    //No answer from api
                    print("Request failed with error: \(error)")
                    
                    self.loadingView.hidden = true
                    self.loadingImg.layer.removeAllAnimations()
                    self.loadingImg.transform = CGAffineTransformMakeRotation(CGFloat(0.0))
                    self.showOKAlert("No connection with openweather api 🤕")
                    
                }
        }
        
    }
}

//MARK: Parser

extension TodayViewController {
    
    func parseTodayJSON(json: JSON) -> Today{
        
        let jsonWeather = json["weather"]
        let jsonMain = json["main"]
        let jsonWind = json["wind"]
        let jsonRain = json["rain"]
        let jsonClouds = json["clouds"]
        
        let temp = (jsonMain["temp"].stringValue as NSString).substringToIndex(2)
        let weather = temp + "º | " + jsonWeather[0]["main"].stringValue
        
        let rainProbability = jsonClouds["all"].stringValue + " %"
        
        var precipitation = ""
        if jsonRain["3h"] == nil {
            precipitation = "0.0 mm"
        }else{
            precipitation = jsonRain["3h"].stringValue + " mm"
        }
        
        let wind = jsonWind["speed"].stringValue + " km/h"
        let pressure = jsonMain["pressure"].stringValue + " hPa"
        let direction =  Today.degreesToDirection(jsonWind["deg"].doubleValue)
        let imageCode = jsonWeather[0]["icon"].stringValue
        
        return Today(rainProbability: rainProbability, precipitation: precipitation, pressure: pressure, wind: wind, direction: direction,
                     weather: weather, imageCode: imageCode)
        
    }
}

//MARK: Share

extension TodayViewController {

    @IBAction func shareAction(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var textToShare = "Today it´s "
        
        if let weather = defaults.stringForKey("weather") {
            textToShare = textToShare + weather + " in "
            
        }
        if let city = defaults.stringForKey("city") {
            textToShare = textToShare + city + "!"
        }
        
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        self.presentViewController(activityVC, animated: true, completion: nil)
        
    }
}

//MARK: Alerts

extension TodayViewController {
    
    func showOKAlert(message: String){
        let alertController = UIAlertController(title: "App", message: message, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            
        }
    }

    
    func showSettingsAlert() {
        let alertController = UIAlertController(title: "Location permits denied 😱", message: "", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "Later", style: .Cancel) { (action) in
            self.loadingView.hidden = true
            self.loadingImg.layer.removeAllAnimations()
            self.loadingImg.transform = CGAffineTransformMakeRotation(CGFloat(0.0))
            
        }
        
        let settingsAction = UIAlertAction(title: "Go to Settings", style: .Default) { (action) in
            
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            
        }
        alertController.addAction(OKAction)
        
        alertController.addAction(settingsAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }

    }
}

//MARK: Checks

extension TodayViewController {
   
    func checkPermission() -> Bool {
        
        return !(CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .Denied)
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    
}

//MARK: Animations

extension TodayViewController {
    
    func setUpAnimations(){
        
        let loadingContents = NSBundle.mainBundle().loadNibNamed(loadingContentXibIdentifier.Normal.rawValue, owner: self, options: nil)
        loadingView = loadingContents[0] as! UIView
        loadingImg = loadingView.subviews[0] as! UIImageView
        hideView = UIView()
        hideView.bounds = UIScreen.mainScreen().bounds
        hideView.backgroundColor = UIColor.whiteColor()
        hideView.center = view.center
        view.addSubview(hideView)
        startAnimating()
        loadingView.center = view.center
        self.view.addSubview(loadingView)
        
    }

    //MARK: Loading animation
    func startAnimating() {
        loadingView.hidden = false
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = 2.0
        rotateAnimation.repeatCount = 100.0
        loadingImg.layer.addAnimation(rotateAnimation, forKey: "transform.rotation")
        
    }
    
    func stopAnimating() {
        hideView.removeFromSuperview()
        loadingView.hidden = true
        loadingImg.layer.removeAllAnimations()
        loadingImg.transform = CGAffineTransformMakeRotation(CGFloat(0.0))
        
    }

}





