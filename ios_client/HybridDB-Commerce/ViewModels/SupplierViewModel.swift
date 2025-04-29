//
//  SupplierViewModel.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 15.04.2025.
//

import Foundation



class SupplierViewModel {
    var productList = [Product]()
    var token = UserDefaults.standard.string(forKey: "jsonwebtoken")!
    
    func fetchProducts(token: String, completion: @escaping (Bool) -> Void) {
        
        SupplierService.shared.fetchProducts(token: self.token) { [weak self] products in
            DispatchQueue.main.async {
                if let products = products {
                    self?.productList = products
                    print("Products fetched after adding:", self?.productList.count)
                    completion(true)
                }
                else {
                    print("Failed to fetch products")
                    completion(false)
                }
            }
        }
    }
    
    func addProduct(product_name: String, price: Double,completion: @escaping (Bool) -> Void) {
        SupplierService.shared.addProduct(token: self.token, product_name: product_name, price: price) { success in
            if success {
                SupplierService.shared.fetchProducts(token: self.token) { products in
                    if let products = products {
                        self.productList = products
                        completion(true)
                    }
                    else {
                        print("products undefined...")
                        completion(false)
                    }
                }
            }
        }
    }
    
    func updateProduct(product_id: String, product_name: String, price: Double, completion: @escaping (Bool) -> Void) {
        SupplierService.shared.updateProduct(token: self.token, product_id: product_id, product_name: product_name, price: price) { success in
            if success {
                SupplierService.shared.fetchProducts(token: self.token) { products in
                    if let products = products {
                        self.productList = products
                        completion(true)
                    }
                    else {
                        print("products undefined...")
                        completion(false)
                    }
                }
            }
            else {
                print("Can not update product")
                completion(false)
            }
        }
    }
    
    func deleteProduct(product_id: String, completion: @escaping (Bool) -> Void) {  
        SupplierService.shared.deleteProduct(token: self.token, product_id: product_id) { success in
            if success {
                SupplierService.shared.fetchProducts(token: self.token) { [weak self] products in
                    if let products = products {
                        self?.productList = products
                        completion(true)
                    }
                    else {
                        print("products undefined...")
                        completion(false)
                    }
                }
            }
            else {
                print("Can not update product")
                completion(false)
            }
        }
    }
}
