//
//  APIClient.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/21/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import Foundation

enum NetworkingError: Error {
  case missingHTTPResponse(message: String)
  case unableToParse(message: String)
  case unexpectedResponse(message: String) // status code not handled
  case resourceNotFound(message: String) // status code 404
  case serviceUnavailable(message: String) // status code 503
  case gatewayTimeout(message: String) // status code 504
}

protocol JSONDecodable {
  init?(JSON: [String : Any])
}

protocol Endpoint {
  var baseURL: String { get }
  var path: String { get }
}

extension Endpoint {
  var request: URLRequest {
    let urlString = "\(baseURL)\(path)"
    let url = URL(string: urlString)!
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
              let error = NetworkingError.missingHTTPResponse(message: "No response. Please check your internet connection") as NSError
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
                case 404:
                  let error = NetworkingError.resourceNotFound(message: "Resource not found") as NSError
                  completion(nil, HTTPResponse, error)
                case 503:
                  let error = NetworkingError.serviceUnavailable(message: "Please try again later. Service not currently available") as NSError
                  completion(nil, HTTPResponse, error)
                case 504:
                  let error = NetworkingError.gatewayTimeout(message: "The request timed out. Please try again later") as NSError
                  completion(nil, HTTPResponse, error)
                default:
                    print("Received HTTP response: \(HTTPResponse.statusCode), which was not handled")
                }
            }
        }) 
        return task
    }
    
  func fetch<T>(_ request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void) {
        let task = JSONTaskWithRequest(request) { json, response, error in
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(.failure(error))
                    }
                    return
                }
                if let resource = parse(json) {
                    completion(.success(resource))
                } else {
                  let error = NetworkingError.unableToParse(message: "Couldn't parse data")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
  
  func fetch<T: JSONDecodable>(endpoint: Endpoint, parse: @escaping (JSON) -> [T]?, completion: @escaping (APIResult<[T]>) -> Void) {
    let request = endpoint.request
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
            let error = NetworkingError.unableToParse(message: "Couldn't parse data")
              completion(.failure(error))
          }
      }
    }
    task.resume()
  }
}

