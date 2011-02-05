//
//  TouchSynthesis.m
//  SelfTesting
//
//  Created by Matt Gallagher on 23/11/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>

@interface UITouch (Synthesize_old)
- (id)initInView:(UIView *)view;
- (void)setPhase:(UITouchPhase)phase;
@end

@implementation UITouch (Synthesize_old)

//
// initInView:phase:
//
// Creats a UITouch, centered on the specified view, in the view's window.
// Sets the phase as specified.
//
- (id)initInView:(UIView *)view
{
	self = [super init];
	if (self != nil)
	{
		CGRect frameInWindow;
		if ([view isKindOfClass:[UIWindow class]])
		{
			frameInWindow = view.frame;
		}
		else
		{
			frameInWindow =
			[view.window convertRect:view.frame fromView:view.superview];
		}
		
		_tapCount = 1;
		_locationInWindow =
		CGPointMake(
					frameInWindow.origin.x + 0.5 * frameInWindow.size.width,
					frameInWindow.origin.y + 0.5 * frameInWindow.size.height);
		_previousLocationInWindow = _locationInWindow;
		
		UIView *target = [view.window hitTest:_locationInWindow withEvent:nil];
		
		_window = [view.window retain];
		_view = [target retain];
		_phase = UITouchPhaseBegan;
		_touchFlags._firstTouchForView = 1;
		_touchFlags._isTap = 1;
		_timestamp = [NSDate timeIntervalSinceReferenceDate];
	}
	return self;
}

//
// setPhase:
//
// Setter to allow access to the _phase member.
//
- (void)setPhase:(UITouchPhase)phase
{
	_phase = phase;
	_timestamp = [NSDate timeIntervalSinceReferenceDate];
}

//
// setPhase:
//
// Setter to allow access to the _locationInWindow member.
//
- (void)setLocationInWindow:(CGPoint)location
{
	_previousLocationInWindow = _locationInWindow;
	_locationInWindow = location;
	_timestamp = [NSDate timeIntervalSinceReferenceDate];
}

@end



//
// GSEvent is an undeclared object. We don't need to use it ourselves but some
// Apple APIs (UIScrollView in particular) require the x and y fields to be present.
//
@interface GSEventProxy : NSObject
{
@public
	unsigned int flags;
	unsigned int type;
	unsigned int ignored1;
	float x1;
	float y1;
	float x2;
	float y2;
	unsigned int ignored2[10];
	unsigned int ignored3[7];
	float sizeX;
	float sizeY;
	float x3;
	float y3;
	unsigned int ignored4[3];
}
@end
@implementation GSEventProxy
@end

//
// PublicEvent
//
// A dummy class used to gain access to UIEvent's private member variables.
// If UIEvent changes at all, this will break.
//
@interface PublicEvent : NSObject
{
@public
    GSEventProxy           *_event;
    NSTimeInterval          _timestamp;
    NSMutableSet           *_touches;
    CFMutableDictionaryRef  _keyedTouches;
}
@end

@implementation PublicEvent
@end

@interface UIEvent (Creation)

- (id)_initWithEvent:(GSEventProxy *)fp8 touches:(id)fp12;

@end


//
// UIEvent (Synthesize)
//
// A category to allow creation of a touch event.
//
@interface UIEvent (Synthesize_old)
- (id)initWithTouch:(UITouch *)touch;
@end

@implementation UIEvent (Synthesize_old)

- (id)initWithTouch:(UITouch *)touch
{
	CGPoint location = [touch locationInView:touch.window];
	GSEventProxy *gsEventProxy = [[GSEventProxy alloc] init];
	gsEventProxy->x1 = location.x;
	gsEventProxy->y1 = location.y;
	gsEventProxy->x2 = location.x;
	gsEventProxy->y2 = location.y;
	gsEventProxy->x3 = location.x;
	gsEventProxy->y3 = location.y;
	gsEventProxy->sizeX = 1.0;
	gsEventProxy->sizeY = 1.0;
	gsEventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
	gsEventProxy->type = 3001;	
	
	//
	// On SDK versions 3.0 and greater, we need to reallocate as a
	// UITouchesEvent.
	//
	Class touchesEventClass = objc_getClass("UITouchesEvent");
	if (touchesEventClass && ![[self class] isEqual:touchesEventClass])
	{
		[self release];
		self = [touchesEventClass alloc];
	}
	
	self = [self _initWithEvent:gsEventProxy touches:[NSSet setWithObject:touch]];
	if (self != nil)
	{
	}
	return self;
}

@end

#import "UIQuery.h"
#import "objc/runtime.h"
#import "UIDescendants.h"
#import "UIChildren.h"
#import "UIParents.h"
#import "WaitUntilIdle.h"
#import "UIRedoer.h"
#import "UIQueryTableViewCell.h"
#import "UIQueryTableView.h"
#import "UIQuerySearchBar.h"
#import "UIQueryTabBar.h"
#import "UIQuerySegmentedControl.h"
#import "UIQueryWebView.h"
#import "UIQueryAll.h"
#import "UIFilter.h"
#import "UIBug.h"
#import "UIQueryExpectation.h"
#import "UITouch+Synthesize.h"
#import "UIEvent+Synthesize.h"

@implementation UIQuery

@synthesize with;
@synthesize should;
@synthesize parent, child, descendant, find;
@synthesize touch, flash, show, path, inspect;
@synthesize timeout;
@synthesize views;
@synthesize className;
@synthesize redoer;
@synthesize first, last, all, redo;
@synthesize exists;

+(id)withApplication {
	return [self withViews:[NSMutableArray arrayWithObject:[UIApplication sharedApplication]] className:NSStringFromClass([UIApplication class])];
}

-(UIQuery *)find {
	return [self descendant];
}

-(UIQuery *)descendant {
	[self wait:.25];
	return [UIQuery withViews:[[[UIDescendants withTraversal] collect:views] mutableCopy] className:className filter:YES];
}

-(UIQuery *)child {
	[self wait:.25];
	return [UIQuery withViews:[[[UIChildren withTraversal] collect:views] mutableCopy] className:className filter:YES];
}

-(UIQuery *)parent {
	[self wait:.25];
	return [UIQuery withViews:[[[UIParents withTraversal] collect:views] mutableCopy] className:className filter:YES];
}

-(UIQueryExpectation *)should {
	return [UIQueryExpectation withQuery:self];
}

-(UIFilter *)with {
	return [UIFilter withQuery:self];
}

+(id)withViews:(NSMutableArray *)views className:(NSString *)className {
	return [UIRedoer withTarget:[[[self alloc] initWithViews:views className:className filter:NO] autorelease]];
}

+(id)withViews:(NSMutableArray *)views className:(NSString *)className filter:(BOOL)filter {
	return [UIRedoer withTarget:[[[self alloc] initWithViews:views className:className filter:filter] autorelease]];
}

-(id)initWithViews:(NSMutableArray *)_views className:(NSString *)_className filter:(BOOL)_filter {
	if (self = [super init]) {
		self.timeout = 10;
		self.views = _views;
		self.className = _className;
		filter = _filter;
	}
	return self;
}

-(NSArray *)collect:(NSArray *)newViews {
	return [[[[UIDescendants alloc] init] autorelease] collect:newViews];
}

-(UIQuery *)target {
	return self;
}

-(NSArray *)targetViews {
	return (views.count == 0) ? [NSArray array] : [NSArray arrayWithObject:[views objectAtIndex:0]];
}

-(UIQuery *)timeout:(int)seconds {
	UIQuery *copy = [UIQuery withViews:views className:className];
	copy.timeout = seconds;
	return copy;
}

-(id)templateFilter {
	NSString *viewName = NSStringFromSelector(_cmd);
	return [self view:[NSString stringWithFormat:@"UI%@", [viewName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[viewName substringWithRange:NSMakeRange(0,1)] uppercaseString]]]];
}

-(UIQuery *)index:(int)index {
	if (index >= views.count) {
		NSLog(@"UISPEC WARNING: %@ doesn't exist at index %i", className, index);
	}
	NSArray *resultViews = (index >= views.count) ? [NSArray array] : [NSArray arrayWithObject:[views objectAtIndex:index]];
	return [UIQuery withViews:[resultViews mutableCopy] className:className];
}

-(UIQuery *)first {
	return [self index:0];
}

-(UIQuery *)last {
	return [self index:views.count - 1];
}

-(UIQuery *)all {
	return [UIQueryAll withViews:views className:className];
}

-(UIQuery *)view:(NSString *)newClassName {
	NSMutableArray *array = [NSMutableArray array];
	NSDate *start = [NSDate date];
	while ([start timeIntervalSinceNow] > (0 - timeout)) {
		NSArray *newViews = filter ? self.views : self.descendant.views;
		Class class = NSClassFromString(newClassName);
		for (UIView * v in newViews) {
			if ([v isKindOfClass:class]) {
				[array addObject:v];
			} 
		}
		if (array.count > 0) {
			break;
		}
		self.redo;
	}
	if ([newClassName isEqualToString:@"UITableViewCell"]) {
		return [UIQueryTableViewCell withViews:array className:newClassName];
	} else if ([className isEqualToString:@"UITableView"]) {
		return [UIQueryTableView withViews:array className:newClassName];
	} 
	else if ([newClassName isEqualToString:@"UISearchBar"]) {
		return [UIQuerySearchBar withViews:array className:newClassName];
	}
	else if ([newClassName isEqualToString:@"UITabBar"]) {
		return [UIQueryTabBar withViews:array className:newClassName];
	}
	else if ([newClassName isEqualToString:@"UISegmentedControl"]) {
		return [UIQuerySegmentedControl withViews:array className:newClassName];
	}
	else if ([newClassName isEqualToString:@"UIWebView"]) {
		return [UIQueryWebView withViews:array className:newClassName];
	}
	else {
		return [UIQuery withViews:array className:newClassName];
	}
}

-(UIQuery *)marked:(NSString *)mark {
	return [self.with accessibilityLabel:mark];
}
 
-(UIQuery *)wait:(double)seconds {
	CFRunLoopRunInMode(kCFRunLoopDefaultMode, seconds, false);
	return [UIQuery withViews:views className:className];
}

-(id)redo {
	//NSLog(@"UIQuery redo");
	if (redoer != nil) {
		//NSLog(@"UIQuery redo redoer = %@", redoer);
		UIRedoer *redone = [redoer redo];
		redoer.target = redone.target;
		self.views = [[redoer play] views];
	}
	//return is provided by uiredoer
}

-(BOOL)exists {
	return [self targetViews].count > 0;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	if ([UIQuery instancesRespondToSelector:aSelector]) {
		return [super methodSignatureForSelector:aSelector];
	}
	
	[[UIQueryExpectation withQuery:self] exist:[NSString stringWithFormat:@"before you can call %@", NSStringFromSelector(aSelector)]];
	NSString *selector = NSStringFromSelector(aSelector);
	
	for (UIView *target in [self targetViews]) {
		if ([target respondsToSelector:aSelector]) {
			return [target methodSignatureForSelector:aSelector];
		}
	}
	
	//Check if any view responds as a property match
	NSArray *selectors = [selector componentsSeparatedByString:@":"];
	if (selectors.count > 1) {
		return [self.with methodSignatureForSelector:aSelector];
	}
	return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	BOOL isDirect = NO;
	for (UIView *target in [self targetViews]) {
		if ([target respondsToSelector:[anInvocation selector]]) {
			[anInvocation invokeWithTarget:target];
			isDirect = YES;
		}
	}
	
	if (!isDirect) {
		[[[UIRedoer withTarget:self] with] forwardInvocation:anInvocation];
	}
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	if ([UIQuery instancesRespondToSelector:aSelector]) {
		return YES;
	}
	for (UIView *target in [self targetViews]) {
		if ([target respondsToSelector:aSelector]) {
			return YES;
		}
	}
	return [super respondsToSelector:aSelector];
}

-(UIQuery *)flash {
	[[UIQueryExpectation withQuery:self] exist:@"before you can flash it"];
	for (UIView *newView in [self targetViews]) {
		UIColor *tempColor = [newView.backgroundColor retain];
		for (int i=0; i<5; i++) {
			newView.backgroundColor = [UIColor yellowColor];
			CFRunLoopRunInMode(kCFRunLoopDefaultMode, .05, false);
			newView.backgroundColor = [UIColor blueColor];
			CFRunLoopRunInMode(kCFRunLoopDefaultMode, .05, false);
		}
		newView.backgroundColor = tempColor;
		[tempColor release];
	}
	return [UIQuery withViews:views className:className];
}

-(UIQuery *)show {
	//NSLog(@"calling show");
	[[UIQueryExpectation withQuery:self] exist:@"before you can show it"];
	[UIQuery show:[self targetViews]];
	return [UIQuery withViews:views className:className];
}

-(UIQuery *)path {
	[[UIQueryExpectation withQuery:self] exist:@"before you can show its path"];
	for (UIView *newView in [self targetViews]) {
		NSMutableString *newPath = [NSMutableString stringWithString:@"\n"];
		NSArray *parentViews = [[UIParents withTraversal] collect:[NSArray arrayWithObject:newView]];
		for (int i = parentViews.count-1; i>=0; i--) {
			[newPath appendFormat:@"%@ -> ", [[parentViews objectAtIndex:i] class]];
		}
		[newPath appendFormat:@"%@", [newView class]];
		NSLog(@"%@", newPath);
	}
	return [UIQuery withViews:views className:className]; 
}

-(UIQuery *)inspect {
	[UIBug openInspectorWithView:[views objectAtIndex:0]];
	return [UIQuery withViews:views className:className]; 
}

+(void)show:(NSArray *)views {
	for (UIView *view in views) {
		NSMutableDictionary *dict = [[self describe:view] mutableCopy];
		if ([dict allKeys].count > 0) {
			NSLog(@"\nClass: %@ \n%@", [view class], [dict description]);
		}
	}
}

+(NSDictionary *)describe:(id)object {
	//NSLog(@"describing object %@", object);
	NSMutableDictionary *properties = [NSMutableDictionary dictionary];
	Class clazz = [object class];
	do {
		//NSLog(@"describing class %@", NSStringFromClass(clazz));
		unsigned i;
		id objValue;
		int intValue;
		long longValue;
		char *charPtrValue;
		char charValue;
		short shortValue;
		float floatValue;
		double doubleValue;
		
		NSUInteger propertyCount = 0;
		objc_property_t *propertyList = class_copyPropertyList(clazz, &propertyCount);
		//NSLog(@"property count = %d", propertyCount);
		for (i=0; i<propertyCount; i++) {
			objc_property_t *thisProperty = propertyList + i;
			const char* propertyName = property_getName(*thisProperty);
			const char* propertyAttributes = property_getAttributes(*thisProperty);
			
			NSString *key = [NSString stringWithFormat:@"%s", propertyName];
			NSString *keyAttributes = [NSString stringWithFormat:@"%s", propertyAttributes];
			//NSLog(@"key = %@", key);
			//NSLog(@"keyAttributes = %@", keyAttributes);
			
			NSArray *attributes = [keyAttributes componentsSeparatedByString:@","];
			if ([[[attributes lastObject] substringToIndex:1] isEqualToString:@"G"]) {
				key = [[attributes lastObject] substringFromIndex:1];
			}
			
			SEL selector = NSSelectorFromString(key);
			if ([object respondsToSelector:selector]) {
				NSMethodSignature *sig = [object methodSignatureForSelector:selector];
				//NSLog(@"sig = %@", sig);
				NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
				[invocation setSelector:selector];
				//NSLog(@"invocation selector = %@", NSStringFromSelector([invocation selector]));
				[invocation setTarget:object];
				
				@try {
					[invocation invoke];
				}
				@catch (NSException *exception) {
					NSLog(@"UIQuery.describe caught %@: %@", [exception name], [exception reason]);
					continue;
				}
				
				const char* type = [[invocation methodSignature] methodReturnType];
				NSString *returnType = [NSString stringWithFormat:@"%s", type];
				const char* trimmedType = [[returnType substringToIndex:1] cStringUsingEncoding:NSASCIIStringEncoding];
				//NSLog(@"return type = %@", returnType);
				switch(*trimmedType) {
					case '@':
						[invocation getReturnValue:(void **)&objValue];
						if (objValue == nil) {
							[properties setObject:[NSString stringWithFormat:@"%@", objValue] forKey:key];
						} else {
							[properties setObject:objValue forKey:key];
						}
						break;
					case 'i':
						[invocation getReturnValue:(void **)&intValue];
						[properties setObject:[NSString stringWithFormat:@"%i", intValue] forKey:key];
						break;
					case 's':
						[invocation getReturnValue:(void **)&shortValue];
						[properties setObject:[NSString stringWithFormat:@"%ud", shortValue] forKey:key];
						break;
					case 'd':
						[invocation getReturnValue:(void **)&doubleValue];
						[properties setObject:[NSString stringWithFormat:@"%lf", doubleValue] forKey:key];
						break;
					case 'f':
						[invocation getReturnValue:(void **)&floatValue];
						[properties setObject:[NSString stringWithFormat:@"%f", floatValue] forKey:key];
						break;
					case 'l':
						[invocation getReturnValue:(void **)&longValue];
						[properties setObject:[NSString stringWithFormat:@"%ld", longValue] forKey:key];
						break;
					case '*':
						[invocation getReturnValue:(void **)&charPtrValue];
						[properties setObject:[NSString stringWithFormat:@"%s", charPtrValue] forKey:key];
						break;
					case 'c':
						[invocation getReturnValue:(void **)&charValue];
						[properties setObject:[NSString stringWithFormat:@"%d", charValue] forKey:key];
						break;
					case '{': {
						unsigned int length = [[invocation methodSignature] methodReturnLength];
						void *buffer = (void *)malloc(length);
						[invocation getReturnValue:buffer];
						NSValue *value = [[[NSValue alloc] initWithBytes:buffer objCType:type] autorelease];
						[properties setObject:value forKey:key];
						break;
					}
				}
			}
		}
	} while ((clazz = class_getSuperclass(clazz)) != nil);
    return properties;
}

- (UIQuery *)touch {
	[[UIQueryExpectation withQuery:self] exist:@"before you can touch it"];
	
	for (UIView *newView in [self targetViews]) {
		UITouch *newTouch = [[UITouch alloc] initInView:newView];
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
	}
	return [UIQuery withViews:views className:className];
}

-(NSString *)description {
	return [NSString stringWithFormat:@"UIQuery: %@", [views description]];
}

-(void)logRange:(NSString *)prefix range:(NSRange)range {
	NSLog(@"%@ location = %d, length = %d", prefix, range.location, range.length);
}

-(void)dealloc {
	self.views = nil;
	self.className = nil;
	self.redoer = nil;
	[super dealloc];
}

@end

UIQuery * $(NSMutableString *script, ...) {
	va_list args;
	va_start(args, script);
	script = [[[NSMutableString alloc] initWithFormat:script arguments:args] autorelease];
	va_end(args);
	
	UIQuery *result = [UIQuery withApplication];
	//NSLog(@"script = %@, length = %d", script, script.length);
	
	NSMutableArray *strings = [NSMutableArray array];
	NSArray *stringParams = [script componentsSeparatedByString:@"'"];
	//NSLog(@"stringParams = %@", stringParams);
	if (stringParams.count > 1) {
		for (int i=1; i<stringParams.count; i=i+2) {
			[strings addObject:[stringParams objectAtIndex:i]];
			[script replaceOccurrencesOfString:[NSString stringWithFormat:@"'%@'", [stringParams objectAtIndex:i]] withString:@"BIGFATGUYWITHPIGFEET" options:NSLiteralSearch range:NSMakeRange(0, [script length])];
		}
	} else {
		stringParams = [script componentsSeparatedByString:@"\""];
		//NSLog(@"stringParams = %@", stringParams);
		if (stringParams.count > 1) {
			for (int i=1; i<stringParams.count; i=i+2) {
				[strings addObject:[stringParams objectAtIndex:i]];
				[script replaceOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", [stringParams objectAtIndex:i]] withString:@"BIGFATGUYWITHPIGFEET" options:NSLiteralSearch range:NSMakeRange(0, [script length])];
			}
		}
	}
	//NSLog(@"script = %@", script);
	//NSLog(@"strings = %@", strings);
	
	NSArray *commands = [script componentsSeparatedByString:@" "];
	//NSLog(@"commands = %@", commands);
	
	int stringCount = 0;
	for (NSString *command in commands) {
		NSArray *commandAndParam = [command componentsSeparatedByString:@":"];
		NSString *commandValue = [commandAndParam objectAtIndex:0];
		//NSLog(@"commandValue = %@", commandValue);
		NSString *param = nil;
		if (commandAndParam.count > 1) {
			param = [commandAndParam objectAtIndex:1];
		}
		if (param != nil) {
			id paramValue = nil;
			if ([param isEqualToString:@"BIGFATGUYWITHPIGFEET"]) {
				paramValue = [strings objectAtIndex:stringCount];
				stringCount++;
				//NSLog(@"paramValue = %@", paramValue);
			} else if ([param isEqualToString:@"YES"] || [param isEqualToString:@"NO"]) {
				paramValue = [param isEqualToString:@"YES"];
				//NSLog(@"paramValue = %d", paramValue);
			} else {
				paramValue = [param intValue];
				//NSLog(@"paramValue = %d", paramValue);
			}
			result = [result performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@:", commandValue]) withObject:paramValue];
		} else {
			result = [result performSelector:NSSelectorFromString(commandValue)];
		}
		//NSLog(@"result = %@", result);
	}
	return result;
}