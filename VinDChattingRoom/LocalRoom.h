//
//  LocalRoom.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/10.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "Room.h"
#import "Server.h"
#import "ServerDelegate.h"
#import "connectionByBonjour.h"




@interface LocalRoom : Room <ServerDelegate, ConnectionByBonjourDelegate>

// Initialize everything
- (id) init;
@end

@protocol ConnectionDelegate

- (void) connectionAttemptFailed:(ConnectionByBonjour*)connection;
- (void) connectionTerminated:(ConnectionByBonjour*)connection;
- (void) receivedNetworkPacket:(NSDictionary*)message viaConnection:(ConnectionByBonjour*)connection;

@end