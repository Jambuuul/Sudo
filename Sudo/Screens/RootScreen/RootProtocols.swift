//
//  RootProtocols.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

protocol RootBusinessLogic {
	typealias Model = RootModel
	func loadStart(_ request: Model.Start.Request)
}

protocol RootPresentationLogic {
	typealias Model = RootModel
	func presentStart(_ response: Model.Start.Response)
}
