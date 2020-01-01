//
//  TodayViewController.swift
//  HW9-iOS
//
//  Created by apple on 2019/11/26.
//  Copyright © 2019 CSCI571. All rights reserved.
//

import UIKit
import SwiftyJSON

class TodayViewController: UIViewController {

    var data: JSON?
    let icon_dict: [String: String] = [
      "clear-day": "weather-sunny",
      "clear-night": "weather-night",
      "rain": "weather-rainy",
      "snow" : "weather-snowy",
      "sleet" : "weather-snowy-rainy",
      "wind" : "weather-windy-variant",
      "fog" : "weather-fog",
      "cloudy" : "weather-cloudy",
      "partly-cloudy-night" : "weather-night-partly-cloudy",
      "partly-cloudy-day" : "weather-partly-cloudy",
      "": "Loading..."
    ]
    
    @IBOutlet weak var WindSpeed_label: UILabel!
    @IBOutlet weak var Pressure_label: UILabel!
    @IBOutlet weak var Precipitation_label: UILabel!
    @IBOutlet weak var Temperature_label: UILabel!
    @IBOutlet weak var Icon_image: UIImageView!
    @IBOutlet weak var weather_icon_label: UILabel!
    @IBOutlet weak var Humidity_label: UILabel!
    @IBOutlet weak var Visibility_label: UILabel!
    @IBOutlet weak var ClouldCover_label: UILabel!
    @IBOutlet weak var Ozone_label: UILabel!
    
    @IBOutlet weak var windspeed_view: UIView!
    @IBOutlet weak var pressure_view: UIView!
    @IBOutlet weak var precipitation_view: UIView!
    @IBOutlet weak var temperature_view: UIView!
    @IBOutlet weak var icon_view: UIView!
    @IBOutlet weak var humidity_view: UIView!
    @IBOutlet weak var visibility_view: UIView!
    @IBOutlet weak var cloudCover_view: UIView!
    @IBOutlet weak var ozone_view: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        windspeed_view.layer.borderWidth = 1
        windspeed_view.layer.borderColor = UIColor.white.cgColor
        pressure_view.layer.borderWidth = 1
        pressure_view.layer.borderColor = UIColor.white.cgColor
        precipitation_view.layer.borderWidth = 1
        precipitation_view.layer.borderColor = UIColor.white.cgColor
        temperature_view.layer.borderWidth = 1
        temperature_view.layer.borderColor = UIColor.white.cgColor
        icon_view.layer.borderWidth = 1
        icon_view.layer.borderColor = UIColor.white.cgColor
        humidity_view.layer.borderWidth = 1
        humidity_view.layer.borderColor = UIColor.white.cgColor
        visibility_view.layer.borderWidth = 1
        visibility_view.layer.borderColor = UIColor.white.cgColor
        cloudCover_view.layer.borderWidth = 1
        cloudCover_view.layer.borderColor = UIColor.white.cgColor
        ozone_view.layer.borderWidth = 1
        ozone_view.layer.borderColor = UIColor.white.cgColor
        
        let current_data = self.data!["currently"]
        self.Icon_image.image = UIImage(named: self.icon_dict[current_data["icon"].stringValue]!)
        self.WindSpeed_label.text = String(round(current_data["windSpeed"].doubleValue * 100)/100) + " mph"
        self.Pressure_label.text = String(round(current_data["pressure"].doubleValue*10)/10) + " mb"
        self.Precipitation_label.text = String(round(current_data["precipIntensity"].doubleValue*10)/10) + " mmph"
        self.Temperature_label.text = String(round(current_data["temperature"].doubleValue)) + " °F"
        self.weather_icon_label.text = current_data["summary"].stringValue
        self.Humidity_label.text = String(round(current_data["humidity"].doubleValue * 1000)/10) + " %"
        self.Visibility_label.text = String(round(current_data["visibility"].doubleValue * 100)/100) + " km"
        self.ClouldCover_label.text = String(round(current_data["cloudCover"].doubleValue * 10000)/100) + " %"
        self.Ozone_label.text = String(round(current_data["ozone"].doubleValue * 10)/10) + " DU"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
