//
//  Server.m
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/11.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <CFNetwork/CFSocketStream.h>

#import "AppDelegate.h"
#import "Server.h"
#import "connectionByBonjour.h"


#pragma mark -
#pragma mark Declare some private properties and methods

@interface Server ()


- (BOOL) createServer;
- (void) terminateServer;

- (BOOL) publishService;
- (void) unpublishService;


@end


// Implementation of the Server interface
@implementation Server

#pragma mark -
#pragma mark Lifecycle

// Cleanup
- (void) dealloc
{
    self.netService = nil;
    self.delegate = nil;
    
//    [super dealloc];
}


// Create server and announce it
- (BOOL) start
{
    // Start the socket server
    BOOL succeed = [self createServer];
    if ( !succeed ) {
        return NO;
    }
    
    // Announce the server via Bonjour
    succeed = [self publishService];
    if ( !succeed ) {
        [self terminateServer];
        return NO;
    }
    
    return YES;
}


// Close everything
- (void) stop
{
    [self terminateServer];
    [self unpublishService];
}

#pragma mark -
#pragma mark  回调函数
// 处理链接需求
- (void) handleNewNativeSocket:(CFSocketNativeHandle)nativeSocketHandle
{
    ///先通过得到的套接字生成一个链接类
    ConnectionByBonjour* connection = [[ConnectionByBonjour alloc] initWithNativeSocketHandle:nativeSocketHandle];
    
    // In case of errors, close native socket handle
    if ( connection == nil ) {
        close(nativeSocketHandle);
        return;
    }
    
    // finish connecting
    BOOL succeed = [connection connect];
    if ( !succeed ) {
        [connection close];
        return;
    }
    
    // Pass this on to our delegate
    [_delegate handleNewConnection:connection];
}

// This function will be used as a callback while creating our listening socket via 'CFSocketCreate'
static void serverAcceptCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    // We can only process "connection accepted" calls here
    if ( type != kCFSocketAcceptCallBack ) {
        return;
    }
    
    // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
    CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
    
    CFRetain(info);
    
    Server *server = (__bridge Server *)info;
    [server handleNewNativeSocket:nativeSocketHandle];
//    CFRelease(info);
}


#pragma mark -
#pragma mark  Sockets and streams

- (BOOL) createServer
{
    //// PART 1: Create a socket that can accept connections
    //
    // Socket context
    //  struct CFSocketContext {
    //   CFIndex version;
    //   void *info;
    //   CFAllocatorRetainCallBack retain;
    //   CFAllocatorReleaseCallBack release;
    //   CFAllocatorCopyDescriptionCallBack copyDescription;
    //  };
    CFSocketContext socketCtxt = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    _listeningSocket = CFSocketCreate(
                                     kCFAllocatorDefault,
                                     PF_INET,        // The protocol family for the socket
                                     SOCK_STREAM,    // The socket type to create
                                     IPPROTO_TCP,    // The protocol for the socket. TCP vs UDP.
                                     kCFSocketAcceptCallBack,  // New connections will be automatically accepted and the callback is called with the data argument being a pointer to a CFSocketNativeHandle of the child socket.
                                     (CFSocketCallBack)&serverAcceptCallback,
                                     &socketCtxt );
    
    // Previous call might have failed
    if ( _listeningSocket == NULL ) {
        return NO;
    }
    
    // getsockopt will return existing socket option value via this variable
    int existingValue = 1;
    
    // Make sure that same listening socket address gets reused after every connection
    // int setsockopt(int socket, int level, int option_name, const void *option_value, socklen_t option_len);
    //
    CFSocketNativeHandle socketNativeHandle = CFSocketGetNative(_listeningSocket);
    setsockopt( socketNativeHandle, SOL_SOCKET, SO_REUSEADDR, (void *)&existingValue, sizeof(existingValue));
    
    
    //// PART 2: Bind our socket to an endpoint.
    //
    // We will be listening on all available interfaces/addresses.
    // Port will be assigned automatically by kernel.
    struct sockaddr_in socketAddress;
    memset(&socketAddress, 0, sizeof(socketAddress));
    socketAddress.sin_len = sizeof(socketAddress);
    socketAddress.sin_family = AF_INET;   // Address family (IPv4 vs IPv6)
    socketAddress.sin_port = 0;           // Actual port will get assigned automatically by kernel
    socketAddress.sin_addr.s_addr =  htonl(INADDR_ANY);    // We must use "network byte order" format (big-endian) for the value here
    
    // Convert the endpoint data structure into something that CFSocket can use
    NSData *socketAddressData = [NSData dataWithBytes:&socketAddress length:sizeof(socketAddress)];
    
    // Bind our socket to the endpoint. Check if successful.
    if ( CFSocketSetAddress(_listeningSocket, (CFDataRef)socketAddressData) != kCFSocketSuccess ) {
        // Cleanup
        if ( _listeningSocket != NULL ) {
            CFRelease(_listeningSocket);
            _listeningSocket = NULL;
        }
        
        return NO;
    }
    
    
    //// PART 3: Find out what port kernel assigned to our socket
    //
    // We need it to advertise our service via Bonjour
    NSData *socketAddressActualData = (NSData *)CFBridgingRelease(CFSocketCopyAddress(_listeningSocket));
    
    // Convert socket data into a usable structure
    struct sockaddr_in socketAddressActual;
    memcpy(&socketAddressActual, [socketAddressActualData bytes], [socketAddressActualData length]);
    
    self.port = ntohs(socketAddressActual.sin_port);
    
    //// PART 4: Hook up our socket to the current run loop
    //
    CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _listeningSocket, 0);
    CFRunLoopAddSource(currentRunLoop, runLoopSource, kCFRunLoopCommonModes);
    CFRelease(runLoopSource);
    
    return YES;
}


- (void) terminateServer
{
    if ( _listeningSocket != nil ) {
        CFSocketInvalidate(_listeningSocket);
        CFRelease(_listeningSocket);
        _listeningSocket = nil;
    }
}


#pragma mark -
#pragma mark Bonjour

- (BOOL) publishService
{
    // come up with a name for our chat room
    NSString* chatRoomName = [NSString stringWithFormat:@"%@'s chat room", [UIDevice currentDevice].name];
    
    // create new instance of netService
    self.netService = [[NSNetService alloc] initWithDomain:@"" type:@"_chatty._tcp." name:chatRoomName port:self.port];
    if (self.netService == nil)
        return NO;
    
    // Add service to current run loop
    [self.netService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    // NetService will let us know about what's happening via delegate methods
    [self.netService setDelegate:self];
    
    // Publish the service
    [self.netService publish];
    
    return YES;
}


- (void) unpublishService
{
    if ( self.netService ) {
        [self.netService stop];
        [self.netService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.netService = nil;
    }
}


#pragma mark -
#pragma mark NSNetService Delegate Method Implementations

// Delegate method, called by NSNetService in case service publishing fails for whatever reason
- (void) netService:(NSNetService*)sender didNotPublish:(NSDictionary*)errorDict
{
    if ( sender != self.netService ) {
        return;
    }
    
    // Stop socket server
    [self terminateServer];
    
    // Stop Bonjour
    [self unpublishService];
    
    // Let delegate know about failure
    [_delegate serverFailed:self reason:@"Failed to publish service via Bonjour (duplicate server name?)"];
}

- (void) netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@" >> netServiceDidPublish: %@", [sender name]);
}

- (void) netServiceDidStop:(NSNetService *)sender
{
    NSLog(@" >> netServiceDidStop: %@", [sender name]);
}



@end
