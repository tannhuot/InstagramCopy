//
//  MainTabVC.swift
//  InstagramCopy
//
//  Created by Huot on 11/19/19.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate {
    //MARK: - Properties
    let dotView = UIView()
    var notificationIds = [String]()
    
    var dbRef: DatabaseReference?
    var notificationListener: DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        // configure view controller
        configureViewControllers()
        
        // configure notification dot
//        configureNotificationDot()
        
        // check user validation
        checkLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedIndex = 0
    }

    func configureViewControllers() {
        // observe notification
        observeNotification()
        
        // home feed controller
        let feedVC = constructNavController(unselectedImage: UIImage(named: "home_unselected")!, selectedImage: UIImage(named: "home_selected")!, rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // search controller
        let searchVC = constructNavController(unselectedImage: UIImage(named: "search_unselected")!, selectedImage: UIImage(named: "search_selected")!, rootViewController: SearchVC())
        
        // post controller ==> select ImageVC
//        let uploadPostVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: UploadPostVC())
        let selectImageVC = constructNavController(unselectedImage: UIImage(named: "plus_unselected")!, selectedImage: UIImage(named: "plus_unselected")!)
        
        //notification controller
        let notificationVC = constructNavController(unselectedImage: UIImage(named: "like_unselected")!, selectedImage: UIImage(named: "like_selected")!, rootViewController: NotificationVC())
        
        // profile controller
        let userProfileVC = constructNavController(unselectedImage: UIImage(named: "profile_unselected")!, selectedImage: UIImage(named: "profile_selected")!, rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // view controller to be added to tab bar controller
        viewControllers = [feedVC, searchVC, selectImageVC, notificationVC, userProfileVC]
        
        tabBar.tintColor = .black
    }
    
    func configureNotificationDot() {
        if UIDevice().userInterfaceIdiom == .phone {
            let tabBarHeight = tabBar.frame.height
            
            if UIScreen.main.nativeBounds.height >= 2436 {
                // configure dot fro iphone x
                dotView.frame = CGRect(x: view.frame.width/5*3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
            }else{
                // configure dot for other model
                dotView.frame = CGRect(x: view.frame.width/5*3, y: view.frame.height - 16, width: 6, height: 6)
            }
            
            // create dot
            dotView.center.x = (view.frame.width/5*3 + (view.frame.width/5)/2)
            dotView.backgroundColor = UIColor.rgb(red: 233, green: 30, blue: 99)
            dotView.layer.cornerRadius = dotView.frame.width/2
            self.view.addSubview(dotView)
            dotView.isHidden = true
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 2 {
            let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.navigationBar.tintColor = .black
            fullScreen(viewController: navController)
            present(navController, animated: true, completion: nil)
        }else if tabBarController.selectedIndex == 3 {
            self.tabBar.items![3].badgeValue = nil
        }
    }
    
    func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController:UIViewController = UIViewController()) -> UINavigationController {
        // contruct nav controller
        if let vc = rootViewController as? FeedVC {
            vc.logoutDelegate = self
        }
        
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
                fullScreen(viewController: navController)
                self.present(navController, animated: true, completion: nil)
            }
        }else{
            print("User is login...")
        }
    }
    
    func observeNotification() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.notificationIds.removeAll()

        dbRef = NOTIFICATION_REF.child(currentUid)
        if notificationListener == nil {
            notificationListener = dbRef!.observe(.childAdded) { (snapshot) in
                let notificationId = snapshot.key
                
                NOTIFICATION_REF.child(currentUid).child(notificationId).child("checked").observeSingleEvent(of: .value) { [self] (snapshot) in
                    guard let checked = snapshot.value as? Int else { return }
                    
                    if checked == 0 {
                        dotView.isHidden = false
                        notificationIds.append(notificationId)
                    }else{
                        dotView.isHidden = true
                    }
                    
                    if notificationIds.count > 0 {
                        self.tabBar.items![3].badgeValue = "\(notificationIds.count)"
                    }else{
                        self.tabBar.items![3].badgeValue = nil
                    }
                }
            }
        }
    }
}

extension MainTabVC: logoutDelegate {
    func didLogout() {
        if let req = notificationListener {
            dbRef!.removeObserver(withHandle: req)
            notificationListener = nil
        }
    }
}
