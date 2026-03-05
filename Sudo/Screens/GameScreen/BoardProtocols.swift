//
//  BusinessLogic.swift
//  Sudo
//
//  Created by Jam on 04.03.2026.
//


protocol BoardBusinessLogic {
    typealias Model = BoardModel
    func loadStart(_ request: Model.Start.Request)
    func selectCell(_ request: Model.SelectCell.Request)
    func inputDigit(_ request: Model.InputDigit.Request)
    func clearCell(_ request: Model.ClearCell.Request)
    // func load(_ request: Model..Request)
}

protocol BoardPresentationLogic {
    typealias Model = BoardModel
    func presentStart(_ response: Model.Start.Response)
    func presentBoardChanged(_ response: Model.BoardChanged.Response)
    // func present(_ response: Model..Response)
}

protocol BoardDisplayLogic: AnyObject {
    typealias Model = BoardModel
    func displayStart(_ viewModel: Model.Start.ViewModel)
    func displayBoardChanged(_ viewModel: Model.BoardChanged.ViewModel)
}
