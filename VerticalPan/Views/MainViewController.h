//
//  ViewController.h
//  VerticalPan
//
//  Created by Suneth Mendis on 20/04/12.
//  Copyright (c) 2012 M2D2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>

typedef enum {
    BackViewInSight,
    FrontViewInSight
} ViewsInSight;

@interface MainViewController : UIViewController
@property (strong, nonatomic) UIViewController *backViewController;
@property (strong, nonatomic) UIViewController *frontViewController;

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *frontView;

@end
