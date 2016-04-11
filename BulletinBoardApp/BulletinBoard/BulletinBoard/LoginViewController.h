//
//  LoginViewController.h
//  BulletinBoard
//
//  Created by Daniel Scott on 3/1/16.
//  Copyright © 2016 Not Quite Human. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController : UIViewController <FBSDKLoginButtonDelegate>

-(void)facebookLoginFinished;

@end
