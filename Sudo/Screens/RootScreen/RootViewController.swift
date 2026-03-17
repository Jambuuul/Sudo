//
//  RootViewController.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import UIKit

final class RootViewController: UIViewController {
	typealias Model = RootModel

	// MARK: - Constants
	private enum Const {
		static let fatalError: String = "init(coder:) has not been implemented"
		static let bottomInset: CGFloat = 12
		static let bottomSpacing: CGFloat = 8
	}

	// MARK: - Fields
	private let interactor: RootBusinessLogic
	private var pages: [UIViewController] = []
	private var currentIndex: Int = 1

	// MARK: - Views
	private let pageViewController: UIPageViewController = UIPageViewController(
		transitionStyle: .scroll,
		navigationOrientation: .horizontal
	)
	private let bottomNavigationView: BottomNavigationView = BottomNavigationView()

	// MARK: - Lifecycle
	init(interactor: RootBusinessLogic) {
		self.interactor = interactor
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError(Const.fatalError)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		configureUI()
		interactor.loadStart(.init())
	}

	// MARK: - Setup
	private func configureUI() {
		view.backgroundColor = .systemBackground
		configurePages()
		configurePageViewController()
		configureBottomNavigationView()
	}

	private func configurePages() {
		let saved: UIViewController = SavedGamesAssembly.build()
		let home: UIViewController = MainMenuAssembly.build()
		let stats: UIViewController = StatsAssembly.build()
		pages = [saved, home, stats]
	}

	private func configurePageViewController() {
		addChild(pageViewController)
		view.addSubview(pageViewController.view)
		pageViewController.didMove(toParent: self)

		pageViewController.dataSource = self
		pageViewController.delegate = self
		pageViewController.setViewControllers(
			[pages[currentIndex]],
			direction: .forward,
			animated: false
		)

		pageViewController.view.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
		pageViewController.view.pinLeft(to: view)
		pageViewController.view.pinRight(to: view)
	}

	private func configureBottomNavigationView() {
		view.addSubview(bottomNavigationView)

		bottomNavigationView.pinLeft(to: view, Const.bottomInset)
		bottomNavigationView.pinRight(to: view, Const.bottomInset)
		bottomNavigationView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Const.bottomInset)
		bottomNavigationView.setHeight(BottomNavigationView.height())
		bottomNavigationView.setSelected(.home)

		pageViewController.view.pinBottom(
			to: bottomNavigationView.topAnchor,
			Const.bottomSpacing
		)

		bottomNavigationView.savedButton.addTarget(self, action: #selector(savedButtonPressed), for: .touchUpInside)
		bottomNavigationView.homeButton.addTarget(self, action: #selector(homeButtonPressed), for: .touchUpInside)
		bottomNavigationView.statsButton.addTarget(self, action: #selector(statsButtonPressed), for: .touchUpInside)
	}

	// MARK: - Private methods
	private func setSelectedIndex(_ index: Int, animated: Bool) {
		guard pages.indices.contains(index) else {
			return
		}

		guard index != currentIndex else {
			return
		}

		let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
		pageViewController.setViewControllers([pages[index]], direction: direction, animated: animated)
		currentIndex = index
		updateBottomSelection()
	}

	private func updateBottomSelection() {
		switch currentIndex {
		case 0:
			bottomNavigationView.setSelected(.saved)
		case 1:
			bottomNavigationView.setSelected(.home)
		case 2:
			bottomNavigationView.setSelected(.stats)
		default:
			break
		}
	}

	// MARK: - Actions
	@objc
	private func savedButtonPressed() {
		setSelectedIndex(0, animated: true)
	}

	@objc
	private func homeButtonPressed() {
		setSelectedIndex(1, animated: true)
	}

	@objc
	private func statsButtonPressed() {
		setSelectedIndex(2, animated: true)
	}
}

// MARK: - UIPageViewControllerDataSource
extension RootViewController: UIPageViewControllerDataSource {
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController? {
		guard let index: Int = pages.firstIndex(where: { $0 === viewController }) else {
			return nil
		}

		let newIndex: Int = index - 1
		guard pages.indices.contains(newIndex) else {
			return nil
		}

		return pages[newIndex]
	}

	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController? {
		guard let index: Int = pages.firstIndex(where: { $0 === viewController }) else {
			return nil
		}

		let newIndex: Int = index + 1
		guard pages.indices.contains(newIndex) else {
			return nil
		}

		return pages[newIndex]
	}
}

// MARK: - UIPageViewControllerDelegate
extension RootViewController: UIPageViewControllerDelegate {
	func pageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating finished: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted completed: Bool
	) {
		guard completed else {
			return
		}

		guard let current: UIViewController = pageViewController.viewControllers?.first,
			  let index: Int = pages.firstIndex(where: { $0 === current })
		else {
			return
		}

		currentIndex = index
		updateBottomSelection()
	}
}
