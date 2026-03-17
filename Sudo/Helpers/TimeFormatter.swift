//
//  TimeFormatter.swift
//  Sudo
//
//  Created by Jam on 16.03.2026.
//

import Foundation

enum TimeFormatter {
	static func makeTimeText(elapsedSeconds: Int) -> String {
		let totalSeconds: Int = max(0, elapsedSeconds)
		let minutes: Int = totalSeconds / 60
		let seconds: Int = totalSeconds % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
}
