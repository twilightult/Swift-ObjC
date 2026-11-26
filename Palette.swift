import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue:  Double(hex & 0xFF) / 255, opacity: 1)
    }
}

/// 蓝紫低饱和「浅变色」：底色近白，主视觉集中在横幅与启动按钮。
enum Palette {
    static let bgTop     = Color(hex: 0xF6F7FE)
    static let bgBottom  = Color(hex: 0xECE8FB)
    static let bannerTop = Color(hex: 0xD8E2FF)
    static let bannerBot = Color(hex: 0xC6B0F4)
    static let accentTop = Color(hex: 0x7C8CFA)   // 蓝
    static let accentBot = Color(hex: 0xA96BF2)   // 紫
    static let surface   = Color.white
    static let line      = Color(hex: 0xE1E3F2)
    static let ink       = Color(hex: 0x2B2E4A)
    static let sub       = Color(hex: 0x7A7E9C)
    static let cardA     = Color(hex: 0xCDD7FF)
    static let cardB     = Color(hex: 0xDCD2F8)
    static let cardC     = Color(hex: 0xD6E2FA)

    static var background: LinearGradient {
        LinearGradient(colors: [bgTop, bgBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var banner: LinearGradient {
        LinearGradient(colors: [bannerTop, bannerBot], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    /// 图标 / 启动按钮共用：蓝 -> 紫
    static var accent: LinearGradient {
        LinearGradient(colors: [accentTop, accentBot], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
