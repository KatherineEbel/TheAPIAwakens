//
//  APIClient.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/21/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import Foundation

public let KAENetworkingErrorDomain = "com.katherineebel.TheAPIAwakens.NetworkingError"

public let MissingHTTPResponseError: Int = 10
public let UnexpectedResponseError: Int = 20

protocol JSONDecodable {
  init?(JSON: [String : Any])
}

protocol Endpoint {
  var baseURL: URL { get }
  var path: String { get }
  var request: URLRequest { get }
}

extension Endpoint {
  var request: URLRequest {
    let url = URL(string: path, relativeTo: baseURL)!
    return URLRequest(url: url)
  }
}

typealias JSON = [String: Any]
typealias JSONCompletion = (JSON?, HTTPURLResponse?, NSError?) -> Void
typealias JSONTask = URLSessionDataTask

enum APIResult<T> {
    case success(T)
    case failure(Error)
}

protocol APIClient {
    var configuration: URLSessionConfiguration { get }
    var session: URLSession { get }
    
    func JSONTaskWithRequest(_ request: URLRequest, completion: @escaping JSONCompletion) -> JSONTask
    func fetch<T: JSONDecodable>(_ request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void)
}

extension APIClient {
    func JSONTaskWithRequest(_ request: URLRequest, completion: @escaping JSONCompletion) -> JSONTask {
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            guard let HTTPResponse = response as? HTTPURLResponse else {
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")]
                let error = NSError(domain: KAENetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                completion(nil, nil, error)
                return
            }
            
            if data == nil {
                if let error = error {
                    completion(nil, HTTPResponse, error as NSError?)
                }
            } else {
                switch HTTPResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                        completion(json, HTTPResponse, nil)
                    } catch let error as NSError {
                        completion(nil, HTTPResponse, error)
                    }
                default:
                    print("Received HTTP response: \(HTTPResponse.statusCode), which was not handled")
                }
            }
        }) 
        
        return task
    }
    
  func fetch<T: JSONDecodable>(_ request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void) {
        let task = JSONTaskWithRequest(request) { json, response, error in
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // TODO: Implement error handling
                    }
                    return
                }
                if let resource = parse(json) {
                    completion(.success(resource))
                } else {
                    let error = NSError(domain: KAENetworkingErrorDomain, code: UnexpectedResponseError, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
  
  func fetch<T: JSONDecodable>(endpoint: Endpoint, parse: @escaping (JSON) -> [T]?, completion: @escaping (APIResult<[T]>) -> Void) {
    let request = endpoint.request
    let task = JSONTaskWithRequest(request) { json, response, error in
      DispatchQueue.global().async {
          guard let json = json else {
              if let error = error {
                  completion(.failure(error))
              } else {
                  // TODO: Implement error handling
              }
              return
          }
          
          if let resource = parse(json) {
              completion(.success(resource))
          } else {
              let error = NSError(domain: KAENetworkingErrorDomain, code: UnexpectedResponseError, userInfo: nil)
              completion(.failure(error))
          }
      }
    }
    task.resume()
  }
}

