//
//  IntradayMarketResponseData.swift
//  CyberStock
//
//  Created by William Hinson on 4/11/22.
//

import Foundation

struct IntradayMarketResponseData: Codable {
    let open: [Double]
    let high: [Double]
    let low: [Double]
    let currentPrice: [Double]
    let previousClose: [Double]
    let timestamps: [TimeInterval]

    enum CodingKeys: String, CodingKey {
        case open = "o"
        case low = "l"
        case previousClose = "pc"
        case high = "h"
        case currentPrice = "c"
        case timestamps = "t"
    }
    
    var quotes: [Quote] {
        var result = [Quote]()

        for index in 0..<open.count {
            result.append(
                .init(
                    date: Date(timeIntervalSince1970: timestamps[index]),
                    high: high[index],
                    low: low[index],
                    open: open[index],
                    previousClose: previousClose[index],
                    currentPrice: currentPrice[index]
                )
            )
        }

        let sortedData = result.sorted(by: { $0.date > $1.date })
        return sortedData
    }
}

struct Quote {
    let date: Date
    let high: Double
    let low: Double
    let open: Double
    let previousClose: Double
    let currentPrice: Double
}
