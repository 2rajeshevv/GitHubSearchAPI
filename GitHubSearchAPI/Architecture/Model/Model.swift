//
//  Model.swift
//  GitHubSearchAPI
//
//  Created by Evv Rajesh on 28/10/21.
//

import Foundation
import RealmSwift


class RepoResponse: Object, Codable {
    var items: List<Item> = List<Item>()
}

class Item: Object, Codable {
    dynamic var id: Int?
    @objc dynamic var name: String?
    @objc dynamic var html_url: String?
    @objc dynamic var url: String?
    @objc dynamic var collaborators_url: String?
    @objc dynamic var contributors_url: String?
    @objc dynamic var subscribers_url: String?
    @objc dynamic var created_at: String?
    @objc dynamic var updated_at: String?
    @objc dynamic var pushed_at: String?
    @objc dynamic var git_url: String?
    @objc dynamic var homepage: String?
    dynamic var open_issues: Int?
    @objc dynamic var visibility: String?
    @objc dynamic var default_branch: String?
    @objc dynamic var owner: ownerItem?
}

class ownerItem: Object, Codable {
    dynamic var id: Int?
    @objc dynamic var avatar_url: String?
    @objc dynamic var html_url: String?
    @objc dynamic var url: String?
}

struct Contributors: Codable {
       let login: String?
       let id: Int?
       let nodeID: String?
       let avatarURL: String?
       let gravatarID: String?
       let url, htmlURL, followersURL: String?
       let followingURL, gistsURL, starredURL: String?
       let subscriptionsURL, organizationsURL, reposURL: String?
       let eventsURL: String?
       let receivedEventsURL: String?
       let type: String?
       let siteAdmin: Bool?
       let contributions: Int?
}

