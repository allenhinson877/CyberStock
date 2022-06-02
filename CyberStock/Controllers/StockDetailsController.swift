//
//  StockDetailsViewController.swift
//  CyberStock
//
//  Created by William Hinson on 3/2/22.
//

import Foundation
import UIKit
import SafariServices
import CoreML


private let reuseIdent = "NewHeaderView"

class StockDetailsController: UIViewController {
    
    private let symbol: String
    private let companyName: String
    private let price: String
    private var candleStickData: [CandleStick] = []
    private var candleStickData2: [CandleStick] = []
    private var candleStickData3: [CandleStick] = []
    private var candleStickData4: [CandleStick] = []
    private var candleStickData5: [CandleStick] = []
    private var quoteData: [Quote] = []
    
    var rightBarButton: UIBarButtonItem!
    
    private let tableView: UITableView = {
      let table = UITableView()
//        table.register(NewHeaderView.self, forHeaderFooterViewReuseIdentifier: reuseIdent)
        table.register(NewsStoryTableViewCell.self,
                       forCellReuseIdentifier: NewsStoryTableViewCell.identfier)

        return table
    }()
    
    private let segmentControl: UISegmentedControl = {
       let control = UISegmentedControl(items: ["2D", "1W", "1M", "1Y", "2W Pred"])
        
        return control
    }()
    
   private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private var stories: [NewsStory] = []
    
    private var metrics: Metrics?
    
    var model: converted_model!

    
    init(symol: String, companyName: String, candleStickData: [CandleStick] = [], price: String) {
        self.symbol = symol
        self.companyName = companyName
        self.candleStickData = candleStickData
        self.price = price
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = companyName
        setupTableView()
        self.candleStickData = []
        self.rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        segmentControl.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
        segmentControl.selectedSegmentIndex = 1
        if segmentControl.selectedSegmentIndex == 1 {
//            fetchFinancialDataToday(for: 6.5, labelText: "1 Day", secondLabelText: "Today")
            fetchFinancialData(for: 7, labelText: "1 Week", secondLabelText: "Past Week")
            
        }
        fetchQuoteData2(for: 40, labelText: "", secondLabelText: "")
        setupAddToWatchListButton()
        fetchNews()
    }

    func convertToMLMultiArray(from array: [Double]) -> MLMultiArray {
        let length = NSNumber(value: array.count)
        
        // Define shape of array
        guard let mlMultiArray = try? MLMultiArray(shape:[1, 14, 1], dataType:MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        
        // Insert elements
        for (index, element) in array.enumerated() {
            mlMultiArray[index] = NSNumber(floatLiteral: element)
        }
        
        return mlMultiArray
    }
    
    func convertToArray(from mlMultiArray: MLMultiArray) -> Double {
        
        // Init our output array
        var double = 0.0
        
        // Get length
        let length = mlMultiArray.count
        
        // Set content of multi array to our out put array
        for i in 0...length - 1 {
            double = Double(truncating: mlMultiArray[[0,NSNumber(value: i)]])
        }
        
        return double
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.width * 0.7) + 180))
    }
    
    private func setupAddToWatchListButton() {
        if !PersistenceManager.shared.watchlistContains(symbol: symbol) {
            self.navigationItem.rightBarButtonItem = self.rightBarButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func fetchFinancialData(for timeInterval: Double, labelText: String, secondLabelText: String) {
        let group = DispatchGroup()
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.marketData(for: symbol, numberOfDays: timeInterval) { [weak self]result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main ) { [weak self] in
            self?.renderChart(for: labelText, labelText: secondLabelText)
        }
        
    }
    
    func fetchFinancialDataMonth(for timeInterval: Double, labelText: String, secondLabelText: String) {
        let group = DispatchGroup()
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.monthMarketData(for: symbol, numberOfDays: timeInterval) { [weak self]result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main ) { [weak self] in
            self?.renderChart(for: labelText, labelText: secondLabelText)
        }
        
    }
    
    func fetchFinancialDataYear(for timeInterval: Double, labelText: String, secondLabelText: String) {
        let group = DispatchGroup()
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.yearMarketData(for: symbol, numberOfDays: timeInterval) { [weak self]result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main ) { [weak self] in
            self?.renderChart(for: labelText, labelText: secondLabelText)
        }
        
    }
    
    func fetchQuoteData(for timeInterval: Double, labelText: String, secondLabelText: String) {
        let group = DispatchGroup()
        if candleStickData2.isEmpty {
            group.enter()
            APICaller.shared.intraDayMarketData(for: symbol, numberOfDays: timeInterval) { [weak self]result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData2 = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main ) { [weak self] in
            self?.renderChartPrediction(for: labelText, labelText: secondLabelText)
            print("TRYING TO RENDER CHART")
        }

    }
    
    func fetchQuoteData2(for timeInterval: Double, labelText: String, secondLabelText: String) {
        let group = DispatchGroup()
        if candleStickData2.isEmpty {
            group.enter()
            APICaller.shared.intraDayMarketData(for: symbol, numberOfDays: timeInterval) { [weak self]result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData2 = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main ) { [weak self] in
//            self?.renderChartPrediction(for: labelText, labelText: secondLabelText)
//            print("TRYING TO RENDER CHART")
            print("This is the prediction data \(String(describing: self?.candleStickData2))")
        }

    }
    
    func fetchFinancialDataToday(for timeInterval: Double, labelText: String, secondLabelText: String) {
        let group = DispatchGroup()
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.marketDataforToady(for: symbol, numberOfHours: timeInterval) { [weak self]result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                    print("Response \(response.close)")
                case .failure(let error):
                    print(error)
                }
            }
        }
        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main ) { [weak self] in
            self?.renderChart(for: labelText, labelText: secondLabelText)
        }
        
    }
    
    private func fetchNews() {
        APICaller.shared.news(for: .compan(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    @objc private func didTapAdd() {
        PersistenceManager.shared.addToWatchlist(symbol: symbol, companyName: companyName)
        HapticsManager.shared.vibrateForSelection()
        let alert = UIAlertController(title: "Added to Watchlist", message: "We've added \(companyName) to your watchlist.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc func segmentControl(_ segmentedControl: UISegmentedControl) {
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            self.candleStickData = []
            HapticsManager.shared.vibrateForSelection()
            fetchFinancialData(for: 2, labelText: "2 Days", secondLabelText: "Past Two Days")
        case 1:
            self.candleStickData = []
            HapticsManager.shared.vibrateForSelection()
            fetchFinancialData(for: 7, labelText: "1 Week", secondLabelText: "Past Week")
        case 2:
            self.candleStickData = []
            HapticsManager.shared.vibrateForSelection()
            fetchFinancialDataMonth(for: 30, labelText: "1 Month", secondLabelText: "Past Month")
        case 3:
            self.candleStickData = []
            HapticsManager.shared.vibrateForSelection()
            fetchFinancialDataYear(for: 365, labelText: "1 Year", secondLabelText: "Past Year")
        case 4:
            HapticsManager.shared.vibrateForSelection()
            fetchQuoteData(for: 40, labelText: "2 Week Prediction", secondLabelText: "2 Week Prediction")
        default:
            print("DEFAULT")
        }
    }
    
    private func renderChart(for timeInterval: String, labelText: String) {
        let headerView = StockDetailHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.width * 0.7) + 200))
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        var viewModels2 = [WatchListTableViewCell.ViewModel]()
        if let metrics = metrics{
            viewModels.append(.init(name: "52w High", value: "\(metrics.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52w Low", value: "\(metrics.AnnualWeekLow)"))
            viewModels.append(.init(name: "52w Return", value: "\(metrics.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol. ", value: "\(metrics.TenDayAverageTradingVolume)"))

        }
        let change = getChangePercentage(symbol: symbol, data: candleStickData)
        headerView.configure(chartViewModel: .init(data: candleStickData.reversed().map { $0.close }, showLegend: true, showAxis: true, fillColor: change < 0 ? .systemRed : .systemGreen, label: timeInterval), metricViewModels: viewModels)
        headerView.addSubview(segmentControl)
        headerView.priceLabel.text = "$"+price
        headerView.timeLabel.text = labelText
        segmentControl.anchor(top: headerView.chartView.bottomAnchor, paddingTop: 0)
        segmentControl.setDimensions(width: headerView.frame.width - 4, height: 30)
        segmentControl.centerX(inView: headerView)
        tableView.tableHeaderView = headerView
        
        print(candleStickData.reversed().map { $0.date })
 
    }
    
    private func renderChartPrediction(for timeInterval: String, labelText: String) {
        let headerView = StockDetailHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.width * 0.7) + 200))
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        var viewModels2 = [WatchListTableViewCell.ViewModel]()
        if let metrics = metrics{
            viewModels.append(.init(name: "52w High", value: "\(metrics.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52w Low", value: "\(metrics.AnnualWeekLow)"))
            viewModels.append(.init(name: "52w Return", value: "\(metrics.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol. ", value: "\(metrics.TenDayAverageTradingVolume)"))
//            viewModels.append(.init(name: "Model Accuracy", value: "92.34%"))

        }
        
 
            do {
                let data = candleStickData2.reversed().map { $0.close }
                let config = MLModelConfiguration()
                let model = try converted_model(configuration: config)
                guard let mlMultiArray1 = try? MLMultiArray(shape: [1,14,1], dataType: MLMultiArrayDataType.float32) else {
                    fatalError()
                }
                guard let mlMultiArray2 = try? MLMultiArray(shape: [1,14,1], dataType: MLMultiArrayDataType.float32) else {
                    fatalError()
                }
                guard let mlMultiArray3 = try? MLMultiArray(shape: [1,14,1], dataType: MLMultiArrayDataType.float32) else {
                    fatalError()
                }
                
                guard let mlMultiArray4 = try? MLMultiArray(shape: [1,14,1], dataType: MLMultiArrayDataType.float32) else {
                    fatalError()
                }
                guard let mlMultiArray5 = try? MLMultiArray(shape: [1,14,1], dataType: MLMultiArrayDataType.float32) else {
                    fatalError()
                }
                guard let mlMultiArray6 = try? MLMultiArray(shape: [1,14,1], dataType: MLMultiArrayDataType.float32) else {
                    fatalError()
                }
                
                guard let mlMultiArray7 = try? MLMultiArray(shape: [1,14,1], dataType: MLMultiArrayDataType.float32) else {
                    fatalError()
                }
                guard let mlMultiArray8 = try? MLMultiArray(shape: [1,14,1], dataType: MLMultiArrayDataType.float32) else {
                    fatalError()
                }
                guard let mlMultiArray9 = try? MLMultiArray(shape: [1,14,1], dataType: MLMultiArrayDataType.float32) else {
                    fatalError()
                }
                
                guard let mlMultiArray10 = try? MLMultiArray(shape: [1,14,1], dataType: MLMultiArrayDataType.float32) else {
                    fatalError()
                }

                
                let count = 14
                for i in 0..<count {
                    mlMultiArray1[i] = NSNumber(floatLiteral: data.reversed()[i])
                    print(mlMultiArray1[i])
                }
                
                for i in 0..<count {
                    mlMultiArray2[i] = NSNumber(floatLiteral: data.reversed()[i+1])
                }
                
                for i in 0..<count {
                    mlMultiArray3[i] = NSNumber(floatLiteral: data.reversed()[i+2])
                }
                
                for i in 0..<count {
                    mlMultiArray4[i] = NSNumber(floatLiteral: data.reversed()[i+3])
                }
                
                for i in 0..<count {
                    mlMultiArray5[i] = NSNumber(floatLiteral: data.reversed()[i+4])
                }
                
                for i in 0..<count {
                    mlMultiArray6[i] = NSNumber(floatLiteral: data.reversed()[i+5])
                }
                
                for i in 0..<count {
                    mlMultiArray7[i] = NSNumber(floatLiteral: data.reversed()[i+6])
                }
                
                for i in 0..<count {
                    mlMultiArray8[i] = NSNumber(floatLiteral: data.reversed()[i+7])
                }
                
                for i in 0..<count {
                    mlMultiArray9[i] = NSNumber(floatLiteral: data.reversed()[i+8])
                }
                
                for i in 0..<count {
                    mlMultiArray10[i] = NSNumber(floatLiteral: data.reversed()[i+9])
                }
                
                var array : [Double] = []
                

                
                let input1 = converted_modelInput(lstm_input: mlMultiArray1)
                let output1 = try model.prediction(input: input1)
                array.append(convertToArray(from: output1.Identity))
                
                let input2 = converted_modelInput(lstm_input: mlMultiArray2)
                let output2 = try model.prediction(input: input2)
                array.append(convertToArray(from: output2.Identity))
                
                let input3 = converted_modelInput(lstm_input: mlMultiArray3)
                let output3 = try model.prediction(input: input3)
                array.append(convertToArray(from: output3.Identity))
                
                let input4 = converted_modelInput(lstm_input: mlMultiArray4)
                let output4 = try model.prediction(input: input4)
                array.append(convertToArray(from: output4.Identity))
                
                let input5 = converted_modelInput(lstm_input: mlMultiArray5)
                let output5 = try model.prediction(input: input5)
                array.append(convertToArray(from: output5.Identity))
                
                let input6 = converted_modelInput(lstm_input: mlMultiArray6)
                let output6 = try model.prediction(input: input6)
                array.append(convertToArray(from: output6.Identity))
                
                let input7 = converted_modelInput(lstm_input: mlMultiArray7)
                let output7 = try model.prediction(input: input7)
                array.append(convertToArray(from: output7.Identity))
                
                let input8 = converted_modelInput(lstm_input: mlMultiArray8)
                let output8 = try model.prediction(input: input8)
                array.append(convertToArray(from: output8.Identity))
                
                let input9 = converted_modelInput(lstm_input: mlMultiArray9)
                let output9 = try model.prediction(input: input9)
                array.append(convertToArray(from: output9.Identity))
                
                let input10 = converted_modelInput(lstm_input: mlMultiArray10)
                let output10 = try model.prediction(input: input10)
                array.append(convertToArray(from: output10.Identity))
                
                let change = getChangePercentagePrediction(symbol: symbol, data: array)
                headerView.configure(chartViewModel: .init(data: array, showLegend: true, showAxis: true, fillColor: change < 0 ? .systemRed : .systemGreen, label: timeInterval), metricViewModels: viewModels)
                headerView.addSubview(segmentControl)
                headerView.priceLabel.text = "$" + .formatter(number: change)
                headerView.timeLabel.text = labelText
                segmentControl.anchor(top: headerView.chartView.bottomAnchor, paddingTop: 0)
                segmentControl.setDimensions(width: headerView.frame.width - 4, height: 30)
                segmentControl.centerX(inView: headerView)
                tableView.tableHeaderView = headerView
                
            } catch {
                
            }
        

        
 
    }
    
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
//        let latestDate = data[1].date
        guard let latestClose = data.first?.close, let priorClose = data.last?.close else { return  0 }
        

        let diff = 1 - (priorClose/latestClose)
        return diff
    }
    
    private func getChangePercentagePrediction(symbol: String, data: [Double]) -> Double {
//        let latestDate = data[0]
        let latestClose = data.last!
        let priorClose = data.first!
        

        let diff = latestClose - priorClose
        print(diff)
        return diff
    }

}

extension StockDetailsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identfier,
                                                       for: indexPath) as? NewsStoryTableViewCell else {
            fatalError()
        }
                
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: stories[indexPath.row].url) else { return }

        HapticsManager.shared.vibrateForSelection()

        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}

extension StockDetailsController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewHeaderView) {
        headerView.button.isHidden = true
    }
}

