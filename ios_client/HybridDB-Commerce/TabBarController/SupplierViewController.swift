//
//  UserViewController.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 10.04.2025.
//

import UIKit

class SupplierViewController: UIViewController {
    let listTableView: UITableView = {
        let listTableView = UITableView()
        listTableView.translatesAutoresizingMaskIntoConstraints = false
        return listTableView
    }()
    
    let alertLabel: UILabel = {
        let label = UILabel()
        label.text = "You haven't added any products yet."
        
        label.font = UIFont(name: "Verdana", size: 16)
        label.textColor = .systemGray3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var supplier = SupplierViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        supplier.fetchProducts(token: supplier.token) { [weak self] succes in
            guard let self = self else { return
            }
            if succes {
                DispatchQueue.main.async {
                    self.listTableView.reloadData()
                }
            }
            
            if self.supplier.productList.isEmpty {
                self.alertLabel.isHidden = false
            }
            else {
                self.alertLabel.isHidden = true
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Your Products"
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.hidesBackButton = true
        
        let addProductButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProduct))
        
        navigationItem.rightBarButtonItem = addProductButton
        
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(SupplierTableViewCell.self, forCellReuseIdentifier: SupplierTableViewCell.identifier)
        
        supplier.fetchProducts(token: supplier.token) { [weak self] succes in
            if succes {
                DispatchQueue.main.async {
                    self?.listTableView.reloadData()
                }
            }
        }

        configureConstraints()
    }
    
    func configureConstraints() {
        view.addSubview(listTableView)
        view.addSubview(alertLabel)
        
        NSLayoutConstraint.activate([
            listTableView.topAnchor.constraint(equalTo: view.topAnchor),
            listTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    //MARK: - Objc Functions
    @objc func addProduct() {
        let ac = UIAlertController(
            title: "New Product",
            message: "Add information",
            preferredStyle: .alert)
        
        ac.addTextField { textfield in
            textfield.placeholder = "Product Name"
        }
        ac.addTextField { textfield in
            textfield.placeholder = "Price"
            textfield.keyboardType = .decimalPad
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let product_name = ac.textFields?[0].text, product_name != "",
                  let priceStr = ac.textFields?[1].text, priceStr != "" else {
                return
            }
            
            let convertedPriceStr = priceStr.replacingOccurrences(of: ",", with: ".")
            let convertedPriceDouble = Double(convertedPriceStr)!
            
            self?.supplier.addProduct(product_name: product_name, price: convertedPriceDouble) { success in
                
                var title = ""
                var message = ""
                
                if success {
                    title = "New Product!"
                    message = "Your new product was added succesfully."
                    DispatchQueue.main.async {
                        self?.alertLabel.isHidden = true
                        self?.listTableView.reloadData()
                    }
                }
                else {
                    title = "Error"
                    message = "Failed to add new product"
                }
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                DispatchQueue.main.async {
                    self?.present(alert, animated: true)
                }
            }
        })
        present(ac, animated: true)
    }
    
    @objc func editProducts() {
        
    }
    
    @objc func tappedLogOut() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SupplierViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supplier.productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let customCell = listTableView.dequeueReusableCell(withIdentifier: SupplierTableViewCell.identifier, for: indexPath) as? SupplierTableViewCell else {
            return UITableViewCell()
        }
        
        customCell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        let productName = supplier.productList[indexPath.row].product_name
        let price = String(supplier.productList[indexPath.row].price)
        
        customCell.set(productName: productName, price: price)
        
        return customCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editVC = EditProductViewController()
        
        editVC.productNameField.text = supplier.productList[indexPath.row].product_name
        editVC.priceField.text = String(supplier.productList[indexPath.row].price)
        editVC.product_id = supplier.productList[indexPath.row]._id
        
        self.navigationController?.pushViewController(editVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
