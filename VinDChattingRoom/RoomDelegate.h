//
//  RoomDelegate.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/10.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Room;

@protocol RoomDelegate

- (void) displayChatMessage:(NSString *)message fromUser:(NSString *)userName;
- (void) roomTerminated:(id)room reason:(NSString *)string;
- (void) newMessageComing;
@end

//@interface RoomDelegate : NSObject
//
//@end
