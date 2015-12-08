//
//  LocalRoom.m
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/10.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import "LocalRoom.h"

#pragma mark -
#pragma mark Private properties

@interface LocalRoom ()

@property(nonatomic, strong) Server * server;
@property(nonatomic, strong) NSMutableSet * clients;

@end


@implementation LocalRoom

#pragma mark -
#pragma mark Lifecycle

// Initialization
- (id)init
{
    self = [super init];
    
    if (self) {
        _clients = [[NSMutableSet alloc] init];
    }
    
    return self;
}


// Cleanup
- (void)dealloc
{
    self.clients = nil;
    self.server = nil;
    
//    [super dealloc];
}

#pragma mark -
#pragma mark Network

// Start the server and announce self
- (BOOL)start
{
    // Create new instance of the server and start it up
    _server = [[Server alloc] init];
    
    // We will be processing server events
    _server.delegate = self;
    
    // Try to start it up
    BOOL succeed = [_server start];
    if ( !succeed ) {
        self.server = nil;
        return NO;
    }
    
    return YES;
}


// Stop everything
- (void)stop
{
    // Destroy server
    if (_server) {
        
        [_server stop];
//    NSLog(@"%@",_server);
        self.server = nil;
        
    }

    
    // Close all connections
    [_clients makeObjectsPerformSelector:@selector(close)];
}


// Send chat message to all connected clients
- (void)broadcastChatMessage:(NSString*)message fromUser:(NSString*)name
{
    // Display message locally
    [self.delegate displayChatMessage:message fromUser:name];
    
    // Create network packet to be sent to all clients
    NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", name, @"from", nil];
    
    // Send it out
    [_clients makeObjectsPerformSelector:@selector(sendNetworkPacket:) withObject:packet];
}


#pragma mark -
#pragma mark ServerDelegate Method Implementations

// Server has failed. Stop the world.
- (void) serverFailed:(Server *)server reason:(NSString *)reason
{
    // Stop everything and let our delegate know
    [self stop];
    
    [self.delegate roomTerminated:self reason:reason];
}


// New client connected to our server. Add it.
- (void) handleNewConnection:(ConnectionByBonjour *)connection
{
    // Delegate everything to us
    connection.delegate = self;
    
    // Add to our list of clients
    [_clients addObject:connection];
}


#pragma mark -
#pragma mark ConnectionDelegate Method Implementations

// We won't be initiating connections, so this is not important
- (void) connectionAttemptFailed:(ConnectionByBonjour *)connection
{
    
    
}

// One of the clients disconnected, remove it from our list
- (void) connectionTerminated:(ConnectionByBonjour *)connection
{
    [_clients removeObject:connection];
}


// One of connected clients sent a chat message. Propagate it further.
- (void) receivedNetworkPacket:(NSDictionary *)packet viaConnection:(ConnectionByBonjour *)connection
{
//    // Display message locally
//    [self.delegate displayChatMessage:[packet objectForKey:@"message"] fromUser:[packet objectForKey:@"from"]];
    
    //放入信息池准备显示
     [[ChatMessageStore shareStore].messages addObject:packet];
    // Broadcast this message to all connected clients, including the one that sent it
    [self.delegate newMessageComing];
    
    [_clients makeObjectsPerformSelector:@selector(sendNetworkPacket:) withObject:packet];
}


@end