//
//  GameScene.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 10/08/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Side: String {
    case nw
    case ne
    case se
    case sw
    case west
    case east
}

class GameScene: SKScene {
    weak var viewController: GameViewController?
    
    var map: SKTileMapNode!
    var reds: [SKSpriteNode]!
    var blues: [SKSpriteNode]!
    var selectedPiece = SKSpriteNode()
    
    var touchCount = 0
    var totalMoves = -1
    
    var possibleMoves: [(Int, Int)] = []
    
    var predictionNodesToBeRemoved = [SKNode]()
    
    var redsInitialPosition: [CGPoint] = []
    var bluesInitialPosition: [CGPoint] = []
    
    var currentMove: [(Int, Int)] = []
    
    var player: PlayerType = Server.shared.player
    
    var playerTurn: PlayerType = .RED
    
    override func didMove(to view: SKView) {
        Server.shared.setProviderScene(scene: self)
        
        map = childNode(withName: "TileMapNode") as? SKTileMapNode
        reds = map.children
            .filter { ($0.userData?["isRed"] as! Bool) == true }
            .map { $0 as! SKSpriteNode }
        blues = map.children
            .filter { ($0.userData?["isBlue"]) as! Bool == true }
            .map { $0 as! SKSpriteNode }
        
        redsInitialPosition = reds.map { $0.position }
        bluesInitialPosition = blues.map { $0.position }
        
        setupGameBoard()
    }
    
    private func setupGameBoard() {
        let columns = map.numberOfColumns
        let rows = map.numberOfRows
        
        for col in 0..<columns {
            for row in 0..<rows {
                let tile = map.tileGroup(atColumn: col, row: row)
                if let tileGroupName = tile?.name,
                    tileGroupName == "Grass" {
                    let tileDefinition = map.tileDefinition(atColumn: col, row: row)
                    tileDefinition?.userData = NSMutableDictionary()
                    tileDefinition?.userData?.setValue(true, forKey: "isBoard")
                }
            }
        }
    }
    
    func restartGame() {
        map.isPaused = false
        for i in stride(from: 0, to: reds.count, by: 1) {
            reds[i].position = redsInitialPosition[i]
            blues[i].position = bluesInitialPosition[i]
        }
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.winnerLabel.isHidden = true
            self?.viewController?.turnLabel.text = "Red turn"
            self?.viewController?.turnLabel.textColor = UIColor(displayP3Red: 254/255, green: 2/255, blue: 0, alpha: 1)
        }
    }
    
    func checkIfHasWinner()  {
        let blueCount = redsInitialPosition.filter {
            (map.nodes(at: $0).first?.userData?["isBlue"] as? Bool) == true
        }.count
        
        let redCount = bluesInitialPosition.filter {
            (map.nodes(at: $0).first?.userData?["isRed"] as? Bool) == true
        }.count
        
        if blueCount == blues.count {
            print("Blue wins!")
            let data = "iam:\(player),msg:>WINNER/BLUE".data(using: .utf8)!
        } else if redCount == reds.count {
            print("Red wins!")
            let data = "iam:\(player),msg:>WINNER/RED".data(using: .utf8)!
        }
    }
    
    func getPieceAt(col: Int, row: Int) -> SKSpriteNode {
        let pos = map.centerOfTile(atColumn: col, row: row)
        let piece = map.nodes(at: pos)
            .filter { $0.userData?["isPiece"] as? Bool == true }.first
        guard let pieceNode = piece as? SKSpriteNode else {
//            closeSocketDuringError()
            return SKSpriteNode()
        }
        return pieceNode
    }
    
    func closeSocketDuringError() {
        let data = "QUIT".data(using: .utf8)!
    }
    
    private func movePiece(atPos pos: CGPoint) {
        let mapPos = self.convert(pos, to: map)
        let col = map.tileColumnIndex(fromPosition: mapPos)
        let row = map.tileRowIndex(fromPosition: mapPos)
        let tileNode = map.nodes(at: mapPos).first
        
        print("row:\(row) | col:\(col)")
        
        if playerTurn == player {
            if touchCount < 1 {
                if !isPlayerPieceType(tileNode: tileNode) { return }
                
                movePreview(tileNode: tileNode)
                touchCount += 1
                currentMove.append((col: col, row: row))
            } else {
                move(tileNode: tileNode, col: col, row: row)
                touchCount += 1
                currentMove = []
            }
            
            if touchCount == 2 {
                touchCount = 0
                selectedPiece = SKSpriteNode()
                changeTurn()
                removePredictionNodes()
            }
        }
    }
    
    func isPlayerPieceType(tileNode: SKNode?) -> Bool {
        var key = ""
        if player == .RED {
            key += "isRed"
        } else if player == .BLUE {
            key += "isBlue"
        }
        
        if let isOfPlayerType = tileNode?.userData?[key] as? Bool,
            isOfPlayerType {
            return true
        }
        return false
    }
    
    func changeTurn() {
        playerTurn = playerTurn == .RED ? .BLUE : .RED
        viewController?.changeTurnLabel(isFirstMove: false)
        Client.shared.changeTurn()
    }
    
    func movePreview(tileNode: SKNode?) {
        checkPiece(tileNode: tileNode)
        
        let key = getPlayerType()
        checkPlayerTurn(tileNode: tileNode, key: key)
        
        let pieceNode = tileNode as? SKSpriteNode
        selectedPiece = pieceNode!
    }
    
    func checkPiece(tileNode: SKNode?) {
        if let isPiece = tileNode?.userData?["isPiece"] as? Bool,
            isPiece {
            return
        }
    }
    
    func checkIfIsValidArea(tileNode: SKNode?, col: Int, row: Int) {
        let tileDefinition = map.tileDefinition(atColumn: col, row: row)
        guard let isBoard = tileDefinition?.userData?["isBoard"] as? Bool,
            tileNode?.userData?["isPiece"] == nil,
            isBoard == true else {
                return
        }
    }
    
    // MARK: - Move piece Action
    func move(tileNode: SKNode?, col: Int, row: Int) {
        checkPiece(tileNode: tileNode)
        checkIfIsValidArea(tileNode: tileNode, col: col, row: row)
        currentMove.append((col: col, row: row))
        viewController?.previousMoves.append([currentMove[1], currentMove[0]])
        movePieceTo(piece: selectedPiece, col: col, row: row)
        moveOpponentPiece()
    }
    
    func getPlayerType() -> String {
        var key = ""
        if player == .RED {
            key += "isRed"
        } else if player == .BLUE {
            key += "isBlue"
        }
        return key
    }
    
    func checkPlayerTurn(tileNode: SKNode?, key: String) {
        if let isOfPlayerType = tileNode?.userData?[key] as? Bool,
            !isOfPlayerType {
            return
        }
    }
    
    func moveOpponentPiece() {
        let prevMove = (col: currentMove[0].0, row: currentMove[0].1)
        let curMove = (col: currentMove[1].0, row: currentMove[1].1)
        Client.shared.movePiece(previousMove: prevMove, currentMove: curMove)
    }
    
    func movePieceTo(piece: SKSpriteNode, col: Int, row: Int) {
        let hexTileCenter = map.centerOfTile(atColumn: col, row: row)
        let offset: CGFloat = 20
        let position = CGPoint(x: hexTileCenter.x + offset, y: hexTileCenter.y)
        piece.run(SKAction.move(to: position, duration: 0.5)) {
            self.checkIfHasWinner()
        }
    }
    
    private func checkNEMove(atPos pos: CGPoint) {
        let mapPos = self.convert(pos, to: map)
        var col = map.tileColumnIndex(fromPosition: mapPos)
        var row = map.tileRowIndex(fromPosition: mapPos)

        var tileDefinition = map.tileDefinition(atColumn: col, row: row)
        var isBoard = tileDefinition?.userData?["isBoard"]
        
        var columnCounter = row % 2 == 0 ? 0 : 1
        
        totalMoves = -1
    
        while isBoard != nil {
            tileDefinition = map.tileDefinition(atColumn: col, row: row)
            isBoard = tileDefinition?.userData?["isBoard"]

            columnCounter += 1
            row += 1
            
            if columnCounter == 2 {
                col += 1
                columnCounter = 0
            }
            print("row: \(row) | column: \(col)")
            
            let hasPossibleMove = validateMove(col: col, row: row)
            if !hasPossibleMove {
                break
            }
        }
        showPossibleMovesInDirection()
        possibleMoves = []
    }
    
    private func checkNWMove(atPos pos: CGPoint) {
        let mapPos = self.convert(pos, to: map)
        var col = map.tileColumnIndex(fromPosition: mapPos)
        var row = map.tileRowIndex(fromPosition: mapPos)
        
        var tileDefinition = map.tileDefinition(atColumn: col, row: row)
        var isBoard = tileDefinition?.userData?["isBoard"]
        
        var columnCounter = row % 2 == 0 ? 1 : 2
        
        totalMoves = -1
        
        while isBoard != nil {
            tileDefinition = map.tileDefinition(atColumn: col, row: row)
            isBoard = tileDefinition?.userData?["isBoard"]
            
            columnCounter -= 1
            row += 1
            
            if columnCounter == 0 {
                col -= 1
                columnCounter = 2
            }
            print("row: \(row) | column: \(col)")
            
            let hasPossibleMove = validateMove(col: col, row: row)
            if !hasPossibleMove {
                break
            }
        }
        showPossibleMovesInDirection()
        possibleMoves = []
    }
    
    private func checkSEMove(atPos pos: CGPoint) {
        let mapPos = self.convert(pos, to: map)
        var col = map.tileColumnIndex(fromPosition: mapPos)
        var row = map.tileRowIndex(fromPosition: mapPos)
        
        var tileDefinition = map.tileDefinition(atColumn: col, row: row)
        var isBoard = tileDefinition?.userData?["isBoard"]
        
        var columnCounter = row % 2 == 0 ? 0 : 1
        totalMoves = -1
        
        while isBoard != nil {
            tileDefinition = map.tileDefinition(atColumn: col, row: row)
            isBoard = tileDefinition?.userData?["isBoard"]

            columnCounter += 1
            row -= 1
            
            if columnCounter == 2 {
                col += 1
                columnCounter = 0
            }
            print("row: \(row) | column: \(col)")
            
            let hasPossibleMove = validateMove(col: col, row: row)
            if !hasPossibleMove {
                break
            }
        }
        showPossibleMovesInDirection()
        possibleMoves = []
    }
    
    private func checkSWMove(atPos pos: CGPoint) {
        let mapPos = self.convert(pos, to: map)
        var col = map.tileColumnIndex(fromPosition: mapPos)
        var row = map.tileRowIndex(fromPosition: mapPos)
        var tileDefinition = map.tileDefinition(atColumn: col, row: row)
        
        var isBoard = tileDefinition?.userData?["isBoard"]
        var columnCounter = row % 2 == 0 ? 1 : 2
        
        totalMoves = -1
        
        while isBoard != nil {
            tileDefinition = map.tileDefinition(atColumn: col, row: row)
            isBoard = tileDefinition?.userData?["isBoard"]
            
            columnCounter -= 1
            row -= 1
            
            if columnCounter == 0 {
                col -= 1
                columnCounter = 2
            }
            print("row: \(row) | column: \(col)")
            
            let hasPossibleMove = validateMove(col: col, row: row)
            if !hasPossibleMove {
                break
            }
        }
        showPossibleMovesInDirection()
        possibleMoves = []
    }
    
    private func checkSides(atPos pos: CGPoint, side: Side) {
        let mapPos = self.convert(pos, to: map)
        var col = map.tileColumnIndex(fromPosition: mapPos)
        let row = map.tileRowIndex(fromPosition: mapPos)
        
        var tileDefinition = map.tileDefinition(atColumn: col, row: row)
        var isBoard = tileDefinition?.userData?["isBoard"]
        
        totalMoves = -1
        
        while isBoard != nil {
            tileDefinition = map.tileDefinition(atColumn: col, row: row)
            isBoard = tileDefinition?.userData?["isBoard"]
            
            if side == .west {
                col -= 1
            } else if side == .east {
                col += 1
            }
            
            let hasPossibleMove = validateMove(col: col, row: row)
            if !hasPossibleMove {
                break
            }
        }
        
        showPossibleMovesInDirection()
        possibleMoves = []
    }
    
    private func showPossibleMovesInDirection() {
        for move in possibleMoves {
            let node = SKShapeNode(circleOfRadius: 40)
            node.fillColor = .yellow
            map.addChild(node)
            let position = map.centerOfTile(atColumn: move.0, row: move.1)
            let offset: CGFloat = 20
            node.position = CGPoint(x: position.x + offset, y: position.y)
            
            predictionNodesToBeRemoved.append(node)
        }
    }
    
    private func removePredictionNodes() {
        for node in predictionNodesToBeRemoved {
            node.removeFromParent()
        }
    }
    
    private func showPossibleMoves(atPos pos: CGPoint) {
        checkNEMove(atPos: pos)
        checkNWMove(atPos: pos)
        checkSWMove(atPos: pos)
        checkSEMove(atPos: pos)
        checkSides(atPos: pos, side: .west)
        checkSides(atPos: pos, side: .east)
    }
    
    private func validateMove(col: Int, row: Int) -> Bool {
        let nodes = map.nodes(at: map.centerOfTile(atColumn: col, row: row))
        let isPiece = checkIfIsPiece(nodes)
        let tileDefinition = map.tileDefinition(atColumn: col, row: row)
        let isBoard = tileDefinition?.userData?["isBoard"]

        if totalMoves == 0 && !isPiece && isBoard != nil {
            possibleMoves.append((col: col, row: row))
            totalMoves = -1
        }
        if isPiece {
            totalMoves += 1
            return true
        } else if !isPiece && totalMoves == -1 && possibleMoves.isEmpty && isBoard != nil {
            possibleMoves.append((col: col, row: row))
            return false
        } else if totalMoves > 1 {
            return false
        }
        return true
    }
    
    private func checkIfIsPiece(_ nodes: [SKNode]) -> Bool {
        let pieceCount = nodes.filter { $0.userData?["isPiece"] != nil }.count
        return pieceCount > 0 ? true : false
    }
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {
        movePiece(atPos: pos)
        
        if touchCount == 1 {
            let mapPos = self.convert(pos, to: map)
            let tileNode = map.nodes(at: mapPos).first
            
            var key = ""
            if player == .RED {
                key += "isRed"
            } else if player == .BLUE {
                key += "isBlue"
            }
            
            if let isOfPlayerType = tileNode?.userData?[key] as? Bool,
                isOfPlayerType {
                showPossibleMoves(atPos: pos)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
