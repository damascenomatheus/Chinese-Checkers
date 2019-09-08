//
//  Client.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 07/09/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import Foundation
import SwiftGRPC
import SpriteKit

class Client {
    static let shared = Client()
    
    private(set) var client: GameServiceClient?
    
    var changed = false
    
    var clientExists: Bool {
        return client != nil
    }
    
    private init() {}
    
    func connect(address: String, port: String, completion: @escaping () -> Void) {
        client = GameServiceClient.init(address: "\(address):\(port)", secure: false, arguments: [])
        completion()
    }
    
    func requestToRestart() {
        do {
            try client?.requestToRestartGame(Empty(), completion: {(_,_) in})
        } catch {
            print("Failed at requestToRestart:")
        }
    }
    
    func responseToRestart(value: Bool) {
        var boolMessage = BoolMessage()
        boolMessage.value = value
        do {
            try client?.responseToRestartGame(boolMessage, completion: {(_,_) in})
        } catch {
            print("Failed at responseToRestart:")
        }
    }
    
    func movePiece(previousMove: Movement, currentMove: Movement) {
        if clientExists {
            var move = Move()
            move.previousPosition.col = Int32(previousMove.col)
            move.previousPosition.row = Int32(previousMove.row)
            move.currentPosition.col = Int32(currentMove.col)
            move.currentPosition.row = Int32(currentMove.row)
            
            do {
                try client?.movePiceTo(move, completion: { (_, _) in
                    print("Deu bom!")
                })
            } catch {
                print("Failed at movePiece:")
            }
        }
    }
    
    func sendMessage(content: String, owner: PlayerType) {
        var message = Message()
        message.content = content
        message.owner = owner == .RED ? "RED" : "BLUE"
        message.isComing = true
        do {
            try client?.send(message, completion: {(_,_) in })
        } catch {
            print("Failed at sendMessage:")
        }
    }
    
    func identifyPlayer(playerType: String) {
        var playerSide = PlayerSide()
        playerSide.value = playerType
        do {
            if !changed {
                changed = true
                try client?.identifyPlayer(playerSide, completion: { (result,_) in
                    let player: PlayerType = result?.value == "BLUE" ? .BLUE : .RED
                    Server.shared.player = player
                })
            }
        } catch {
            print("Failed at identifyPlayer:(playerType)")
        }
    }
    
    func changeTurn() {
        do {
           try client?.changeTurn(Empty(), completion: {(_,_) in})
        } catch {
            print("Failed at changeTurn:")
        }
    }
    
    func surrender(winner: PlayerType) {
        var winnerPlayer = PlayerSide()
        winnerPlayer.value = winner == .RED ? "RED" : "BLUE"
        do {
            try client?.surrender(winnerPlayer, completion: {(_,_) in})
        } catch {
            print("Failed at surrender:")
        }
    }
    
    func showWinner(winner: PlayerType) {
        var winnerPlayer = PlayerSide()
        winnerPlayer.value = winner == .RED ? "RED" : "BLUE"
        do {
            try client?.showWinner(winnerPlayer, completion: {(_,_) in})
        } catch {
            print("Failed at showWinner:")
        }
    }
}
