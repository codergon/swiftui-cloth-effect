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
  let spacing: CGFloat = 3
  let cornerRadius: CGFloat = 4
  @Binding var touchLocation: CGPoint?

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        ForEach(0..<rows, id: \.self) { row in
          ForEach(0..<cols, id: \.self) { col in
            GridCell(
              row: row,
              col: col,
              rows: rows,
              cols: cols,
              padding: padding,
              spacing: spacing,
              cornerRadius: cornerRadius,
              size: geometry.size,
              touchLocation: $touchLocation
            )
          }
        }
      }
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { value in
            withAnimation(.easeOut(duration: 0.6)) {
              touchLocation = value.location
            }
          }
          .onEnded { _ in
            withAnimation(.easeOut(duration: 0.8)) {
              touchLocation = nil
            }
          }
      )
    }
  }
}

struct GridCell: View {
  let row: Int
  let col: Int
  let rows: Int
  let cols: Int
  let padding: CGFloat
  let spacing: CGFloat
  let cornerRadius: CGFloat
  let size: CGSize
  @Binding var touchLocation: CGPoint?

  private var circleSize: CGFloat {
    ((size.width - (padding * 2)) - (spacing * (CGFloat(cols) - 1))) / CGFloat(cols)
  }

  private var initialPosition: CGPoint {
    let x = (CGFloat(col) * (circleSize + spacing) + circleSize / 2) + padding
    let gridHeight = (CGFloat(rows) * (circleSize + spacing)) - spacing
    let y = CGFloat(row) * (circleSize + spacing) + circleSize / 2 + (size.height - gridHeight) / 2
    return CGPoint(x: x, y: y)
  }

  private var currentPosition: (CGPoint, CGFloat) {
    var position = initialPosition
    var currentSize = circleSize

    guard let touch = touchLocation else {
      return (position, currentSize)
    }

    let deltaX = touch.x - position.x
    let deltaY = touch.y - position.y
    let distance = hypot(deltaX, deltaY)
    let maxDistance: CGFloat = 150
    let forceFactor: CGFloat = 0.7

    if distance < maxDistance {
      let strength = pow(1 - (distance / maxDistance), spacing)
      position.x += deltaX * strength * forceFactor
      position.y += deltaY * strength * forceFactor
    }

    let scale = min(1, max(0.1, distance / maxDistance))
    currentSize *= scale

    return (position, currentSize)
  }

  var body: some View {
    let (position, size) = currentPosition

    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(Color.gray)
      .frame(width: size, height: size)
      .position(position)
  }
}

#Preview {
  DistortionEffect()
}
