//
//  ServerBrowser.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/11.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerBrowserDelegate.h"

@class ServerBrowserDelegate;

@interface ServerBrowser : NSObject <NSNetServiceBrowserDelegate>
{
    NSNetServiceBrowser *       netServiceBrowser;

}

@property(nonatomic, readonly) NSMutableArray * servers;
@property(nonatomic, weak) id<ServerBrowserDelegate> delegate;


// Start browsing for Bonjour services
- (BOOL)start;

// Stop everything
- (void)stop;

@end
