//
//  MainViewController.swift
//  GitHubSearchAPI
//
//  Created by Evv Rajesh on 28/10/21.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {

    @IBOutlet weak var repoListCollectionView: UICollectionView!
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var repoUserViewModel = [RepoListCellViewModel]()
    private var repoItem = List<Item>()
    
    private var searchText: String = ""
    private var isLoading = false
    private var loadingReusableView: PaginationReusableView?
    
    let testNetwork: NetworkManager = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GitHub Repo"
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.size.height, height: 90)
        repoListCollectionView.collectionViewLayout = layout
        
        repoListCollectionView.register(UINib.init(nibName: "RepoListCellView", bundle: nil), forCellWithReuseIdentifier: RepoListCellView.identifier)
        
        repoListCollectionView.register(UINib.init(nibName: "PaginationReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "paginatingReusbaleViewID")
        
        createSearchController()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NetworkManager.isUnReachable { [self] _ in
            
            APIHandler.shared.readDataFromRealm()
            repoListCollectionView.reloadData()
            
        }
    
    }
    
    
    private func createSearchController() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
    
    private func searchRepoUsingQuery(query: String, scrollMore: Bool) {
        APIHandler.shared.fetchRepo(searchQuery: query) { [weak self] result in
            
            switch result {
            case .success(let repos):
                self?.repoItem = repos.items
                self?.repoUserViewModel = repos.items.compactMap({
                    RepoListCellViewModel(title: $0.name ?? "N/A", subTitle: $0.visibility ?? "N/A", userImage: $0.owner?.avatar_url ?? "user")
                })
                DispatchQueue.main.async {
                    self?.repoListCollectionView.reloadData()
                    self?.searchController.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                print("error of \(error)")
            }
        }
    }
}


extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return repoUserViewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepoListCellView.identifier, for: indexPath) as? RepoListCellView else {
            fatalError()
        }
        cell.backgroundColor = .secondarySystemBackground
        cell.configureView(with: repoUserViewModel[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.size.width, height: 90)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.isLoading {
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: 60)
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "paginatingReusbaleViewID", for: indexPath) as! PaginationReusableView
            loadingReusableView = footerView
            loadingReusableView?.backgroundColor = UIColor.clear
            return footerView
        }
        return UICollectionReusableView()
    }
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingReusableView?.paginatingActivityIndicator.startAnimating()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingReusableView?.paginatingActivityIndicator.stopAnimating()
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == repoUserViewModel.count - 10 && !self.isLoading {
            fetchMoreRepos()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let detailRepoController = storyboard?.instantiateViewController(identifier: "RepoDetailViewController") as? RepoDetailViewController else {
            return
        }
        let item = repoItem[indexPath.row]
        detailRepoController.item = item
        self.navigationController?.pushViewController(detailRepoController, animated: true)
    }
    
    private func fetchMoreRepos() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global().async {
                sleep(5)
                DispatchQueue.main.async {
                    self.repoListCollectionView.reloadData()
                    self.isLoading = false
                }
            }
        }
    }
}


extension MainViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        searchText = text
        print("query to search \(text)")
        searchRepoUsingQuery(query: text, scrollMore: false)
    
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.repoUserViewModel.removeAll()
            self.repoListCollectionView.reloadData()
        }
    }
}


