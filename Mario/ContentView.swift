//
//  ContentView.swift
//  Mario
//
//  Created by Omri Shapira on 21/08/2024.
//

import SwiftUI

import SwiftUI

struct GameElement: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGSize
    var type: ElementType
    
    enum ElementType {
        case ground, pipe, coin, goomba
    }
}

struct ContentView: View {
    @State private var marioPosition = CGPoint(x: 50, y: 300)
    @State private var jumpHeight: CGFloat = 0
    @State private var isJumping = false
    @State private var verticalVelocity: CGFloat = 0
    @State private var horizontalVelocity: CGFloat = 0
    @State private var score: Int = 0
    @State private var isGameOver = false
    
    let gravity: CGFloat = 0.8
    let groundLevel: CGFloat = 350
    let jumpVelocity: CGFloat = -18
    let moveSpeed: CGFloat = 5
    
    @State private var gameElements: [GameElement] = [
        GameElement(position: CGPoint(x: 0, y: 375), size: CGSize(width: 1000, height: 50), type: .ground),
        GameElement(position: CGPoint(x: 200, y: 300), size: CGSize(width: 50, height: 100), type: .pipe),
        GameElement(position: CGPoint(x: 400, y: 300), size: CGSize(width: 50, height: 100), type: .pipe),
        GameElement(position: CGPoint(x: 150, y: 250), size: CGSize(width: 20, height: 20), type: .coin),
        GameElement(position: CGPoint(x: 300, y: 250), size: CGSize(width: 20, height: 20), type: .coin),
        GameElement(position: CGPoint(x: 500, y: 330), size: CGSize(width: 30, height: 30), type: .goomba)
    ]
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sky
                Color.blue.edgesIgnoringSafeArea(.all)
                
                // Game elements
                ForEach(gameElements) { element in
                    switch element.type {
                    case .ground:
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: element.size.width, height: element.size.height)
                            .position(element.position)
                    case .pipe:
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: element.size.width, height: element.size.height)
                            .position(element.position)
                    case .coin:
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: element.size.width, height: element.size.height)
                            .position(element.position)
                    case .goomba:
                        Circle()
                            .fill(Color.brown)
                            .frame(width: element.size.width, height: element.size.height)
                            .position(element.position)
                    }
                }
                
                // Mario
                Image(systemName: "person.fill")
                    .resizable()
                    .foregroundColor(.red)
                    .frame(width: 30, height: 50)
                    .position(x: marioPosition.x, y: marioPosition.y - jumpHeight)
                
                // Score
                Text("Score: \(score)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .position(x: 50, y: 30)
                
                if isGameOver {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let dragDistance = value.translation.width
                    horizontalVelocity = dragDistance > 0 ? moveSpeed : -moveSpeed
                }
                .onEnded { _ in
                    horizontalVelocity = 0
                }
        )
        .onTapGesture {
            if !isJumping {
                jump()
            }
        }
        .onReceive(timer) { _ in
            updateGame()
        }
    }
    
    func jump() {
        isJumping = true
        verticalVelocity = jumpVelocity
    }
    
    func updateGame() {
        if isGameOver { return }
        
        // Update Mario's position
        marioPosition.x += horizontalVelocity
        marioPosition.x = max(15, min(marioPosition.x, 985))  // Keep Mario within screen bounds
        
        if isJumping {
            jumpHeight += verticalVelocity
            verticalVelocity += gravity
            
            if jumpHeight <= 0 {
                jumpHeight = 0
                isJumping = false
                verticalVelocity = 0
            }
        }
        
        // Check for collisions and interactions
        for (index, element) in gameElements.enumerated() {
            if checkCollision(marioPosition: CGPoint(x: marioPosition.x, y: marioPosition.y - jumpHeight),
                              elementPosition: element.position,
                              elementSize: element.size) {
                switch element.type {
                case .ground, .pipe:
                    // Collision with ground or pipe
                    marioPosition.y = element.position.y - element.size.height / 2 - 25
                    jumpHeight = 0
                    isJumping = false
                    verticalVelocity = 0
                case .coin:
                    // Collect coin
                    score += 10
                    gameElements.remove(at: index)
                case .goomba:
                    // Game over on Goomba collision
                    isGameOver = true
                }
            }
        }
        
        // Move Goomba
        for index in gameElements.indices {
            if gameElements[index].type == .goomba {
                gameElements[index].position.x -= 1
                if gameElements[index].position.x < 0 {
                    gameElements[index].position.x = 1000
                }
            }
        }
    }
    
    func checkCollision(marioPosition: CGPoint, elementPosition: CGPoint, elementSize: CGSize) -> Bool {
        return abs(marioPosition.x - elementPosition.x) < (30 + elementSize.width) / 2 &&
               abs(marioPosition.y - elementPosition.y) < (50 + elementSize.height) / 2
    }
}

#Preview {
    ContentView()
}
