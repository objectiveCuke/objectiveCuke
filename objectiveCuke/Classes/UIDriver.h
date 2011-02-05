//
//  UIDriver.h
//  objectiveCuke
//
//  Created by Nathaniel Hamming on 11-01-31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDriver : NSObject {
	UIWindow *appWindow;
}

@property(nonatomic,assign) UIWindow *appWindow;

+ (UIDriver *)sharedUIDriver;
- (void)tapElementWithLabel: (NSString*)label;
- (void)tapPoint: (CGPoint)point;

@end
