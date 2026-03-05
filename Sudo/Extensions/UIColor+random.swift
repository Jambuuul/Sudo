//
//  ColorStuff.swift
//  doabdulovPW1
//
//  Created by Jam on 15.09.2025.
//

import Foundation
import UIKit


extension UIColor {
	
	//MARK: Generates random color in hex, converts it to sRGB
	static var random: UIColor {
		return UIColor(
			displayP3Red: .random(in: 0...1),
			green: .random(in: 0...1),
			blue: .random(in: 0...1),
			alpha: 1
		)
	}
}

