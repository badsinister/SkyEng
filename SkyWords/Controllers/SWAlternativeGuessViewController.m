
#import "SWAlternativeGuessViewController.h"
#import "SWButton.h"




@implementation SWAlternativeGuessViewController

// ===================================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // !!!!! Плохое место! Количество альтернатив может не совпасть с количеством кнопок в exception сторону..
    
    self.buttons = [NSArray arrayWithObjects:self.button0, self.button1, self.button2, self.button3, nil];
    if ([self.delegate respondsToSelector:@selector(alternatives)]) {
        NSArray *alternatives = [self.delegate alternatives];
        for (NSUInteger i = 0; i < [self.buttons count]; i++) {
            SWButton *button = self.buttons[i];
            [button setTitle:alternatives[i] forState:UIControlStateNormal];
        }
    }
} // viewDidLoad

// ===================================================================================
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
} // didReceiveMemoryWarning



#pragma mark - Actions

// ===================================================================================
- (void)doSkip:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(presentMeaningViewControllerStyle:)]) {
        [self.delegate presentMeaningViewControllerStyle:SWMeaningViewControllerStyleDefault];
    }
} // doSkip

// ===================================================================================
- (IBAction)doAnswer:(id)sender
{
    // Выбор сделан!
    // заблокируем все кнопки!
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]] ) {
            subview.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.2 animations:^{
                subview.alpha = 0.3;
            }];
        }
    }
    // Посмотрим что с выбранной кнопкой
    SWButton *answerButton = (SWButton *)sender;
    BOOL answer = NO;
    if ([self.delegate respondsToSelector:@selector(answerWithAlternative:)]) {
        answer = [self.delegate answerWithAlternative:answerButton.titleLabel.text];
    }
    if (answer) {
        answerButton.greenButton = YES;
    } else {
        answerButton.redButton = YES;
    }
    [UIView animateWithDuration:0.4 animations:^{
        answerButton.alpha = 1;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(presentMeaningViewControllerStyle:)]) {
            if (answer) {
                [self.delegate presentMeaningViewControllerStyle:SWMeaningViewControllerStyleGreen];
            } else {
                [self.delegate presentMeaningViewControllerStyle:SWMeaningViewControllerStyleRed];
            }
        }
    }];
} // doAnswer

@end // SWAlternativeGuessViewController
