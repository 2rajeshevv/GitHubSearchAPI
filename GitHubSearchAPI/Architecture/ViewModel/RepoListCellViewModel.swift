//
//  RepoListCellViewModel.swift
//  GitHubSearchAPI
//
//  Created by Evv Rajesh on 28/10/21.
//

import Foundation

class RepoListCellViewModel {
    let title: String
    let subTitle: String
    let userImage: String?
    var imageData: Data?
    
    init(title: String, subTitle: String, userImage: String?) {
        self.title = title
        self.subTitle = subTitle
        self.userImage = userImage
    }
}
