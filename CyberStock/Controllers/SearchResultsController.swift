//
//  SearchResultsController.swift
//  CyberStock
//
//  Created by William Hinson on 3/2/22.
//

import Foundation
import UIKit

private let reuseIdent = "SearchResultsTableViewCell"

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didSelectSearchResult(searchResult: SearchResult)
}
class SearchResultController: UIViewController {
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var results: [SearchResult] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(SearchResultsTableViewCell.self, forCellReuseIdentifier: reuseIdent)
        table.isHidden = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results: [SearchResult]) {
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }
}

extension SearchResultController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdent, for: indexPath) as! SearchResultsTableViewCell
        
        let model = results[indexPath.row]
        
        cell.textLabel?.text = model.description
        cell.detailTextLabel?.text = model.displaySymbol
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = results[indexPath.row]
        delegate?.didSelectSearchResult(searchResult: model)
    }
}
