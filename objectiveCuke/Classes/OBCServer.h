//
//  server.h
//  objectiveCuke
//
//  Created by Grant McInnes on 11-01-26.
//  Copyright 2011 eyesopen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AsyncSocket;

@interface OBCServer : NSObject {
	AsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;
	NSNotificationCenter* notificationCenter;
}

+ (OBCServer *)sharedOBCServer;
- (void)start;

@end
