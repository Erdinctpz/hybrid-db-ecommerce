//
//  CartViewController.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 24.04.2025.
//

import UIKit

class CartViewController: UIViewController {
    var myProducts = [Product]()
    var totalPrice: Double = 0.0
    
    var customer = CustomerViewModel()
    
    //MARK: - UI Components
    let middleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let alertLabel: UILabel = {
        let label = UILabel()
        label.text = "Cart is empty"
        label.font = UIFont(name: "Verdana", size: 16)
        label.textColor = .systemGray3
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let listTableView: UITableView = {
        let table = UITableView()
        table.layer.cornerRadius = 8
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let totalPriceLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "Verdana-Bold", size: 14)
        label.text = "Total Price: 0.0 TL"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let checkoutButton: UIButton = {
        let button = UIButton()
        button.addTarget(nil, action: #selector(tappedCheckoutButton), for: .touchUpInside)
        button.setTitle("Checkout", for: .normal)
        button.configuration = .borderedProminent()
        button.configuration?.baseForegroundColor = .white
        button.configuration?.baseBackgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var removeAllButton: UIBarButtonItem?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = self.middleView.center
        spinner.startAnimating()
        self.middleView.addSubview(spinner)
        
        
        customer.getCartWithPopulate { [weak self] products, total_price in
            guard let self = self else { return }
            self.myProducts = products
            self.totalPrice = total_price
            
            DispatchQueue.main.async {
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                
                self.totalPriceLabel.text = String(format: "Total Price: %.2f TL", self.totalPrice)
                self.listTableView.reloadData()
                
                if self.myProducts.isEmpty {
                    self.removeAllButton?.isEnabled = false
                    self.checkoutButton.isEnabled = false
                    self.alertLabel.isHidden = false
                }
                else {
                    self.removeAllButton?.isEnabled = true
                    self.checkoutButton.isEnabled = true
                    self.alertLabel.isHidden = true
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .secondarySystemBackground
        self.navigationItem.title = "My Cart"
        self.navigationItem.largeTitleDisplayMode = .never
        
        removeAllButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(tappedRemoveAll)
        )
        
        removeAllButton?.tintColor = UIColor.systemRed
        self.navigationItem.rightBarButtonItem = removeAllButton
        
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(CartTableViewCell.self, forCellReuseIdentifier: CartTableViewCell.identifier)
        
        configureConstraints()
    }
    
    func configureConstraints() {
        middleView.addSubview(listTableView)
        view.addSubview(middleView)
        
        middleView.addSubview(alertLabel)
        
        view.addSubview(bottomView)
        bottomView.addSubview(totalPriceLabel)
        bottomView.addSubview(checkoutButton)
        
        NSLayoutConstraint.activate([
            listTableView.topAnchor.constraint(equalTo: middleView.topAnchor),
            listTableView.leadingAnchor.constraint(equalTo: middleView.leadingAnchor),
            listTableView.trailingAnchor.constraint(equalTo: middleView.trailingAnchor),
            listTableView.bottomAnchor.constraint(equalTo: middleView.bottomAnchor),
            
            middleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            middleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            middleView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            middleView.heightAnchor.constraint(equalToConstant: 300),
            
            alertLabel.centerXAnchor.constraint(equalTo: middleView.centerXAnchor),
            alertLabel.centerYAnchor.constraint(equalTo: middleView.centerYAnchor),
            
            bottomView.topAnchor.constraint(equalTo: middleView.bottomAnchor, constant: 50),
            bottomView.leadingAnchor.constraint(equalTo: middleView.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: middleView.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 150),
            
            totalPriceLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20),
            totalPriceLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            totalPriceLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            totalPriceLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),
            
            checkoutButton.topAnchor.constraint(equalTo: totalPriceLabel.bottomAnchor, constant: 20),
            checkoutButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            checkoutButton.widthAnchor.constraint(equalToConstant: 100),
            checkoutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
    @objc func tappedRemoveAll() {
        customer.clearCart { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                var title: String
                var message: String
                    
                if success {
                    self.myProducts.removeAll()
                    self.totalPrice = 0.0
                    
                    self.alertLabel.isHidden = false
                    self.listTableView.reloadData()
                    self.totalPriceLabel.text = String(format: "Total Price: %.2f TL", self.totalPrice)
                    
                    self.removeAllButton?.isEnabled = false
                    self.checkoutButton.isEnabled = false
                    
                    title = "Cart Cleared"
                    message = "Your cart has been successfully emptied."
                    
                } else {
                    title = "Error"
                    message = "Something went wrong while clearing your cart. Please try again later."
                }
                
                let ac = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
            
                self.present(ac, animated: true)
            }
        }
    }
    
    @objc func tappedCheckoutButton() {
        customer.clearCart { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                var title: String
                var message: String
                    
                if success {
                    self.myProducts.removeAll()
                    self.totalPrice = 0.0
                    
                    self.listTableView.reloadData()
                    self.totalPriceLabel.text = String(format: "Total Price: %.2f TL", self.totalPrice)
                    
                    self.removeAllButton?.isEnabled = false
                    self.checkoutButton.isEnabled = false
                    
                    title = "Order Confirmed"
                    message = "Your order has been placed successfully."
                } else {
                    title = "Order Failed"
                    message = "Something went wrong. Please try again."
                }
                
                let ac = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
            
                self.present(ac, animated: true)
            }
        }
    }
}

extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let customCell = listTableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell else {
            return UITableViewCell()
        }
        
        customCell.productNameLabel.text = myProducts[indexPath.row].product_name
        customCell.priceLabel.text = "Price: \(self.myProducts[indexPath.row].price) TL"
        
        return customCell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        customer.removeProductFromCart(product_id: myProducts[indexPath.row]._id) { [weak self] success in
            guard let self = self else { return }
            if success {
                DispatchQueue.main.async {
                    self.totalPrice -= self.myProducts[indexPath.row].price
                    self.myProducts.remove(at: indexPath.row)
                    
                    if self.myProducts.isEmpty {
                        self.alertLabel.isHidden = false
                    }
                    
                    self.listTableView.reloadData()
                    self.totalPriceLabel.text = String(format: "Total Price: %.2f TL", self.totalPrice)
                    
                    if self.myProducts.isEmpty {
                        self.removeAllButton?.isEnabled = false
                        self.checkoutButton.isEnabled = false
                    }
                }
            }
        }
    }
}
