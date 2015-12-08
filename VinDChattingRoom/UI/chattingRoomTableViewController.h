//
//  chattingRoomViewControllerTableViewController.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/12.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//
#import "selectRoomViewController.h"
#import <UIKit/UIKit.h>
#import "Room.h"
#import "LocalRoom.h"
#import "RemoteRoom.h"


@interface chattingRoomTableViewController : UITableViewController <RoomDelegate, UITextFieldDelegate>

@property (nonatomic,strong) Room * room;
@property (nonatomic, weak) selectRoomViewController *superController;


- (void)activate;

@end
