//
//  chattingRoomViewControllerTableViewController.h
//  VinDChattingRoom
//
//  Created by Vincent_D on 15/9/12.
//  Copyright (c) 2015年 Vincent_D. All rights reserved.

#import "WeiXinCell.h"

@implementation WeiXinCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _bubbleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0)];
        _bubbleView.backgroundColor = [UIColor clearColor];
        
//        _photo = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
        
        [self.contentView addSubview:_bubbleView];
//        [self.contentView addSubview:_photo];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setContent:(NSMutableDictionary*)dict
{
    NSString *text = [NSString stringWithFormat:@"%@ :%@",[dict objectForKey:@"from"],[dict objectForKey:@"message"]]; //合成总句子
    
    if ([[dict objectForKey:@"from"]isEqualToString:[UIDevice currentDevice].name]) {

//        _photo.frame = CGRectMake(320-60, 10, 50, 50);
//        _photo.image = [UIImage imageNamed:@"photo1"];
//        
        if ([[dict objectForKey:@"message"] isEqualToString:@"0"]) {
//            [self yuyinView:1 from:YES withPosition:65 withView:_bubbleView];
        }else{
            [self bubbleView:text from:YES withPosition:0 withView:_bubbleView];
        }
        
    }else{
//        _photo.frame = CGRectMake(10, 10, 50, 50);
//        _photo.image = [UIImage imageNamed:@"photo"];
        
        if ([[dict objectForKey:@"message"] isEqualToString:@"0"]) {
//            [self yuyinView:1 from:NO withPosition:65 withView:_bubbleView];
        }else{
            [self bubbleView:text from:NO withPosition:0 withView:_bubbleView];
        }
    }

}

//泡泡文本
- (void)bubbleView:(NSString *)text from:(BOOL)fromSelf withPosition:(int)position withView:(UIView*)bulleView{
    for (UIView *subView in bulleView.subviews) {
        [subView removeFromSuperview];
    }
    
    //计算大小
    UIFont *font = [UIFont systemFontOfSize:14];
	CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(180.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    
	// build single chat bubble cell with given text
	UIView *returnView = bulleView;
	returnView.backgroundColor = [UIColor clearColor];
	
    //背影图片
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"SenderAppNodeBkg_HL":@"ReceiverTextNodeBkg" ofType:@"png"]];
    
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:floorf(bubble.size.width/2) topCapHeight:floorf(bubble.size.height/2)]];
	NSLog(@"%f,%f",size.width,size.height);
	
    
    //添加文本信息
	UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(fromSelf?15.0f:22.0f, 20.0f, size.width+10, size.height+10)];
	bubbleText.backgroundColor = [UIColor clearColor];
	bubbleText.font = font;
	bubbleText.numberOfLines = 0;
	bubbleText.lineBreakMode = NSLineBreakByWordWrapping;
	bubbleText.text = text;
	
	bubbleImageView.frame = CGRectMake(0.0f, 14.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+20.0f);
    
	if(fromSelf)
		returnView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width -position-(bubbleText.frame.size.width)-45.0f, 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+30.0f);
	else
		returnView.frame = CGRectMake(position+10.f, 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+30.0f);
	
	[returnView addSubview:bubbleImageView];
	[returnView addSubview:bubbleText];
    
}

////泡泡语音
//- (void)yuyinView:(NSInteger)logntime from:(BOOL)fromSelf  withPosition:(int)position withView:(UIView *)yuyinView{
//    
//    for (UIView *subView in yuyinView.subviews) {
//        [subView removeFromSuperview];
//    }
//    
//    //根据语音长度
//    int yuyinwidth = 66+fromSelf;
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.tag = 250;
//    if(fromSelf)
//        yuyinView.frame =CGRectMake(320-position-yuyinwidth, 10, yuyinwidth, 54);
//	else
//		yuyinView.frame =CGRectMake(position, 10, yuyinwidth, 54);
//    
//    button.frame = CGRectMake(0, 0, yuyinwidth, 54);
//    [yuyinView addSubview:button];
//    
//    //image偏移量
//    UIEdgeInsets imageInsert;
//    imageInsert.top = -10;
//    imageInsert.left = fromSelf?button.frame.size.width/3:-button.frame.size.width/3;
//    button.imageEdgeInsets = imageInsert;
//    
//    [button setImage:[UIImage imageNamed:fromSelf?@"SenderVoiceNodePlaying":@"ReceiverVoiceNodePlaying"] forState:UIControlStateNormal];
//    UIImage *backgroundImage = [UIImage imageNamed:fromSelf?@"SenderVoiceNodeDownloading":@"ReceiverVoiceNodeDownloading"];
//    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:20 topCapHeight:0];
//    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
//    
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(fromSelf?-30:button.frame.size.width, 0, 30, button.frame.size.height)];
//    label.text = [NSString stringWithFormat:@"%d''",logntime];
//    label.textColor = [UIColor grayColor];
//    label.font = [UIFont systemFontOfSize:13];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.backgroundColor = [UIColor clearColor];
//    [button addSubview:label];
//    
//}

@end
