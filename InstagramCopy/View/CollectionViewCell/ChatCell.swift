//
//  ChatCell.swift
//  InstagramCopy
//
//  Created by Khouv Tannhuot on 7/3/21.
//

import UIKit

class ChatCell: UICollectionViewCell {
    //MARK: - Properties
    static let reuseIdentifire = String(describing: self)
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
