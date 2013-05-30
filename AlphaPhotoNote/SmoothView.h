//
//  SmoothView.h
//  AlphaPhotoNote
//
//  Created by Juan Ribes on 20/04/13.
//  Copyright (c) 2013 Juan Ribes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "SmoothedBIView.h"

@interface SmoothView : SmoothedBIView

@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) CGPoint prePreviousPoint;
@property (nonatomic) CGPoint previousPoint;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic,weak) UIColor* colorPen;
@property (nonatomic,strong) UIImage *incrementalImage;
@property (nonatomic,strong) UIImage *bufferedImage;
@property BOOL shouldClean,beginTouch;

-(void) trash;
-(void) replaceImage;

@end
