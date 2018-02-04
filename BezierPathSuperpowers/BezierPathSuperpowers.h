//
//  BezierPathSuperpowers.h
//  BezierPathSuperpowers
//
//  Created by Maximilian Kraus on 01.02.18.
//  Copyright © 2018 Maximilian Kraus. All rights reserved.
//

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/Appkit.h>
#endif

//! Project version number for BezierPathSuperpowers.
FOUNDATION_EXPORT double BezierPathSuperpowersVersionNumber;

//! Project version string for BezierPathSuperpowers.
FOUNDATION_EXPORT const unsigned char BezierPathSuperpowersVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <BezierPathSuperpowers/PublicHeader.h>
