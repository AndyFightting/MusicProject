//
//  LrcLabel.m
//  MusicProject
//
//  Created by guimingsu on 15/6/15.
//  Copyright (c) 2015年 guimingsu. All rights reserved.
//

#import "LrcLabel.h"

@implementation LrcLabel{

    NSTimer *timer;
    float currentTime;
    
    float totalSecond;//这一行的总时间
    float startTime;//这行的开始时间
    float endTime;//这行的结束时间
    float nextStartTime;//下一行的开始时间
    
    CGRect totalRect;
    float frontWidth;
    float frontStep;
}
@synthesize playDelegate;

-(id)initCurrentText:(NSString*)currentText andNextText:(NSString*)nextText{

    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        NSRange startIndex = [currentText rangeOfString:@"]"];
        NSRange endIndex = [currentText rangeOfString:@"["];
        NSString* tmpStr = [currentText substringToIndex:endIndex.location];//"0.00]\U5343\U767e\U5ea6"
        startTime = [[tmpStr substringToIndex:startIndex.location] floatValue];
        endTime = [[currentText substringFromIndex:endIndex.location+1] floatValue];
        totalSecond = endTime - startTime;
        self.text = [tmpStr substringFromIndex:startIndex.location+1];
        
        //下一行的开始时间
        NSRange nextStartRange = [nextText rangeOfString:@"]"];
        nextStartTime = [[nextText substringToIndex:nextStartRange.location] floatValue];
        
        [self sizeToFit];
        CGSize textSize = [self.text sizeWithFont:textFont
                                constrainedToSize:CGSizeMake(MAXFLOAT, 0.0)
                                    lineBreakMode:NSLineBreakByWordWrapping];

        totalRect = CGRectMake(0, 0, textSize.width, textSize.height);
        [self setFrame:totalRect];
    }
    return self;
}

-(void)start{
    frontStep =totalRect.size.width/(totalSecond/minTime);
    timer = [NSTimer scheduledTimerWithTimeInterval:minTime target:self selector:@selector(refreshRect) userInfo:nil repeats:YES];
}

- (void)drawRect:(CGRect)rect
{
    
    frontWidth = frontWidth+frontStep;

    CGRect frontRect=CGRectMake(0, 0, frontWidth, totalRect.size.height);
    CGPoint frontPoint=frontRect.origin;
    
    CGRect backRect=CGRectMake(0, 0, totalRect.size.width, totalRect.size.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextClipToRect(context, backRect);
    [backColor set];
    [self.text drawAtPoint:CGPointMake(0, 0) withFont:textFont];
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextClipToRect(context, frontRect);
    [frontColor set];
    [self.text drawAtPoint:frontPoint withFont:textFont];
    CGContextRestoreGState(context);
    
}
-(void)refreshRect{

    if (startTime+currentTime>=nextStartTime) {
            //还原前景色
            frontWidth = -frontStep;
            [self setNeedsDisplay];
            
            [timer invalidate];
            timer = nil;
            //开始下一行
            [playDelegate playEndAtRow:(int)self.tag];
    }
    else{
        [self setNeedsDisplay];
    }
    
    currentTime=currentTime+ minTime;
}
@end
