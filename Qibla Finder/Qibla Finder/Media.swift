//
//  Media.swift
//  Qibla Finder
//
//  Created by sardar saqib on 04/03/2025.
//

import SwiftUI

public enum Media {
    public enum Color {
        public static let accent = SwiftUI.Color("#490094")
        public static let primary = SwiftUI.Color("#FFFFFF")
    }

    public enum Image {
        public static let compassNeedle = SwiftUI.Image("needle", bundle: .main)
        public static let directionCompass = SwiftUI.Image("directionCompass", bundle: .main)
    }
}

