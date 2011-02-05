//
//  UITouch+DriverExtensions.m
//  objectiveCuke
//
//  Created by Nate on 11-02-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UITouch+DriverExtensions.h"

@implementation UITouch (UITouch_DriverExtensions)

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


//@implementation UITouch (Synthesize)

//
// initInView:phase:
//
// Creats a UITouch, centered on the specified view, in the view's window.
// Sets the phase as specified.
//
//- (id)initInView:(UIView *)view
//{
//	self = [super init];
//	if (self != nil)
//	{
//		CGRect frameInWindow;
//		if ([view isKindOfClass:[UIWindow class]])
//		{
//			frameInWindow = view.frame;
//		}
//		else
//		{
//			frameInWindow =
//			[view.window convertRect:view.frame fromView:view.superview];
//		}
		
//		_tapCount = 1;
//		_locationInWindow =
//		CGPointMake(
//					frameInWindow.origin.x + 0.5 * frameInWindow.size.width,
//					frameInWindow.origin.y + 0.5 * frameInWindow.size.height);
//		_previousLocationInWindow = _locationInWindow;
		
//		UIView *target = [view.window hitTest:_locationInWindow withEvent:nil];
		
		//_window = [view.window retain];
		//_view = [target retain];
//		_phase = UITouchPhaseBegan;
//		_touchFlags._firstTouchForView = 1;
//		_touchFlags._isTap = 1;
//		_timestamp = [NSDate timeIntervalSinceReferenceDate];
//	}
//	return self;
//}