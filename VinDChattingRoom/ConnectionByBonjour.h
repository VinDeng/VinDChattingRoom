//
//  ConnectByBonjour1.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/12.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

//
//  connectionByBanjour.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/10.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFSocketStream.h>
#import "ConnectionByBonjourDelegate.h"

@interface ConnectionByBonjour : NSObject <NSNetServiceDelegate>

@property (nonatomic, weak) id<ConnectionByBonjourDelegate>  delegate;

// Initialize and store connection information until 'connect' is called
- (id) initWithHostAddress:(NSString *)host andPort:(NSInteger)port;

// Initialize using a native socket handle, assuming connection is open
- (id) initWithNativeSocketHandle:(CFSocketNativeHandle)nativeSocketHandle;

// Initialize using an instance of NSNetService
- (id) initWithNetService:(NSNetService *)netService;

// Connect using whatever connection info that was passed during initialization
- (BOOL) connect;

// Close connection
- (void) close;

// Send network message
- (void) sendNetworkPacket:(NSDictionary *)packet;


@end


