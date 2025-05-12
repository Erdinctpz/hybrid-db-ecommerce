//
//  CustomerService.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 23.04.2025.
//

import Foundation

struct ProductRequestBody: Codable {
    let _id: String?
}

struct CartResponseBody: Codable {
    let success: Bool
    let message: String?
}

struct Carts: Codable {
    var success: Bool
    var cart: Cart?
}

struct Cart: Codable {
    var _id: String
    var customer_id: Int
    var products: [String]
    var total_price: Double
}

struct PopulateCarts: Codable {
    var success: Bool
    var cart: PopulateCart?
}

struct PopulateCart: Codable {
    var _id: String
    var customer_id: Int
    var products: [Product]
    var total_price: Double
}


class CustomerService {
    static let shared = CustomerService()
    
    func fetchAllProducts(completion: @escaping ([Product]?) -> Void) {
        guard let url = URL(string: "http://localhost:3000/allProducts") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
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
            }
            catch {
                completion(nil)
            }
        }.resume()
    }
    
    func addToCart(token: String, product_id: String, completion: @escaping (CartResponseBody?) -> Void) {
        guard let url = URL(string: "http://localhost:3000/addToCart") else {
            completion(nil)
            return
        }
        
        let body = ProductRequestBody(_id: product_id)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            guard let responseString = try? JSONDecoder().decode(CartResponseBody.self, from: data) else {
                completion(nil)
                return
            }
            
            guard let message = responseString.message else {
                completion(nil)
                return
            }
            
            print("\(message)")
            completion(responseString)
            
        }.resume()
    }
    
    func getCart(token: String, completion: @escaping (Cart?) -> Void) {
        guard let url = URL(string: "http://localhost:3000/getCart") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(Carts.self, from: data)
                if response.success {
                    completion(response.cart)
                }
                else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    func getCartWithPopulate(token: String, completion: @escaping (PopulateCart?) -> Void) {
        guard let url = URL(string: "http://localhost:3000/getCartWithPopulate") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(PopulateCarts.self, from: data)
                if response.success {
                    completion(response.cart)
                }
                else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
            
        }.resume()
    }
    
    func removeProductFromCart(token: String, product_id: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3000/removeProductFromCart") else {
            completion(false)
            return
        }
        
        let body = ProductRequestBody(_id: product_id)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            guard let response = try? JSONDecoder().decode(CartResponseBody.self, from: data) else {
                completion(false)
                return
            }
            
            guard let message = response.message else {
                completion(false)
                return
            }
            
            print("\(message)")
            completion(response.success)
        }.resume()
    }
    
    func clearCart(token: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3000/clearCart") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            guard let response = try? JSONDecoder().decode(CartResponseBody.self, from: data) else {
                completion(false)
                return
            }
            
            print(response.message)
            completion(response.success)
        }.resume()
        
    }
}
