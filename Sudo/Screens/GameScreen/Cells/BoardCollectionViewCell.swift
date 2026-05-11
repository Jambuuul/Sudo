//
//  BoardCollectionViewCell.swift
//  Sudo
//
//  Created by Jam on 05.03.2026.
//

import UIKit

final class BoardCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private enum Const {
        static let fatalError: String = "init(coder:) has not been implemented"
        static let thinBorderWidth: CGFloat = 1
        static let thickBorderWidth: CGFloat = 2
        static let zero: CGFloat = 0
        static let borderColor: UIColor = .separator
        static let selectedBackgroundColor: UIColor = UIColor.systemBlue.withAlphaComponent(0.2)
        static let matchingValueBackgroundColor: UIColor = UIColor.systemYellow.withAlphaComponent(0.25)
		static let duplicateRowColumnBackgroundColor: UIColor = UIColor.systemRed.withAlphaComponent(0.12)
        static let givenBackgroundColor: UIColor = .tertiarySystemBackground
        static let editableBackgroundColor: UIColor = .systemBackground
        static let givenTextColor: UIColor = .label
        static let editableTextColor: UIColor = .systemBlue
        static let incorrectTextColor: UIColor = .systemRed
        static let givenFontSize: CGFloat = 20
        static let editableFontSize: CGFloat = 21
        static let cornerRadius: CGFloat = 0
    }

    // MARK: - Static
    static let reuseIdentifier: String = "BoardCollectionViewCell"

    // MARK: - Fields
    private let valueLabel: UILabel = UILabel()
    private let topBorder: CALayer = CALayer()
    private let leftBorder: CALayer = CALayer()
    private let bottomBorder: CALayer = CALayer()
    private let rightBorder: CALayer = CALayer()

    private var topBorderWidth: CGFloat = Const.thinBorderWidth
    private var leftBorderWidth: CGFloat = Const.thinBorderWidth
    private var bottomBorderWidth: CGFloat = Const.thinBorderWidth
    private var rightBorderWidth: CGFloat = Const.thinBorderWidth

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Const.fatalError)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        valueLabel.text = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBordersLayout()
    }

    // MARK: - Public methods
    func configure(with viewModel: BoardModel.CellViewModel, index: Int, boardSize: Int) {
        valueLabel.text = viewModel.valueText
        valueLabel.textColor = makeTextColor(for: viewModel)
        valueLabel.font = makeFont(for: viewModel)
        contentView.backgroundColor = makeBackgroundColor(for: viewModel)
        contentView.layer.cornerRadius = Const.cornerRadius

        updateBorderWidth(index: index, boardSize: boardSize)
        setNeedsLayout()
    }

    // MARK: - Private methods
    private func configureUI() {
        contentView.addSubview(valueLabel)
        valueLabel.textAlignment = .center
        valueLabel.pin(to: contentView)
        configureBorderLayers()
    }

    private func configureBorderLayers() {
        let borders: [CALayer] = [topBorder, leftBorder, bottomBorder, rightBorder]
        for border in borders {
            border.backgroundColor = Const.borderColor.cgColor
            contentView.layer.addSublayer(border)
        }
    }

    private func updateBorderWidth(index: Int, boardSize: Int) {
        let row: Int = index / boardSize
        let column: Int = index % boardSize

        let blockSize: Int = Int(Double(boardSize).squareRoot())
        let isHorizontalBlockStart: Bool = row % blockSize == .zero
        let isVerticalBlockStart: Bool = column % blockSize == .zero
        let isLastRow: Bool = row == (boardSize - 1)
        let isLastColumn: Bool = column == (boardSize - 1)

        topBorderWidth = isHorizontalBlockStart ? Const.thickBorderWidth : Const.thinBorderWidth
        leftBorderWidth = isVerticalBlockStart ? Const.thickBorderWidth : Const.thinBorderWidth
        bottomBorderWidth = isLastRow ? Const.thickBorderWidth : Const.zero
        rightBorderWidth = isLastColumn ? Const.thickBorderWidth : Const.zero
    }

    private func updateBordersLayout() {
        topBorder.frame = CGRect(
            x: Const.zero,
            y: Const.zero,
            width: contentView.bounds.width,
            height: topBorderWidth
        )

        leftBorder.frame = CGRect(
            x: Const.zero,
            y: Const.zero,
            width: leftBorderWidth,
            height: contentView.bounds.height
        )

        bottomBorder.frame = CGRect(
            x: Const.zero,
            y: contentView.bounds.height - bottomBorderWidth,
            width: contentView.bounds.width,
            height: bottomBorderWidth
        )

        rightBorder.frame = CGRect(
            x: contentView.bounds.width - rightBorderWidth,
            y: Const.zero,
            width: rightBorderWidth,
            height: contentView.bounds.height
        )
    }

    private func makeBackgroundColor(for viewModel: BoardModel.CellViewModel) -> UIColor {
        if viewModel.isSelected {
            return Const.selectedBackgroundColor
        }

        if viewModel.isMatchingSelectedValue {
            return Const.matchingValueBackgroundColor
        }

		if viewModel.isInDuplicateRowOrColumn {
			return Const.duplicateRowColumnBackgroundColor
		}

        return viewModel.isGiven ? Const.givenBackgroundColor : Const.editableBackgroundColor
    }

    private func makeTextColor(for viewModel: BoardModel.CellViewModel) -> UIColor {
        if viewModel.isIncorrect {
            return Const.incorrectTextColor
        }

        return viewModel.isGiven ? Const.givenTextColor : Const.editableTextColor
    }

    private func makeFont(for viewModel: BoardModel.CellViewModel) -> UIFont {
        if viewModel.isGiven {
            return .systemFont(ofSize: Const.givenFontSize, weight: .bold)
        }

        return .systemFont(ofSize: Const.editableFontSize, weight: .semibold)
    }
}
