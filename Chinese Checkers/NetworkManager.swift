//
//  NetworkManager.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 16/08/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import Foundation


protocol NetworkManagerDelegate: class {
    func didReceiveMessage(message: String)
    func didStopSession()
}

final class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    let port: Int32 = 1338
    var data = Data()
    var inputStream: InputStream!
    var outputStream: OutputStream!
    let maxReadLength = 4096
    
    weak var delegate: NetworkManagerDelegate?
    
    private override init() {
        super.init()
        self.setupNetworkCommunication()
    }
    
    func setupNetworkCommunication() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           "192.168.0.6" as CFString,
                                           1338,
                                           &readStream,
                                           &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
    }
    
    func joinChat() {
        let data = "iam:RED,msg:>JOIN".data(using: .utf8)!
        
        _ = data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Error joining chat")
                return
            }
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    func stopChatSession() {
        inputStream.close()
        outputStream.close()
    }
    
    func send(data: Data) {
        _ = data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Error joining chat")
                return
            }
            outputStream.write(pointer, maxLength: data.count)
        }
    }
}

extension NetworkManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            print("new message received")
            stopChatSession()
        case .errorOccurred:
            print("error occurred")
        case .hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }
            
            if let message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                self.delegate?.didReceiveMessage(message: message)
            }
        }
    }
    
    func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                length: Int) -> String? {
        guard
            let stringArray = String(
                bytesNoCopy: buffer,
                length: length,
                encoding: .utf8,
                freeWhenDone: true)
            else {
                return nil
        }
        
        return stringArray
    }
}
