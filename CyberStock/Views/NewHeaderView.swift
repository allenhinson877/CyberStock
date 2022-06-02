//
//  NewHeaderView.swift
//  CyberStock
//
//  Created by William Hinson on 3/7/22.
//

import UIKit

protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDidTapAddButton(_ headerView: NewHeaderView)
}

class NewHeaderView: UITableViewHeaderFooterView {
    
    struct ViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }
    
    weak var delegate: NewsHeaderViewDelegate?
    
    private let label: UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()
    
    let button: UIButton = {
       let button = UIButton()
        button.setTitle("Add to Watchlist", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        contentView.backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.anchor(left: leftAnchor, paddingLeft: 24)
        label.centerY(inView: self)
        button.centerY(inView: self)
        button.anchor(right: rightAnchor, paddingRight: 24)
        button.setDimensions(width: 150, height: 30)
    }
    
    @objc func didTapButton() {
        delegate?.newsHeaderViewDidTapAddButton(self)
    }
    
   
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure(with viewModel: ViewModel) {
     label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
    }
    
    
}
