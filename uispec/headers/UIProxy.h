
@interface UIProxy : NSObject {
	id target;
}

@property(nonatomic, retain) id target;

+(id)withTarget:(id)target;
-(id)initWithTarget:(id)_target;

@end
