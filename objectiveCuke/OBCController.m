//
//  OBCController.m
//  objectiveCuke
//
//  Created by Grant McInnes on 11-01-27.
//  Copyright 2011 eyesopen. All rights reserved.
//

#import "OBCController.h"


@implementation OBCController

- (id)init
{
	if((self = [super init])) {
		server = [[OBCServer alloc] init];
		requestHandler = [[OBCRequestHandler alloc] init];
	}
	return self;
}

@end
