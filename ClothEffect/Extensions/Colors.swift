//
//  Colors.swift
//  ClothEffect
//
//  Created by Kester Atakere on 30/01/2025.
//

import SwiftUI

extension Color {
  init(hex: String) {
    var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")

    // Expand 3-digit hex to 6-digits by duplicating each character
    if cleanHexCode.count == 3 {
      cleanHexCode = cleanHexCode.map { String(repeating: $0, count: 2) }.joined()
    }

    var rgb: UInt64 = 0
    Scanner(string: cleanHexCode).scanHexInt64(&rgb)

    let redValue = Double((rgb >> 16) & 0xFF) / 255.0
    let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
    let blueValue = Double(rgb & 0xFF) / 255.0

    self.init(red: redValue, green: greenValue, blue: blueValue)
  }
}
