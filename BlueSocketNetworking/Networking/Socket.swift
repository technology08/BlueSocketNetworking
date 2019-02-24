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
    
    /// The `RectangleData` to pass on to the robot
    private var visionData = RectangleData()
    
    /// User configured port to connect to on IP Address
    let port: Int
    
    private var listenSocket: Socket? = nil
    private var continueRunning = true
    private var connectedSockets = [Int32: Socket]()
    private let socketLockQueue = DispatchQueue(label: "com.CE.BlueSocketNetworking.socketLockQueue")
    
    init(port: Int) {
        self.port = port
    }
    
    /**
     Closes the socket and shuts down the server.
     */
    deinit {
        // Close all open sockets...
        for socket in connectedSockets.values {
            socket.close()
        }
        self.listenSocket?.close()
    }
    
    /**
     Multi-threaded locking way of the robot fetching the current vision data.
     - Returns: Current `RectangleData` object.
     */
    public func getVisionData() -> RectangleData? {
        var returnthing: RectangleData? = nil
        lock(obj: visionData as AnyObject) {
            returnthing = visionData
        }
        return returnthing
    }
    
    /**
     Update the current vision data from the processing thread.
     
     - Parameter data: The most recent data to add to the server.
     */
    
    public func setVisionData(data: RectangleData) {
        lock(obj: visionData as AnyObject) {
            self.visionData = data
        }
    }
    
    /**
     Fires up the server and opens a socket.
     */
    
    func runClient() {
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        queue.async { [unowned self] in
            
            do {
                // Create an IPV4 socket...
                try self.listenSocket = Socket.create(family: .inet)
                
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
        //dispatchMain()
    }
    
    private func addNewConnection(socket: Socket) {
        print(socket)
        // Add the new socket to the list of connected sockets...
        socketLockQueue.sync { [unowned self, socket] in
            self.connectedSockets[socket.socketfd] = socket
        }
        print("QUEUE")
        print(self.connectedSockets[socket.socketfd])
        // Get the global concurrent queue...
        let queue = DispatchQueue.global(qos: .default)
        
        // Create the run loop work item and dispatch to the default priority global queue...
        queue.async { [unowned self, socket] in
            
            var shouldKeepRunning = true
            
            //var readData = Data(capacity: EchoServer.bufferSize)
            //print(readData)
            
            do {
                // Write the welcome string...
                //try socket.write(from: "Hello, type 'QUIT' to end session\nor 'SHUTDOWN' to stop server.\n")
                //let string = try socket.readString()
                //print("String" + string!)
                while shouldKeepRunning {
                    //let bytesRead = try socket.read(into: &readData)
                    let string = try socket.readString()

                    print("String" + string!)
                    if string != nil {
                        /*guard let request = String(data: readData, encoding: .utf8) else {
                         
                         print("Error decoding response...")
                         readData.count = 0
                         break
                         }*/
                        guard let request = string else { return }
                        if request.hasPrefix(EchoServer.shutdownCommand) {
                            
                            print("Shutdown requested by connection at \(socket.remoteHostname):\(socket.remotePort)")
                            
                            // Shut things down...
                            self.shutdownServer()
                            
                            return
                        }
                        print("Server received from connection at \(socket.remoteHostname):\(socket.remotePort): \(request) ")
                        if request.starts(with: "VISION") {
                            //self.visionData.randomize()
                            DispatchQueue.main.async {
                                let string = self.getVisionData()!.getPipeString()
                                print(string)
                                do {
                                    try socket.write(from: string)
                                } catch {
                                    print(error)
                                }
                            }
                            
                        } else if request.hasPrefix(EchoServer.quitCommand) || request.hasSuffix(EchoServer.quitCommand) {
                            
                            shouldKeepRunning = false
                        }
                        
                    } else {
                        
                        shouldKeepRunning = false
                        break
                    }
                    
                    //readData.count = 0
                    
                }
                
                print("Socket: \(socket.remoteHostname):\(socket.remotePort) closed...")
                socket.close()
                
                self.socketLockQueue.sync { [unowned self, socket] in
                    self.connectedSockets[socket.socketfd] = nil
                }
                
            } catch let error {
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
