//
//  APIService.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 9.04.2025.
//

import Foundation

enum AuthenticationError: Error {
    case invalidCredentials
    case custom(errorMessage: String)
}

struct LoginOrSignUpRequestBody: Codable {
    let username: String?
    let password: String?
    let role: Int?
}

struct LoginResponseBody: Codable {
    let token: String?
}

struct UserInfo: Codable {
    let username: String?
    let password: String?
}

struct getUserInfoResponseBody: Codable {
    let success: Bool
    let data: UserInfo
}

struct SignUpResponseBody: Codable {
    let success: Bool
    let message: String?
}

class StandartUserService {
    
    static let shared = StandartUserService() // singleton
    
    func login(username: String, password: String, role: Int, completion: @escaping (Result<String, AuthenticationError>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/login") else {
            completion(.failure((.custom(errorMessage: "URL is not correct"))))
            return
        }
        
        let body = LoginOrSignUpRequestBody(username: username, password: password, role: role)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response ,error) in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            
            guard let loginRespone = try? JSONDecoder().decode(LoginResponseBody.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            guard let token = loginRespone.token else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            completion(.success(token))
            
        }.resume()
    }
    
    func signup(username: String, password: String, role: Int, completion: @escaping (SignUpResponseBody?) -> Void) {
        guard let url = URL(string: "http://localhost:3000/createUser") else {
            completion(nil)
            return
        }
        
        let body = LoginOrSignUpRequestBody(username: username, password: password, role: role)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            guard let signupResponse = try? JSONDecoder().decode(SignUpResponseBody.self, from: data) else {
                completion(nil)
                return
            }
            
            guard let message = signupResponse.message else {
                completion(nil)
                return
            }
            
            completion(signupResponse)
        }.resume()
    }
    
    func getUserInfo(completion: @escaping (getUserInfoResponseBody?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jsonwebtoken") else {
            completion(nil)
            return
        }
        
        guard let url = URL(string: "http://localhost:3000/getUserInfo") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let userResponse = try JSONDecoder().decode(getUserInfoResponseBody.self, from: data)
                
                if userResponse.success {
                    completion(userResponse)
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
    
    func updateUserInfo(username: String, password: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3000/updateUserInfo") else {
            completion(false)
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "jsonwebtoken") else {
            completion(false)
            return
        }
        
        let body = UserInfo(username: username, password: password)
        
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
            
            guard let responseString = try? JSONDecoder().decode(SignUpResponseBody.self, from: data) else {
                completion(false)
                return
            }
            
            print(responseString.message)
            completion(true)
        }.resume()
    }
}
