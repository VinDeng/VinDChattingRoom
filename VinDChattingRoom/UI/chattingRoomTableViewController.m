//
//  chattingRoomViewControllerTableViewController.m
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/12.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//

#import "AppDelegate.h"
#import "chattingRoomTableViewController.h"
#import "selectRoomViewController.h"
#import "WeiXinCell.h"

@interface chattingRoomTableViewController ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIBarButtonItem *cancleButton;

@end



@implementation chattingRoomTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        [self.tableView registerClass:[WeiXinCell class] forCellReuseIdentifier:@"WeChatCell"];
    
    UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(exit)];
    
    self.navigationItem.leftBarButtonItem = exitButton;
    

//    UIBarButtonItem *sentMessageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(sentMessage)];
    
    self.cancleButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancle)];
    
//    self.cancleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStylePlain target:self action:nil];
    
    self.navigationItem.rightBarButtonItem = self.cancleButton;
    
    self.cancleButton.enabled = NO;
    
//    self.navigationItem.rightBarButtonItem = sentMessageButton;

    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.center.x/2, self.navigationController.navigationBar.center.y/3-5, [UIScreen mainScreen].bounds.size.width*4/7,self.navigationController.navigationBar.bounds.size.height*3/5 )];
    
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    
    _textField.returnKeyType = UIReturnKeySend;
    
    _textField.delegate = self;
    
    [self.navigationController.navigationBar addSubview:_textField];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)activate
{
    if (self.room) {
        self.room.delegate = self;
        [self.room start];
    }
}

- (void)exit
{
    [self.room stop];
    
    [[ChatMessageStore shareStore].messages removeAllObjects];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.superController performSelector:@selector(refreshRoom)];
}

- (void)newMessageComing
{
    [self.tableView reloadData];
}

- (void)roomTerminated:(id)room reason:(NSString *)string
{
    [self exit];
}



#pragma mark - Table view 委托方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[ChatMessageStore shareStore] getSortedMessages].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [[[ChatMessageStore shareStore] getSortedMessages] objectAtIndex:indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize size = [[dict objectForKey:@"message"] sizeWithFont:font constrainedToSize:CGSizeMake(180.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height+64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeChatCell" forIndexPath:indexPath];
    
    WeiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeChatCell"];
    if (cell == nil) {
        cell = [[WeiXinCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WeChatCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }


    NSDictionary *message = [[[ChatMessageStore shareStore] getSortedMessages] objectAtIndex:indexPath.row];
    
//    NSString *name = [message objectForKey:@"from"];
//    
//    NSString *body = [message objectForKey:@"message"];
//    
//    NSString *text = [NSString stringWithFormat:@"%@: %@\n",name,body];
//    
//    cell.textLabel.text = text;
    
    
    
    [cell setContent:(NSMutableDictionary *)message];
    
    cell.userInteractionEnabled = NO;
    
    return cell;
}



- (void)sentMessage:(NSString *)message fromUser:(NSString *)name
{
    [self.room broadcastChatMessage:message fromUser:name];
//    self.navigationController.navigationBar.bounds
}

- (void)displayChatMessage:(NSString *)message fromUser:(NSString *)userName
{
    
    NSDictionary* packet = 
    [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", userName, @"from", nil];
    [[ChatMessageStore shareStore].messages addObject:packet];
    
    [self.tableView reloadData];
}

- (void)setContent:(NSDictionary *)message
{
    NSString *name = [message objectForKey:@"from"];
    
    NSString *body = [message objectForKey:@"message"];
}

#pragma -
#pragma 输入框委托方法

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        self.cancleButton.enabled = YES;
    }
}

- (void)cancle
{
    [self.textField resignFirstResponder];
    
    self.cancleButton.enabled = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    NSString *message = textField.text;
    NSString *name = [UIDevice currentDevice].name;
    
    textField.text = nil;
    
    [self sentMessage:message fromUser:name];
    
    [self cancle];
    
    return YES;
    
}

@end
