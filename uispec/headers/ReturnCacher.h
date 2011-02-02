
#import "CallCache.h"
#import "UIProxy.h"

@interface ReturnCacher : UIProxy {
	CallCache *callCache;
}

@property(nonatomic, retain) CallCache *callCache;

-(NSInvocation *)invocationInArray:(NSArray *)array withMatchingArgValues:(NSInvocation *)invocation;

@end
