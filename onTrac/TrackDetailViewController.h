//
//  TrackDetailViewController.h
//  onTrac
//
//  Created by Stan Zhang on 11/28/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GPXRoot;

@interface TrackDetailViewController : UITableViewController

@property (strong, nonatomic) NSString *filePath;

- (id)initWithFilePath:(NSString *)filePath;

@end
