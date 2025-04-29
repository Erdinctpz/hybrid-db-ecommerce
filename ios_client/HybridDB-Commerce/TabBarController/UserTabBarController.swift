//
//  UserTabBarController.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 11.04.2025.
//

import UIKit

class UserTabBarController: UITabBarController {
    
    var userRole: Int = 0
    
    init(userRole: Int) {
        self.userRole = userRole
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
        
        configureTabs()
    }

    func configureTabs() {
        let homeVC = self.userRole == 0 ? CustomerViewController() : SupplierViewController()
        let profileVC = ProfileViewController()
        
        homeVC.tabBarItem.title = "Home"
        profileVC.tabBarItem.title = "Profile"
        
        homeVC.tabBarItem.image = UIImage(systemName: "house")
        profileVC.tabBarItem.image = UIImage(systemName: "person")
        
        homeVC.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
        profileVC.tabBarItem.selectedImage = UIImage(systemName: "person.fill")
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let profileNav = UINavigationController(rootViewController: profileVC)
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemRed
        
        appearance.stackedLayoutAppearance.normal.iconColor = .white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        tabBar.scrollEdgeAppearance = appearance
        tabBar.standardAppearance = appearance
        
        setViewControllers([homeNav, profileNav], animated: true)
    }

}
