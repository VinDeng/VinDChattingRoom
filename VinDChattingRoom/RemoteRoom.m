//
//  RemoteRoom.m
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/10.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import "RemoteRoom.h"



@implementation RemoteRoom


#pragma mark -
#pragma mark Lifecycle

// Setup connection but don't connect yet
- (id)initWithHost:(NSString*)host andPort:(int)port
{
    
    _connection = [[ConnectionByBonjour alloc] initWithHostAddress:host andPort:port];
    return self;
}


// Initialize and connect to a net service
- (id)initWithNetService:(NSNetService*)netService
{
    _connection = [[ConnectionByBonjour alloc] initWithNetService:netService];
    return self;
}


// Cleanup
- (void)dealloc
{
    self.connection = nil;
//    [super dealloc];
}

#pragma mark -
#pragma mark Network

// Start everything up, connect to server
- (BOOL)start
{
    if ( _connection == nil ) {
        return NO;
    }
    
    // We are the delegate
    _connection.delegate = self;
    
    return [_connection connect];
}


// Stop everything, disconnect from server
- (void)stop {
    if ( _connection == nil ) {
        return;
    }
    
    [_connection close];
    self.connection = nil;
}


// Send chat message to the server
- (void)broadcastChatMessage:(NSString *)message fromUser:(NSString *)name
{
    // Create network packet to be sent to all clients
    NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", name, @"from", nil];
    
    // Send it out
    [_connection sendNetworkPacket:packet];
}


#pragma mark -
#pragma mark ConnectionDelegate Method Implementations

- (void)connectionAttemptFailed:(ConnectionByBonjour*)connection
{
    [self.delegate roomTerminated:self reason:@"Wasn't able to connect to server"];
}


- (void)connectionTerminated:(ConnectionByBonjour*)connection
{
    [self.delegate roomTerminated:self reason:@"Connection to server closed"];
}


- (void)receivedNetworkPacket:(NSDictionary*)packet viaConnection:(ConnectionByBonjour*)connection
{
//    // Display message locally
//    [self.delegate displayChatMessage:[packet objectForKey:@"message"] fromUser:[packet objectForKey:@"from"]];
    
    //放入信息池等待显示
    [[ChatMessageStore shareStore].messages addObject:packet];
    
    [self.delegate newMessageComing];
    
}




@end
