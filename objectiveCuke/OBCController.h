//
//  OBCController.h
//  objectiveCuke
//
//  Created by Grant McInnes on 11-01-27.
//  Copyright 2011 eyesopen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBCServer.h"
#import "OBCRequestHandler.h"

@interface OBCController : NSObject {

	OBCRequestHandler *requestHandler;
	OBCServer *server;
	
}

@end
