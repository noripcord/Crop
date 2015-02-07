//
//  Cropper.m
//  Crop
//
//  Created by Franco Santa Cruz on 2/6/15.
//  Copyright (c) 2015 BirdMaker. All rights reserved.
//

#import "Cropper.h"

@interface Cropper ()

@property (assign, nonatomic) CGRect croppingRect;
@property (assign, nonatomic) CGPoint lastDistance;
@property (assign, nonatomic) CGPoint lastDistancePan;
@property (strong, nonatomic) UIView *bar;
@property (strong, nonatomic) UIImageView *imageView;


@end

@implementation UIImageView (util)

-(CGRect)cropRectForFrame:(CGRect)frame
{
    NSAssert(self.contentMode == UIViewContentModeScaleAspectFit, @"content mode must be aspect fit");
    
    CGFloat widthScale = self.bounds.size.width / self.image.size.width;
    CGFloat heightScale = self.bounds.size.height / self.image.size.height;
    
    float x, y, w, h, offset;
    if (widthScale<heightScale) {
        offset = (self.bounds.size.height - (self.image.size.height*widthScale))/2;
        x = frame.origin.x / widthScale;
        y = (frame.origin.y-offset) / widthScale;
        w = frame.size.width / widthScale;
        h = frame.size.height / widthScale;
    } else {
        offset = (self.bounds.size.width - (self.image.size.width*heightScale))/2;
        x = (frame.origin.x-offset) / heightScale;
        y = frame.origin.y / heightScale;
        w = frame.size.width / heightScale;
        h = frame.size.height / heightScale;
    }
    return CGRectMake(x, y, w, h);
}

@end

@implementation Cropper

- (instancetype)initWithImageView:(UIImageView*)imageView
{
    [imageView setNeedsLayout];
    [imageView layoutIfNeeded];
    self = [super initWithFrame:imageView.frame];
    if (self) {
        self.imageView = imageView;
        [self setupInitialCroppingRect];
        [self setBackgroundColor:[UIColor clearColor]];
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        [self addGestures];
        [self addButtonsBar];
        
        UIView *sup = [imageView superview];
        [self addViewToHierarchy:imageView parent:sup];
        
    }
    return self;
}

- (UIImage*)image
{
    return self.imageView.image;
}

// add contraints so the view is always align with imageview
- (void)addViewToHierarchy:(UIImageView*)imageView parent:(UIView*)sup
{
    //add
    [sup addSubview:self];
    
    // add contraints so the view is always align with imageview
    //
    // left
    [sup addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    // right
    [sup addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    // top
    [sup addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    // bottom
    [sup addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

- (void)cancel:(id)sender
{
    if( self.cropAction )
    {
        self.cropAction(CropperActionCancel, nil);
        [self finishCropper];
    }
}

- (IBAction)crop:(id)sender
{
    if( self.cropAction )
    {
        UIImage *image = [self generateCroppedImage];
        self.cropAction(CropperActionDidCrop, image);
        [self finishCropper];
    }
}

- (void)finishCropper
{
    [self removeFromSuperview];
}

- (void)addButtonsBar
{
    UIView *bar = [[UIView alloc] initWithFrame:CGRectZero];
    // set instance
    self.bar = bar;
    // set to manage via autolayout
    [bar setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [bar setBackgroundColor:[UIColor blackColor]];
    [self addSubview:bar];
    id views = @{@"bar":bar};
    id metrics = @{@"buttonHeight":@40};
    // add constraints
    //
    // Vertical
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bar(buttonHeight)]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    // Horizontal
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bar]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    // create crop & cancel buttons
    UIButton *crop = [UIButton buttonWithType:UIButtonTypeSystem];
    [crop addTarget:self action:@selector(crop:) forControlEvents:UIControlEventTouchUpInside];
    [crop setTranslatesAutoresizingMaskIntoConstraints:NO];
    [crop setTitle:@"Crop" forState:UIControlStateNormal];
    // add
    [bar addSubview:crop];
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    // add
    [bar addSubview:cancel];
    // set constraints
    
    id array = @[ crop, cancel, bar ];
    // force buttons calculate their width & height
    [array makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [array makeObjectsPerformSelector:@selector(layoutIfNeeded)];
    
    
    CGFloat separationBetweenButtons = 9;
    // center constant
    CGFloat firstButtonCenterXConstant = cancel.frame.size.width/2 + separationBetweenButtons/2;
    
    // add bar & buttons constraints
    [bar addConstraint:[NSLayoutConstraint constraintWithItem:bar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:crop attribute:NSLayoutAttributeCenterX multiplier:1 constant:firstButtonCenterXConstant]];
    // bar & crop center y
    [bar addConstraint:[NSLayoutConstraint constraintWithItem:bar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:crop attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    // bar & cancel center y
    [bar addConstraint:[NSLayoutConstraint constraintWithItem:bar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cancel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    // separation cancel & crop
    [bar addConstraint:[NSLayoutConstraint constraintWithItem:crop attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cancel attribute:NSLayoutAttributeLeft multiplier:1 constant:-1*separationBetweenButtons]];
    
}

- (void)setupInitialCroppingRect
{
    // create initial cropping rect
    CGFloat w = self.frame.size.width / 4 * 3;
    CGFloat h = self.frame.size.height / 4 * 3;
    CGFloat x = (self.frame.size.width - w) / 2;
    CGFloat y = (self.frame.size.height - h) / 2;
    // set
    self.croppingRect = CGRectMake(x, y, w, h);
    // invalidate view so initial rect gets drawn
    [self setNeedsDisplay];
}

- (UIImage*)generateCroppedImage
{
    CGRect rect = [self.imageView cropRectForFrame:self.croppingRect];
    // begin
    UIGraphicsBeginImageContext(rect.size);
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.image.size.width, self.image.size.height);
    // draw image
    [self.image drawInRect:drawRect];
    // grab image
    UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    // end
    UIGraphicsEndImageContext();
    return croppedImage;
}


- (void)addGestures
{
    // create pinch
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    // add
    [self addGestureRecognizer:
        pinch
     ];
    
    // create & configure pan
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches = 1;
    pan.minimumNumberOfTouches = 1;
    // add pan
    [self addGestureRecognizer:pan];
    
    [pinch addTarget:self action:@selector(genericGesture:)];
    [pan addTarget:self action:@selector(genericGesture:)];
}

#pragma mark - Gestures

- (void)genericGesture:(UIGestureRecognizer*)gesture
{
    CGFloat duration = 0.1;
    if( gesture.state == UIGestureRecognizerStateBegan )
    {
        [UIView animateWithDuration:duration animations:^{
            [self.bar setAlpha:0];
        }];
    }
    else if( gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateFailed || gesture.state == UIGestureRecognizerStateCancelled )
    {
        [UIView animateWithDuration:duration animations:^{
            [self.bar setAlpha:1];
        }];
    }
}

- (void)pan:(UIPanGestureRecognizer*)pan
{
    if( pan.state == UIGestureRecognizerStateEnded || !pan.numberOfTouches )
    {
        return;
    }
    CGPoint point = [pan locationOfTouch:0 inView:self];
    if( pan.state == UIGestureRecognizerStateChanged )
    {
        // x
        _croppingRect.origin.x += (point.x-_lastDistancePan.x);
        // x checks
        _croppingRect.origin.x = _croppingRect.origin.x < 0 ? 0 : _croppingRect.origin.x;
        _croppingRect.origin.x = CGRectGetMaxX(_croppingRect) > self.bounds.size.width ? self.bounds.size.width - _croppingRect.size.width : _croppingRect.origin.x;
        
        // y
        _croppingRect.origin.y += (point.y-_lastDistancePan.y);
        // y checks
        _croppingRect.origin.y = _croppingRect.origin.y < 0 ? 0 : _croppingRect.origin.y;
        _croppingRect.origin.y = CGRectGetMaxY(_croppingRect) > self.bounds.size.height ? self.bounds.size.height - _croppingRect.size.height : _croppingRect.origin.y;
        
        // make redraw happen
        [self setNeedsDisplay];
    }
    
    _lastDistancePan = point;
}

- (void)pinch:(UIPinchGestureRecognizer*)pinch
{
    if( pinch.state == UIGestureRecognizerStateEnded || [pinch numberOfTouches] != 2 )
    {
        return;
    }
    
    // get points
    CGPoint point1 = [pinch locationOfTouch:0 inView:self];
    CGPoint point2 = [pinch locationOfTouch:1 inView:self];
    // calc diff
    int xDiff = abs(point1.x-point2.x);
    int yDiff = abs(point1.y-point2.y);
    
    if( pinch.state == UIGestureRecognizerStateChanged )
    {
        [self growWidth:(xDiff-_lastDistance.x)];
        [self growHeight:(yDiff-_lastDistance.y)];
        [self setNeedsDisplay];
    }
    
    _lastDistance.x = xDiff;
    _lastDistance.y = yDiff;
    
}

#pragma mark - Helper



- (void)growWidth:(int)distance
{
    _croppingRect.origin.x -= (distance/3.0);
    _croppingRect.size.width += (distance*2.0/3.0);
    // checks    
    _croppingRect.origin.x = _croppingRect.origin.x < 0 ? 0 : _croppingRect.origin.x;
    _croppingRect.size.width = _croppingRect.size.width < 20 ? 20 : _croppingRect.size.width;
    _croppingRect.size.width = _croppingRect.size.width > self.bounds.size.width ? self.bounds.size.width : _croppingRect.size.width;
}

- (void)growHeight:(int)distance
{
    _croppingRect.origin.y -= (distance/3.0);
    _croppingRect.size.height += (distance*2.0/3.0);
    // checks
    _croppingRect.origin.y = _croppingRect.origin.y < 0 ? 0 : _croppingRect.origin.y;
    _croppingRect.size.height = _croppingRect.size.height < 20 ? 20 : _croppingRect.size.height;
    _croppingRect.size.height = _croppingRect.size.height > self.bounds.size.height ? self.bounds.size.height : _croppingRect.size.height;
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor);
    // fill bkg with black transparent
    CGContextFillRect(c, self.bounds);
    
    // set clear the cropping rect
    CGContextClearRect(c, self.croppingRect);

    // set cropping rect border
    CGContextSetStrokeColorWithColor(c, [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1].CGColor);
    CGContextStrokeRect(c, self.croppingRect);
    
}




@end
