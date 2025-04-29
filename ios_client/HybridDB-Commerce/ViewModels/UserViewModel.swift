//
//  LoginViewModel.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 9.04.2025.
//

import Foundation

class UserViewModel: ObservableObject {
    var username: String = ""
    var password: String = ""
    var role: Int = -1
    
    
    func login(completion: @escaping (Bool) -> Void) {
        
        let defaults = UserDefaults.standard
        
        StandartUserService.shared.login(username: username, password: password, role: role) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let token):
                        defaults.set(token, forKey: "jsonwebtoken")
                        completion(true)

                    case .failure(let error):
                        print(error.localizedDescription)
                        completion(false)
                }
            }
        }
    }
    
    func signup(completion: @escaping (SignUpResponseBody) -> Void) {
        StandartUserService.shared.signup(username: username, password: password, role: role) { response in
            DispatchQueue.main.async {
                guard let response = response else {
                    print("Sign up error")
                    return
                }
                
                completion(response)
            }
            
        }
    }
}
