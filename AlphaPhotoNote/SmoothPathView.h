//
//  SmoothPathView.h
//  AlphaPhotoNoteFree
//
//  Created by Juan Ribes on 25/05/13.
//  Copyright (c) 2013 Juan Ribes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmoothPathView : UIImageView
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
