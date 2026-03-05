//
//  BusinessLogic.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


protocol MainMenuBusinessLogic {
    typealias Model = MainMenuModel
    func loadStart(_ request: Model.Start.Request)
	
	func loadNewGame(_ request: Model.NewGame.Request)
	
    // func load(_ request: Model..Request)
}

protocol MainMenuPresentationLogic {
    typealias Model = MainMenuModel
    func presentStart(_ response: Model.Start.Response)
	
	func presentNewGame(_ response: Model.NewGame.Response)
	
    // func present(_ response: Model..Response)
	
	
}
