//
//  CCGameProvider.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 07/09/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import Foundation
import SpriteKit
import SwiftGRPC

class CCGameProvider: GameProvider {
    private(set) var scene: GameScene?
    private(set) var controller: GameViewController?
    
    func setScene(scene: GameScene) {
        self.scene = scene
    }
    
    func setController(controller: GameViewController) {
        self.controller = controller
    }
    
    func movePiceTo(request: Move, session: GamemovePiceToSession) throws -> Empty {
        let previousMove = (col: Int(request.previousPosition.col), row: Int(request.previousPosition.row))
        let currentMove = (col: Int(request.currentPosition.col), row: Int(request.currentPosition.row))

        let piece = scene?.getPieceAt(col: Int(previousMove.col), row: Int(previousMove.row))
        scene?.movePieceTo(piece: piece!, col: Int(currentMove.col), row: Int(currentMove.row))
        controller?.previousMoves.append([currentMove, previousMove])
        
        return Empty()
    }
    
    func requestToRestartGame(request: Empty, session: GamerequestToRestartGameSession) throws -> BoolMessage {
        controller?.showReceivedRestartMessage()
        return BoolMessage()
    }
    
    func responseToRestartGame(request: BoolMessage, session: GameresponseToRestartGameSession) throws -> Empty {
        if request.value == true {
            scene?.restartGame()
        } else {
            controller?.showDeclineAlert()
        }
        return Empty()
    }
}
