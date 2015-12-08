//
//  connectionByBanjour.m
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/10.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import "ConnectionByBonjour.h"

void readStreamEventHandler(CFReadStreamRef stream, CFStreamEventType eventType, void *info);
void writeStreamEventHandler(CFWriteStreamRef stream, CFStreamEventType eventType, void *info);

@interface ConnectionByBonjour ()

{
    // Read stream
    CFReadStreamRef         readStream;
    BOOL                    readStreamOpen;
    NSMutableData *         incomingDataBuffer;
    int	                    packetBodySize;
    
    // Write stream
    CFWriteStreamRef        writeStream;
    BOOL                    writeStreamOpen;
    NSMutableData *         outgoingDataBuffer;
}




// Properties
@property(nonatomic, retain) NSString * host;
@property(nonatomic, assign) NSInteger port;
// Connection info: host address and port

@property(nonatomic, assign) CFSocketNativeHandle connectedSocketHandle;
// Connection info: native socket handle

@property(nonatomic, retain) NSNetService * netService;

// Initialize
- (void) clean;

// Further setup streams created by one of the 'init' methods
- (BOOL) setupSocketStreams;

// Stream event handlers
- (void) readStreamHandleEvent:(CFStreamEventType)event;
- (void) writeStreamHandleEvent:(CFStreamEventType)event;

// Read all available bytes from the read stream into buffer and try to extract packets
- (void) readFromStreamIntoIncomingBuffer;

// Write whatever data we have in the buffer, as much as stream can handle
- (void) writeOutgoingBufferToStream;

@end


@implementation ConnectionByBonjour

- (void) clean
{
    readStream = nil;
    readStreamOpen = NO;
    
    writeStream = nil;
    writeStreamOpen = NO;
    
    incomingDataBuffer = nil;
    outgoingDataBuffer = nil;
    
//    self.delegate = nil;
    self.host = nil;
    self.netService = nil;
    
    self.connectedSocketHandle = -1;
    packetBodySize = -1;
    
    return;
}

- (void)dealloc
{
    self.netService = nil;
    self.host = nil;
    self.delegate = nil;
}


- (instancetype)initWithHostAddress:(NSString *)host andPort:(NSInteger)port
{
    [self clean];
    if (self = [super init]) {
        self.host = host;
        self.port = port;
    }

    return self;
}

- (instancetype)initWithNativeSocketHandle:(CFSocketNativeHandle)nativeSocketHandle
{
    [self clean];
    if (self = [super init]) {
        self.connectedSocketHandle = nativeSocketHandle;
    }
    return self;
}

- (instancetype)initWithNetService:(NSNetService *)netService
{
    [self clean];
    if (self = [super init]) {
        if (netService.hostName)
        {
           return [self initWithHostAddress:_netService.hostName andPort:_netService.port];
        }
        self.netService = netService;
    }
    
    return self;
}

#pragma mark -
#pragma mark 网络

// Connect using whatever connection info that was passed during initialization
- (BOOL) connect
{
    if ( self.host != nil ) {
        // Bind read/write streams to a new socket
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)(self.host),
                                           (UInt32)self.port, &readStream, &writeStream);
        
        // Do the rest
        return [self setupSocketStreams];
    }
    
    else if ( self.connectedSocketHandle != -1 ) {
        // Bind read/write streams to a socket represented by a native socket handle
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, self.connectedSocketHandle,
                                     &readStream, &writeStream);
        
        // Do the rest
        return [self setupSocketStreams];
    }
    
    else if ( _netService != nil ) {
        // Still need to resolve?
        if ( _netService.hostName != nil ) {
            CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                               (__bridge CFStringRef)_netService.hostName, (UInt32)_netService.port, &readStream, &writeStream);
            return [self setupSocketStreams];
        }
        
        // Start resolving
        _netService.delegate = self;
        [_netService resolveWithTimeout:5.0];
        
        return YES;
    }
    
    // Nothing was passed, connection is not possible
    return NO;
}

- (BOOL)setupSocketStreams
{
    if (writeStream == nil || readStream == nil) {
        [self close];
        return NO;
    }
    
    incomingDataBuffer = [[NSMutableData alloc] init];
    outgoingDataBuffer = [[NSMutableData alloc] init];
    //以下开始设置socket以及流参数
    
    //设置在流关闭的时候关闭socket
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    //注册回调事件
    CFOptionFlags registeredEvents = kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable
    | kCFStreamEventCanAcceptBytes | kCFStreamEventEndEncountered
    | kCFStreamEventErrorOccurred;
    //设定回调代理
     CFStreamClientContext ctx = {0, (__bridge void *)(self), NULL, NULL, NULL};
    // Specify callbacks that will be handling stream events
    CFReadStreamSetClient(readStream, registeredEvents, readStreamEventHandler, &ctx);
    CFWriteStreamSetClient(writeStream, registeredEvents, writeStreamEventHandler, &ctx);
    
    // Schedule streams with current run loop
    CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    // Open both streams
    if ( !CFReadStreamOpen(readStream) || !CFWriteStreamOpen(writeStream)) {
        [self close];
        return NO;
    }
    
    return YES;
}

- (void)close
{
    // Cleanup read stream
    if ( readStream != nil ) {
        CFReadStreamUnscheduleFromRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFReadStreamClose(readStream);
        CFRelease(readStream);
        readStream = NULL;
    }
    
    // Cleanup write stream
    if ( writeStream != nil ) {
        CFWriteStreamUnscheduleFromRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFWriteStreamClose(writeStream);
        CFRelease(writeStream);
        writeStream = NULL;
    }
    
    // Cleanup buffers
//    [incomingDataBuffer release];
    incomingDataBuffer = NULL;
    
//    [outgoingDataBuffer release];
    outgoingDataBuffer = NULL;
    
    // Stop net service?
    if ( _netService != nil ) {
        [_netService stop];
        self.netService = nil;
    }
    
    // Reset all other variables
    [self clean];

}

#pragma mark -
#pragma mark 实现发送流数据

- (void)sendNetworkPacket:(NSDictionary *)packet
{
    // 讲数据打包固化成文件
    NSData * rawPacket = [NSKeyedArchiver archivedDataWithRootObject:packet];
    
    // 讲数据长度写进输出缓存头
    NSInteger packetLength = [rawPacket length];
    [outgoingDataBuffer appendBytes:&packetLength length:sizeof(int)];
    
    // 将数据内容写入输出缓存
    [outgoingDataBuffer appendData:rawPacket];
    
    // 发送
    [self writeOutgoingBufferToStream];
}

#pragma mark 实现读取流数据

// Dispatch readStream events
void readStreamEventHandler(CFReadStreamRef stream, CFStreamEventType eventType, void *info)
{
    CFRetain(info);
    ConnectionByBonjour* connection = (__bridge ConnectionByBonjour*)info;
    [connection readStreamHandleEvent:eventType];
//    CFRelease(info);
}


// 实现读取流数据时候的回调方法
- (void) readStreamHandleEvent:(CFStreamEventType)event
{
    // Stream successfully opened
    if ( event == kCFStreamEventOpenCompleted ) {
        readStreamOpen = YES;
    }
    
    // New data has arrived
    else if ( event == kCFStreamEventHasBytesAvailable ) {
        // Read as many bytes from the stream as possible and try to extract meaningful packets
        [self readFromStreamIntoIncomingBuffer];
    }
    
    // Connection has been terminated or error encountered (we treat them the same way)
    else if ( event == kCFStreamEventEndEncountered || event == kCFStreamEventErrorOccurred ) {
        // Clean everything up
        [self close];
        
        // If we haven't connected yet then our connection attempt has failed
        if ( !readStreamOpen || !writeStreamOpen ) {
            [_delegate connectionAttemptFailed:self];
        }
        else {
            [_delegate connectionTerminated:self];
        }
    }
}

- (void) readFromStreamIntoIncomingBuffer
{
    // Temporary buffer to read data into
    UInt8 buf[1024];
    
    // Try reading while there is data
    while( CFReadStreamHasBytesAvailable(readStream) ) {
        CFIndex len = CFReadStreamRead(readStream, buf, sizeof(buf));
        if ( len <= 0 ) {
            // Either stream was closed or error occurred. Close everything up and treat this as "connection terminated"
            [self close];
            [_delegate connectionTerminated:self];
            return;
        }
        //将数据放到输入缓存中
        [incomingDataBuffer appendBytes:buf length:len];
    }
    
    // Try to extract packets from the buffer.
    //
    // Protocol: header + body
    //  header: an integer that indicates length of the body
    //  body: bytes that represent encoded NSDictionary
    
    // We might have more than one message in the buffer - that's why we'll be reading it inside the while loop
    while( YES ) {
        // Did we read the header yet?
        if ( packetBodySize == -1 ) {
            // Do we have enough bytes in the buffer to read the header?
            //现将一个INT数据长度的数据放到对象中存储读包长度的地方(取数据头)
            if ( [incomingDataBuffer length] >= sizeof(int) ) {
                // extract length
                memcpy(&packetBodySize, [incomingDataBuffer bytes], sizeof(int));
                
                // 将包头（一个INT数据长度的数据体LEN)从输入缓存中去掉
                NSRange rangeToDelete = {0, sizeof(int)};
                [incomingDataBuffer replaceBytesInRange:rangeToDelete withBytes:NULL length:0];
            }
            else {
                //传过来的数据不足一个INT长度（包头未传送完毕）
                break;
            }
        }
        
        // 开始接受包体数据
        if ( [incomingDataBuffer length] >= packetBodySize ) {
            // We now have enough data to extract a meaningful packet.
            NSData* raw = [NSData dataWithBytes:[incomingDataBuffer bytes] length:packetBodySize];
            NSDictionary* packet = [NSKeyedUnarchiver unarchiveObjectWithData:raw];
            
            // Tell our delegate about it
            [_delegate receivedNetworkPacket:packet viaConnection:self];
            
            // Remove that chunk from buffer
            NSRange rangeToDelete = {0, packetBodySize};
            [incomingDataBuffer replaceBytesInRange:rangeToDelete withBytes:NULL length:0];
            
            // We have processed the packet. Resetting the state.
            packetBodySize = -1;
        }
        else {
            // Not enough data yet. Will wait.
            break;
        }
    }
}

#pragma mark Write stream methods

// Dispatch writeStream event handling
void writeStreamEventHandler(CFWriteStreamRef stream, CFStreamEventType eventType, void *info)
{
    CFRetain(info);
    ConnectionByBonjour* connection = (__bridge ConnectionByBonjour*)info;
    
    [connection writeStreamHandleEvent:eventType];
//    CFRelease(info);
}


// Handle events from the write stream
- (void) writeStreamHandleEvent:(CFStreamEventType)event
{
    // Stream successfully opened
    if ( event == kCFStreamEventOpenCompleted ) {
        writeStreamOpen = YES;
    }
    
    // Stream has space for more data to be written
    else if ( event == kCFStreamEventCanAcceptBytes ) {
        // Write whatever data we have, as much as stream can handle
        [self writeOutgoingBufferToStream];
    }
    
    // Connection has been terminated or error encountered (we treat them the same way)
    else if ( event == kCFStreamEventEndEncountered || event == kCFStreamEventErrorOccurred ) {
        // Clean everything up
        [self close];
        
        // If we haven't connected yet then our connection attempt has failed
        if ( !readStreamOpen || !writeStreamOpen ) {
            [_delegate connectionAttemptFailed:self];
        }
        else {
            [_delegate connectionTerminated:self];
        }
    }
}


// Write whatever data we have, as much of it as stream can handle
- (void) writeOutgoingBufferToStream
{
    // Is connection open?
    if ( !readStreamOpen || !writeStreamOpen ) {
        // No, wait until everything is operational before pushing data through
        return;
    }
    
    // Do we have anything to write?
    if ( [outgoingDataBuffer length] == 0 ) {
        return;
    }
    
    // Can stream take any data in?
    if ( !CFWriteStreamCanAcceptBytes(writeStream) ) {
        return;
    }
    
    // Write as much as we can
    CFIndex writtenBytes = CFWriteStreamWrite(writeStream, [outgoingDataBuffer bytes], [outgoingDataBuffer length]);
    
    if ( writtenBytes == -1 ) {
        // Error occurred. Close everything up.
        [self close];
        [_delegate connectionTerminated:self];
        
        return;
    }
    
    // Remove that chunk from buffer
    NSRange range = {0, writtenBytes};
    [outgoingDataBuffer replaceBytesInRange:range withBytes:NULL length:0];
}


#pragma mark -
#pragma mark NSNetService Delegate Method Implementations

// Called if we weren't able to resolve net service
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    if ( sender != _netService ) {
        return;
    }
    
    // Close everything and tell delegate that we have failed
    [_delegate connectionAttemptFailed:self];
    
    [self close];
}


// Called when net service has been successfully resolved
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    if ( sender != _netService ) {
        return;
    }
    
    // Save connection info
    self.host = sender.hostName;
    self.port = sender.port;
    
    // Don't need the service anymore
    self.netService = nil;
    
    // Connect!
    if ( ![self connect] ) {
        [_delegate connectionAttemptFailed:self];
        [self close];
    }
}


@end
