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
    
    private init() {}
    
    var clientExists: Bool {
        return client != nil
    }
    
    func connect(address: String, port: String) {
        client = GameServiceClient.init(address: "\(address):\(port)", secure: false, arguments: [])
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
    
}
