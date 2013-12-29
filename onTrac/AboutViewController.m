//
//  AboutViewController.m
//  onTrac
//
//  Created by Stan Zhang on 6/12/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import "AboutViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AboutViewController ()

@end

@implementation AboutViewController

#pragma mark - UIViewController

- (id)init {
    self = [super init];
    if (self) {
        // set navbar items
        self.title = @"About";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init text view
    UITextView *textView = [UITextView new];
    
    // set text view properties
    NSError *error;
    textView.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    if (error) NSLog(@"Error loading about.txt: %@", error);
    textView.font = [UIFont systemFontOfSize:14.0f];
    textView.textColor = [UIColor darkTextColor];
    textView.backgroundColor = [UIColor lightGrayColor];
    textView.editable = NO;
    
    // add the text view as a subview of the main view
    [self.view addSubview:textView];
    
    // set constraints
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(textView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[textView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:([self respondsToSelector:@selector(topLayoutGuide)]
                                                                               ? @"V:|-0-[textView]-0-|"
                                                                               : @"V:|-navBar-[textView]-0-|")
                                                                      options:0
                                                                      metrics:@{@"navBar": [NSNumber numberWithFloat:self.navigationController.navigationBar.frame.size.height]}
                                                                        views:viewsDictionary]];
}

@end
