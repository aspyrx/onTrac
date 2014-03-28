//
//  CBLayer.h
//  onTrac
//
//  Created by Stan Zhang on 6/12/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CBLayer : UIButton

@property (strong,nonatomic) CAGradientLayer *backgroundLayer, *highlightBackgroundLayer;
@property (strong,nonatomic) CALayer *innerGlow;
@property (strong,nonatomic) UILabel *textLabel;

@end
