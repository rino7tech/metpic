//
//  IsometricView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/24.
//


import SwiftUI

struct CustomProjection: GeometryEffect {
    var value: CGFloat

    var animatableData: CGFloat {
        get {
            return value
        }
        set {
            value = newValue
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        var transform = CATransform3DIdentity
        transform.m11 = (value == 0 ? 0.0001 : value)
        return .init(transform)
    }
}


struct IsometricView<Content: View, Bottom: View, Side: View>: View {
    var content: Content
    var bottom: Bottom
    var side: Side
    var depth: CGFloat

    init(depth: CGFloat,@ViewBuilder content: @escaping()->Content, @ViewBuilder bottom: @escaping()->Bottom, @ViewBuilder side: @escaping()->Side) {
        self.depth = depth
        self.content = content()
        self.bottom = bottom()
        self.side = side()
    }
    var body: some View {
        Color.clear
            .overlay {
                GeometryReader {
                    let size = $0.size

                    ZStack {
                        content
                        DepthView(isBottom: true, size: size)
                        DepthView(size: size)
                    }
                    .frame(width: size.width, height: size.height)
                }
            }
    }

    @ViewBuilder
    func DepthView(isBottom: Bool = false, size: CGSize) -> some View {
        ZStack {
            if isBottom {
                bottom
                    .scaleEffect(y: depth, anchor: .bottom)
                    .frame(height: depth, alignment: .bottom)
                    .overlay(content: {
                        Rectangle()
                            .fill(Color.black.opacity(0.25))
                            .blur(radius: 2.5)
                    })

                    .clipped()
                    .projectionEffect(.init(.init(a: 1, b: 0, c: 1, d: 1, tx: 0, ty: 0)))
                    .offset(y: depth)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            } else {
                side
                    .scaleEffect(x: depth, anchor: .trailing)
                    .frame(width: depth, alignment: .trailing)
                    .overlay(content: {
                        Rectangle()
                            .fill(Color.black.opacity(0.25))
                            .blur(radius: 2.5)
                    })

                    .clipped()
                    .projectionEffect(.init(.init(a: 1, b: 1, c: 0, d: 1, tx: 0, ty: 0)))
                    .offset(x: depth)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

