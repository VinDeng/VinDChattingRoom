//
//  chattingRoomViewControllerTableViewController.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/12.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface WeiXinCell : UITableViewCell

@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UIImageView *photo;

-(void)setContent:(NSMutableDictionary*)dict;

@end
