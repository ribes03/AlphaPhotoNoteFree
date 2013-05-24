//
//  SmoothView.m
//  AlphaPhotoNote
//
//  Created by Juan Ribes on 20/04/13.
//  Copyright (c) 2013 Juan Ribes. All rights reserved.
//

#import "SmoothView.h"

@interface SmoothView()

- (CGPoint)calculateMidPointForPoint:(CGPoint)p1 andPoint:(CGPoint)p2;

@end

@implementation SmoothView

@synthesize lastPoint;
@synthesize prePreviousPoint;
@synthesize previousPoint;
@synthesize lineWidth;
@synthesize colorPen = _colorPen;
@synthesize incrementalImage = _incrementalImage;
@synthesize bufferedImage = _bufferedImage;


-(void)configure
{
    [self setMultipleTouchEnabled:NO];
    [self setColorPen:[UIColor blueColor]];
    _shouldClean = NO;
    _beginTouch = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replaceImage:)];
    tap.numberOfTapsRequired = 3; // Tap three to clear drawing!
    [self addGestureRecognizer:tap];
    
}


- (void) setIncrementalImage:(UIImage *)incrementalImage
{
    _incrementalImage = incrementalImage;
    self.image = incrementalImage;
}
-(void) setColorPen:(UIColor *)colorPen
{
    if (colorPen != _colorPen)
        _colorPen = colorPen;
}

- (UIColor *) colorPen
{
    if (!_colorPen) {
        return [UIColor blueColor];
    } else {
        return _colorPen;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self configure];
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect
{
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!self.incrementalImage) // first time; paint background white
    {
        [[UIColor whiteColor] setFill];
        CGContextFillRect(context, self.bounds);
    } else {
        if ((!_shouldClean) && (!self.incrementalImage))
            [[UIColor colorWithPatternImage:self.incrementalImage] setFill];
    }
    [self.incrementalImage drawInRect:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    [self.colorPen setStroke];
    CGContextStrokePath(context);
    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.previousPoint = [touch locationInView:self];
    _beginTouch = YES;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!self.incrementalImage) // first time; paint background white
    {
        [[UIColor whiteColor] setFill];
        CGContextFillRect(context, self.bounds);
    } else {
        if ((!_shouldClean) && (!self.incrementalImage))
            [[UIColor colorWithPatternImage:self.incrementalImage] setFill];
    }
    [self.incrementalImage drawInRect:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    [self.colorPen setStroke];
    CGContextStrokePath(context);
    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}



-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    self.prePreviousPoint = self.previousPoint;
    self.previousPoint = [touch previousLocationInView:self];
    CGPoint currentPoint = [touch locationInView:self];
    
    // calculate mid point
    CGPoint mid1 = [self calculateMidPointForPoint:self.previousPoint andPoint:self.prePreviousPoint];
    CGPoint mid2 = [self calculateMidPointForPoint:currentPoint andPoint:self.previousPoint];
   //from
    
   // UIGraphicsBeginImageContext(self.incrementalImage.size);
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
   // UIGraphicsPushContext(context);
    
    [[self colorPen] setStroke];
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), true);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), true);
    
    //[self.incrementalImage drawInRect:CGRectMake(0, 0, self.incrementalImage.size.width, self.incrementalImage.size.height)];
    [self.incrementalImage drawInRect:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    
    CGContextMoveToPoint(context, mid1.x, mid1.y);
    // Use QuadCurve is the key
    CGContextAddQuadCurveToPoint(context, self.previousPoint.x, self.previousPoint.y, mid2.x, mid2.y); 
    
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGFloat xDist = (previousPoint.x - currentPoint.x); //[2]
    CGFloat yDist = (previousPoint.y - currentPoint.y); //[3]
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist)); //[4]
    
    distance = distance / 10;
    
    if (distance > 10) {
        distance = 10.0;
    }
    
    distance = distance / 10;
    distance = distance * 3;
    
    if (3.0 - distance > self.lineWidth) {
        lineWidth = lineWidth + 0.3;
    } else {
        lineWidth = lineWidth - 0.3;
    }
    
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextStrokePath(context);
  //  UIGraphicsPopContext();
    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   
    
    //to
}

- (CGPoint)calculateMidPointForPoint:(CGPoint)p1 andPoint:(CGPoint)p2 {
    return CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    [self setLineWidth:1.0];
    
    if ([touch tapCount] == 1) {
       // UIGraphicsBeginImageContext(self.incrementalImage.size);
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
      //  UIGraphicsPushContext(context);
        
        [[self colorPen] setStroke];
        
        CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), true);
        CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), true);
        
      //  [self.incrementalImage drawInRect:CGRectMake(0, 0, self.incrementalImage.size.width, self.incrementalImage.size.height)];
        [self.incrementalImage drawInRect:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
        CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
        CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
        
        CGContextSetLineCap(context, kCGLineCapRound);
        
        CGContextSetLineWidth(context, 4.0);
        
        CGContextStrokePath(context);
       // UIGraphicsPopContext();
        self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
       
    }
}

- (void)trash
{
    _shouldClean = YES;
    self.incrementalImage = nil;
    self.bufferedImage = nil;
    [self setNeedsDisplay];
}

-(void) replaceImage:(UITapGestureRecognizer *)t
{
    [self replaceImage];
}

-(void) replaceImage
{
    self.incrementalImage = self.bufferedImage;
    [self setNeedsDisplay];
}


@end
