//
//  CollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Jay Mutzafi on 5/28/17.
//  Copyright © 2017 Paradox Apps. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                self.layer.opacity = 0.5
            } else {
                self.layer.opacity = 1
            }
            
        }
        
    }

}
