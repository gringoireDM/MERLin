//
//  MenuItemCell.swift
//  RestaurantDetailModule
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

class MenuItemCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func applyAppearance() {
        title.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        priceLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        priceLabel.textColor = tintColor
    }
}
