//
//  SupplierService.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 15.04.2025.
//

import Foundation

struct NewProductRequestBody: Codable {
    var product_name: String
    var price: Double
}

struct UpdateProductRequestBody: Codable {
    var _id: String
    var product_name: String
    var price: Double
}

struct Product: Codable {
    var _id: String
    var supplier_id: Int
    var product_name: String
    var price: Double
}

struct ProductResponse: Codable {
    let success: Bool
    let data: [Product]
}

struct AddProductResponse: Codable {
    let message: String?
}

struct UpdateProductResponse: Codable {
    let message: String?
    let data: Product
}


class SupplierService {
    static let shared = SupplierService() // singleton
    
    func fetchProducts(token: String, completion: @escaping ([Product]?) -> Void) {
        guard let url = URL(string: "http://localhost:3000/fetchProducts") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let productResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                if productResponse.success {
                    completion(productResponse.data)
                }
                else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    func addProduct(token: String, product_name: String, price: Double, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3000/addProduct") else {
            completion(false)
            return
        }
        
        let body = NewProductRequestBody(product_name: product_name, price: price)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            guard let responseString = try? JSONDecoder().decode(AddProductResponse.self, from: data) else {
                completion(false)
                return
            }
            
            guard let message = responseString.message else {
                completion(false)
                return
            }
            
            print("\(message)")
            completion(true)
        }.resume()
    }
    
    func updateProduct(token: String, product_id: String, product_name: String, price: Double, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3000/updateProduct") else {
            return
        }
        
        let body = UpdateProductRequestBody(_id: product_id, product_name: product_name, price: price)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            guard let responseString = try? JSONDecoder().decode(UpdateProductResponse.self, from: data) else {
                completion(false)
                return
            }
            
            guard let message = responseString.message else {
                completion(false)
                return
            }
            
            print(message)
            completion(true)
        }.resume()
    }
    
    func deleteProduct(token: String, product_id: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3000/deleteProduct") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let parameters = ["_id": product_id]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            guard let responseString = try? JSONDecoder().decode(AddProductResponse.self, from: data) else {
                completion(false)
                return
            }
            
            guard let message = responseString.message else {
                completion(false)
                return
            }
            
            print(message)
            completion(true)
        }.resume()
    }
}
