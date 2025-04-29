//
//  CustomLabel.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 9.04.2025.
//

import UIKit

class CustomLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = UIFont(name: "Verdana-Bold", size: 16)
        self.textColor = .black
    }
}
