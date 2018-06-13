//
//  Socket.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/13/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//
//  Using https://github.com/IBM-Swift/BlueSocket

import Socket
import Foundation

class EchoServer {
    
    static let quitCommand: String = "QUIT"
    static let shutdownCommand: String = "SHUTDOWN"
    static let bufferSize = 4096
    
    let port: Int
    var listenSocket: Socket? = nil
    var continueRunning = true
    var connectedSockets = [Int32: Socket]()
    let socketLockQueue = DispatchQueue(label: "com.CE.BlueSocketNetworking.socketLockQueue")
    
    init(port: Int) {
        self.port = port
    }
    
    deinit {
        // Close all open sockets...
        for socket in connectedSockets.values {
            socket.close()
        }
        self.listenSocket?.close()
    }
    
    func runClient() {
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        queue.async { [unowned self] in
            
            do {
                // Create an IPV6 socket...
                try self.listenSocket = Socket.create(family: .inet6)
                
                guard let socket = self.listenSocket else {
                    
                    print("Unable to unwrap socket...")
                    return
                }
                
                try socket.listen(on: self.port)
                
                print("Listening on port: \(socket.listeningPort)")
                
                repeat {
                    let newSocket = try socket.acceptClientConnection()
                    
                    print("Accepted connection from: \(newSocket.remoteHostname) on port \(newSocket.remotePort)")
                    print("Socket Signature: \(newSocket.signature?.description)")
                    
                    self.addNewConnection(socket: newSocket)
                    
                } while self.continueRunning
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error...")
                    return
                }
                
                if self.continueRunning {
                    
                    print("Error reported:\n \(socketError.description)")
                    
                }
            }
        }
        dispatchMain()
    }
    
    func addNewConnection(socket: Socket) {
        
        // Add the new socket to the list of connected sockets...
        socketLockQueue.sync { [unowned self, socket] in
            self.connectedSockets[socket.socketfd] = socket
        }
        
        // Get the global concurrent queue...
        let queue = DispatchQueue.global(qos: .default)
        
        // Create the run loop work item and dispatch to the default priority global queue...
        queue.async { [unowned self, socket] in
            
            var shouldKeepRunning = true
            
            var readData = Data(capacity: EchoServer.bufferSize)
            
            do {
                // Write the welcome string...
                try socket.write(from: "Hello, type 'QUIT' to end session\nor 'SHUTDOWN' to stop server.\n")
                
                repeat {
                    let bytesRead = try socket.read(into: &readData)
                    
                    if bytesRead > 0 {
                        guard let response = String(data: readData, encoding: .utf8) else {
                            
                            print("Error decoding response...")
                            readData.count = 0
                            break
                        }
                        if response.hasPrefix(EchoServer.shutdownCommand) {
                            
                            print("Shutdown requested by connection at \(socket.remoteHostname):\(socket.remotePort)")
                            
                            // Shut things down...
                            self.shutdownServer()
                            
                            return
                        }
                        print("Server received from connection at \(socket.remoteHostname):\(socket.remotePort): \(response) ")
                        let reply = "Server response: \n\(response)\n"
                        try socket.write(from: reply)
                        
                        if (response.uppercased().hasPrefix(EchoServer.quitCommand) || response.uppercased().hasPrefix(EchoServer.shutdownCommand)) &&
                            (!response.hasPrefix(EchoServer.quitCommand) && !response.hasPrefix(EchoServer.shutdownCommand)) {
                            
                            try socket.write(from: "If you want to QUIT or SHUTDOWN, please type the name in all caps. 😃\n")
                        }
                        
                        if response.hasPrefix(EchoServer.quitCommand) || response.hasSuffix(EchoServer.quitCommand) {
                            
                            shouldKeepRunning = false
                        }
                    }
                    
                    if bytesRead == 0 {
                        
                        shouldKeepRunning = false
                        break
                    }
                    
                    readData.count = 0
                    
                } while shouldKeepRunning
                
                print("Socket: \(socket.remoteHostname):\(socket.remotePort) closed...")
                socket.close()
                
                self.socketLockQueue.sync { [unowned self, socket] in
                    self.connectedSockets[socket.socketfd] = nil
                }
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error by connection at \(socket.remoteHostname):\(socket.remotePort)...")
                    return
                }
                if self.continueRunning {
                    print("Error reported by connection at \(socket.remoteHostname):\(socket.remotePort):\n \(socketError.description)")
                }
            }
        }
    }
    
    func shutdownServer() {
        print("\nShutdown in progress...")
        continueRunning = false
        
        // Close all open sockets...
        for socket in connectedSockets.values {
            socket.close()
        }
        
        listenSocket?.close()
        
        DispatchQueue.main.sync {
            exit(0)
        }
    }
}

public class VisionServer {
    
    //Server
    
    var socket: Socket? = nil
    var port: Int32
    var sendData = false
    var visionData = VisionData()
    
    init(port: Int32) {
        self.port = port
    }
    
    public func runClient() {
        
        do {
            socket = try Socket.create(family: .inet6)
            
            try socket?.connect(to: "127.0.0.1", port: port)
            
            print("Connected to: \(socket?.remoteHostname) on port \(socket?.remotePort)")
            sendData = true
            
            repeat {
                let response = try readFromServer(socket!)
                if response == "" {
                    //Send vision Data
                    self.visionData.randomize()
                    try socket?.write(from: JSONEncoder().encode(visionData))
                    sleep(1/60) //60fps
                } else if response == "STOP" {
                    sendData = false
                }
            } while sendData == true
            
       }
        catch {
            guard let socketError = error as? Socket.Error else {
                print("Unexpected error ...")
                return
            }
            print("Error reported:\n \(socketError.description)")
        }
    }
    
    var vision = VisionData()
    
    // This is very simple-minded. It blocks until there is input, and it then assumes that all the
    // relevant input has been read in one go.
    func readFromServer(_ chatSocket : Socket) throws -> String? {
        var readData = Data(capacity: chatSocket.readBufferSize)
        let bytesRead = try chatSocket.read(into: &readData)
        guard bytesRead > 0 else {
            print("Zero bytes read.")
            
            return ""
        }
        guard let response = String(data: readData, encoding: .utf8) else {
            print("Error decoding response ...")
            return nil
        }
        return response
    }
    
    func stop() {
        sendData = false //Break loop
        sleep(1)  // Be nice to the server
        self.socket?.close()
    }
}
