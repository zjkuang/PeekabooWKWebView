# PeekabooWKWebView
A WKWebView providing pickability of its HTML content, wrapped as UIViewRepresentable to be available for SwiftUI
## Motivation
In one of my iOS project, I was displaying a massive reading material stored in SQLite resource. The material shall be rendered in RTF and the view also needs to support tap-to-pick-word. I was planning to convert the material to HTML and render it in a WKWebView. Unfortunately I did not find a way to accomplish tap-to-pick-word in a WKWebView. I tried some jquery script solution in the HTML header which worked perfectly only with a browser like Safari but was stopped by WKWebView. Having regretfully given up the HTML+WKWebView, I turned to AttributedText+UITextView. Almost one year later, I happened to read [an artical](https://medium.com/john-lewis-software-engineering/ios-wkwebview-communication-using-javascript-and-swift-ee077e0127eb) which completely solved my problem.
## Implementation
* I choose SwiftUI to demonstrate this idea. By the time this example is created, SwiftUI does not have a native WebView yet so I have to wrap up a WKWebView as UIViewRepresentable, which is PeekabooWKWebView.swift (peekaboo stands for pickable) in this project. For your future convenience to add this file to your Swift Package, all the types in PeekabooWKWebView.swift are declared as "public" when necessary.
* The key to the solution is a little tricky, achieved by several parts: (1) A jquery script in click_to_select.html header to detect the clicking and post the message, (2) A userContentController method in PeekabooWKWebView.swift to list to the message posted and then call the delegate, and (3) SmartWebViewModel.swift, which is the delegate, to receive the event and update the view.
## Meaning
This solution is not narrowed in just picking up a word in an HTML page. It actually opened the passage between the JavaScript code within the HTML content and the native iOS View.
## Run
Tap a word on the sentence "Baa Baa Black Sheep" and the word you tapped will be shown on the topmost of the view.

![](https://github.com/zjkuang/WKWebViewClickToPickWord/blob/master/ScreenRecording.gif)
