//
//  MainTabVC.swift
//  InstagramCopy
//
//  Created by Huot on 11/19/19.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        configureViewControllers()
        
        // check user validation
        checkLogin()
    }

    func configureViewControllers() {
        // home feed controller
        let feedVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        // search controller
        let searchVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchVC())
        // post controller
        let uploadPostVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: UploadPostVC())
        //notification controller
        let notificationVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationVC())
        // profile controller
        let userProfileVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // view controller to be added to tab bar controller
        viewControllers = [feedVC, searchVC, uploadPostVC, notificationVC, userProfileVC]
        
        tabBar.tintColor = .black
    }
    
    func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController:UIViewController = UIViewController()) -> UINavigationController {
        // contruct nav controller
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        
        return navController
    }
    
    func checkLogin() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async{
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
            }
        }else{
            print("User is login...")
        }
    }
}
