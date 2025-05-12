//
//  CustomerViewController.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 10.04.2025.
//

import UIKit

class CustomerViewController: UIViewController {
    
    var products = [Product]()
    var addedToCartProductIDs = [String]()
    var customer = CustomerViewModel()
    
    let alertLabel: UILabel = {
        let label = UILabel()
        label.text = "No products available"
        label.font = UIFont(name: "Verdana", size: 16)
        label.textColor = .systemGray3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let listTableView: UITableView = {
        let listTableView = UITableView()
        listTableView.translatesAutoresizingMaskIntoConstraints = false
        return listTableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshView()
        
        customer.getCartAPI {[weak self] products, total_price in
            self?.addedToCartProductIDs = products
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "All Products"
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.hidesBackButton = true
        
        let cartButton = UIBarButtonItem(image: UIImage(systemName: "cart.fill"), style: .plain, target: self, action: #selector(tappedCartButton))
        
        let refreshButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(tappedRefreshButton))
        
        self.navigationItem.leftBarButtonItem = refreshButton
        self.navigationItem.rightBarButtonItem = cartButton
        
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: CustomerTableViewCell.identifier)
        
        configureConstraints()
    }
    
    func configureConstraints() {
        view.addSubview(listTableView)
        view.addSubview(alertLabel)
        
        NSLayoutConstraint.activate([
            listTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func refreshView() {
        CustomerService.shared.fetchAllProducts { [weak self] products in
            guard let self = self else { return }
            
            if let products = products{
                self.products = products
                
                DispatchQueue.main.async {
                    self.listTableView.reloadData()
                    
                    if !(self.products.isEmpty) {
                        self.alertLabel.isHidden = true
                    }
                    else {
                        self.alertLabel.isHidden = false
                    }
                }
            }
        }
    }
    
    @objc func tappedCartButton() {
        let cartVC = CartViewController()
        self.navigationController?.pushViewController(cartVC, animated: true)
    }
    
    @objc func tappedRefreshButton() {
        self.refreshView()
    }
}

extension CustomerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let customCell = listTableView.dequeueReusableCell(withIdentifier: CustomerTableViewCell.identifier, for: indexPath) as? CustomerTableViewCell else {
            return UITableViewCell()
        }
        
        let productName = products[indexPath.row].product_name
        let price = String(products[indexPath.row].price)
        
        customCell.set(productName: productName, price: price)
        
        customCell.addToCart = { [weak self] in
            guard let self = self else { return }
            
            let product_id = self.products[indexPath.row]._id
            self.customer.addToCartAPI(product_id: product_id) { success in
                var title = ""
                var message = ""
                
                if success {
                    title = "Product Added"
                    message = "The product has been successfully added to your cart."
                    
                    self.addedToCartProductIDs.append(product_id)
                }
                else {
                    title = "Add to Cart Failed"
                    message = "An error occurred while adding the product to your cart. Please try again."
                }
                
                let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                DispatchQueue.main.async {
                    self.present(ac, animated: true)
                }
            }
        }
        
        customCell.removeFromCart = { [weak self] in
            let product_id = self?.products[indexPath.row]._id
            
            self?.customer.removeProductFromCart(product_id: product_id!) { [weak self] success in
                guard let self = self else { return }
                
                var title = ""
                var message = ""
                
                if success {
                    title = "Product Removed"
                    message = "The product has been successfully removed from your cart."
                }
                else {
                    title = "Removal Failed"
                    message = "The product could not be removed from your cart. Please try again."
                }
                
                let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                DispatchQueue.main.async {
                    self.present(ac, animated: true)
                }
            }
        }
        
        let productID = products[indexPath.row]._id
        if addedToCartProductIDs.contains(productID) {
            customCell.addToCartButton.setImage(UIImage(systemName: "plus.app.fill"), for: .normal)
            customCell.isProductAdd = true
        }
        else {
            customCell.addToCartButton.setImage(UIImage(systemName: "plus.app"), for: .normal)
            customCell.isProductAdd = false
        }
        
        return customCell
    }
}
