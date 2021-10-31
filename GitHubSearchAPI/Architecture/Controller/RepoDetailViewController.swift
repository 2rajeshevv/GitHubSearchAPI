//
//  RepoDetailViewController.swift
//  GitHubSearchAPI
//
//  Created by Evv Rajesh on 30/10/21.
//

import UIKit
import SafariServices

class RepoDetailViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var repoUserImageView: UIImageView!
    @IBOutlet weak var repoUserName: UILabel!
    @IBOutlet weak var repoContributions: UILabel!
    var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Repo", style: .done, target: self, action: #selector(tapToViewRepo))
        
        loadRepoImageData()
        repoUserName.text = item?.name
        
        guard let contributorUrl = item?.contributors_url else {
            return
        }
        
        APIHandler.shared.fetchRepoContributors(forRepo: contributorUrl) { [weak self]  result in
            switch result {
            case .success(let contributor):
                guard let totalContributions = contributor.first?.contributions else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.repoContributions.text = "\(totalContributions)"
                }
            case .failure(let error):
                print(error)
            }
        }
       
    }
    
    private func loadRepoImageData() {
        
        guard let imageUrl = item?.owner?.avatar_url else {
            return
        }
        
        APIHandler.shared.fetchImage(fromImageUrl:imageUrl) { imageData in
            
            switch imageData {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.repoUserImageView.image = UIImage(data: data)
                    }
                case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func tapToViewRepo() {
        guard let repoUrl = item?.html_url else {
            return
        }
        
        if  let url = URL(string: repoUrl) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            present(safariVC, animated: true, completion: nil)
        }
      
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }
}
