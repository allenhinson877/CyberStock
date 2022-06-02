//
//  AppDelegate.swift
//  CyberStock
//
//  Created by William Hinson on 3/2/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        
        let navVC = UINavigationController(rootViewController: WatchListController())
        window?.rootViewController = navVC
        
        navVC.navigationBar.prefersLargeTitles = true
        
        debug()
        
//        APICaller.shared.search(query: "Apple") { result in
//            switch result {
//            case .success(let response):
//                print(response.result)
//            case .failure(let error):
//                print(error)
//            }
//        }
        
        return true
    }
    
    private func debug() {
        
        APICaller.shared.marketData(for: "AAPL", numberOfDays: 1) { result in
            print("Result")

            switch result {
            case .success(let data):
                let candleSticks = data.candleSticks
                print("These are the candleSticks: \(candleSticks)")
            case .failure(let error):
                print(error)
            }
        }
        
        print("CALLING DEBUG")
    }

}

