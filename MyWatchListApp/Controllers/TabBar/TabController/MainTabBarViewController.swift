//
//  ViewController.swift
//
//
//  Created by may on 1/12/23.


import UIKit

// class is a tab bar
class MainTabBarViewController: UITabBarController {
	
	private let rootvc = [
		HomeViewController(),
		SearchViewController(),
		AddViewController(),
		MyWatchlistViewController(),
		ProfileViewController()
	]
	
	private lazy var tabs: [UINavigationController] = rootvc.map{ vc in
		return UINavigationController(rootViewController: vc)
	}
	
	private let tabImage = [
		"rectangle.and.hand.point.up.left.filled",
		"magnifyingglass",
		"plus.circle",
		"play.rectangle.on.rectangle",
		"person.crop.circle"
	]
	
	private let tabImage_selected = [
		"rectangle.and.hand.point.up.left.fill",
		"magnifyingglass.circle.fill",
		"plus.circle.fill",
		"play.rectangle.on.rectangle.fill",
		"person.crop.circle.fill"
	]
	
	private let tabTitles = [
		"Explore",
		"Search",
		"",
		"My Watchlist",
		"Profile"
	]
	
	
	
	

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set the tab bar appearance
		tabBar.layer.masksToBounds = true
		tabBar.isTranslucent = true
		tabBar.layer.cornerRadius = 50
		tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

		// Set the selected item tint color to white
		tabBar.tintColor = UIColor(named: "AccentColor")
		// Bring the tab bar to the front
		view.bringSubviewToFront(tabBar)



		
		for (index, tab) in tabs.enumerated() {
			tab.tabBarItem.image = UIImage(systemName: tabImage[index])
			if(tabImage_selected[index] != ""){
				tab.tabBarItem.selectedImage = UIImage(systemName: tabImage_selected[index])
			}
			tab.title = tabTitles[index]
			
		}
		
		setViewControllers(tabs, animated: true)
		
		
	}
	


}


