//
//  RepoListCellView.swift
//  GitHubSearchAPI
//
//  Created by Evv Rajesh on 28/10/21.
//

import UIKit

class RepoListCellView: UICollectionViewCell {

    static let identifier = "RepoListCellView"
    private var request: URLRequest? = nil
    
    @IBOutlet weak var repoUserLabel: UILabel!
    @IBOutlet weak var repoUserSubLabel: UILabel!
    @IBOutlet weak var repoUserImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        repoUserImageView.image = nil
        repoUserLabel.text = nil
        repoUserSubLabel.text = nil
    }
    
    func configureView(with viewModel: RepoListCellViewModel) {
        repoUserLabel.text = viewModel.title
        repoUserSubLabel.text = viewModel.subTitle
        
        if let data = viewModel.imageData {
            
            repoUserImageView.image = UIImage(data: data)
            
        } else {
            guard let image = viewModel.userImage else {
                return
            }
            if let url = URL(string: image) {
                
                let task = URLSession.shared.dataTask(with: url) { data, _, error in
                    
                    guard let data = data, error == nil else {
                        return
                    }
                    viewModel.imageData = data
                    
                    DispatchQueue.main.async {
                        self.repoUserImageView.image = UIImage(data: data)
                    }
                }
                task.resume()
            }
        }
    }
}
