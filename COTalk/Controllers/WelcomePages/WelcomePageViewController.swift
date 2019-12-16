//
//  WelcomePageViewController.swift
//  COTalk
//
//  Created by BCS Media on 1/11/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import UIKit

class WelcomePageViewController: UIPageViewController,UIPageViewControllerDelegate {

    var pagecontroler = UIPageControl()
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController(vcname: "welcomeOne"),
                self.newColoredViewController(vcname: "welcomeTwo"),
                self.newColoredViewController(vcname: "welcomeThree")]//sellerinforvc
        
    }()
    
    //var pagessdelegate : CurrentViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        print("VIEW CONTROLLERS\(orderedViewControllers.count)")
        
        pagecontroler = UIPageControl.appearance()
        pagecontroler.pageIndicatorTintColor = UIColor.lightGray
        pagecontroler.currentPageIndicatorTintColor = UIColor.orange
        pagecontroler.backgroundColor = UIColor.clear
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    private func newColoredViewController(vcname: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(vcname)")
    }
    
    func shouldmovetoPage(pageindex:Int,currentindx:Int){
        
        
        
        if pageindex > currentindx{
            if pageindex <= orderedViewControllers.count{
                print("Moved forward to page Page Index:\(pageindex) Current Index\(currentindx)")
                setViewControllers([orderedViewControllers[pageindex]],
                                   direction: .forward,
                                   animated: true,
                                   completion: nil)
            }
        }else{
            print("Moved reverse to page Page Index:\(pageindex) Current Index\(currentindx)")
            setViewControllers([orderedViewControllers[pageindex]],
                               direction: .reverse,
                               animated: true,
                               completion: nil)
        }
        
    }
    
    
    func returnPrevVC(indx:Int)-> UIViewController{
        let prevVc = orderedViewControllers[indx]
        return prevVc
        
    }
    
    func updateVisibleVC(){
        orderedViewControllers.remove(at: 5)
    }
    
    func addLenderView(){
        orderedViewControllers.insert(self.newColoredViewController(vcname: "lenderinfovc"), at: 5)
    }
    
    func returnVCs()-> [UIViewController]{
        let prevVc = orderedViewControllers
        return prevVc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print(previousViewControllers.count)
        let pageContentViewController = pageViewController.viewControllers![previousViewControllers.count - 1]
        self.pagecontroler.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!
    }
    
    
}

extension WelcomePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
       /* if nextIndex == orderedViewControllers.count{
            let vc = orderedViewControllers[nextIndex - 1] as! RepContractTableViewController
            vc.pagesdelegate = self
        }*/
        
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    
    
    
}

