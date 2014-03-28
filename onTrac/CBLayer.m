//
//  CBLayer.m
//  onTrac
//
//  Created by Stan Zhang on 6/12/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import "CBLayer.h"

@implementation CBLayer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    // Call the parent implementation of initWithCoder
    self = [super initWithCoder:coder];
    
    // Custom drawing methods
    if (self)
    {
        [self drawButton];
        [self drawInnerGlow];
        [self drawBackgroundLayer];
        [self drawHighlightBackgroundLayer];
        _highlightBackgroundLayer.hidden = YES;
    }
    
    return self;
}

- (void)layoutSubviews
{
    // Set inner glow frame (1pt inset)
    _innerGlow.frame = CGRectInset(self.bounds, 1, 1);
    
    // Set gradient frame (fill the whole button))
    _backgroundLayer.frame = self.bounds;
    
    // Set inverted gradient frame
    _highlightBackgroundLayer.frame = self.bounds;
    
    [super layoutSubviews];
}

- (void)setHighlighted:(BOOL)highlighted
{
    // Disable implicit animations
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    // Hide/show inverted gradient
    _highlightBackgroundLayer.hidden = !highlighted;
    
    [CATransaction commit];
    
    [super setHighlighted:highlighted];
}

+ (CBLayer *)buttonWithType:(UIButtonType)type
{
    return [super buttonWithType:UIButtonTypeCustom];
}

- (void)drawButton
{
    // Get the root layer (any UIView subclass comes with one)
    CALayer *layer = self.layer;
    
    layer.cornerRadius = 7.0f;
    layer.borderWidth = 1;
    layer.borderColor = [UIColor colorWithRed:0.33f green:0.33f blue:0.33f alpha:1.00f].CGColor;
}

- (void)drawBackgroundLayer
{
    // Check if the property has been set already
    if (!_backgroundLayer)
    {
        // set colors
        NSArray *bgColors = @[
                              (id)[UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.00f].CGColor,
                              (id)[UIColor colorWithRed:0.51f green:0.51f blue:0.55f alpha:1.00f].CGColor
                              ];
        _backgroundLayer = [self drawLayerWithGradient:bgColors];
        
        // Add the gradient to the layer hierarchy
        [self.layer insertSublayer:_backgroundLayer atIndex:0];
    }
}

- (void)drawHighlightBackgroundLayer {
    // Check if the property has been set already
    if (!_highlightBackgroundLayer)
    {
        // set colors
        NSArray *bgColors = @[
                             (id)[UIColor colorWithRed:0.51f green:0.51f blue:0.55f alpha:1.00f].CGColor,
                             (id)[UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.00f].CGColor
                             ];
        _highlightBackgroundLayer = [self drawLayerWithGradient:bgColors];
        
        // Add the gradient to the layer hierarchy
        [self.layer insertSublayer:_highlightBackgroundLayer atIndex:1];
    }
}

- (CAGradientLayer *)drawLayerWithGradient:(NSArray *)colors {
    // instantiate gradient layer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    // set colors and location
    gradientLayer.colors = (colors);
    
    return gradientLayer;
}

- (void)drawInnerGlow
{
    if (!_innerGlow)
    {
        // Instantiate the innerGlow layer
        _innerGlow = [CALayer layer];
        
        _innerGlow.cornerRadius= 7.0f;
        _innerGlow.borderWidth = 1;
        _innerGlow.borderColor = [[UIColor whiteColor] CGColor];
        _innerGlow.opacity = 0.5;
        
        [self.layer insertSublayer:_innerGlow atIndex:2];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
