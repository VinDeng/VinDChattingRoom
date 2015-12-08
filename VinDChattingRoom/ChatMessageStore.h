//
//  ChatMessageStore.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/12.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessageStore : NSObject

@property NSMutableArray *messages;

+ (instancetype)shareStore;

- (NSMutableArray *)getSortedMessages;

@end
