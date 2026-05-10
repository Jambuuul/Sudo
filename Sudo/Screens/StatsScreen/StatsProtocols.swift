//
//  StatsProtocols.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

protocol StatsBusinessLogic {
	typealias Model = StatsModel
	func loadStats(_ request: Model.LoadStats.Request)
}

protocol StatsPresentationLogic {
	typealias Model = StatsModel
	func presentStats(_ response: Model.LoadStats.Response)
}

protocol StatsDisplayLogic: AnyObject {
	typealias Model = StatsModel
	func displayStats(_ viewModel: Model.LoadStats.ViewModel)
}
