//
//  ServerBrowser.m
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/11.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import "ServerBrowser.h"

#pragma mark -
#pragma mark NSNetService (BrowserViewControllerAdditions)

// A category on NSNetService that's used to sort NSNetService objects by their name.
@interface NSNetService (BrowserViewControllerAdditions)

- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService *)aService;

@end

@implementation NSNetService (BrowserViewControllerAdditions)

- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService *)aService
{
    return [[self name] localizedCaseInsensitiveCompare:[aService name]];
}

@end


#pragma mark -
#pragma mark ServerBrowser - Private properties and methods

@interface ServerBrowser ()

// Sort services alphabetically
- (void) sortServers;

@end


@implementation ServerBrowser

#pragma mark -
#pragma mark Lifecycle

// Initialize
- (id) init
{
    self = [super init];
    if (self) {
        _servers = [[NSMutableArray alloc] init];
    }
    
    return self;
}


// Cleanup
- (void) dealloc
{
    if ( _servers != nil ) {
//        [servers release];
        _servers = nil;
    }
    
    self.delegate = nil;
    
//    [super dealloc];
}


// Start browsing for servers
- (BOOL) start
{
    // Restarting?
    if ( netServiceBrowser != nil ) {
        [self stop];
    }
    
    netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    if( !netServiceBrowser ) {
        return NO;
    }
    
    netServiceBrowser.delegate = self;
    [netServiceBrowser searchForServicesOfType:@"_chatty._tcp." inDomain:@""];
    
    return YES;
}


// Terminate current service browser and clean up
- (void) stop {
    if ( netServiceBrowser == nil ) {
        return;
    }
    
    [netServiceBrowser stop];
//    [netServiceBrowser release];
    netServiceBrowser = nil;
    
    [_servers removeAllObjects];
}


// Sort servers array by service names
- (void) sortServers
{
    [_servers sortUsingSelector:@selector(localizedCaseInsensitiveCompareByName:)];
}


#pragma mark -
#pragma mark NSNetServiceBrowser Delegate Method Implementations

// New service was found
- (void) netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
            didFindService:(NSNetService *)netService
                moreComing:(BOOL)moreServicesComing
{
    // Make sure that we don't have such service already (why would this happen? not sure)
    if ( ! [_servers containsObject:netService] ) {
        // Add it to our list
        [_servers addObject:netService];
    }
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing ) {
        return;
    }
    
    // Sort alphabetically and let our delegate know
    [self sortServers];
    
    [_delegate updateServerList];
}


// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    // Remove from list
    [_servers removeObject:netService];
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing ) {
        return;
    }
    
    // Sort alphabetically and let our delegate know
    [self sortServers];
    
    [_delegate updateServerList];
}

@end



