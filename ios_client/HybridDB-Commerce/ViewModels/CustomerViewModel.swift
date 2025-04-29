//
//  CustomerViewModel.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 23.04.2025.
//

import Foundation

class CustomerViewModel {
    let token = UserDefaults.standard.string(forKey: "jsonwebtoken")
    
    func addToCartAPI(product_id: String, completion: @escaping (Bool) -> Void) {
        CustomerService.shared.addToCart(token: self.token!, product_id: product_id) { response in
            if ((response?.success) != nil) {
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    func getCartAPI(completion: @escaping ([String], Double) -> Void) {
        CustomerService.shared.getCart(token: self.token!) { cart in
            if let cart = cart, !cart.products.isEmpty {
                print("Fetched cart...")
                completion(cart.products, cart.total_price)
            }
            else {
                print("Cart is empty...")
                completion([], 0)
            }
        }
    }
    
    func getCartWithPopulate(completion: @escaping ([Product] ,Double) -> Void) {
        CustomerService.shared.getCartWithPopulate(token: self.token!) { cart in
            if let cart = cart, !cart.products.isEmpty {
                print("Fetched cart...")
                completion(cart.products, cart.total_price)
            }
            else {
                print("Cart is empty...")
                completion([], 0.0)
            }
        }
    }
    
    func removeProductFromCart(product_id: String, completion: @escaping (Bool) -> Void) {
        CustomerService.shared.removeProductFromCart(token: self.token!, product_id: product_id) { success in
            if success {
                print("Product removed from the cart.")
                completion(true)
            }
            else {
                print("Failed to remove product")
                completion(false)
            }
        }
    }
    
    func clearCart(completion: @escaping (Bool) -> Void) {
        CustomerService.shared.clearCart(token: self.token!) { success in
            if success {
                print("succes")
                print("Your cart has been successfully emptied.")
                completion(true)
            }
            else {
                print("An error occurred while clearing your cart.")
                completion(false)
            }
        }
    }
}
