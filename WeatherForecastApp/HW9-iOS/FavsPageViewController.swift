//
//  FavsPageViewController.swift
//  HW9-iOS
//
//  Created by apple on 2019/11/20.
//  Copyright © 2019 CSCI571. All rights reserved.
//

import UIKit
import SwiftyJSON
class FavsPageViewController: UIPageViewController {

    weak var FavPVCDelegate: FavPageViewControllerDelegate?
    
    var favVCList: [FavViewController] = []
    var curVC: CurViewController!
    public var cur_weather_data: JSON?
    public var fav_weather_data: [String: JSON] = [:]
    public var fav_weather_array: [String]?
    public var cur_city: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dataSource = self
        self.delegate = self
        
        let cvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Cur_viewController") as! CurViewController
        self.curVC = cvc
    
    }
    
    func loadCurrentVC(_ index: Int){
        self.curVC.data = cur_weather_data!
        if curVC.isViewLoaded {
            self.curVC.load_data()
        }
        if index == 0{
            setViewControllers([self.curVC], direction: .forward, animated: false, completion: nil)
        }
    }
    
    func loadCity(){
        self.curVC.location = ["city": self.cur_city]
        if curVC.isViewLoaded {
            self.curVC.loadCity()
        }
        
    }
    
    func loadFavVCs(_ index: Int){
        var tmpVCList: [FavViewController] = []
        for city: String in self.fav_weather_array ?? [] {
            let itemJSON = self.fav_weather_data[city]
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Fav_viewController") as! FavViewController
            vc.location = ["city": city]
            vc.data = itemJSON
            if vc.isViewLoaded {
                vc.load_data()
            }
            vc.FavVCDelegate = self
            tmpVCList.append(vc)
        }
        self.favVCList = tmpVCList
        self.FavPVCDelegate?.FavPVSetCount(favsPVC: self, didUpdatePageCount: self.fav_weather_data.count + 1)
        if index > 0 {
            if index-1 < self.favVCList.count{
                setViewControllers([self.favVCList[index-1]], direction: .forward, animated: false, completion: nil)
            }else {
                if self.favVCList.count == 0{
                    setViewControllers([self.curVC], direction: .forward, animated: false, completion: nil)
                    self.FavPVCDelegate?.FavPVSetIndex(favsPVC: self, didUpdatePageIndex: 0)
                } else {
                    setViewControllers([self.favVCList[self.favVCList.count-1]], direction: .forward, animated: false, completion: nil)
                    self.FavPVCDelegate?.FavPVSetIndex(favsPVC: self, didUpdatePageIndex: self.favVCList.count)
                }
            }
        }
    }
    
    func clearCurrentView() {
        if let firstViewController = viewControllers?.first{
            if firstViewController == self.curVC {
                self.curVC.clear_data()
            }else if let index = self.favVCList.firstIndex(of: firstViewController as! FavViewController){
                self.favVCList[index].clear_data()
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

extension FavsPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if self.curVC == viewController{
            return nil
        }
        guard let viewControllerIndex = self.favVCList.firstIndex(of: viewController as! FavViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            if previousIndex == -1 {
                return self.curVC
            }
            return nil
        }
        
        guard self.favVCList.count > previousIndex else {
            return nil
        }
        
        
        return self.favVCList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if self.curVC == viewController{
            if self.favVCList.count == 0{
                return nil
            }else {
                return self.favVCList[0]
            }
        }
        guard let viewControllerIndex = self.favVCList.firstIndex(of: viewController as! FavViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = self.favVCList.count
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return self.favVCList[nextIndex]
    }
    

}

extension FavsPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first{
            if firstViewController == self.curVC {
                FavPVCDelegate?.FavPVSetIndex(favsPVC: self,
                didUpdatePageIndex: 0)
            }else if let index = self.favVCList.firstIndex(of: firstViewController as! FavViewController){
                FavPVCDelegate?.FavPVSetIndex(favsPVC: self,
                didUpdatePageIndex: index+1)
            }
        }
    }
}

protocol FavPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func FavPVSetCount(favsPVC: FavsPageViewController,
        didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func FavPVSetIndex(favsPVC: FavsPageViewController,
        didUpdatePageIndex index: Int)
    
    func FavVC2FavPVCUpdate(favsPVC: FavsPageViewController)
    
}
extension FavsPageViewController: FavViewControllerDelegate {
    func FavVCUpdate(FavVC: FavViewController, city: String) {
        FavPVCDelegate?.FavVC2FavPVCUpdate(favsPVC: self)
        self.view.makeToast( city + " was removed from the Favorite List")
    }
}
