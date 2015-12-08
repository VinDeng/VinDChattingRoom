//
//  RemoteRoom.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/10.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Room.h"
#import "connectionByBonjour.h"


//@protocol ConnectionDelegate
//
//- (void) connectionAttemptFailed:(ConnectionByBonjour*)connection;
//- (void) connectionTerminated:(ConnectionByBonjour*)connection;
//- (void) receivedNetworkPacket:(NSDictionary*)message viaConnection:(ConnectionByBonjour*)connection;
//
//@end

@interface RemoteRoom : Room <ConnectionByBonjourDelegate>


@property (nonatomic,strong)ConnectionByBonjour *connection ;

// Initialize with host address and port
- (id)initWithHost:(NSString*)host andPort:(int)port;

// Initialize with a reference to a net service discovered via Bonjour
- (id)initWithNetService:(NSNetService*)netService;

@end
