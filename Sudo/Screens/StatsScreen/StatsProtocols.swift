//
//  StatsProtocols.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

protocol StatsBusinessLogic {
	typealias Model = StatsModel
	func loadStart(_ request: Model.Start.Request)
}

protocol StatsPresentationLogic {
	typealias Model = StatsModel
	func presentStart(_ response: Model.Start.Response)
}
