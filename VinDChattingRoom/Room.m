//
//  Room.m
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/10.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import "Room.h"

@implementation Room

// Cleanup
- (void) dealloc
{
    self.delegate = nil;

}


// "Abstract" methods
- (BOOL) start
{
    // Crude way to emulate "abstract" class
    [self doesNotRecognizeSelector:_cmd];
    
    return NO;
}

- (void) stop
{
    // Crude way to emulate "abstract" class
    [self doesNotRecognizeSelector:_cmd];
}

- (void) broadcastChatMessage:(NSString *)message fromUser:(NSString *)name
{
    // Crude way to emulate "abstract" class
    [self doesNotRecognizeSelector:_cmd];
}



@end
