#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "PocketSVG.h"
#import "SVGBezierPath.h"
#import "SVGEngine.h"
#import "SVGImageView.h"
#import "SVGLayer.h"
#import "SVGPortability.h"

FOUNDATION_EXPORT double PocketSVGVersionNumber;
FOUNDATION_EXPORT const unsigned char PocketSVGVersionString[];

