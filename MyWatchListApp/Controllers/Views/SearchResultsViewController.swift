//
//  SearchResultsViewController.swift
//  MyWatchListApp
//
//  Created by may on 3/12/23.
//

import UIKit

protocol SearchResultsViewControllerDelagate: AnyObject {
	
}

class SearchResultsViewController: UIViewController {

	var films: [Film] = [Film]()
	
	weak var delegate: SearchResultsViewControllerDelagate?
	
	private var itemsPerRow: CGFloat {
		let landscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
		return landscape ? 6 : 3
	}
	private let spacing: CGFloat = 10
	public lazy var resultsCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = spacing
		layout.minimumLineSpacing = spacing
		
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.register(FilmCollectionViewCell.self, forCellWithReuseIdentifier: FilmCollectionViewCell.identifier)
		cv.dataSource = self
		cv.delegate = self
		
		return cv
	}()
	
	// MARK: - Main
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(resultsCollectionView)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		resultsCollectionView.frame = view.safeAreaLayoutGuide.layoutFrame
		
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		resultsCollectionView.collectionViewLayout.invalidateLayout()
	}
	

}

extension SearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilmCollectionViewCell.identifier, for: indexPath) as? FilmCollectionViewCell else {return UICollectionViewCell() }
		
		cell.configure(with: films[indexPath.row])
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return films.count
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
	
		let totalSpacing = (itemsPerRow - 1) * spacing
		let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow
		let height = width + 50
		
		return CGSize(width: width, height: height)
	}
	

}
