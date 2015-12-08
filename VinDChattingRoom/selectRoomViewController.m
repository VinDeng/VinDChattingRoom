//
//  selectRoomViewController.m
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/9.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.
//
#import "LocalRoom.h"
#import "selectRoomViewController.h"
#import "chattingRoomTableViewController.h"

@interface selectRoomViewController ()

@property(nonatomic, strong) ServerBrowser* serverBrowser;

@end

@implementation selectRoomViewController

- (instancetype)init
{
    if (self = [super init]) {

        self.serverBrowser = [[ServerBrowser alloc] init];
        
        self.serverBrowser.delegate = self;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"请选择聊天室";
    
    UIBarButtonItem *createRoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createRoom)];
    
    self.navigationItem.leftBarButtonItem = createRoomButton;
    
    UIBarButtonItem *refleshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshRoom)];
    
    self.navigationItem.rightBarButtonItem = refleshButton;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)activate
{
    [self.serverBrowser start];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)createRoom
{
    // Stop browsing for servers
    [self.serverBrowser stop];
    
    // Create local chat room and go
    LocalRoom* room = [[LocalRoom alloc] init];
    
    chattingRoomTableViewController *crvc = [[chattingRoomTableViewController alloc] init];
    crvc.room = room;
    
    [crvc activate];
    
    crvc.superController = self;
    
    [self.navigationController pushViewController:crvc animated:YES];
}

//- (void)joinRoom
//{
//    // Figure out which server is selected
//    NSInteger currentRow = [self.tableView ];
//    if ( currentRow == -1 ) {
//        return;
//    }
//    
//    NSNetService* selectedServer = [serverBrowser.servers objectAtIndex:currentRow];
//    
//    // Create chat room that will connect to that chat server
//    RemoteRoom* room = [[[RemoteRoom alloc] initWithNetService:selectedServer] autorelease];
//    
//    // Stop browsing and switch over to chat room
//    [serverBrowser stop];
//    
//    [[MyDocument sharedInstance] showChatRoom:room];
//}

- (void)refreshRoom
{
    [self.serverBrowser start];
    
    [self updateServerList];
}

#pragma mark -
#pragma mark ServerBrowserDelegate

- (void) updateServerList
{
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark TableView

//- (NSInteger)numberOfRowsInTableView:(UITableView *)tableView
//{
//    return [self.serverBrowser.servers count];
//}
//
//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    NSNetService* server = [serverBrowser.servers objectAtIndex:row];
//    NSString *text = [server name];
//    return text;
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.serverBrowser.servers count];
}




 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
//     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
     
     NSNetService* server = [self.serverBrowser.servers objectAtIndex:indexPath.row];
     NSString *text = [server name];
     
     cell.textLabel.text = text;
 
     return cell;
 }


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  Navigation logic may go here, for example:
//  Create the next view controller.
     
     if (indexPath.row <=[self.serverBrowser.servers count]) {
        
         NSNetService* server = [self.serverBrowser.servers objectAtIndex:indexPath.row];
         chattingRoomTableViewController *detailViewController = [[chattingRoomTableViewController alloc] init];
         
         detailViewController.room = [[RemoteRoom alloc] initWithNetService:server];
         //     [self.serverBrowser stop];
         //  Pass the selected object to the new view controller.
         [detailViewController activate];
         //  Push the view controller.
         
         detailViewController.superController = self;
         
         [self.navigationController pushViewController:detailViewController animated:YES];

         
     
    }else{
        [self.tableView reloadData];
     }
     
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end