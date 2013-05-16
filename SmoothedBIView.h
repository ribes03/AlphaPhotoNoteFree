//
//  SmoothedBIView.h
//  FreehandDrawingTut
//
//  Created by A Khan on 12/10/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmoothedBIView : UIImageView
@property (nonatomic,weak) UIColor* colorPen;
@property (nonatomic,strong) UIImage *incrementalImage;
@property (nonatomic,strong) UIImage *bufferedImage;
@property BOOL shouldClean,beginTouch;

-(void) trash;
-(void) replaceImage;
@end
