//
//  UIDriver.m
//  objectiveCuke
//
//  Created by Nathaniel Hamming on 11-01-31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIDriver.h"
#import "UIQuery.h"

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
	UIQuery *app = [UIQuery withApplication];
	[[app.tableViewCell.label text:@"Buttons"] touch];
}


@end
