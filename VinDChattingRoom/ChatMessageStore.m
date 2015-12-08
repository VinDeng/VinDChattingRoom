//
//  ChatMessageStore.m
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/12.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import "ChatMessageStore.h"

@implementation ChatMessageStore

+ (instancetype)shareStore
{
    
    static ChatMessageStore * chatMessageStore = nil;
    
    if (!chatMessageStore) {
        chatMessageStore = [[self alloc] initPrivate];
        chatMessageStore.messages = [[NSMutableArray alloc] init];
    }
    return chatMessageStore;
}

- (instancetype) initPrivate
{
    self = [super init];
    
    return  self;
}
//只显示最近20条聊天纪律保证系统顺畅
- (NSMutableArray *)getSortedMessages
{
    if ([self.messages count] <= 20) {
        return self.messages;
    }else{
        while ([self.messages count] > 20) {
            [self.messages removeObjectAtIndex:0];
        }
        return self.messages;
    }
}

@end
