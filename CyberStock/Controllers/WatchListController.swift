//
//  ViewController.swift
//  CyberStock
//
//  Created by William Hinson on 3/2/22.
//

import UIKit

private let reuseIdent = "WatchListTableViewCell"
private let reuseIdent2 = "TopStoriesTableViewCell"



class WatchListController: UIViewController {
    
    private var searchTimer: Timer?
    

    
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListTableViewCell.self, forCellReuseIdentifier: reuseIdent)
        table.register(TopStoriesTableViewCell.self, forCellReuseIdentifier: reuseIdent2)
        return table
    }()
    let refreshControl = UIRefreshControl()

    
    private var observer: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stocks"
        setUpController()
        setUpTableView()
        fetchWatchListData()
        stUpObserver()


    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func setUpController() {
        let resultVC = SearchResultController()
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        resultVC.delegate = self
        navigationItem.searchController = searchVC
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func stUpObserver() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchList, object: nil, queue: .main)
        { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchWatchListData()
        }
    }
    
    
    private func fetchWatchListData() {
        let symbols = PersistenceManager.shared.watchlist
        
        let group = DispatchGroup()
        
        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()
            APICaller.shared.marketDataforToady(for: symbol, numberOfHours: 24 ) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let data):
                    let candleStick = data.candleSticks
                    self?.watchlistMap[symbol] = candleStick
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.creatViewModels()
            self?.tableView.reloadData()
        }
        

    }
    
    private func creatViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        

        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = getChangePercentage(symbol: symbol, data: candleSticks)
            viewModels.append(.init(symbol: symbol, companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company", price: getLatestClosingPrice(from: candleSticks), changeColor: changePercentage < 0 ? .systemRed: .systemGreen, changePercentage: .percentage(from: changePercentage), chartViewModel: .init(data: candleSticks.reversed().map { $0.close }, showLegend: false, showAxis: false, fillColor: changePercentage < 0 ? .systemRed: .systemGreen, label: "")))

        }
        
       
        
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol })
    }
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        guard let latestClose = data.first?.close, let priorClose = data.last?.close else { return  0 }
        
        let diff = 1 - (priorClose/latestClose)
        
        print("Current: \(latestClose) || Prior: \(priorClose)")
        return diff
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        
        return .formatter(number: closingPrice)
    }
}

extension WatchListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, let resultsVC = searchController.searchResultsController as? SearchResultController, !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultsVC.update(with: response.result)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultsVC.update(with: [])
                    }
                    print(error)
                }
            }
        })
    }
}

extension WatchListController: SearchResultsViewControllerDelegate {
    func didSelectSearchResult(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let symbol = searchResult.displaySymbol
        let companyName = searchResult.description
        
        HapticsManager.shared.vibrateForSelection()
        
        let vc = StockDetailsController(symol: symbol, companyName: companyName, candleStickData: [], price: "")
//        vc.title = searchResult.displaySymbol
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)

    }
}


extension WatchListController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
  
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdent, for: indexPath) as? WatchListTableViewCell else { fatalError() }
        
        cell.configure(with: viewModels[indexPath.row])
        
        return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdent2, for: indexPath) as? TopStoriesTableViewCell else { fatalError() }
        
//        cell.configure(with: viewModels[indexPath.row])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            PersistenceManager.shared.removeFromWatchlist(symbol: viewModels[indexPath.row].symbol)
            viewModels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewModel = viewModels[indexPath.row]
        HapticsManager.shared.vibrateForSelection()
        let vc = StockDetailsController(symol: viewModel.symbol, companyName: viewModel.companyName, candleStickData: [], price: viewModel.price)
//        navigationController?.pushViewController(vc, animated: true)
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}

//watchlistMap[viewModel.symbol] ?? []
