//
//  selectRoomViewController.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/9.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerBrowserDelegate.h"
#import "ServerBrowser.h"

@interface selectRoomViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, ServerBrowserDelegate>





// View is active, start everything up
- (void)activate;
- (void)refreshRoom;

@end
