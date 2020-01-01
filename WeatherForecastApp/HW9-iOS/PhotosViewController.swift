//
//  PhotosViewController.swift
//  HW9-iOS
//
//  Created by apple on 2019/11/27.
//  Copyright © 2019 CSCI571. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class PhotosViewController: UIViewController {

    let server_url = "http://my-angular-weather-project.appspot.com"
    var location: [String: String]?
    
    @IBOutlet weak var photos_container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SwiftSpinner.show("Fetching Google Images...")
        let city = self.location!["city"]
        Alamofire.request(self.server_url+"/getSearchedImg", parameters: ["city_name": String(city!).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!]).responseJSON {
            response in
            switch response.result {
                case .success: do {
                    let ret = JSON(response.result.value!)
                    for i in 0...ret["items"].count-1 {
                        
                        if let str = ret["items"][i]["link"].string
                        {
                            let url = URL(string: str)
                            let img_data = try! Data(contentsOf: url!)
                            let searched_img = UIImageView(image:  UIImage(data: img_data))
                            searched_img.frame = CGRect(x: 0, y: i*600, width: 374, height: 600)
                            self.photos_container.addSubview(searched_img)
                        }
                        
                    }
                    SwiftSpinner.hide()
                    
                }
                case .failure(let error):
                    print(error)
            }
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
