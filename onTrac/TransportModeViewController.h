//
//  TransportModeViewController.h
//  onTrac
//
//  Created by Stan Zhang on 12/30/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransportModeViewController : UITableViewController

@property (strong, nonatomic) UIView *tapView;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UITextField *activeField;

@end
