
//  MyWatchlistViewController.swift
//  MyWatchListApp
//
//  Created by may on 3/11/23.
//
import UIKit
import Combine

class MyWatchlistViewController: UIViewController {

	private let viewModel = MyWatchlistViewViewModel()
	private var subscriptions: Set<AnyCancellable> = []
	
	private var itemsPerRow: CGFloat {
		let landscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
		return landscape ? 6 : 3
	}
	private let spacing: CGFloat = 10
	private lazy var resultsCollectionView: UICollectionView = {
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
		view.backgroundColor = .systemBackground
		
		view.addSubview(resultsCollectionView)
		
		bindViews()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		resultsCollectionView.frame = view.safeAreaLayoutGuide.layoutFrame
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		viewModel.retrievePlaylist(playlist_title: PlaylistTitle.Watched.rawValue)
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		resultsCollectionView.collectionViewLayout.invalidateLayout()
	}
	
	// MARK: - Private Methods
	
	private var playlists: [String: FilmPlaylist] = [:]
	private func bindViews(){
		viewModel.$films
			.sink { [weak self] playlists in
				self?.playlists = playlists
				self?.resultsCollectionView.reloadData()
			}
			.store(in: &subscriptions)
		
		
	}
	

}

extension MyWatchlistViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilmCollectionViewCell.identifier, for: indexPath) as? FilmCollectionViewCell,
			  let watchedList = playlists[PlaylistTitle.Watched.rawValue]?.films
		else {return UICollectionViewCell() }
		
		
		//watched
		cell.configure(with: watchedList[indexPath.row])
		return cell
	}
	

	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let watchedList = playlists[PlaylistTitle.Watched.rawValue]?.films else { return 0 }
		return watchedList.count
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		
//		let selected = viewModel.myListFilms[indexPath.row]
//		 
//		let vc = FilmDetailsViewController()
//		vc.configure(model: selected)
//		present(vc, animated: true)
		
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
	
		let totalSpacing = (itemsPerRow - 1) * spacing
		let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow
		let height = width + 50
		
		return CGSize(width: width, height: height)
	}
	

}


