//
//  ChartsViewController.swift
//  HW9-iOS
//
//  Created by apple on 2019/11/26.
//  Copyright © 2019 CSCI571. All rights reserved.
//

import UIKit
import SwiftyJSON
import Charts

class ChartsViewController: UIViewController {

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
    
    @IBOutlet weak var weather_view: UIView!
    @IBOutlet weak var weather_icon: UIImageView!
    @IBOutlet weak var weather_summary: UILabel!
    
    @IBOutlet weak var weather_line_chart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        weather_view.layer.borderWidth = 1
        weather_view.layer.borderColor = UIColor.white.cgColor
        
        let daily_data = self.data!["daily"]
        let daily_line_datasource = daily_data["data"]
        
        self.weather_icon.image = UIImage(named: self.icon_dict[daily_data["icon"].stringValue]!)
        self.weather_summary.text = daily_data["summary"].stringValue
        self.weather_summary.numberOfLines = 5
        print(daily_data["summary"].stringValue)
        
        var lineChartEntryMaxTemp = [ChartDataEntry]()
        var lineChartEntryMinTemp = [ChartDataEntry]()
        let c_count = daily_line_datasource.count
        for i in 0...c_count-1 {
            let value = ChartDataEntry(x: Double(i), y: daily_line_datasource[i]["temperatureHigh"].doubleValue)
            lineChartEntryMaxTemp.append(value)
            let value2 = ChartDataEntry(x: Double(i), y: daily_line_datasource[i]["temperatureLow"].doubleValue)
            lineChartEntryMinTemp.append(value2)
        }
        let lineMaxTemp = LineChartDataSet( entries: lineChartEntryMaxTemp, label: "Maximum Temperature(°F)")
        lineMaxTemp.colors = [UIColor.orange]
        lineMaxTemp.circleRadius = 5
        lineMaxTemp.circleColors = [UIColor.orange]
        lineMaxTemp.circleHoleColor = UIColor.orange
        let lineMinTemp = LineChartDataSet( entries: lineChartEntryMinTemp, label: "Minimum Temperature(°F)")
        lineMinTemp.colors = [UIColor.white]
        lineMinTemp.circleRadius = 5
        lineMinTemp.circleColors = [UIColor.white]
        lineMinTemp.circleHoleColor = UIColor.white

        
        let datasource = LineChartData()
        datasource.addDataSet(lineMinTemp)
        datasource.addDataSet(lineMaxTemp)

        self.weather_line_chart.data = datasource
        self.weather_line_chart.backgroundColor = UIColor(red: 231/255.0, green: 231/255.0, blue: 231/255.0, alpha: 0.5)
        
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
