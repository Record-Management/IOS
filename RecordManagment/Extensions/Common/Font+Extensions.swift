import SwiftUI

struct Typography {
    let font: Font
    let size: CGFloat
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
    let weight: Font.Weight
}

extension Typography {
    static let p22Bold = Typography(
        font: .custom("Pretendard", size: 22),
        size: 22,
        lineHeight: 22 * 1.5,
        letterSpacing: 0,
        weight: .bold
    )

    static let p20Bold = Typography(
        font: .custom("Pretendard-Bold", size: 20),
        size: 20,
        lineHeight: 20 * 1.5,
        letterSpacing: 0,
        weight: .bold
    )

    static let p20SemiBold = Typography(
        font: .custom("Pretendard-SemiBold", size: 20),
        size: 20,
        lineHeight: 20 * 1.5,
        letterSpacing: 0,
        weight: .semibold
    )

    static let p18SemiBold = Typography(
        font: .custom("Pretendard-SemiBold", size: 18),
        size: 18,
        lineHeight: 18 * 1.5,
        letterSpacing: 0,
        weight: .semibold
    )

    static let p18Medium = Typography(
        font: .custom("Pretendard-Medium", size: 18),
        size: 18,
        lineHeight: 18 * 1.5,
        letterSpacing: 0,
        weight: .medium
    )

    static let p16SemiBold = Typography(
        font: .custom("Pretendard-SemiBold", size: 16),
        size: 16,
        lineHeight: 16 * 1.5,
        letterSpacing: 0,
        weight: .semibold
    )

    static let p16Medium = Typography(
        font: .custom("Pretendard-Medium", size: 16),
        size: 16,
        lineHeight: 16 * 1.5,
        letterSpacing: 0,
        weight: .medium
    )

    static let p16Regular = Typography(
        font: .custom("Pretendard-Regular", size: 16),
        size: 16,
        lineHeight: 16 * 1.5,
        letterSpacing: 0,
        weight: .regular
    )

    static let p14SemiBold = Typography(
        font: .custom("Pretendard-SemiBold", size: 14),
        size: 14,
        lineHeight: 14 * 1.5,
        letterSpacing: 0,
        weight: .semibold
    )

    static let p14Medium = Typography(
        font: .custom("Pretendard-Medium", size: 14),
        size: 14,
        lineHeight: 14 * 1.5,
        letterSpacing: 0,
        weight: .medium
    )

    static let p14Regular = Typography(
        font: .custom("Pretendard-Regular", size: 14),
        size: 14,
        lineHeight: 14 * 1.5,
        letterSpacing: 0,
        weight: .regular
    )

    static let p12Medium = Typography(
        font: .custom("Pretendard-Medium", size: 12),
        size: 12,
        lineHeight: 12 * 1.5,
        letterSpacing: 0,
        weight: .medium
    )

    static let p12Regular = Typography(
        font: .custom("Pretendard-Regular", size: 12),
        size: 12,
        lineHeight: 12 * 1.5,
        letterSpacing: 0,
        weight: .regular
    )

    static let p10Medium = Typography(
        font: .custom("Pretendard-Medium", size: 10),
        size: 10,
        lineHeight: 10 * 1.2,
        letterSpacing: 0,
        weight: .medium
    )
}

extension Text {
    func typography(_ style: Typography) -> some View {
        self.font(style.font)
            .fontWeight(style.weight)
            .lineSpacing(style.lineHeight - style.size)
            .kerning(style.letterSpacing)
    }
}

extension ButtonStyleConfiguration.Label {
    func typography(_ style: Typography) -> some View {
        self.font(style.font)
            .fontWeight(style.weight)
            .lineSpacing(style.lineHeight - style.size)
            .kerning(style.letterSpacing)
    }
}
