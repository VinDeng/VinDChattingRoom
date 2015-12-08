//
//  Room.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/10.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoomDelegate.h"
#import "ChatMessageStore.h"

@interface Room : NSObject

@property (strong, nonatomic) id <RoomDelegate> delegate;

- (BOOL) start;
- (void) stop;
- (void) broadcastChatMessage:(NSString *)message fromUser:(NSString *)name;

@end
