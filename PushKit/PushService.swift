//
//  PushService.swift
//  Gather
//
//  Created by Dan Sessions on 15/05/2015.
//  Copyright (c) 2015 Daniel Sessions. All rights reserved.
//

import Foundation
import Pusher

public enum Error: ErrorType {
    case InvalidKey
    case NotConnected
    case SSLOnly
    case QuotaReached
    case Unexpected
}

public protocol PushServiceDelegate {
    func channel(channel:String, receivedEvent event: String, withData data: AnyObject)
}

public class PushService: NSObject {
    
    var delegate: PushServiceDelegate?
    var client: PTPusher?
    var key: String?
    
    var didConnect: (() -> Void)?
    var connectionFailed: ((Error) -> Void)?
    
    var connected: Bool {
        guard let client = client else {
            return false
        }
        return client.connection.connected
    }
    
    public init(key: String) {
        super.init()
        self.key = key
    }
    
    public func connect() throws {
        guard let _ = key else {
            throw(Error.InvalidKey)
        }
        client = PTPusher(key: key, delegate: self)
        if let client = client  {
            client.connect()
        } else {
            throw(Error.Unexpected)
        }
    }
    
    public func listen(channel: String, event: String) throws {
        guard let client = client else {
            throw(Error.NotConnected)
        }
        let channel = client.subscribeToChannelNamed(channel)
        channel.bindToEventNamed(event, handleWithBlock: { channelEvent in
            let data: AnyObject = channelEvent.data as AnyObject
            let event = channelEvent.name
            let channel = channelEvent.channel
            self.delegate?.channel(channel, receivedEvent: event, withData: data)
        })
    }
    
}

extension PushService: PTPusherDelegate {
    
    public func pusher(pusher: PTPusher!, connectionWillConnect connection: PTPusherConnection!) -> Bool {
        return true
    }
    
    public func pusher(pusher: PTPusher!, connection: PTPusherConnection!, failedWithError error: NSError!) {
        connectionFailed?(Error.Unexpected)
    }
    
    public func pusher(pusher: PTPusher!, connectionDidConnect connection: PTPusherConnection!) {
        didConnect?()
    }
    
    public func pusher(pusher: PTPusher!, didReceiveErrorEvent errorEvent: PTPusherErrorEvent!) {
        connectionFailed?(Error.Unexpected)
    }
    
    public func pusher(pusher: PTPusher!, connectionWillAutomaticallyReconnect connection: PTPusherConnection!, afterDelay delay: NSTimeInterval) -> Bool {
        return true
    }
    
    public func pusher(pusher: PTPusher!, connection: PTPusherConnection!, didDisconnectWithError error: NSError!, willAttemptReconnect: Bool) {
        switch error.code {
        case 4000:
            connectionFailed?(Error.SSLOnly)
        case 4001:
            connectionFailed?(Error.InvalidKey)
        case 4004:
            connectionFailed?(Error.QuotaReached)
        default:
            connectionFailed?(Error.Unexpected)
        }
    }
    
}
