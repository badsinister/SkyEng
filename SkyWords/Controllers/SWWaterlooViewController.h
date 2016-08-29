
#import <UIKit/UIKit.h>
#import "SWEngineViewController.h"




@interface SWWaterlooViewController : UIViewController

@property (weak, nonatomic) id<SWEngineDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *waterlooLabel;

- (IBAction)doEndGame:(id)sender;

@end // SWWaterlooViewController
