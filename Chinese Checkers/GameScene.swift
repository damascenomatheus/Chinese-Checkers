//
//  GameScene.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 10/08/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var map: SKTileMapNode!
    var reds: [SKSpriteNode]!
    var selectedPiece = SKSpriteNode()
    
    var touchCount = 0
    
    override func didMove(to view: SKView) {
        map = childNode(withName: "TileMapNode") as? SKTileMapNode
        reds = map.children
            .filter { ($0.userData?["isRed"] as! Bool) == true }
            .map { $0 as! SKSpriteNode }
        
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
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {
        let mapPos = self.convert(pos, to: map)
        let col = map.tileColumnIndex(fromPosition: mapPos)
        let row = map.tileRowIndex(fromPosition: mapPos)
        
        let tileNode = map.nodes(at: mapPos).first
        
        if touchCount < 1 {
            if let isPiece = tileNode?.userData?["isPiece"] as? Bool,
                isPiece {
                touchCount += 1
                let pieceNode = tileNode as? SKSpriteNode
                selectedPiece = pieceNode!
            }
        } else {
            let hexTileCenter = map.centerOfTile(atColumn: col, row: row)
            let tileDefinition = map.tileDefinition(atColumn: col, row: row)
            
            if let isBoard = tileDefinition?.userData?["isBoard"] as? Bool,
                isBoard {
                selectedPiece.run(SKAction.move(to: hexTileCenter, duration: 0.5))
                touchCount += 1
            }
        }
        
        if touchCount == 2 {
            touchCount = 0
            selectedPiece = SKSpriteNode()
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
