//
//  DistortionEffect.swift
//  InfiniteCards
//
//  Created by Kester Atakere on 30/01/2025.
//

import SwiftUI

struct DistortionEffect: View {
  @State private var touchLocation: CGPoint? = nil

  var body: some View {
    VStack {
      GeometryReader { geometry in
        CanvasView(touchLocation: $touchLocation)
          .overlay(
            Rectangle()
              .fill(
                AngularGradient(
                  colors: [.red, .teal, .blue, Color(hex: "#6A9D94"), .indigo, .red],
                  center: .center
                )
              )
              .mask(CanvasView(touchLocation: $touchLocation))
              .allowsHitTesting(false)
          )
      }
    }
    .background(Color.black)

  }
}

struct CanvasView: View {
  let rows = 12
  let cols = 20
  let padding: CGFloat = 24
  let spacing: CGFloat = 2.4
  let cornerRadius: CGFloat = 5
  @Binding var touchLocation: CGPoint?

  var body: some View {
    GeometryReader { geometry in
      Canvas { context, size in

        let maxDistance: CGFloat = 180
        let forceFactor: CGFloat = 0.7

        for row in 0..<rows {
          for col in 0..<cols {
            let circleSize: CGFloat = {
              ((geometry.size.width - (padding * 2)) - (spacing * (CGFloat(cols) - 1)))
                / CGFloat(cols)
            }()

            let initialX = (CGFloat(col) * (circleSize + spacing) + circleSize / 2) + padding
            let initialY =
              CGFloat(row) * (circleSize + spacing) + circleSize / 2
              + (geometry.size.height - gridHeight(circleSize: circleSize)) / 2

            var currentX = initialX
            var currentY = initialY
            var currentSize = circleSize

            if let touch = touchLocation {
              let deltaX = touch.x - initialX
              let deltaY = touch.y - initialY
              let distance = hypot(deltaX, deltaY)

              if distance < maxDistance {
                let strength = pow(1 - (distance / maxDistance), spacing)
                let displacementX = deltaX * strength * forceFactor
                let displacementY = deltaY * strength * forceFactor

                currentX += displacementX
                currentY += displacementY
              }

              // Size scaling (0.2 to 1.0 based on distance)
              let scale = min(1, max(0.2, distance / 80))
              currentSize *= scale

            }

            let rect = CGRect(
              x: currentX - circleSize / 2,
              y: currentY - circleSize / 2,
              width: currentSize,
              height: currentSize
            )

            context.fill(
              Path(roundedRect: rect, cornerRadius: cornerRadius),
              with: .color(.gray)
            )
          }
        }
      }
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { value in
            touchLocation = value.location
          }
          .onEnded { _ in
            touchLocation = nil
          }
      )
    }
  }

  private func gridHeight(circleSize: CGFloat) -> CGFloat {
    (CGFloat(rows) * (circleSize + spacing)) - spacing
  }
}

#Preview {
  DistortionEffect()
}
