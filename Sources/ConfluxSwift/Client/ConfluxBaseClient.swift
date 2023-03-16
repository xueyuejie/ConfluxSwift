//
//  ConfluxBaseClient.swift
//  
//
//  Created by 薛跃杰 on 2023/3/13.
//

import Foundation
import PromiseKit

public class ConfluxBaseClient {
    
    public var url: URL
    private var session: URLSession
    
    public init(url: URL) {
        self.url = url
        self.session = URLSession(configuration: .default)
    }
    
    public func GET<T: Codable>(path: String = "", parameters: [String: Any]? = nil) -> Promise<T> {
        let rp = Promise<Data>.pending()
        var task: URLSessionTask? = nil
        let queue = DispatchQueue(label: "conflux.get")
        queue.async {
            var getUrl = self.url.appendingPathComponent(path)
            if let p = parameters, !p.isEmpty {
                var urlComponents = URLComponents(url: getUrl, resolvingAgainstBaseURL: true)!
                var items = urlComponents.queryItems ?? []
                items += p.map({ URLQueryItem(name: $0, value: "\($1)") })
                urlComponents.queryItems = items
                getUrl = urlComponents.url!
            }
            
            //            debugPrint("GET \(url)")
            var urlRequest = URLRequest(url: getUrl, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            
            task = self.session.dataTask(with: urlRequest){ (data, response, error) in
                guard error == nil else {
                    rp.resolver.reject(error!)
                    return
                }
                guard data != nil else {
                    rp.resolver.reject(ConfluxError.providerError("Node response is empty"))
                    return
                }
                rp.resolver.fulfill(data!)
            }
            task?.resume()
        }
        return rp.promise.ensure(on: queue) {
            task = nil
        }.map(on: queue){ (data: Data) throws -> T in
            //            debugPrint(String(data: data, encoding: .utf8) ?? "")
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let result = try decoder.decode(ConfluxRPCResult<T>.self, from: data)
                if let resulterror = result.error {
                    throw ConfluxError.otherError(resulterror.message)
                }
                guard let data = result.result else {
                    throw ConfluxError.unknow
                }
                return data
            } catch {
                throw ConfluxError.providerError("Parameter error or received wrong message")
            }
        }
    }
    
    public func POST<T: Codable>(path: String = "", parameters: Any? = nil, headers: [String: String] = [:]) -> Promise<T> {
        let rp = Promise<Data>.pending()
        var task: URLSessionTask? = nil
        let queue = DispatchQueue(label: "conflux.post")
        queue.async {
            do {
                let postUrl = self.url.appendingPathComponent(path)
                var urlRequest = URLRequest(url: postUrl, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
                urlRequest.httpMethod = "POST"
                
                for key in headers.keys {
                    urlRequest.setValue(headers[key], forHTTPHeaderField: key)
                }
                if !headers.keys.contains("Content-Type") {
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                if !headers.keys.contains("Accept") {
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                }
                if let p = parameters {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: p)
                    //debugPrint(p)
                }
                //            debugPrint(body?.toHexString() ?? "")
                
                task = self.session.dataTask(with: urlRequest){ (data, response, error) in
                    guard error == nil else {
                        rp.resolver.reject(error!)
                        return
                    }
                    guard data != nil else {
                        rp.resolver.reject(ConfluxError.providerError("Node response is empty"))
                        return
                    }
                    rp.resolver.fulfill(data!)
                }
                task?.resume()
            } catch {
                rp.resolver.reject(error)
            }
        }
        
        return rp.promise.ensure(on: queue) {
            task = nil
        }.map(on: queue) { (data: Data) throws -> T in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let result = try decoder.decode(ConfluxRPCResult<T>.self, from: data)
                if let resulterror = result.error {
                    throw ConfluxError.otherError(resulterror.message)
                }
                guard let data = result.result else {
                    throw ConfluxError.unknow
                }
                return data
            } catch let error {
                throw error
            }
        }
    }
}

extension ConfluxBaseClient {
    public func sendRPC<T: Codable>(method: String, params: [Any] = [Any]()) -> Promise<T> {
        let parameters = [
            "id": 1,
            "jsonrpc": "2.0",
            "method": method,
            "params": params
        ] as [String : Any]
        return POST(parameters: parameters)
    }
    
    public func call(from: String? = nil,
                     to: String,
                     gasLimit: Int? = nil,
                     gasPrice: Int? = nil,
                     value: Int? = nil,
                     data: String? = nil) -> Promise<String> {
        var parameters: [String: Any] = [:]
        parameters["to"] = to
        
        if let fromAddress = from {
            parameters["from"] = fromAddress
        }
        
        if let gas = gasLimit {
            parameters["gas"] = gas
        }
        
        if let gasPrice = gasPrice {
            parameters["gasPrice"] = gasPrice
        }
        
        if let value = value {
            parameters["value"] = value
        }
        
        if let data = data {
            parameters["data"] = data
        }
        return Promise<String> { seal in
            sendRPC(method:  "cfx_call", params: [parameters, "latest_state"]).done { (result: String) in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
