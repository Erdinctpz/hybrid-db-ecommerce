//
//  CustomButton.swift
//  VT_Proje
//
//  Created by Erdinç Topuz on 9.04.2025.
//

import UIKit

class CustomButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.configuration = .borderedProminent()
        self.configuration?.baseBackgroundColor = .systemGray4//UIColor(white: 0.94, alpha: 1)
        self.layer.cornerRadius = 8
        self.configuration?.baseForegroundColor = .black
        self.translatesAutoresizingMaskIntoConstraints = false
    }

}
