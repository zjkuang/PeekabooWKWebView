//
//  SmartWebView.swift
//  PeekabooWKWebView
//
//  Created by Zhengqian Kuang on 2020-06-26.
//  Copyright © 2020 Kuang. All rights reserved.
//

import SwiftUI

struct SmartWebView: View {
    @ObservedObject var viewModel = SmartWebViewModel()

    var body: some View {
        VStack {
            Spacer()
            HStack{
                Text("You picked: \(self.viewModel.wordPicked ?? "")")
                Spacer()
            }
            Spacer()
            WrappedWKWebView(postMessageHandlers: [.textClickHandler], customDelegate: viewModel).loadFile(resource: "click_to_select", ext: "html")
            Spacer()
        }
    }
}

struct SmartWebView_Previews: PreviewProvider {
    static var previews: some View {
        SmartWebView()
    }
}
