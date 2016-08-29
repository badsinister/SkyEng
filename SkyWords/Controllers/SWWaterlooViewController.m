
#import "SWWaterlooViewController.h"




@implementation SWWaterlooViewController

// ===================================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.delegate respondsToSelector:@selector(soothCount)] && [self.delegate respondsToSelector:@selector(totalCount)]) {
        self.waterlooLabel.text = [NSString stringWithFormat:@"%@/%@", @([self.delegate soothCount]), @([self.delegate totalCount])];
    }
    
} // viewDidLoad

// ===================================================================================
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
} // didReceiveMemoryWarning



#pragma mark - Actions

// ===================================================================================
- (void)doEndGame:(id)sender
{
    [self.delegate endGame];
} // doEndGame

@end // SWWaterlooViewController
