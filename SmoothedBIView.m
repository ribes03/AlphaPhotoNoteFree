#import "SmoothedBIView.h"


@interface SmoothedBIView ()
@property (nonatomic,strong) UIBezierPath *path;


@end

@implementation SmoothedBIView

{
    CGPoint pts[5];
    uint ctr;
}

@synthesize colorPen = _colorPen;
@synthesize path = _path;
@synthesize incrementalImage = _incrementalImage;
@synthesize bufferedImage = _bufferedImage;



-(void)configure
{
    [self setMultipleTouchEnabled:NO];
    [self setPath:[UIBezierPath bezierPath]];
    [self.path setLineWidth:2.0];
    [self setColorPen:[UIColor blueColor]];
    _shouldClean = NO;
    _beginTouch = NO;
     
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
    _colorPen = colorPen;
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
- (void)drawRect:(CGRect)rect
{
    [self.incrementalImage drawInRect:rect];
    [self.path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
    _beginTouch = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4) 
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment 
        
        [self.path moveToPoint:pts[0]];
        [self.path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
        [self drawBitmap];
       //[self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3]; 
        pts[1] = pts[4]; 
        ctr = 1;
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self drawBitmap];
    [self setNeedsDisplay];
    [self.path removeAllPoints];
    ctr = 0;
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
    [self drawBitmap];
    [self setNeedsDisplay];
}

-(void) replaceImage
{
    self.incrementalImage = self.bufferedImage;
    [self drawBitmap];
    [self setNeedsDisplay];
}


- (void)drawBitmap
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
    [self.incrementalImage drawInRect:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
    [self.colorPen setStroke];
    [self.path stroke];
    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}


@end


