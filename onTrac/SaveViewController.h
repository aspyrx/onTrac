//
//  SaveViewController.h
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaveViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *trackNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)trackNameEditingChanged:(UITextField *)sender;
- (IBAction)tapViewTapped:(id)sender;

@end
