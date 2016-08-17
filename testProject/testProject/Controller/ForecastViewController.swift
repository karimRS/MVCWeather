//
//  ViewController.swift
//  testProject
//
//  Created by Karim on 14/08/16.
//  Copyright © 2016 Karim. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForecastViewController: UIViewController {

    var refreshControl:UIRefreshControl!
    var customImage: UIImageView!
    var timer: NSTimer!
    var customView: UIView!

    var forecastView: ForecastView {
        return view as! ForecastView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshActions()
        setupTableView()

        //Retrieve from userdefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey("city") {
            self.navigationItem.title = name
            getJSON(name)
        }
    }
}

extension ForecastViewController {
    
    private func setupTableView() {
        forecastView.tableView.delegate = self
        forecastView.tableView.dataSource = self
        forecastView.tableView.tableFooterView = UIView()
    }
}

//MARK: TableViewController
extension ForecastViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Forecasts.countForecast()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ForecastViewTableViewCellIdentifier.Normal.rawValue) as! ForecastTableViewCell
        cell.separatorInset.left = cell.dayLabel.frame.origin.x
        cell.selectionStyle = .None

        let forecast = Forecasts.getForecastFromIndexPath(indexPath)
        cell.updateCell(forecast)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
}

//MARK: Refresh

extension ForecastViewController {
    
    func refreshActions(){
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.clearColor()
        self.refreshControl.backgroundColor = UIColor.clearColor()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(ForecastViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        forecastView.tableView.addSubview(refreshControl)
        
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshContents", owner: self, options: nil)
        customView = refreshContents[0] as! UIView
        customView.frame = refreshControl.bounds
        customImage = customView.subviews[0] as! UIImageView
        refreshControl.addSubview(customView)
    }
    
    func refresh(sender: AnyObject) {
        
        refreshControl.beginRefreshing()
        animateRefresh()
        timerUp()
    }
    
    func animateRefresh() {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = 0.9
        rotateAnimation.repeatCount = 3.0
        self.customImage.layer.addAnimation(rotateAnimation, forKey: "transform.rotation")
        
    }
    
    func timerUp() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.55, target: self, selector: #selector(ForecastViewController.endOfWork), userInfo: nil, repeats: true)
    }
    
    func endOfWork() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey("city") {
            self.navigationItem.title = name
            getJSON(name)
        }
        timer.invalidate()
        timer = nil
    }


}
//MARK: Request

extension ForecastViewController {
    func getJSON(city :String){
        
        var lat = 0.0
        var lon = 0.0
        let defaults = NSUserDefaults.standardUserDefaults()
        if let latitude = defaults.stringForKey("latitude") ,
            let longitude = defaults.stringForKey("longitude"){
            lat = Double(latitude)!
            lon = Double(longitude)!
        }
        
        
        Alamofire.request(
            .GET,
            "http://api.openweathermap.org/data/2.5/forecast/daily",
            parameters: ["lat": lat, "lon": lon, "units": "metric", "cnt": 7, "APPID":"22172aaeb2713aa034a86f9fb3149ce3"]).responseJSON{ response in
                
                switch response.result {
                case .Success(let data):
                    let json = JSON(data)
                    self.parseJSON(json)
                    self.refreshControl.endRefreshing()
                    self.forecastView.tableView.reloadData()
                    
                case .Failure(let error):
                    //No answer from api
                    print("Request failed with error: \(error)")
                    
                    self.showOKAlert("No connection with openweather api 🤕")
                }
        }
    }

}

//MARK: Parser

extension ForecastViewController {
    
    func parseJSON(json: JSON) {
        
        let jsonList = json["list"]
        Forecasts.resetForecast()
        
        for index in 0...jsonList.count-1 {
            
            let temperature = (jsonList[index]["temp"]["day"].stringValue as NSString).substringToIndex(2) + "º"
            let weather = jsonList[index]["weather"][0]["main"].stringValue
            let imageCode = jsonList[index]["weather"][0]["icon"].stringValue
            
            let calendar = NSCalendar.currentCalendar()
            let date = NSDate().dateByAddingTimeInterval(60*60*24*Double(index))
            let components = calendar.components(.Weekday , fromDate: date)
            let day = components.weekday

            let forecast = Forecast(day: day, weather: weather, temperature: temperature, imageCode: imageCode)
            Forecasts.addForecasts(forecast)
        }
    }
}

//MARK: Alert

extension ForecastViewController {
    
    func showOKAlert(message: String){
        let alertController = UIAlertController(title: "App", message: message, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            
        }
    }
}
