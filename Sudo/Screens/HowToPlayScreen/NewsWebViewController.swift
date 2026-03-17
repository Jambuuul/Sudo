//
//  NewsWebViewController.swift
//  Sudo
//
//  Created by Jam on 17.03.2026.
//


import UIKit
import WebKit

final class HowToPlayViewController: UIViewController {
	private let url: URL
	private let webView: WKWebView = .init(frame: .zero)
	
	init(url: URL) {
		self.url = url
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = webView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		webView.load(URLRequest(url: url))
	}
}
