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
        
        DispatchQueue.main.async { [weak self] in
            self?.scene?.movePieceTo(piece: piece!, col: Int(currentMove.col), row: Int(currentMove.row))
            self?.controller?.previousMoves.append([currentMove, previousMove])
        }
        
        return Empty()
    }
    
    func requestToRestartGame(request: Empty, session: GamerequestToRestartGameSession) throws -> BoolMessage {
        DispatchQueue.main.async { [weak self] in
            self?.controller?.showReceivedRestartMessage()
        }
        return BoolMessage()
    }
    
    func responseToRestartGame(request: BoolMessage, session: GameresponseToRestartGameSession) throws -> Empty {
        if request.value == true {
            DispatchQueue.main.async { [weak self] in
                self?.scene?.playerTurn = .RED
                self?.controller?.changeTurnLabel(isFirstMove: true)
                self?.scene?.restartGame()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.controller?.showDeclineAlert()
            }
        }
        return Empty()
    }
    
    func send(request: Message, session: GamesendSession) throws -> Empty {
        let message = ChatMessage(content: request.content, owner: PlayerType(rawValue: request.owner)!, isComing: request.isComing)
        controller?.chatMessages.append(message)
        return Empty()
    }
    
    func identifyPlayer(request: PlayerSide, session: GameidentifyPlayerSession) throws -> PlayerSide {
        let player = request.value
        var playerSide = PlayerSide()
        
        if player == "RED" {
            playerSide.value = "BLUE"
        } else {
            playerSide.value = "RED"
        }
        
        Client.shared.changed = true
        return playerSide
    }
    
    func changeTurn(request: Empty, session: GamechangeTurnSession) throws -> Empty {
        DispatchQueue.main.async { [weak self] in
            self?.controller?.changeTurnLabel(isFirstMove: false)
        }
        return Empty()
    }
    
    func surrender(request: PlayerSide, session: GamesurrenderSession) throws -> Empty {
        let winner: PlayerType = request.value == "RED" ? .RED : .BLUE
        DispatchQueue.main.async { [weak self] in
            self?.controller?.showWinnerLabel(winner: winner)
        }
        return Empty()
    }
    
    func showWinner(request: PlayerSide, session: GameshowWinnerSession) throws -> Empty {
        let winner: PlayerType = request.value == "RED" ? .RED : .BLUE
        DispatchQueue.main.async { [weak self] in
            self?.controller?.showWinnerLabel(winner: winner)
        }
        return Empty()
    }
}
