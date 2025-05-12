//
//  CustomTextField.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 9.04.2025.
//

import UIKit

class CustomTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemGray4
        self.layer.cornerRadius = 8
        self.clearButtonMode = .whileEditing
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: self.bounds.width))
        self.leftViewMode = .always
    }

}
