//
//  SearchResultsTableViewCell.swift
//  CyberStock
//
//  Created by William Hinson on 3/2/22.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {

    static let reuseIdent = "SearchResultsTableViewCell"
    
    let label: UILabel = {
       let label = UILabel()
       label.text = "AAPL"
       return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
