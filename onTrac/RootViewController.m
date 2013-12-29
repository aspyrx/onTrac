//
//  RootViewController.m
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import "RootViewController.h"
#import "MapViewController.h"

#define KB_OFFSET 4.0

@interface RootViewController ()

@end

@implementation RootViewController {
    UITextField *activeField;
    NSMutableDictionary *personalInfo;
}

#pragma mark - UIViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // register for keyboard notifications
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    activeField = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    // set navbar items
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    // send username
    [self sendUsername];
    
    return NO;
}

#pragma mark - interface actions

- (IBAction)loginButtonPressed:(id)sender {
    // send username when go button is pressed
    [self sendUsername];
}

- (IBAction)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (activeField && touch.view == self.tapView) {
        // close keyboard when touched outside of field
        [activeField resignFirstResponder];
    }
}

#pragma mark - private methods

/*
- (void)keyboardWillShow:(NSNotification *)notification {
    // get keyboard size
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // set content inset distances
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height + KB_OFFSET, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // scroll if keyboard hides active field
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(visibleRect, CGPointMake(activeField.frame.origin.x, activeField.frame.origin.y + activeField.frame.size.height + KB_OFFSET))) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y - kbSize.height + KB_OFFSET);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // return to normal scroll if keyboard is hidden
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}
*/

- (void)sendUsername {
    NSString *username = self.usernameField.text;
    if (![username isEqualToString:@""]) {
        NSString *personalInfoFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"personalInfo.plist"];
        personalInfo = [NSMutableDictionary dictionaryWithContentsOfFile:personalInfoFilePath];
        if (!personalInfo) {
            // set personal info if file doesn't exist
            personalInfo = [[NSMutableDictionary alloc] initWithObjects:@[username] forKeys:@[@"username"]];
        }
        
        // save username to userInfo.plist file
        NSLog(@"Username: %@", [personalInfo objectForKey:@"username"]);
        if (![personalInfo writeToFile:personalInfoFilePath atomically:NO]) {
            NSLog(@"Error writing personalInfo to file.");
        }
        
        // alloc and init map view controller, set as nav controller
        MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    
        // set transition type and duration
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view.window cache:YES];
        [UIView setAnimationDuration:0.75];
        
        // present map view controller
        [self.navigationController presentViewController:navController animated:NO completion:nil];
    
        // animate presentation
        [UIView commitAnimations];
    }
}

@end
