//
//  Server.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/11.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import "ServerDelegate.h"


@interface Server : NSObject <NSNetServiceDelegate>

@property  (nonatomic, assign)  u_int16_t   port;
@property  (nonatomic, assign)  CFSocketRef listeningSocket;
@property  (nonatomic, weak)  id<ServerDelegate>  delegate;
@property  (nonatomic, strong)  NSNetService *    netService;


// Initialize and start listening for connections
- (BOOL) start;
- (void) stop;
- (void) terminateServer;
- (void) unpublishService;
// Delegate receives various notifications about the state of our server

@end