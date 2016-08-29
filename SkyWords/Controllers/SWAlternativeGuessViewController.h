/**
 
    Кручу, верчу - обмануть хочу.
    =============================

    Варианты переводов для слова
 
*/


#import <UIKit/UIKit.h>
#import "SWGuessViewController.h"




@interface SWAlternativeGuessViewController : UIViewController

@property (weak, nonatomic) id<SWGuessDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *button0;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;

@property (strong, nonatomic) NSArray *buttons;

- (IBAction)doAnswer:(id)sender;
- (IBAction)doSkip:(id)sender;

@end // SWAlternativeGuessViewController
