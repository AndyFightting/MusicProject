//
//  LrcLabel.h
//  MusicProject
//
//  Created by guimingsu on 15/6/15.
//  Copyright (c) 2015年 guimingsu. All rights reserved.
//

#import <UIKit/UIKit.h>

//16进制颜色
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define textFont [UIFont systemFontOfSize:15]
#define frontColor [UIColor greenColor]
#define backColor [UIColor whiteColor]
#define minTime 0.01

@protocol TextLabelProtocol <NSObject>

-(void)playEndAtRow:(int)rowNum;
@end

@interface LrcLabel : UILabel
//一行播放结束代理 启动下一行
@property(nonatomic,retain)id<TextLabelProtocol>playDelegate;

//当前行 和 下一行(要下一行的开始时间)
-(id)initCurrentText:(NSString*)currentText andNextText:(NSString*)nextText;//包含 开始时间，字母，结束时间 如： "0.00]翻着我们的照片[3.00",
-(void)start;

@end
