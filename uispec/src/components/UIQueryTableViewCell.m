
#import "UIQueryTableViewCell.h"


@implementation UIQueryTableViewCell

-(void)delete {
	UITableView *newTableView = (UITableView*)self.parent.tableView;
	[newTableView.dataSource tableView:newTableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[newTableView indexPathForCell:[self.views objectAtIndex:0]]];
}

@end
