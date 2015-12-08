//
//  ConnectionByBonjourDelegate.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/10.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConnectionByBonjour;

@protocol ConnectionByBonjourDelegate <NSObject>

- (void) connectionAttemptFailed:(ConnectionByBonjour *)connection;
- (void) connectionTerminated:(ConnectionByBonjour *)connection;
- (void) receivedNetworkPacket:(NSDictionary*)message viaConnection:(ConnectionByBonjour *)connection;

@end
