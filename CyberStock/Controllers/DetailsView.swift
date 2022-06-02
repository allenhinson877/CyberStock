//
//  DetailsView.swift
//  CyberStock
//
//  Created by William Hinson on 3/8/22.
//

import SwiftUI
import SwiftUICharts


struct DetailsView: View {
    var demoData: [Double] = [8, 2, 4, 6, 12, 9, 2]
    var body: some View {
        LineView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Full screen") // legend is optional, use optional .padding()
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView()
    }
}
