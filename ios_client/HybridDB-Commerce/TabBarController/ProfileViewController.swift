//
//  ProfileViewController.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 11.04.2025.
//

import UIKit

class ProfileViewController: UIViewController {
    var username = ""
    var password = ""
    
    //MARK: - UI Components
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Verdana-Bold", size: 22)
        label.text = "Username"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let usernameField: UITextField = {
        let field = UITextField()
        field.layer.borderWidth = 0.5
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.cornerRadius = 8
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: field.bounds.width))
        field.leftViewMode = .always
        field.backgroundColor = UIColor(red: 0.8627, green: 0.8627, blue: 0.8627, alpha: 1.0)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Verdana-Bold", size: 22)
        label.text = "Password"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let passwordField: UITextField = {
        let field = UITextField()
        field.layer.borderWidth = 0.5
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.cornerRadius = 8
        field.backgroundColor = UIColor(red: 0.8627, green: 0.8627, blue: 0.8627, alpha: 1.0)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: field.bounds.width))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshProfileData()
    }
    
    let saveButton: UIButton = {
        let button = UIButton()
        
        button.configuration = .borderedProminent()
        button.configuration?.baseBackgroundColor = .systemBlue
        button.configuration?.baseForegroundColor = .white
        
        button.setTitle("Save", for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(save), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        let logoutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logout))
        logoutButton.tintColor = .systemRed

        self.navigationItem.rightBarButtonItem = logoutButton
        
        configureConstraints()
    }
    
    func configureConstraints() {
        view.addSubview(usernameLabel)
        view.addSubview(usernameField)
        
        view.addSubview(passwordLabel)
        view.addSubview(passwordField)
        
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            usernameLabel.heightAnchor.constraint(equalToConstant: 40),
        
            usernameField.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            usernameField.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            usernameField.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            usernameField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordLabel.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 30),
            passwordLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            passwordLabel.heightAnchor.constraint(equalToConstant: 40),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10),
            passwordField.leadingAnchor.constraint(equalTo: passwordLabel.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: passwordLabel.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 40),
            
            saveButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            saveButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func refreshProfileData() {
        StandartUserService.shared.getUserInfo { userInfo in
            if userInfo!.success {
                self.username = userInfo!.data.username!
                self.password = userInfo!.data.password!
                DispatchQueue.main.async {
                    self.navigationItem.title = "Welcome \(self.username)!"
                    self.usernameField.text = self.username
                    self.passwordField.text = self.password
                }
            }
            else {
                print("Can not get user info.")
            }
        }
    }
    
    //MARK: - Objc Functions
    @objc func logout() {
        let loginVC = LoginViewController()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc: loginVC)
    }
    
    @objc func save() {
        guard let username = usernameField.text, username != "",
              let password = passwordField.text, password != "" else {
            return
        }
        
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        StandartUserService.shared.updateUserInfo(username: username, password: password) { [weak self] success in
            var title = ""
            var message = ""
            
            if success {
                title = "Profile Updated"
                message = "Your profile information has been successfully updated."
                self?.refreshProfileData()
            }
            else {
                title = "Update Failed"
                message = "There was a problem updating your profile. Please try again."
            }
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            DispatchQueue.main.async {
                
                self?.present(ac, animated: true)
            }
        }
    }
}
