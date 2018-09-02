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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.applyLabelStyle(.body(attribute: .regular))
        descriptionLabel.applyLabelStyle(.caption(attribute: .regular))
        priceLabel.applyLabelStyle(.body(attribute: .bold))
        priceLabel.textColor = .color(forPalette: .primary)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
