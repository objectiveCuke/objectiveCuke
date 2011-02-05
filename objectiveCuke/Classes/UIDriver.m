#import <UIKit/UIKit.h>

@interface UITouch (UITouch_DriverExtensions_inline)
- (id)initWithPoint: (CGPoint)point andWindow: (UIWindow*)window;
@end

@implementation UITouch (UITouch_DriverExtensions_inline)
- (id)initWithPoint: (CGPoint)point andWindow: (UIWindow*)window {
	if (self = [super init]) {
		_tapCount = 1;
		_locationInWindow = point;
		_previousLocationInWindow = _locationInWindow;
		
		UIView *target = [window hitTest:_locationInWindow withEvent:nil];
		_view = [target retain];
		
		_phase = UITouchPhaseBegan;
		_touchFlags._firstTouchForView = 1;
		_touchFlags._isTap = 1;
		_timestamp = [NSDate timeIntervalSinceReferenceDate];
	}
	return self;
}
@end

#import "UIQuery.h"

@interface UIQuery (UIQuery_TouchExtensions_inline)

- (UIQuery*)touchPoint: (CGPoint)point;

@end



#import "UIQuery+TouchExtensions.h"
#import "UITouch+DriverExtensions.h"
#import "UITouch+Synthesize.h"
#import "UIEvent+Synthesize.h"

@implementation UIQuery (UIQuery_TouchExtensions_inline)

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

//
//  UIDriver.m
//  objectiveCuke
//
//  Created by Nathaniel Hamming on 11-01-31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIDriver.h"
#import "UIQuery.h"
#import "UIQuery+TouchExtensions.h"
#import "UITouch+DriverExtensions.h"
#import "UITouch+Synthesize.h"
#import "UIEvent+Synthesize.h"

static UIDriver *sharedUIDriver;

@implementation UIDriver
@synthesize appWindow;

#pragma mark -
#pragma mark Memory Management
- (void) dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark Singleton methods
+ (UIDriver *)sharedUIDriver {
	if (!sharedUIDriver) {
		sharedUIDriver = [[UIDriver alloc] init];
	}
	return sharedUIDriver;	
}

+ (id)alloc {
	NSAssert(sharedUIDriver == nil, @"Attempted to allocate a second instance of a sharedUIDriver.");
	sharedUIDriver = [super alloc];
	return sharedUIDriver;
}

#pragma mark -
#pragma mark Public Methods
- (void)tapElementWithLabel: (NSString*)label {	
	NSLog(@"label: %@",label);
	UIQuery *app = [UIQuery withApplication];
	
	//not sure how to find back button and since it is a key word,
	//reserve label for that purpose
	if ([label isEqualToString: @"Back"]) {
		if ([app.navigationItemButtonView exists]) {
			[app.navigationItemButtonView touch];
		} else {
			//TODO pass back fail here
			NSLog(@"element not found");
		}

	} else {
		id element = [app.find text:label];
		if ([element exists]) {
			[element touch];
		} else {
			//TODO pass back fail here
			NSLog(@"element not found");
		}
	}
}

- (void)tapPoint: (CGPoint)point {
	NSLog(@"point: (%f,%f)", point.x, point.y);
	UIQuery *app = [UIQuery withApplication];
	
	[app touchPoint:point];	
}

@end
