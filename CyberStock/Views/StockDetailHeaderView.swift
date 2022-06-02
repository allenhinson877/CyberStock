//
//  StockDetailHeaderView.swift
//  CyberStock
//
//  Created by William Hinson on 3/7/22.
//

import UIKit

protocol StockDetailHeaderViewDelegate: AnyObject {
    func segmentChanged(_ segmentedControl: StockDetailHeaderView)
    func buttonTapped(_ headerView: StockDetailHeaderView)
}

private let reuseIdent = "MetricCollectionViewCell"

class StockDetailHeaderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let chartView = StockChartView()
    
    private var metricViewModels: [MetricCollectionViewCell.ViewModel] = []
    
    weak var delegate: StockDetailHeaderViewDelegate?
    
    var SDC: StockDetailsController?

    
//    private let segmentItems = ["1D", "1W", "1M", "3M", "1Y", "ALL"]
    let segmentControl: UISegmentedControl = {
       let control = UISegmentedControl(items: ["1D", "1W", "1M", "3M", "14D Predicition"])
        return control
    }()
    
    let button1: UIButton = {
       let button = UIButton()
        button.setTitle("1D", for: .normal)
        button.backgroundColor = .systemBackground
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MetricCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdent)
        return collectionView
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    

    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(chartView)
        addSubview(collectionView)
        addSubview(priceLabel)
        addSubview(timeLabel)
        collectionView.delegate = self
        collectionView.dataSource = self
        segmentControl.addTarget(self, action: #selector(segmentControlTapped), for: .valueChanged)
        segmentControl.selectedSegmentIndex = 0
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        priceLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 0, paddingLeft: 20)
        chartView.frame = CGRect(x: 0, y: 20, width: frame.width, height: frame.height-160)
//        segmentControl.anchor(top: chartView.bottomAnchor, paddingTop: 0)
//        segmentControl.setDimensions(width: frame.width, height: 30)
//        button1.anchor(top: chartView.bottomAnchor, paddingTop: 8)
        timeLabel.anchor(left: priceLabel.rightAnchor, bottom: priceLabel.bottomAnchor, paddingLeft: 8, paddingBottom: 0)
        collectionView.anchor(top: chartView.bottomAnchor, paddingTop: 38)
        collectionView.setDimensions(width: frame.width - 16, height: 100)
        collectionView.centerX(inView: self)
//        collectionView.frame = CGRect(x: 0, y: frame.height-100, width: frame.width, height: 100)
    }
    
    func configure(chartViewModel: StockChartView.vieweModel, metricViewModels: [MetricCollectionViewCell.ViewModel]) {
        chartView.configure(with: chartViewModel)
        priceLabel.textColor = chartViewModel.fillColor
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
    }
    
    @objc func segmentControlTapped() {
        delegate?.segmentChanged(self)
        
    }
    
    @objc func buttonTapped() {
        delegate?.buttonTapped(self)
    }
    
    // MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = metricViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdent, for: indexPath) as? MetricCollectionViewCell else { fatalError() }
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width/2, height: 100/3)
    }
}
