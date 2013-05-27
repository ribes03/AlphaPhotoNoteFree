//
//  SmoothPathView.m
//  AlphaPhotoNoteFree
//
//  Created by Juan Ribes on 25/05/13.
//  Copyright (c) 2013 Juan Ribes. All rights reserved.
//

#import "SmoothPathView.h"




@interface SmoothPathView()

- (CGPoint)calculateMidPointForPoint:(CGPoint)p1 andPoint:(CGPoint)p2;
@property (nonatomic,strong) UIBezierPath *path;
@property (nonatomic) CGPoint mid1,mid2;

@end

@implementation SmoothPathView

@synthesize lastPoint;
@synthesize prePreviousPoint;
@synthesize previousPoint;
@synthesize lineWidth;
@synthesize colorPen = _colorPen;
@synthesize path = _path;
@synthesize incrementalImage = _incrementalImage;
@synthesize bufferedImage = _bufferedImage;


-(void)configure
{
    [self setMultipleTouchEnabled:NO];
    [self setPath:[UIBezierPath bezierPath]];
    [self setColorPen:[UIColor blueColor]];
    _shouldClean = NO;
    _beginTouch = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replaceImage:)];
    tap.numberOfTapsRequired = 3; // Tap three to clear drawing!
    [self addGestureRecognizer:tap];
    
}

- (void) setPath:(UIBezierPath *)path
{
    if (path != _path) {
        _path = path;
    }
}

- (UIBezierPath *) path
{
    if (!_path) {
        return [UIBezierPath bezierPath];
    } else {
        return _path;
    }
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

/*
- (void)drawRect:(CGRect)rect
{
    [self.incrementalImage drawInRect:rect];
    [self.path stroke];

}*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.previousPoint = [touch locationInView:self];
    _beginTouch = YES;
    //[self drawtouchesBegan];
    //[self setNeedsDisplay];
    
}

- (void)drawtouchesBegan
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    if (!self.incrementalImage) // first time; paint background white
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    } else {
        if ((!_shouldClean) && (!self.incrementalImage))
            [[UIColor colorWithPatternImage:self.incrementalImage] setFill];
    }
    //[self.incrementalImage drawInRect:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    
    [self.incrementalImage drawInRect:CGRectMake(0, 0, self.incrementalImage.size.width, self.incrementalImage.size.height)];
    [self.colorPen setStroke];
    [self.path stroke];
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
    self.mid1 = [self calculateMidPointForPoint:self.previousPoint andPoint:self.prePreviousPoint];
    self.mid2 = [self calculateMidPointForPoint:currentPoint andPoint:self.previousPoint];
 
    [self drawtouchesMoved:currentPoint];
    [self setNeedsDisplay];

}

- (void)drawtouchesMoved:(CGPoint) currentPoint
{
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    
    if (!self.incrementalImage) // first time; paint background white
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    } else {
        if ((!_shouldClean) && (!self.incrementalImage))
            [[UIColor colorWithPatternImage:self.incrementalImage] setFill];
    }
    
    [[self colorPen] setStroke];
    
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), true);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), true);
    
    //[self.incrementalImage drawInRect:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    [self.incrementalImage drawInRect:CGRectMake(0, 0, self.incrementalImage.size.width, self.incrementalImage.size.height)];
    [[self path] moveToPoint:self.mid1];
    //Use QuadCurve is the key
    //[[self path] addQuadCurveToPoint:self.prePreviousPoint controlPoint:self.mid2];
    [[self path] addCurveToPoint:currentPoint controlPoint1:self.mid1 controlPoint2:self.mid2];
    [[self path] setLineCapStyle:kCGLineCapRound];
    
    CGFloat xDist = (previousPoint.x - currentPoint.x); //[2]
    CGFloat yDist = (previousPoint.y - currentPoint.y); //[3]
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist)); //[4]
    
    distance = distance / 10;
    
    if (distance > 10) {
        distance = 10.0;
    }
    
    distance = distance / 10;
    distance = distance * 3;
    
    if (4.0 - distance > self.lineWidth) {
        lineWidth = lineWidth + 0.3;
    } else {
        lineWidth = lineWidth - 0.3;
    }
    [[self path] setLineWidth:self.lineWidth];
    [self.path stroke];
    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}


- (CGPoint)calculateMidPointForPoint:(CGPoint)p1 andPoint:(CGPoint)p2 {
    return CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    [self setLineWidth:1.0];
    
    if ([touch tapCount] == 1) {
        [self drawtouchesEnded:currentPoint];
        [self setNeedsDisplay];
        [self.path removeAllPoints];
    }
}


- (void)drawtouchesEnded:(CGPoint) currentPoint
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    [[self colorPen] setStroke];
    
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), true);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), true);

   // [self.incrementalImage drawInRect:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    [self.incrementalImage drawInRect:CGRectMake(0, 0, self.incrementalImage.size.width, self.incrementalImage.size.height)];
    [[self path] moveToPoint:currentPoint];
    [[self path] addLineToPoint:currentPoint];
    
    [[self path] setLineCapStyle:kCGLineCapRound];
    [[self path] setLineWidth:4.0];
    [self.path stroke];
    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
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
