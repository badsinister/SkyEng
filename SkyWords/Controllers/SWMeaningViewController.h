/**
 
    Отображение задуманного слова слова.
    ====================================
    
    Если слово переведено верно - цвет кнопки зеленый,
    иначе красный. В реальной жизни здесь можно показать 
    какие нибудь салютики или горести...
 
*/

#import <UIKit/UIKit.h>
#import "SWGuessViewController.h"
#import "SWButton.h"




@interface SWMeaningViewController : UIViewController

@property (weak, nonatomic) id<SWGuessDelegate> delegate;

@property (assign, nonatomic) SWMeaningViewControllerStyle style;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *translationLabel;
@property (weak, nonatomic) IBOutlet SWButton *forwardButton;

- (IBAction)doForward:(id)sender;

@end // SWMeaningViewController
