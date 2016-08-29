
#import <UIKit/UIKit.h>
#import "SWEngineViewController.h"




@interface SWStartViewController : UIViewController

@property (strong, nonatomic) id<SWEngineDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)doStart:(id)sender;

/** Количество слов в тренировке */
- (IBAction)doChangeTotal:(id)sender;

/** Подсвечивание нужной кнопки */
- (void)colorizeTotalButtons;

@end // SWStartViewController
