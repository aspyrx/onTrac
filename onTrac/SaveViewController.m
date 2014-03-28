//
//  SaveViewController.m
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import "SaveViewController.h"
#import "Defines.h"

// keyboard offset
#define KB_OFFSET 4.0

@interface SaveViewController ()

@end

@implementation SaveViewController {
    UITextField *activeField;
    CGRect textViewInitialFrame;
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // set navbar items
        self.title = @"Save Current Track";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set navbar style
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
    // add constraint between top layout guide and track name label if necessary
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        id topGuide = self.topLayoutGuide;
        UIView *trackNameLabelView = self.trackNameLabel;
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat: @"V:[topGuide]-20-[trackNameLabelView]"
                                                 options: 0
                                                 metrics: nil
                                                   views: NSDictionaryOfVariableBindings(trackNameLabelView, topGuide)]];
    }
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // set track name text field default
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"EEE, MMM d h:mm a"];
    self.trackNameTextField.text = [dateFormatter stringFromDate:[NSDate date]];
    
    // add border to text view
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.borderWidth = 0.5f;
    self.textView.layer.cornerRadius = 6.0f;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // go to next field when return key is pressed
    [textField resignFirstResponder];
    [self.textView becomeFirstResponder];
    return NO;
}

#pragma mark - interface methods

- (IBAction)trackNameEditingChanged:(UITextField *)sender {
    if ([sender.text length] > 0) self.navigationItem.rightBarButtonItem.enabled = YES;
    else self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (IBAction)tapViewTapped:(id)sender {
    if (activeField) // close keyboard when touched outside of field
        [activeField resignFirstResponder];
    else if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
}

- (void)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveButtonPressed:(id)sender {
    // stop recording and save track
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSetRecordingStatus
                                                        object:nil
                                                      userInfo:@{kUserInfoKeyRecordingState: [NSNumber numberWithInt:RecordingStateOff],
                                                                 kUserInfoKeyTrackName: self.trackNameTextField.text,
                                                                 kUserInfoKeyTrackDescription: self.textView.text}];
    
    // dismiss save view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods

- (void)keyboardWillShow:(NSNotification *)aNotification {
    // resize text view to fit
    CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    textViewInitialFrame = self.textView.frame;
    CGRect newFrame = self.textView.frame;
    newFrame.size.height =  self.view.frame.size.height - newFrame.origin.y - kbSize.height - KB_OFFSET;
    [UIView animateWithDuration:0.25 animations:^{self.textView.frame = newFrame;}];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    if (!CGRectIsEmpty(textViewInitialFrame))
        // resize text view to original size if it has been resized
        self.textView.frame = textViewInitialFrame;
}

@end
