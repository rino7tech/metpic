//
//  CustomCornerShape.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/27.
//

import SwiftUI

struct CustomCornerShape: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)

        path.move(to: CGPoint(x: topLeft.x + radius, y: topLeft.y))
        path.addArc(
            center: CGPoint(x: topLeft.x + radius, y: topLeft.y + radius),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(180),
            clockwise: true
        )
        path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - radius))
        path.addArc(
            center: CGPoint(x: bottomLeft.x + radius, y: bottomLeft.y - radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(90),
            clockwise: true
        )
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
        path.addLine(to: CGPoint(x: topRight.x, y: topRight.y))

        path.closeSubpath()

        return path
    }
}
