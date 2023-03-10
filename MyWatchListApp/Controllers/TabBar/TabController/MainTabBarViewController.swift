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
		MyWatchlistViewController()
	]
	
	private lazy var tabs: [UINavigationController] = rootvc.map{ vc in
		return UINavigationController(rootViewController: vc)
	}
	
	private let tabImage = [
		"house",
		"magnifyingglass",
		"play.rectangle.on.rectangle",
	]
	
	private let tabImage_selected = [
		"house.fill",
		"",
		"play.rectangle.on.rectangle.fill",
	]
	
	private let tabTitles = [
		"Explore",
		"Search",
		"My Watchlist"
	]
	
	

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		tabBar.tintColor = .label
		tabBar.layer.zPosition = 99
		
		
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


