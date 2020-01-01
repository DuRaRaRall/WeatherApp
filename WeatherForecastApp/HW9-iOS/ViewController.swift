//
//  ViewController.swift
//  HW9-iOS
//
//  Created by apple on 2019/11/18.
//  Copyright © 2019 CSCI571. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON
import CoreLocation


class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    let server_url = "http://my-angular-weather-project.appspot.com"
    
    var loc_manager : CLLocationManager!
    var lat: Float = 0
    var lon: Float = 0
    var cur_city: String = ""
    var searched_city: String = ""
    var searched_lat: String = ""
    var searched_lon: String = ""
    var search_json: JSON = JSON("{}")
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var nav_item: UINavigationItem!
    @IBOutlet weak var c_searchbar: UISearchBar!
        
    @IBOutlet weak var searchBarTable: UITableView!
    
    @IBOutlet weak var c_page_control: UIPageControl!
    var embeddedPageViewController: FavsPageViewController!
    var search_result_list = [String]()
    
    var is_updated = false
    var is_first_visit = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Weather"
        
        loc_manager = CLLocationManager()
        loc_manager.delegate = self
        loc_manager.desiredAccuracy = kCLLocationAccuracyKilometer
        loc_manager.requestAlwaysAuthorization()
        //loc_manager.startUpdatingLocation()

        
        //searchbar
        c_searchbar.delegate = self
        self.nav_item.titleView =  self.c_searchbar
        
        //searchbar tableview
        searchBarTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        searchBarTable.delegate = self
        searchBarTable.dataSource = self
        
        c_page_control.currentPage = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBarTable.isHidden = true
        if self.is_updated == false{
            if self.is_first_visit{
                SwiftSpinner.show("Loading...")
                self.is_first_visit = false
            }
            self.updatePage()
            self.is_updated = true
        }
        
        print("will appear")
    }
    
    func updatePage(){
        self.getFavsAndLoadData()
        //request current location whenever the view appeared
        
        self.embeddedPageViewController.clearCurrentView()
        
        loc_manager.requestLocation()
        //print(loc_manager.location)
    }
    
    func getFavsAndLoadData(){
        // Get User Defaults
        let local_storage = UserDefaults.standard
        if let fav_data = local_storage.dictionary(forKey: "WeatherApp_UserDefaults"), let fav_array =  local_storage.array(forKey: "WeatherApp_FavArray") {
            if fav_array.count > 0 {
                var weather_data: [String: JSON] = [:]
                var my_count = 0
                for (city, value_dict) in fav_data {
                    let tmp_dict = value_dict as! [String: String]
                    // Request fav data with lat and lon
                    Alamofire.request(self.server_url+"/getWeather", parameters: ["lat": tmp_dict["lat"]!, "lon": tmp_dict["lon"]!]).responseJSON {
                        response in
                        switch response.result {
                            case .success: do {
                                //Gather fav weather to dictionary
                                print("success get fav weather")
                                let ret = JSON(response.result.value!)
                                weather_data[city] = ret
                            }
                            case .failure(let error):
                                print(error)
                        }
                        my_count += 1
                        if my_count == fav_data.count {
                            self.embeddedPageViewController.fav_weather_data = weather_data
                            self.embeddedPageViewController.fav_weather_array = (fav_array as! [String])
                            self.embeddedPageViewController.loadFavVCs( self.c_page_control.currentPage)
                            
                        }
                    }
                    
                }
                
            }else {
                self.embeddedPageViewController.fav_weather_data = [:]
                self.embeddedPageViewController.fav_weather_array = []
                self.embeddedPageViewController.loadFavVCs( self.c_page_control.currentPage)
                
            }
 
        }else{
//            var fav_data = ["Moscow": ["city": "Moscow", "state": "Moscow", "country": "Russia", "lat": "34.5", "lon": "-117.2"], "Russia": ["city": "Paris", "state": "Paris", "country": "France", "lat": "34.5", "lon": "-117.2"]]
            let fav_data: [String: [String: String]] = [:], fav_array: [String] = []
            local_storage.set(fav_data, forKey: "WeatherApp_UserDefaults")
            local_storage.set(fav_array, forKey: "WeatherApp_FavArray")
            self.embeddedPageViewController.fav_weather_data = [:]
            self.embeddedPageViewController.fav_weather_array = []
            self.embeddedPageViewController.loadFavVCs( self.c_page_control.currentPage)
        }
    }
    
    //current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Get current location
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        self.lat = Float(location.latitude)
        self.lon = Float(location.longitude)
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {
            (placemarks, error) -> Void in
            if error != nil{
                print("error in getting current city!")
            }else if let city = placemarks?.first?.locality {
                self.cur_city = city
                self.embeddedPageViewController.cur_city = self.cur_city
                self.embeddedPageViewController.loadCity()
                print(city)
            }
        })
        print("location= \(location.latitude), \(location.longitude)")
        //Use current location to get weather
        Alamofire.request(self.server_url+"/getWeather", parameters: ["lat": String(self.lat), "lon": String(self.lon)]).responseJSON {
            response in
            switch response.result {
                case .success: do {
                    //Pass current weather in current location to PageViewController
                    print("success get local weather")
                    let ret = JSON(response.result.value!)
                    self.embeddedPageViewController.cur_weather_data = ret

                    self.embeddedPageViewController.loadCurrentVC(self.c_page_control.currentPage)
                    SwiftSpinner.hide()

                }
                case .failure(let error):
                    print(error)
            }
        }
        return
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopUpdatingLocation()
            return
        }
    }
    
    //searchbar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count == 0) {
            self.searchBarTable.isHidden = true
            return
        }else{
            Alamofire.request(self.server_url+"/getAutoC", parameters: ["AutoC": searchText]).responseJSON {
                response in
                switch response.result {
                    case .success: do {
                        print("success get details")
                        let ret = JSON(response.result.value!)
//                        print(ret)
                        var search_result: [String] = []
                        if let pred_array = ret["predictions"].arrayObject {
                            for subJson:[String: AnyObject] in (pred_array as! [[String: AnyObject]]) {
                                let tmp_string: String = subJson["description"] as! String
                                search_result.append(tmp_string)
                            }
                        }
//                        print(search_result)
                        self.search_result_list = search_result
                        if(self.search_result_list.count > 0){
                            self.searchBarTable.isHidden = false
                            self.searchBarTable.reloadData()
                        }
                    }

                    case .failure(let error):
                        print(error)
                        self.searchBarTable.isHidden = true
                }
            }
            
        }
    }
    
    //searchbar tableview
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.search_result_list.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.searchBarTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!

        cell.textLabel?.text = self.search_result_list[indexPath.row]
        cell.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)

        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        SwiftSpinner.show("Fetching Weather Details for " + self.search_result_list[indexPath.row].split(separator: ",")[0] + "...")

        Alamofire.request(self.server_url+"/getLocFromCity", parameters: ["city_string": (self.search_result_list[indexPath.row]).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!]).responseJSON {
            response in
            switch response.result {
                case .success: do {
                    let ret1 = JSON(response.result.value!)
                    let lat = ret1["results"][0]["geometry"]["location"]["lat"].stringValue
                    let lon = ret1["results"][0]["geometry"]["location"]["lng"].stringValue
                    self.searched_lat = lat
                    self.searched_lon = lon
                    Alamofire.request(self.server_url+"/getWeather", parameters: ["lat": lat, "lon": lon]).responseJSON {
                        response in
                        switch response.result {
                            case .success: do {
                                print("success get searched weather")
                                let ret2 = JSON(response.result.value!)
                                self.search_json = ret2
                                self.segue_to(id: "segue2Searched")
                            }
                            case .failure(let error):
                                print(error)
                        }
                    }
                }
                case .failure(let error):
                    print(error)
            }
        }
        self.searched_city = self.search_result_list[indexPath.row]
        
//        if let path = Bundle.main.path(forResource: "sample_data_daily", ofType: "json") {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
//                self.search_json = try JSON(data: data)
//            } catch let error {
//                print("parse error: \(error.localizedDescription)")
//            }
//        } else {
//            print("Invalid filename/path.")
//        }

    }
    
    private func segue_to(id: String) {
        performSegue(withIdentifier: id, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue2Searched" {
            let SVC: SecondViewController = segue.destination as! SecondViewController
            SVC.SecVCDelegate = self
            SVC.data = self.search_json
            let loc_array = self.searched_city.split(separator: ",")
            SVC.location = [
                "city": String(loc_array[0]),
                "city_string": self.searched_city,
                "lat": self.searched_lat,
                "lon": self.searched_lon
            ]
            SVC.data = self.search_json
            let fav_data = UserDefaults.standard.dictionary(forKey: "WeatherApp_UserDefaults")
            if fav_data?[String(loc_array[0])] != nil {
                SVC.is_in_favList = true
            }else{
                SVC.is_in_favList = false
            }
            
        }else if segue.identifier == "pagecontrolsegue" {
            if let FavsPVC = segue.destination as? FavsPageViewController {
                FavsPVC.FavPVCDelegate = self
                self.embeddedPageViewController = FavsPVC
                print("show page")
            }
        }
    }
}

extension ViewController: FavPageViewControllerDelegate {
    func FavPVSetCount(favsPVC: FavsPageViewController, didUpdatePageCount count: Int) {
        self.c_page_control.numberOfPages = count
    }
    
    func FavPVSetIndex(favsPVC: FavsPageViewController, didUpdatePageIndex index: Int) {
        self.c_page_control.currentPage = index
    }
    
    func FavVC2FavPVCUpdate(favsPVC: FavsPageViewController) {
        self.updatePage()
    }
    
}

extension ViewController: SecViewControllerDelegate {
    func SecVCSetNotUpdated(SecVC: SecondViewController) {
        self.is_updated = false
    }
}
