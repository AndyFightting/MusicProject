//
//  ViewController.m
//  MusicProject
//
//  Created by guimingsu on 15/6/15.
//  Copyright (c) 2015年 guimingsu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "LrcLabel.h"

@interface ViewController ()<TextLabelProtocol>


@end

@implementation ViewController{
    
    BOOL conentBegin;
    NSMutableArray* lrcArray;//处理后的数据 数组
    NSMutableArray* rowLabelArray;//歌词rowLabel数组
    
    UIScrollView* mainScroll;
    AVPlayer * player;


}
@synthesize mp3Name;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0x4c4c4c);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
     self.automaticallyAdjustsScrollViewInsets = NO;//scrollview问题
#endif

//这里切换名字即可 @"qianBaiDu" @"jieKou"   @"shengRuXiaHua"
    mp3Name = @"jieKou";

//mp3准备----------------------------
    NSString * path = [[NSBundle mainBundle] pathForResource:mp3Name ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:asset];
    
    player = [AVPlayer playerWithPlayerItem:anItem];
    [player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    
//lrc歌词准备----------------------------
    lrcArray = [[NSMutableArray alloc]init];
    rowLabelArray = [[NSMutableArray alloc]init];
    [self operaterData];
    
    UIImageView* imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 150,self.view.frame.size.width, 200)];
    [imgView setImage:[UIImage imageNamed:@"backImg"]];
    [self.view addSubview:imgView];

    mainScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 150,self.view.frame.size.width, 200)];
    [self.view addSubview:mainScroll];
    [mainScroll setContentSize:CGSizeMake(self.view.frame.size.width, 40*(lrcArray.count-1))];
    mainScroll.showsVerticalScrollIndicator = NO;
    mainScroll.backgroundColor = [UIColor clearColor];
    mainScroll.scrollEnabled = NO;
    
    for (int i=0; i<lrcArray.count-1; i++) {//最后一行只有时间
        LrcLabel* songLabel= [[LrcLabel alloc]initCurrentText:lrcArray[i] andNextText:lrcArray[i+1]];
        songLabel.tag = i;
        songLabel.playDelegate = self;
        songLabel.center = CGPointMake(mainScroll.frame.size.width/2, 20+40*i);
        [mainScroll addSubview:songLabel];
        
        [rowLabelArray addObject:songLabel];
    }
    
//开始播放---------------------------
    [self playTap];
       
}

-(void)playTap{
    LrcLabel* rowOne = [rowLabelArray objectAtIndex:0];
    [rowOne start];

    [player play];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == player && [keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
        } else if (player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayer Ready to Play");
        } else if (player.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
        }
    }
}

-(void)operaterData{
    
    NSString *lrcPath = [[NSBundle mainBundle] pathForResource:mp3Name ofType:@"lrc"];
    NSString * textContent = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:nil];
    NSArray * ary=[textContent componentsSeparatedByString:@"\n"];

    //处理成一行只有一个时间一个文字（或者没有文字)主要处理如下情况 ----》[01:24.57]单行字幕
    // [02:56.70][02:31.56][01:22.71]（没有字幕）
    // [02:56.89][02:34.34][01:24.57]重复字幕
    for (int i=0;i<ary.count;i++) {
        NSString* str = ary[i];
        if (str && str.length>0) {//这行不空
            [self singleLine:str];
        }else{
           // NSLog(@"这行没有东西");
        }
    }
    [self sortLrcArray];//按时间排序
    [self addEndTime];//每一行末尾添加这一行的结束时间
    
    // NSLog(@"%@",lrcArray);
}

//处理成一行的----》[01:24.57]单行字幕
-(void)singleLine:(NSString*)str{
    NSArray* rowAry = [str componentsSeparatedByString:@"]"];
    NSString* other = rowAry[1];
    //字幕开始
    if (other && other.length>0) {
        conentBegin = YES;
    }else{//这里获取ti ar al等信息
        NSString* tagText = [rowAry[0] substringWithRange:NSMakeRange(1, 2)];
        if ([@"ti" isEqualToString:tagText]) {
            self.title = [rowAry[0] substringFromIndex:4];
        }
        
    }
    
    if (conentBegin) {
        for (int i=0; i<rowAry.count-1; i++) {
            NSMutableString* tmpStr = [[NSMutableString alloc]init];
            [tmpStr appendString:[self timeToSecond:rowAry[i]]];
            [tmpStr appendString:[rowAry lastObject]];
          
            [lrcArray addObject:tmpStr];
        }
    }
}
//得到秒数
-(NSString *)timeToSecond:(NSString *)formatTime {
    NSString * minutes = [formatTime substringWithRange:NSMakeRange(1, 2)];
    NSString * second = [formatTime substringWithRange:NSMakeRange(4, 5)];
    
    float finishSecond = minutes.floatValue * 60 + second.floatValue;
    return [NSString stringWithFormat:@"%0.2f]",finishSecond];
}

// 以时间顺序进行排序
-(void)sortLrcArray{
if (lrcArray.count > 0){
    for (int i = 0; i < lrcArray.count - 1; i++)
    {
        for (int j = i + 1; j < lrcArray.count; j++)
        {
            NSString* str1 = [lrcArray objectAtIndex:i];
            NSString* str2 = [lrcArray objectAtIndex:j];
            
            NSRange range1 = [str1 rangeOfString:@"]"];
            NSRange range2 = [str2 rangeOfString:@"]"];

            NSString *time1 = [str1 substringToIndex:range1.location];
            NSString *time2 =[str2 substringToIndex:range2.location];

            if (time1.floatValue > time2.floatValue) 
            {
                [lrcArray replaceObjectAtIndex:i withObject:str2];
                [lrcArray replaceObjectAtIndex:j withObject:str1];
            }
        }
      }
   }
}
//末尾添加结束时间
-(void)addEndTime{
    for (int i=0; i<lrcArray.count-1; i++) {
        NSString* str1 = [lrcArray objectAtIndex:i];
        NSString* str2 = [lrcArray objectAtIndex:i+1];
        
        NSRange range1 = [str1 rangeOfString:@"]"];
        NSRange range2 = [str2 rangeOfString:@"]"];
        
        NSString *text1 = [str1 substringFromIndex:range1.location+1];//第一行字母
        NSString *endTime1 =[str2 substringToIndex:range2.location];//第一行结束时间
        if (text1 && text1.length>0) {
            NSMutableString* tmpStr = [[NSMutableString alloc]init];
            [tmpStr appendString:str1];
            [tmpStr appendString:@"["];
            [tmpStr appendString:endTime1];
            [lrcArray replaceObjectAtIndex:i withObject:tmpStr];
            
        }else{
            [lrcArray removeObjectAtIndex:i];
            i--;
        }
    }
}

-(void)playEndAtRow:(int)rowNum{
     //row+1 是将要播放的行
    
    if (rowNum<rowLabelArray.count-1) {
        LrcLabel* rowText = [rowLabelArray objectAtIndex:rowNum+1];
        [rowText start];
    }
    if (rowNum<rowLabelArray.count-1-3) {
       [mainScroll setContentOffset:CGPointMake(0, 40*rowNum) animated:YES];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return YES;
}

@end
