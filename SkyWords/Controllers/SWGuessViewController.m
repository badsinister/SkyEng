
#import "SWGuessViewController.h"




static NSString *const SWAlternativeGuessViewControllerKey  = @"SWAlternativeGuessViewController";
static NSString *const SWMeaningViewControllerKey           = @"SWMeaningViewController";




@implementation SWGuessViewController

// ===================================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Создадим PageViewController - все экраны будут жить в нем - никто лучше него не выполнит скролл налево! (И направо!!)
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    // Установим первый контроллер
    UIViewController *alternativeViewController = [self.storyboard instantiateViewControllerWithIdentifier:SWAlternativeGuessViewControllerKey];
    [alternativeViewController setValue:self forKey:@"delegate"];
    [self.pageViewController setViewControllers:@[alternativeViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
    }];
    
    // Наведем красоту и добавимся
    self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO; // подружимся с auto generated constraints
    [self.view insertSubview:self.pageViewController.view atIndex:0];
    
    NSDictionary *views = @{@"subview": self.pageViewController.view};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:0 views:views]];
    [self.view updateConstraintsIfNeeded];
    
    [self addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self];
    
    // Заблокируем рукоблудие (скролл свайпом в UIPageViewControllers, накосяченный эпплами)
    // www.stackoverflow.com/questions/13103613/uipageviewcontroller-returns-no-gesture-recognizers-in-ios-6/13293661#13293661
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = NO;
        }
    }
    
    self.meaningLabel.text = self.meaning.text;
} // viewDidLoad

// ===================================================================================
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
} // didReceiveMemoryWarning



#pragma mark - SWGuessDelegate

// ===================================================================================
- (void)presentNextGuessViewController
{
    if ([self.delegate respondsToSelector:@selector(presentNextGuess)]) {
        [self.delegate presentNextGuess];
    }
} // presentNextGuessViewController

// ===================================================================================
- (void)presentMeaningViewControllerStyle:(SWMeaningViewControllerStyle)style
{
    UIViewController *meaningViewController = [self.storyboard instantiateViewControllerWithIdentifier:SWMeaningViewControllerKey];
    [meaningViewController setValue:self forKey:@"delegate"];
    [meaningViewController setValue:@(style) forKey:@"style"];
    [self.pageViewController setViewControllers:@[meaningViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
    }];
} // presentMeaningViewControllerStyle

// ===================================================================================
- (BOOL)answerWithAlternative:(NSString *)alternative
{
    if ([alternative isEqualToString:self.meaning.translation]) {
        if ([self.delegate respondsToSelector:@selector(congratulate)]) {
            [self.delegate congratulate];
        }
        return YES;
    }
    return NO;
} // answerWithAlternativeAtIndex

// ===================================================================================
- (NSArray *)alternatives
{
    NSMutableArray *alternatives = [[NSMutableArray alloc] initWithArray:self.meaning.diversity];
    [alternatives insertObject:self.meaning.translation atIndex:0];

    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[alternatives objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]]];
    // Тщательно перемещаем...
    NSUInteger countOfItems = [items count];
    for (NSUInteger i = 0; i < countOfItems; ++i) {
        NSUInteger index = (arc4random() % countOfItems - i) + i;
        [items exchangeObjectAtIndex:i withObjectAtIndex:index];
    }
    return [NSArray arrayWithArray:items];
} // alternatives

// ===================================================================================
- (NSString *)translation
{
    return self.meaning.translation;
} // translation

// ===================================================================================
- (UIImage *)image
{
    if ([self.delegate respondsToSelector:@selector(meaningImage)]) {
        return [self.delegate meaningImage];
    }
    // Тут можно вернуть какую нибудь красивую картинку, например...
    return nil;
} // translation

@end // SWGuessViewController
