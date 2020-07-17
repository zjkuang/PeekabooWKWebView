//
//  SmartWebViewModel.swift
//  PeekabooWKWebView
//
//  Created by Zhengqian Kuang on 2020-06-26.
//  Copyright © 2020 Kuang. All rights reserved.
//

import Foundation

class SmartWebViewModel: ObservableObject, WrappedWKWebViewEventDelegate {
    @Published var wordPicked: String? = nil
    
    func didHappen(event: WrappedWKWebViewEvent, info: Any?) {
        wordPicked = info as? String
    }
}
