//
//  SettingsViewController.h
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (strong, nonatomic) UIView *tapView;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UITextField *activeField;
@end
