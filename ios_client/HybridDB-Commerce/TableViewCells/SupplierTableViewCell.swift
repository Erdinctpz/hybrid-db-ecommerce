//
//  SubtitleViewCell.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 10.04.2025.
//

import UIKit

class SupplierTableViewCell: UITableViewCell {
    static let identifier = "supplierCell"
    
    var productNameLabel: UILabel = {
        var productNameLabel = UILabel()
        productNameLabel.font = UIFont(name: "Verdana-Bold", size: 16)
        productNameLabel.textColor = .black
        productNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return productNameLabel
    }()
    
    var priceLabel: UILabel = {
        var priceLabel = UILabel()
        priceLabel.font = UIFont(name: "Verdana", size: 14)
        priceLabel.textColor = .darkGray
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        return priceLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureConstraints() {
        contentView.addSubview(productNameLabel)
        contentView.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            productNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            productNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            productNameLabel.widthAnchor.constraint(equalToConstant: (contentView.bounds.width / 2)),
            
            priceLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 3),
            priceLabel.leadingAnchor.constraint(equalTo: productNameLabel.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)

        ])
    }
    
    func set(productName: String, price: String) {
        self.productNameLabel.text = "\(productName)"
        self.priceLabel.text = "\(price) TL"
    }

}
