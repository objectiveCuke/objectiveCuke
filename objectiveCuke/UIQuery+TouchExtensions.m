//
//  UIQuery+TouchExtensions.m
//  objectiveCuke
//
//  Created by Nate on 11-02-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIQuery+TouchExtensions.h"
#import "UITouch+DriverExtensions.h"
#import "UITouch+Synthesize.h"
#import "UIEvent+Synthesize.h"

@implementation UIQuery (UIQuery_TouchExtensions)

- (UIQuery*)touchPoint: (CGPoint)point {
	NSLog(@"entering touchPoint");
	[[UIQueryExpectation withQuery:self] exist:@"before you can touch it"];
	
	UITouch *newTouch = [[UITouch alloc] initWithPoint: point andWindow: (UIWindow*)self.window.view];
	UIEvent *eventDown = [(UIEvent*)[NSClassFromString(@"UITouchesEvent") alloc] initWithTouch:newTouch];
	NSSet *touches = [[NSMutableSet alloc] initWithObjects:&newTouch count:1];
	
	[newTouch.view touchesBegan:touches withEvent:eventDown];
	
	UIEvent *eventUp = [[NSClassFromString(@"UITouchesEvent") alloc] initWithTouch:newTouch];
	[newTouch setPhase:UITouchPhaseEnded];
	
	[newTouch.view touchesEnded:touches withEvent:eventDown];
	
	[eventDown release];
	[eventUp release];
	[touches release];
	[newTouch release];
	[self wait:.5];
	return [UIQuery withViews:views className:className];
}

@end
