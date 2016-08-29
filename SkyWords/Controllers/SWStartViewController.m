
#import "SWStartViewController.h"
#import "SWButton.h"




@implementation SWStartViewController

// ===================================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];
} // viewDidLoad

// ===================================================================================
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
} // didReceiveMemoryWarning

// ===================================================================================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self colorizeTotalButtons];
} // viewWillAppear

// ===================================================================================
- (void)colorizeTotalButtons
{
    if ([self.delegate respondsToSelector:@selector(totalCount)]) {
        NSUInteger total = [self.delegate totalCount];
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[SWButton class]] && view.tag) {
                SWButton *button = (SWButton *)view;
                if (button.tag == total) {
                    button.greenButton = YES;
                } else {
                    button.greenButton = NO;
                }
                [button setNeedsDisplay];
            }
        }
    }
} // colorizeTotalButtons



#pragma mark - Actions

// ===================================================================================
- (void)doChangeTotal:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(setTotalCount:)]) {
        SWButton *button = (SWButton *)sender;
        [self.delegate setTotalCount:button.tag];
    }
    [self colorizeTotalButtons];
} // doChangeTotal

// ===================================================================================
- (void)doStart:(id)sender
{
    [self.delegate startGame];
} // doStart

@end // SWStartViewController
