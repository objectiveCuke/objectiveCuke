//
//  server.m
//  objectiveCuke
//
//  Created by Grant McInnes on 11-01-26.
//  Copyright 2011 eyesopen. All rights reserved.
//

#import "OBCServer.h"
#import "AsyncSocket.h"

NSString * const kCucumberMessageArrived = @"kCucumberMessageArrived";
NSString * const kCucumberMessage = @"kCucumberMessage";

#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0
#define PORT 7678

static OBCServer *sharedOBCServer;

@implementation OBCServer

#pragma mark -
#pragma mark Singleton methods
+ (OBCServer *)sharedOBCServer 
{
	if (!sharedOBCServer) 
	{
		sharedOBCServer = [[OBCServer alloc] init];
	}
	return sharedOBCServer;	
}

+ (id)alloc 
{
	NSAssert(sharedOBCServer == nil, @"Attempted to allocate a second instance of a sharedOBCServer.");
	sharedOBCServer = [super alloc];
	return sharedOBCServer;
}

#pragma mark -
- (id)init
{
	if((self = [super init]))
	{
		listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
		connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
	}
	notificationCenter = [NSNotificationCenter defaultCenter];
	// Advanced options - enable the socket to contine operations
	// even during modal dialogs, and menu browsing
	[listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
	NSLog(@"Ready");
	return self;
}

- (void)dealloc
{
	[super	dealloc];
	[listenSocket disconnect];
	[listenSocket dealloc];
}

- (void)start {	
	NSError *error = nil;
	if(![listenSocket acceptOnPort:PORT error:&error]) {
		NSLog(@"There was an error");
		[listenSocket disconnect];
		return;
	}	
}

- (void)onSocket:(AsyncSocket *)sock 
didAcceptNewSocket:(AsyncSocket *)newSocket
{
	[connectedSockets addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock
didConnectToHost:(NSString *)host
			port:(UInt16)port
{
	NSLog(@"Accepted client %@:%hu", host, port);
	[sock readDataToData:[AsyncSocket CRLFData]
			 withTimeout:READ_TIMEOUT
					 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock
	 didReadData:(NSData *)data
		 withTag:(long)tag
{
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 1)];
	NSString *msg = [[[NSString alloc] initWithData:strData 
										   encoding:NSUTF8StringEncoding] autorelease];
	if(msg)
	{
		NSLog(@"Recieved %@", msg);
	}
	else {
		NSLog(@"Error converting data into UTF-8 String");
	}
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msg 
														 forKey:kCucumberMessage];
	[notificationCenter postNotificationName:kCucumberMessageArrived 
									  object:self
									userInfo:userInfo];
	
	[sock readDataToData:[AsyncSocket LFData]
			 withTimeout:READ_TIMEOUT
					 tag:0];
	
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	NSLog(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]);
	[connectedSockets removeObject:sock];
}

@end
