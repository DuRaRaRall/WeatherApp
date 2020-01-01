//
//  DetailsTabBarController.swift
//  HW9-iOS
//
//  Created by apple on 2019/11/26.
//  Copyright © 2019 CSCI571. All rights reserved.
//

import UIKit
import SwiftyJSON

class DetailsTabBarController: UITabBarController {

    var data: JSON?
    var location: [String: String]?
    
    @IBAction func jump2Twitter(_ sender: Any) {
        var url_string: String = "https://twitter.com/intent/tweet?text=The current temperature at "
        url_string += self.location!["city"]! + " is "
        url_string += String(Int(round(self.data!["currently"]["temperature"].doubleValue)))
        url_string += "°F. The weather conditions are "
        url_string += self.data!["currently"]["summary"].stringValue + "."
        //print(url_string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        guard let url = URL(string: url_string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        UIApplication.shared.open(url)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = self.location!["city"]
        
        let TodayVC: TodayViewController = self.viewControllers![0] as! TodayViewController
        TodayVC.data = self.data
        let ChartsVC: ChartsViewController = self.viewControllers![1] as! ChartsViewController
        ChartsVC.data = self.data
        let PhotosVC: PhotosViewController = self.viewControllers![2] as! PhotosViewController
        PhotosVC.location = self.location
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
