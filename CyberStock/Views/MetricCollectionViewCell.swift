//
//  MetricCollectionViewCell.swift
//  CyberStock
//
//  Created by William Hinson on 3/7/22.
//

import UIKit

class MetricCollectionViewCell: UICollectionViewCell {
    struct ViewModel {
        let name: String
        let value: String
    }
    
    let nameLabel: UILabel = {
       let label = UILabel()
        return label
    }()
    
    let valueLabel: UILabel = {
       let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubview(nameLabel)
        contentView.addSubview(valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        valueLabel.sizeToFit()
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(x: 3, y: 0, width: nameLabel.width, height: contentView.height)
        valueLabel.frame = CGRect(x: nameLabel.right + 3, y: 0, width: valueLabel.width, height: contentView.height)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: ViewModel) {
        nameLabel.text = viewModel.name+": "
        valueLabel.text = viewModel.value
    }
}
