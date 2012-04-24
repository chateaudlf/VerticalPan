//
//  ViewController.m
//  Calendar
//
//  Created by Suneth Mendis on 7/04/12.
//  Copyright (c) 2012 M2D2. All rights reserved.
//
#import <QuartzCore/CoreAnimation.h>
#import "MainViewController.h"

#define GRAVITY 80.0f
#define MIN_Y_POS 0.0f
#define MAX_Y_POS 396.0f
#define SCREEN_HEIGHT_PORTRAIT 460.0f
#define SCREEN_WIDTH_PORTRAIT 320.0f


// 'VELOCITY_REQUIRED_FOR_QUICK_FLICK' is the minimum speed of the finger required to instantly trigger a reveal/hide.
#define VELOCITY_REQUIRED_FOR_QUICK_FLICK 1300.0f

@interface MainViewController ()
@property (assign, nonatomic) ViewsInSight currentViewInSightStatus;
@property (strong) UIPanGestureRecognizer *oneFingerpanGestureRecognizer;
@property (strong) UIPanGestureRecognizer *twoFingerPanGestureRecognizer;

@end

@implementation MainViewController

@synthesize backView, backViewController; 
@synthesize frontView, frontViewController;

@synthesize currentViewInSightStatus;
@synthesize oneFingerpanGestureRecognizer, twoFingerPanGestureRecognizer;

#pragma mark -
#pragma mark helper

- (BOOL)isMovingDown:(UIPanGestureRecognizer *)recognizer {
    return [recognizer translationInView:self.view].y > 0.0f;
}

- (void) setViewInSightStates:(UIPanGestureRecognizer *)recognizer {
    if (self.frontView.frame.origin.y == MIN_Y_POS) {
        currentViewInSightStatus = FrontViewInSight;
    } else {
         currentViewInSightStatus = BackViewInSight;
    }
}

- (void)addSlidingBounceEffect:(BOOL)movingUp {
    CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    bounceAnimation.duration = 0.2;
    bounceAnimation.fromValue = [NSNumber numberWithInt:(movingUp) ? 0 : 10];
    bounceAnimation.toValue = [NSNumber numberWithInt:(movingUp) ? 10 : 0];
    bounceAnimation.repeatCount = 1;
    bounceAnimation.autoreverses = YES;
    bounceAnimation.fillMode = kCAFillModeForwards;
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.additive = YES;
    [self.frontView.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
}

- (void) applyShadowOnViews:(UIView *)view {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.view.frame];
	view.layer.masksToBounds = NO;
	view.layer.shadowColor = [UIColor blackColor].CGColor;
	view.layer.shadowOffset = CGSizeMake(0.0f, 15.0f);
	view.layer.shadowOpacity = 1.0f;
	view.layer.shadowRadius = 10.0f;
	view.layer.shadowPath = shadowPath.CGPath;
}

- (void) togglefrontView:(BOOL)inView withGesture:(UIPanGestureRecognizer *)recognizer animate:(BOOL)animate{
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.frontView.frame = CGRectMake(0.0f, (inView) ? MIN_Y_POS : MAX_Y_POS, SCREEN_WIDTH_PORTRAIT, SCREEN_HEIGHT_PORTRAIT);
        if (animate) {
//           [self addSlidingBounceEffect:inView];      
        }
    } completion:^(BOOL finished) {
        [self setViewInSightStates:recognizer];
    }]; 
}

#pragma mark -
#pragma mark PanGesture Protocol

- (void)delegateOneFingerRecognizedPanGesture:(UIPanGestureRecognizer *)recognizer {
    
    if (UIGestureRecognizerStateEnded == [recognizer state]) {
        if (fabs([recognizer velocityInView:self.view].y) > VELOCITY_REQUIRED_FOR_QUICK_FLICK) {
            if (self.currentViewInSightStatus == FrontViewInSight) {
                if ([self isMovingDown:recognizer]) {
                    [self togglefrontView:NO withGesture:recognizer animate:YES];
                } 
                
            } else {
                if (![self isMovingDown:recognizer]) {
                    [self togglefrontView:YES withGesture:recognizer animate:YES];
                } 
            }
        } else {			
            float dynamicTriggerLevel = (self.currentViewInSightStatus == FrontViewInSight) ? GRAVITY : MAX_Y_POS - GRAVITY;
			if ([self isMovingDown:recognizer] && self.frontView.frame.origin.y >= dynamicTriggerLevel) {
                [self togglefrontView:NO withGesture:recognizer animate:NO];
            } else {
                [self togglefrontView:YES withGesture:recognizer animate:NO];
            }
        }
    } else {
    
        //Pan is inprogress (dragging)
        if (self.currentViewInSightStatus == FrontViewInSight) {
            if ([recognizer translationInView:self.view].y < 0.0f) {
                self.frontView.frame = CGRectMake(0.0f, MIN_Y_POS, SCREEN_WIDTH_PORTRAIT, SCREEN_HEIGHT_PORTRAIT);
            } else if (self.frontView.frame.origin.y <= MAX_Y_POS) {
                [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationCurveLinear animations:^{
                    self.frontView.frame = CGRectMake(0.0f, [recognizer translationInView:self.view].y, SCREEN_WIDTH_PORTRAIT, SCREEN_HEIGHT_PORTRAIT);
                } completion:nil];     
            }
        } else {
            if ([recognizer translationInView:self.view].y > 0.0f) {
                self.frontView.frame = CGRectMake(0.0f, MAX_Y_POS, SCREEN_WIDTH_PORTRAIT, SCREEN_HEIGHT_PORTRAIT);
            } else if (self.frontView.frame.origin.y >= MIN_Y_POS) {
               [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationCurveLinear animations:^{
                   self.frontView.frame = CGRectMake(0.0f, MAX_Y_POS + [recognizer translationInView:self.view].y, SCREEN_WIDTH_PORTRAIT, SCREEN_HEIGHT_PORTRAIT);
               } completion:nil]; 
            }
        }
    }
}

#pragma mark -
#pragma mark View setup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *libraryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"back_vc"];
    UINavigationController *libraryNVC = [[UINavigationController alloc] initWithRootViewController:libraryVC];
    self.backViewController = libraryNVC;

    self.frontViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"front_vc"];
    
    self.currentViewInSightStatus = FrontViewInSight;
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addChildViewController:self.backViewController];
	[self.backView addSubview:self.backViewController.view];
	[self.backViewController didMoveToParentViewController:self];

    [self addChildViewController:self.frontViewController];
	[self.frontView addSubview:self.frontViewController.view];
	[self.frontViewController didMoveToParentViewController:self];
    [self applyShadowOnViews:self.frontView];
    
    self.oneFingerpanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(delegateOneFingerRecognizedPanGesture:)];
    self.oneFingerpanGestureRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:self.oneFingerpanGestureRecognizer];    
}

- (void)viewDidUnload {
    [self setBackView:nil];
    [self setFrontView:nil];
    [self.view removeGestureRecognizer:self.oneFingerpanGestureRecognizer];
    [self setOneFingerpanGestureRecognizer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
