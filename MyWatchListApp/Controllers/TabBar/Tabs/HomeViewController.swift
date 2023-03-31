//
//  HomeViewController.swift
//  MyWatchListApp
//
//  Created by may on 3/11/23.
//

import UIKit
import FirebaseAuth
import Combine


class HomeViewController: UIViewController {

	private var viewModel = HomeViewViewModel()
	private var subscriptions: Set<AnyCancellable> = []
	
	private var films = Dictionary<Int, [Film]>()
	private var currentIndexPath: IndexPath = IndexPath(row: 0, section: 0)
	
	private let titleView: UIView = {
		let frame = CGRect(x: 0, y: 0, width: 200, height: 30)
		let v = UIView(frame: frame)
		v.backgroundColor = UIColor(named: "AccentColor")
		v.layer.cornerRadius = 5
		
		let titleLabel = UILabel(frame: frame)
		titleLabel.text = " My Watchlist App."
		titleLabel.font = .systemFont(ofSize: 20, weight: .heavy)
		titleLabel.textColor = .white
		titleLabel.clipsToBounds = true
		
		v.addSubview(titleLabel)
		
		return v
	}()
	
	private lazy var searchController: UISearchController = {
		let controller = UISearchController(searchResultsController: SearchResultsViewController())
		controller.searchBar.placeholder = "Search for Movies, TV, and People"
		controller.searchBar.searchBarStyle = .default
	
		controller.searchResultsUpdater = self
		controller.hidesNavigationBarDuringPresentation = false
		controller.searchBar.tintColor = UIColor(named: "AccentColor")
		return controller
	}()
	
	private let sectionBarView = SectionBarView()
	public let sectionHeader = [
		Section(title: "Upcoming Movies", icon: UIImage(systemName: "play.display")!),
		Section(title: "Popular Right Now!", icon:UIImage(systemName: "play.display")!),
		Section(title: "Top 5 TV Shows", icon: UIImage(systemName: "play.display")!),
		Section(title: "Top 5 Movies", icon: UIImage(systemName: "play.display")! ),
	]
	
	private lazy var homeViewHeader: UIView = {
		let header = UIView()
		header.addSubview(sectionBarView)
		header.clipsToBounds = true
		header.layer.masksToBounds = true
		NSLayoutConstraint.activate([
			
			sectionBarView.leadingAnchor.constraint(equalTo: header.leadingAnchor),
			sectionBarView.trailingAnchor.constraint(equalTo: header.trailingAnchor),
			sectionBarView.heightAnchor.constraint(equalToConstant: 50),
			sectionBarView.bottomAnchor.constraint(equalTo: header.bottomAnchor),
		])
		
		header.translatesAutoresizingMaskIntoConstraints = false
		return header
	}()
	
	
	
	private let tableViewCells: [TableViewCell] = [
		TableViewCell(cellType: UpcomingTableViewCell.self, reuseIdentifier: UpcomingTableViewCell.identifier),
		TableViewCell(cellType: PopularTableViewCell.self, reuseIdentifier: PopularTableViewCell.identifier),
		TableViewCell(cellType: TopFilmsTableViewCell.self, reuseIdentifier: TopFilmsTableViewCell.identifier),
		TableViewCell(cellType: TopFilmsTableViewCell.self, reuseIdentifier: TopFilmsTableViewCell.identifier),
	]
	

	
	private lazy var VCTable: UITableView = {
		let table = UITableView(frame: .zero, style: .grouped)
		
		for x in tableViewCells{
			table.register(x.cellType, forCellReuseIdentifier: x.reuseIdentifier)
		}
		
		table.delegate = self
		table.dataSource = self
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
	}()
	

	// MARK: - Main
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		
		navigationController?.hidesBarsOnSwipe = true
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bell.fill"), style: .plain, target: self, action: #selector(didTapBell))
		
		navigationItem.titleView = titleView
		navigationItem.searchController = searchController
		
		
		configureHeaderView()
		configureVCTable()
		
		applyConstraints()
	}
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		handleAuthentication()
	}
	
	// MARK: - Private Methods
	private func handleAuthentication(){
	
		if Auth.auth().currentUser == nil {
			let vc = UINavigationController(rootViewController: OnboardingViewController())
			vc.modalPresentationStyle = .fullScreen
			present(vc, animated: false)
		}
		
	}
	
	@objc private func didTapBell(){
		//
	}
	
	private func applyConstraints(){
		NSLayoutConstraint.activate([
			homeViewHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			homeViewHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			homeViewHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			homeViewHeader.heightAnchor.constraint(equalToConstant: 55)
		])

		NSLayoutConstraint.activate([
			VCTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			VCTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			VCTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			VCTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
		
		
		
//		NSLayoutConstraint.activate([
//			VCTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//			VCTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//			VCTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//			VCTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//		])
	}
	
	private func configureSectionBar(){
		sectionBarView.sectionItems = sectionHeader
		sectionBarView.translatesAutoresizingMaskIntoConstraints = false
		sectionBarView.didSelectSection = { [weak self] section in
			self?.VCTable.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
		}
		
	}
	
	private func configureHeaderView(){
		configureSectionBar()
		view.addSubview(homeViewHeader)
	}
	
	private func configureVCTable(){
		fetchUpcomingFromAPI()
		fetchPopularFromAPI()
		fetchTrendingFromAPI(media_type: MediaType.tv, tableSection: 2)
		fetchTrendingFromAPI(media_type: MediaType.movie, tableSection: 3)
		
		VCTable.reloadData()
		view.addSubview(VCTable)
	}
	
	private func fetchUpcomingFromAPI(media_type: MediaType = .movie, total_results: Int = 5){
		APICaller.shared.getUpcoming(media_type: media_type.rawValue) { [weak self] result in
			switch result{
				case .success(let list):
					self?.films[0] = list.reversed()
					print("num of upcoming films",list.count)

				case .failure(let error):
					print(error)
			}
		}
	}
	
	private func fetchPopularFromAPI(media_type: MediaType = .movie, total_results: Int = 5){
		APICaller.shared.getPopular(media_type: media_type.rawValue) { [weak self] results in
			switch results {
				case .success(let list):
					self?.films[1] = Array(list.suffix(total_results))

				case .failure(let error):
					print(error)
			}
		}
	}
	
	private func fetchTrendingFromAPI(media_type: MediaType = .all, total_results: Int = 5, tableSection: Int){
		APICaller.shared.getTrending(media_type: media_type.rawValue) { [weak self] result in
			switch result {
				case .success(let list):
					self?.films[tableSection] = Array(list.prefix(total_results))
				case .failure(let error):
					print(error)
			}
		}
	}


  

}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section{
			case 0: //upcoming
				return films[0]?.count ?? 1
			default:
				return 5
				
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	
		let reuseIdentifier = tableViewCells[indexPath.section].reuseIdentifier
		guard let filmModel = films[indexPath.section]?[indexPath.row] else {
			tableView.reloadData()
			return UITableViewCell()
		}
		
		switch indexPath.section {
			case 0:
				guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? UpcomingTableViewCell else { return UITableViewCell() }
				
				cell.configureDetails(model: filmModel)
				cell.selectionStyle = .none
				
				return cell
			case 1: // popular cell
				guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? PopularTableViewCell else { return UITableViewCell() }
				
				cell.configureTabView(model: filmModel)
				cell.configureDetails(with: filmModel)
				cell.selectionStyle = .none
				return cell

			default: //top films
				guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TopFilmsTableViewCell else { return UITableViewCell() }
				
				cell.configureTabView(model: filmModel)
				cell.configureDetails(with: filmModel, top: indexPath.row + 1)
				cell.selectionStyle = .none
				return cell

		}
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sectionHeader.count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 50
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
		
		let iconImageView = UIImageView()
		iconImageView.image = sectionHeader[section].icon
		iconImageView.contentMode = .scaleAspectFit
		iconImageView.translatesAutoresizingMaskIntoConstraints = false
		headerView.addSubview(iconImageView)

		let titleLabel = UILabel()
		titleLabel.textColor = .label
		titleLabel.text = sectionHeader[section].title
		titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		headerView.addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			iconImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
			iconImageView.widthAnchor.constraint(equalToConstant: 20),
			iconImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
			
			titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
			titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
			titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
		])

		return headerView
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 400
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		sectionBarView.selectedIndexPath.row = section
		sectionBarView.sectionCollectionView.scrollToItem(at: IndexPath(row: section, section: 0), at: [], animated: true)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		searchController.searchBar.resignFirstResponder()
	}
}

extension HomeViewController: UISearchResultsUpdating, SearchResultsViewControllerDelagate {
	func updateSearchResults(for searchController: UISearchController) {
		let searchBar = searchController.searchBar
		guard let query = searchBar.text, !query.isEmpty, let resultsVC = searchController.searchResultsController as? SearchResultsViewController else {return}
		
		//added with SearchResultsViewControllerDelagate, so resultsCollectionView will refresh from here
		resultsVC.delegate = self
		
		APICaller.shared.search(with: query) { result in
			switch result{
				case .success(let list):
					resultsVC.films = list
					DispatchQueue.main.async {
						resultsVC.resultsCollectionView.reloadData()
					}
	
				case .failure(let error):
					print(error.localizedDescription)
			}
		}
	}
	
}
