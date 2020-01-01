//
//  SecondViewController.swift
//  HW9-iOS
//
//  Created by apple on 2019/11/19.
//  Copyright © 2019 CSCI571. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Toast_Swift

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var SecVCDelegate: SecViewControllerDelegate?
    
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
      "partly-cloudy-day" : "weather-partly-cloudy",
      "" : "weather-sunny"
    ]
    var weekly_data:[[String: JSON]] = []
    var is_in_favList = false

    @IBOutlet weak var back_nav_bar: UINavigationItem!
    
    @IBAction func jump2twitter(_ sender: Any) {
        var url_string: String = "https://twitter.com/intent/tweet?text=The current temperature at "
        url_string += self.location!["city"]! + " is "
        url_string += String(Int(round(self.data!["currently"]["temperature"].doubleValue)))
        url_string += "°F. The weather conditions are "
        url_string += self.data!["currently"]["summary"].stringValue + ". #CSCI571WeatherSearch"
        //print(url_string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        guard let url = URL(string: url_string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBOutlet weak var add_N_delete: UIImageView!
    
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
        
        self.back_nav_bar.title = self.location?["city"]

        self.weather_city.text = self.location?["city"]
        if self.is_in_favList {
            self.add_N_delete.image = UIImage(named: "trash-can")
        }else{
            self.add_N_delete.image = UIImage(named: "plus-circle")
        }
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.tapped4Fav(_ :)))
        self.add_N_delete.addGestureRecognizer(gesture)
        
        let gesture2 = UITapGestureRecognizer(target: self, action:  #selector (self.jump2Details(_ :)))
        self.clickable_view.addGestureRecognizer(gesture2)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load_data()
        SwiftSpinner.hide()
    }
    
    @objc func tapped4Fav(_ sender:UITapGestureRecognizer){
        let local_storage = UserDefaults.standard
        if let c_indicator = self.data!["currently"].dictionary{}else{
            self.view.makeToast("An internal error occured. Not a valid city.")
            return
        }
        if self.is_in_favList {
            if var fav_data = local_storage.dictionary(forKey: "WeatherApp_UserDefaults"), let fav_array = local_storage.array(forKey: "WeatherApp_FavArray") {
                var arr = (fav_array as! [String])
                arr.remove(at: arr.firstIndex(of: self.location!["city"]!)!)
                fav_data.removeValue(forKey: self.location!["city"]!)
                local_storage.set(fav_data, forKey: "WeatherApp_UserDefaults")
                local_storage.set(arr, forKey: "WeatherApp_FavArray")
                self.add_N_delete.image = UIImage(named: "plus-circle")
                self.view.makeToast( self.location!["city"]! + " was removed from the Favorite List")
            }
        }else {
            if var fav_data = local_storage.dictionary(forKey: "WeatherApp_UserDefaults"), let fav_array = local_storage.array(forKey: "WeatherApp_FavArray") {
                var arr = (fav_array as! [String])
                arr.append(self.location!["city"]!)
                fav_data[self.location!["city"]!] = self.location
                local_storage.set(fav_data, forKey: "WeatherApp_UserDefaults")
                local_storage.set(arr, forKey: "WeatherApp_FavArray")
                self.add_N_delete.image = UIImage(named: "trash-can")
                self.view.makeToast( self.location!["city"]! + " was added to the Favorite List")
            }
        }
        self.is_in_favList = !self.is_in_favList
        self.SecVCDelegate?.SecVCSetNotUpdated(SecVC: self)
    }
    
    @objc func jump2Details(_ sender:UITapGestureRecognizer){
        if let c_indicator = self.data!["currently"].dictionary{}else{
            self.view.makeToast("An internal error occured. Not a valid city.")
            return
        }
        performSegue(withIdentifier: "detailsSec", sender: self)
    }
        
    func load_data() {
        if let tmp_weekly_data = self.data?["daily"]["data"]{
            self.weekly_data = []
            for i in 0..<tmp_weekly_data.count {
                let subJSON = tmp_weekly_data[i]
                self.weekly_data.append([
                    "time": subJSON["time"],
                    "icon": subJSON["icon"],
                    "sunrisetime": subJSON["sunriseTime"],
                    "sunsettime": subJSON["sunsetTime"]
                ])
            }
            
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.weekly_data.count)
        return self.weekly_data.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell: WeeklyTableCellTableViewCell = self.weekly_table.dequeueReusableCell(withIdentifier: "weekly_table_cell") as! WeeklyTableCellTableViewCell

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSec" {
            let DTC: DetailsTabBarController = segue.destination as! DetailsTabBarController
            DTC.data = self.data
            DTC.location = self.location
        }
    }

}

protocol SecViewControllerDelegate: class {
    
    func SecVCSetNotUpdated(SecVC: SecondViewController)
    
}
