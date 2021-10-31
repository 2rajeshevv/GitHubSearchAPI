//
//  APIHandler.swift
//  GitHubSearchAPI
//
//  Created by Evv Rajesh on 28/10/21.
//

import Foundation
import RealmSwift



final class APIHandler {
    
    static let shared = APIHandler()
    var realmDatabase = try! Realm()
    
    private init() {
        
    }
    //  https://api.github.com/search/repositories?q=sanjayshingarwad&sort=stars&order=desc
    private struct Constants {
        static let BasePoint = "https://api.github.com/search/repositories?"
        static let QueryPoint = "&sort=stars&order=desc"
    }
    
    public func fetchRepo(searchQuery: String, completion: @escaping (Result<RepoResponse, Error>) -> Void) {
       
        guard let url = URL(string: Constants.BasePoint + "q=\(searchQuery)" + Constants.QueryPoint) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data, error == nil else {
                return
            }
            
            do {
                
                let result = try JSONDecoder().decode(RepoResponse.self, from: data)
                completion(.success(result))
                
                DispatchQueue.main.async {
                    self.saveDataToRealm(response: result)
                  
                }
                
            } catch let error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchImage(fromImageUrl: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let url = URL(string: fromImageUrl) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    func fetchRepoContributors(forRepo: String, completion: @escaping (Result<[Contributors], Error>) -> Void) {
        
        guard let url = URL(string: forRepo) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let contributions = try JSONDecoder().decode([Contributors].self, from: data)
               
                completion(.success(contributions))
                
            } catch let error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func saveDataToRealm(response: RepoResponse) {
        
        var storingModel = RepoResponse()
        storingModel = response
        realmDatabase.beginWrite()
        realmDatabase.add(storingModel)
        try! realmDatabase.commitWrite()
    }
    
    func readDataFromRealm() {
//        try! realmDatabase.write{
//            realmDatabase.deleteAll()
//        }
        realmDatabase.beginWrite()
        let data = realmDatabase.objects(RepoResponse.self)
        let jsonResponse = try! JSONEncoder().encode(data)
        print("realm database \(jsonResponse)")
        print(String(data: jsonResponse, encoding: .utf8) ?? "could not convert data from realm database")
        try! realmDatabase.commitWrite()
    }
}


