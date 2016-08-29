
#import "SWEngineViewController.h"
#import "SWMeaning.h"



static NSString *const SWStartViewControllerKey     = @"SWStartViewController";
static NSString *const SWGuessViewControllerKey     = @"SWGuessViewController";
static NSString *const SWWaterlooViewControllerKey  = @"SWWaterlooViewController";
static NSString *const SWTotalCountKey              = @"SWTotalCount";




@implementation SWEngineViewController

// ===================================================================================
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.totalCount = [[NSUserDefaults standardUserDefaults] integerForKey:SWTotalCountKey];
    if (!self.totalCount) {
        self.totalCount = 10;
    }
} // awakeFromNib

// ===================================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Создадим PageViewController - все экраны будут жить в нем - никто лучше него не выполнит скролл налево! (И направо!!)
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    // Установим первый контроллер
    UIViewController *startViewController = [self.storyboard instantiateViewControllerWithIdentifier:SWStartViewControllerKey];
    [startViewController setValue:self forKey:@"delegate"];
    [self.pageViewController setViewControllers:@[startViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
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

    // Индикатор Progress
    // Будем считать что это один компонент - что мы не поленились,
    // унаследовались от UIProgressView... и кастомизировались
    self.progressView.transform = CGAffineTransformMakeScale(1.0, 3.0);
    self.progressView.alpha = 0;
    
    self.progressView.layer.cornerRadius = 3.5;
    self.progressView.clipsToBounds = YES;
    
    self.progressViewBorder.layer.cornerRadius = 3.5;
    self.progressViewBorder.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
    self.progressViewBorder.layer.borderWidth = 1.0;
    self.progressViewBorder.alpha = 0;
    
    // Создадим контекст с данными
    self.dataContext = [[SWDataContext alloc] initWithDelegate:self];
    [self.dataContext initializeManagedObjectContext];
} // viewDidLoad

// ===================================================================================
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
} // didReceiveMemoryWarning

// ===================================================================================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
} // viewWillAppear

// ===================================================================================
- (void)hideLoaderView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.loaderView.alpha = 0;
    }];
} // hideLoaderView

// ===================================================================================
- (void)setTotalCount:(NSUInteger)totalCount
{
    _totalCount = totalCount;
    [[NSUserDefaults standardUserDefaults] setInteger:totalCount forKey:SWTotalCountKey];
} // setTotalCount



#pragma mark - SWDataContextDelegate

// ===================================================================================
- (void)dataContext:(SWDataContext *)dataContext didInitializeWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    // Контекст с данными готов...
    if ([dataContext loadMeanings]) {
        // и даже есть слова...
        [self hideLoaderView];
    };
} // didInitializeWithManagedObjectContext

// ===================================================================================
- (void)dataContextDidChangeContent:(SWDataContext *)dataContext
{
    // Здесь оказываемся после дозагрузки слов
    // Рассказываем с большим интересом, то мы загрузили много нового..
    [self hideLoaderView];
} // didStartContext



#pragma mark - SWEngineDelegate

// ===================================================================================
- (void)startGame
{
    self.guessIndex = 0;
    self.soothCount = 0;
    self.progressView.progress = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.progressView.alpha = 1;
        self.progressViewBorder.alpha = 1;
    }];

    [self presentGuessViewControllerAtIndex:self.guessIndex];
} // startGame

// ===================================================================================
- (void)presentNextGuess
{
    self.guessIndex++;
    if (self.guessIndex < self.totalCount) {
        [self presentGuessViewControllerAtIndex:self.guessIndex];
    } else {
        // Закончили упражнения! Переходим к водным процедурам..
        self.progressView.progress = 1.0;
        [UIView animateWithDuration:0.3 animations:^{
            self.progressView.alpha = 0;
            self.progressViewBorder.alpha = 0;
        }];

        UIViewController *waterlooViewController = [self.storyboard instantiateViewControllerWithIdentifier:SWWaterlooViewControllerKey];
        [waterlooViewController setValue:self forKey:@"delegate"];
        [self.pageViewController setViewControllers:@[waterlooViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        }];
    }
} // presentNextGuess

// ===================================================================================
- (void)congratulate
{
    // Тут надо конечно насобирать статистики всякой..
    // Но мы попростому..
    self.soothCount++;
} // congratulate

// ===================================================================================
- (void)endGame
{
    // Отправимся в начало
    UIViewController *startViewController = [self.storyboard instantiateViewControllerWithIdentifier:SWStartViewControllerKey];
    [startViewController setValue:self forKey:@"delegate"];
    [self.pageViewController setViewControllers:@[startViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
    }];
    
    // Перемешаем слова для будущих поколений
    // Почему делаем это здесь? А к тому, что бы при старте небыло ни малейших задержек
    
    [self.dataContext shakeMeanings];
} // endGame

// ===================================================================================
- (UIImage *)meaningImage
{
    return [self.dataContext fetchImageForMeaningAtIndex:self.guessIndex];
} // meaningImage


#pragma mark -

// ===================================================================================
- (void)presentGuessViewControllerAtIndex:(NSUInteger)index
{
    UIViewController *guessViewController = [self.storyboard instantiateViewControllerWithIdentifier:SWGuessViewControllerKey];
    [guessViewController setValue:self forKey:@"delegate"];
    
    // Подготовим слово
    [guessViewController setValue:[self.dataContext meaningAtIndex:index] forKey:@"meaning"];
    
    __weak UIProgressView *weakProgressView = self.progressView;
    [self.pageViewController setViewControllers:@[guessViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        weakProgressView.progress = (CGFloat)index / (self.totalCount + 1);
    }];
} // presentGuessViewControllerAtIndex

@end // SWEngineViewController
