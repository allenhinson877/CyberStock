//
//  WatchListTableViewCell.swift
//  CyberStock
//
//  Created by William Hinson on 3/4/22.
//

import UIKit

class WatchListTableViewCell: UITableViewCell {
    static let identifier = "WatchListIdentifier"
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String
        let changeColor: UIColor
        let changePercentage: String
        let chartViewModel: StockChartView.vieweModel
    }
    
    private let symLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let priceLable: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        return label
    }()
    
    private let changeContainer: UIView = {
       let view = UIView()
        
       return view
    }()
    
    private let miniChartView: StockChartView = {
       let chart = StockChartView()
        chart.clipsToBounds = true
        chart.isUserInteractionEnabled = false
        chart.chartView.animate(xAxisDuration: 0)
        return chart
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubview(symLabel)
        addSubview(companyLabel)
        addSubview(priceLable)
        addSubview(changeLabel)
        addSubview(changeContainer)
        addSubview(miniChartView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        symLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 24)
//        companyLabel.anchor(top: symLabel.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 24)
        
        priceLable.anchor(top: topAnchor, right: rightAnchor, paddingTop: 16, paddingRight: 24)
        changeLabel.anchor(top: priceLable.bottomAnchor, right: rightAnchor, paddingTop: 8, paddingRight: 24)
        changeLabel.setDimensions(width: 60, height: 20)
        miniChartView.anchor(right: changeLabel.leftAnchor, paddingRight: 20)
        miniChartView.centerY(inView: self)
        miniChartView.setDimensions(width: 100, height: 60)
        
        let labelStack = UIStackView(arrangedSubviews: [symLabel, companyLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 8
        self.contentView.addSubview(labelStack)
        labelStack.anchor(left: leftAnchor, right: miniChartView.leftAnchor, paddingLeft: 24, paddingRight: 8)
        labelStack.centerY(inView: self)
        

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symLabel.text = nil
        companyLabel.text = nil
        priceLable.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    
    public func configure(with viewModel: ViewModel) {
        symLabel.text = viewModel.symbol
        companyLabel.text = viewModel.companyName
        priceLable.text = "$"+viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        miniChartView.configure(with: viewModel.chartViewModel)
    }
}
