//
//  RootViewController.h
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UIView *tapView;

- (IBAction)loginButtonPressed:(id)sender;

@end
