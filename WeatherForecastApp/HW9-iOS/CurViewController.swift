//
//  CurViewController.swift
//  HW9-iOS
//
//  Created by apple on 2019/11/23.
//  Copyright © 2019 CSCI571. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift

class CurViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var data: JSON?
    var location: [String: String]?
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
       "partly-cloudy-day" : "weather-partly-cloudy"
     ]
    var weekly_data:[[String: JSON]] = []

    @IBOutlet weak var clickable_view: UIView!
    @IBOutlet weak var weather_img: UIImageView!
    @IBOutlet weak var weather_temp: UILabel!
    @IBOutlet weak var weather_summary: UILabel!
    @IBOutlet weak var weather_city: UILabel!


    @IBOutlet weak var property_humidity: UILabel!
    @IBOutlet weak var property_windSpeed: UILabel!
    @IBOutlet weak var property_visibility: UILabel!
    @IBOutlet weak var property_pressure: UILabel!

    @IBOutlet weak var weekly_table: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        weekly_table.delegate = self
        weekly_table.dataSource = self
        weekly_table.rowHeight = 55
        clickable_view.layer.borderWidth = 1
        clickable_view.layer.borderColor = UIColor.white.cgColor
        weekly_table.layer.borderWidth = 1
        weekly_table.layer.borderColor = UIColor.white.cgColor
        
        self.clear_data()
        self.load_data()
        
        let gesture2 = UITapGestureRecognizer(target: self, action:  #selector (self.jump2Details(_ :)))
        self.clickable_view.addGestureRecognizer(gesture2)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func jump2Details(_ sender:UITapGestureRecognizer){
        if let c_indicator = self.data!["currently"].dictionary{}else{
            self.view.makeToast("An internal error occured. Not a valid city.")
            return
        }
        performSegue(withIdentifier: "detailsCur", sender: self)
    }
    
    func clear_data(){
        self.weather_img.image = UIImage(named: "weather-sunny")
        self.weather_temp.text = "Loading..."
        self.weather_summary.text = "Loading..."
        self.weather_city.text = "Loading..."

        self.property_humidity.text = ""
        self.property_windSpeed.text = ""
        self.property_visibility.text = ""
        self.property_pressure.text = ""
        
        self.weekly_data = []
        self.weekly_table.reloadData()
    }
    
    func load_data() {
        if let tmp_weekly_data = self.data?["daily"]["data"] {
            self.weekly_data = []
            for i in 0...tmp_weekly_data.count-1 {
                let subJSON = tmp_weekly_data[i]
                self.weekly_data.append([
                    "time": subJSON["time"],
                    "icon": subJSON["icon"],
                    "sunrisetime": subJSON["sunriseTime"],
                    "sunsettime": subJSON["sunsetTime"]
                ])
            }
            self.loadCity()
            let current_data = self.data!["currently"]
            self.weather_img.image = UIImage(named: self.icon_dict[current_data["icon"].stringValue]!)
            self.weather_temp.text = String(Int(round(current_data["temperature"].doubleValue))) + "°F"
            self.weather_summary.text = current_data["summary"].stringValue

            self.property_humidity.text = String(round(current_data["humidity"].doubleValue * 1000)/10) + " %"
            self.property_windSpeed.text = String(round(current_data["windSpeed"].doubleValue * 100)/100) + " mph"
            self.property_visibility.text = String(round(current_data["visibility"].doubleValue * 100)/100) + " km"
            self.property_pressure.text = String(round(current_data["pressure"].doubleValue * 100)/100) + " mb"
            
            self.weekly_table.reloadData()
        }
    }
    
    func loadCity(){
        self.weather_city.text = self.location?["city"]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.weekly_data.count)
        return self.weekly_data.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell: WeeklyTableCellTableViewCell = self.weekly_table.dequeueReusableCell(withIdentifier: "weekly_table_cell_cur") as! WeeklyTableCellTableViewCell

        cell.time_label.text = self.convert_time_MDY(time: self.weekly_data[indexPath.row]["time"]?.doubleValue)
        cell.summary_label.image = UIImage(named: self.icon_dict[self.weekly_data[indexPath.row]["icon"]!.stringValue]!)
        cell.sunrise_time_label.text = self.convert_time_hs(time: self.weekly_data[indexPath.row]["sunrisetime"]?.doubleValue)
        cell.sunset_time_label.text = self.convert_time_hs(time: self.weekly_data[indexPath.row]["sunsettime"]?.doubleValue)
        return cell
    }
    
    func convert_time_MDY(time: Double?) -> String {
        if time == nil {
            return ""
        }
        let format = DateFormatter()
        format.dateFormat = "MM/dd/yyyy"
        return format.string(from: Date(timeIntervalSince1970: time!))
    }
    
    func convert_time_hs(time: Double?) -> String {
        if time == nil {
            return ""
        }
        let format = DateFormatter()
        format.dateFormat = "hh:mm"
        return format.string(from: Date(timeIntervalSince1970: time!))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsCur" {
            let DTC: DetailsTabBarController = segue.destination as! DetailsTabBarController
            DTC.data = self.data
            DTC.location = self.location
        }
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
