//
//  EditProductViewController.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 15.04.2025.
//

import UIKit

class EditProductViewController: UIViewController {
    var product_id = ""
    let supplier = SupplierViewModel()
    
    //MARK: - UI Components
    let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Verdana-Bold", size: 22)
        label.text = "Product Name"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let productNameField: UITextField = {
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
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Verdana-Bold", size: 22)
        label.text = "Price"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let priceField: UITextField = {
        let field = UITextField()
        field.layer.borderWidth = 0.5
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.cornerRadius = 8
        field.backgroundColor = UIColor(red: 0.8627, green: 0.8627, blue: 0.8627, alpha: 1.0)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: field.bounds.width))
        field.leftViewMode = .always
        field.keyboardType = .decimalPad
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(tappedDelete))
        deleteButton.tintColor = .systemRed
        
        self.navigationItem.rightBarButtonItems = [saveButton, deleteButton]
        
        
        configureConstraints()
    }
    
    func configureConstraints() {
        view.addSubview(productNameLabel)
        view.addSubview(productNameField)
        
        view.addSubview(priceLabel)
        view.addSubview(priceField)

        NSLayoutConstraint.activate([
            productNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            productNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            productNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            productNameLabel.heightAnchor.constraint(equalToConstant: 40),
        
            productNameField.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 10),
            productNameField.leadingAnchor.constraint(equalTo: productNameLabel.leadingAnchor),
            productNameField.trailingAnchor.constraint(equalTo: productNameLabel.trailingAnchor),
            productNameField.heightAnchor.constraint(equalToConstant: 40),
            
            priceLabel.topAnchor.constraint(equalTo: productNameField.bottomAnchor, constant: 30),
            priceLabel.leadingAnchor.constraint(equalTo: productNameLabel.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: productNameLabel.trailingAnchor),
            priceLabel.heightAnchor.constraint(equalToConstant: 40),
            
            priceField.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            priceField.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            priceField.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
            priceField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    //MARK: - Objc Functions
    @objc func save() {
        guard let product_name = productNameField.text, product_name != "",
                let price = priceField.text, price != "" else {
            return
        }
        
        let convertedPriceStr = price.replacingOccurrences(of: ",", with: ".")
        
        guard let convertedPriceDouble = Double(convertedPriceStr) else {
            print("unvalid price!")
            return
        }
        
        self.supplier.updateProduct(product_id: product_id, product_name: product_name, price: convertedPriceDouble) { [weak self] success in
            var title = ""
            var message = ""
            
            if success {
                title = "Product Updated!"
                message = "The product has been successfully updated."
            }
            else {
                title = "Update Failed"
                message = "The product could not be updated."
            }
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            
            DispatchQueue.main.async {
                self?.present(ac, animated: true)
            }
        }
    }
    
    @objc func tappedDelete() {
        supplier.deleteProduct(product_id: product_id) { [weak self] success in
            var title = ""
            var message = ""
            
            if success {
                title = "Product Deleted!"
                message = "The product has been successfully deleted."
            }
            else {
                title = "Deletion Failed"
                message = "The product could not be deleted."
            }

            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            
            DispatchQueue.main.async {
                self?.present(ac, animated: true)
            }
        }
    }
}
