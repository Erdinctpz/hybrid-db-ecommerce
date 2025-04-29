//
//  ViewController.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 9.04.2025.
//

import UIKit

class LoginViewController: UIViewController {
    
    private var user = UserViewModel()
    
    //MARK: - UI Component
    let usernameLabel = CustomLabel()
    let passwordLabel = CustomLabel()
    
    let usernameField = CustomTextField()
    let passwordField = CustomTextField()
    
    let alertLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loginButton = CustomButton()
    let signupButton = CustomButton()
    
    
    let userTypeSegmented: UISegmentedControl = {
        let userTypeSegmented = UISegmentedControl(items: ["Customer", "Supplier"])
        userTypeSegmented.addTarget(nil, action: #selector(segmentFunc), for: .valueChanged)
        userTypeSegmented.selectedSegmentIndex = 0
        userTypeSegmented.selectedSegmentTintColor = .systemTeal
        userTypeSegmented.backgroundColor = .systemGray4
        userTypeSegmented.translatesAutoresizingMaskIntoConstraints = false
        return userTypeSegmented
    }()
    
    let loginViewHeader: UILabel = {
        let header = UILabel()
        header.font = UIFont(name: "Verdana-Bold", size: 28)
        header.text = "Customer"
        header.textColor = .white
        header.textAlignment = .center
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()
    
    let loginView: UIView = {
        let loginView = UIView()
        loginView.backgroundColor = .secondarySystemBackground
        loginView.layer.cornerRadius = 8
        loginView.translatesAutoresizingMaskIntoConstraints = false
        return loginView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemRed
        
        configureUI()
        configureConstraints()
    }
    
    func configureUI() {
        usernameLabel.text = "Username:"
        passwordLabel.text = "Password:"
        
        passwordField.isSecureTextEntry = true
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tappedDoneButton))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [spacer, doneButton]
        
        usernameField.inputAccessoryView = toolbar
        passwordField.inputAccessoryView = toolbar
        
        loginButton.setTitle("Login", for: .normal)
        signupButton.setTitle("Sign up", for: .normal)
        
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside )
        signupButton.addTarget(self, action: #selector(tappedSignUpButton), for: .touchUpInside)
    }

    func configureConstraints() {
        view.addSubview(loginView)
        
        loginView.addSubview(usernameLabel)
        
        view.addSubview(loginViewHeader)
        
        loginView.addSubview(userTypeSegmented)
        
        loginView.addSubview(passwordLabel)
        
        loginView.addSubview(usernameField)
        
        loginView.addSubview(passwordField)
        
        loginView.addSubview(loginButton)
        
        loginView.addSubview(signupButton)

        NSLayoutConstraint.activate([
            loginViewHeader.bottomAnchor.constraint(equalTo: loginView.topAnchor, constant: -10),
            loginViewHeader.leadingAnchor.constraint(equalTo: loginView.leadingAnchor),
            loginViewHeader.trailingAnchor.constraint(equalTo: loginView.trailingAnchor),
            loginViewHeader.heightAnchor.constraint(equalToConstant: 30),
            
            loginView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            loginView.heightAnchor.constraint(equalToConstant: 300),
            
            userTypeSegmented.topAnchor.constraint(equalTo: loginView.topAnchor, constant: 20),
            userTypeSegmented.leadingAnchor.constraint(equalTo: loginView.leadingAnchor, constant: 20),
            userTypeSegmented.trailingAnchor.constraint(equalTo: loginView.trailingAnchor, constant: -30),
            
            usernameLabel.leadingAnchor.constraint(equalTo: loginView.leadingAnchor, constant: 20),
            usernameLabel.topAnchor.constraint(equalTo: loginView.topAnchor, constant: 80),
            usernameLabel.widthAnchor.constraint(equalToConstant: 110),
            
            passwordLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            passwordLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 50),
            passwordLabel.widthAnchor.constraint(equalToConstant: 110),
            
            usernameField.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            usernameField.trailingAnchor.constraint(equalTo: loginView.trailingAnchor, constant: -30),
            usernameField.heightAnchor.constraint(equalToConstant: 30),
            usernameField.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            
            passwordField.leadingAnchor.constraint(equalTo: passwordLabel.trailingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: loginView.trailingAnchor, constant: -30),
            passwordField.heightAnchor.constraint(equalToConstant: 30),
            passwordField.centerYAnchor.constraint(equalTo: passwordLabel.centerYAnchor),
            
            loginButton.leadingAnchor.constraint(equalTo: loginView.leadingAnchor, constant: 60),
            loginButton.bottomAnchor.constraint(equalTo: loginView.bottomAnchor, constant: -40),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            loginButton.widthAnchor.constraint(equalToConstant: 100),
            
            signupButton.trailingAnchor.constraint(equalTo: loginView.trailingAnchor, constant: -60),
            signupButton.bottomAnchor.constraint(equalTo: loginView.bottomAnchor, constant: -40),
            signupButton.heightAnchor.constraint(equalToConstant: 44),
            signupButton.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    //MARK: - Obcj Functions
    @objc func segmentFunc(_ segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 1 {
            loginViewHeader.text = "Supplier"
        }
        else {
            loginViewHeader.text = "Customer"
        }
    }
    
    @objc func tappedLoginButton() {
        if usernameField.text != "", passwordField.text != "" {
            user.username = usernameField.text!
            user.password = passwordField.text!
            user.role = userTypeSegmented.selectedSegmentIndex
            
            user.login { [weak self] succes in
                if succes {
                    if self?.user.role == 0 {
                        let userTabBar = UserTabBarController(userRole: (self?.user.role)!)
 
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc: userTabBar)
                        
                    }
                    else {
                        let userTabBar = UserTabBarController(userRole: (self?.user.role)!)
                        
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc: userTabBar)
                        
                    }
                }
                else {
                    let ac = UIAlertController(title: "Login Failed", message: "Please check your information", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ac, animated: true)
                }
            }
        }
        else {
            let ac = UIAlertController(title: "Login Error",
                                     message: "Please do not leave the username or password fields empty.",
                                     preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    @objc func tappedSignUpButton() {
        if usernameField.text != "", passwordField.text != "" {
            user.username = usernameField.text!
            user.password = passwordField.text!
            user.role = userTypeSegmented.selectedSegmentIndex
            
            user.signup { response in
                var title: String
                var message: String
                
                if response.success {
                    title = "Account Created"
                    message = "Your account has been successfully created."
                }
                else {
                    title = "Username Unavailable"
                    message = "The username you entered is already in use. Please choose a different one."
                }
                
                let ac = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .alert)
                
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }
        else {
            let ac = UIAlertController(title: "Sign Up Error",
                                     message: "Please fill in all required fields, including username and password.",
                                     preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    @objc func tappedDoneButton() {
        if usernameField.isFirstResponder {
            usernameField.resignFirstResponder()
        }
        else {
            passwordField.resignFirstResponder()
        }
    }

}

