/**

    Основной контроллер, в котором живет вся механика.
    ==================================================
 
*/

#import <UIKit/UIKit.h>
#import "SWDataContext.h"




@protocol SWEngineDelegate <NSObject>

- (void)startGame; // отображаем стартовый контроллер "Начать тренировку!"
- (void)presentNextGuess; // отображаем следующий Guess контроллер
- (void)endGame; // отображаем завершающий контроллер "Начать сначала"

- (UIImage *)meaningImage;

- (void)congratulate;
- (NSUInteger)soothCount;
- (NSUInteger)totalCount;
- (void)setTotalCount:(NSUInteger)totalCount;

@end // SWEngineDelegate




@interface SWEngineViewController : UIViewController <SWEngineDelegate, SWDataContextDelegate, NSFetchedResultsControllerDelegate>

/** PageViewController в котором живут ViewControllers */
@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (strong, nonatomic) SWDataContext *dataContext;

/** Количество слов... короче, важная переменная 10 */
@property (assign, nonatomic) NSUInteger totalCount;

/** Текущее слово */
@property (assign, nonatomic) NSUInteger guessIndex;

/** Количество правильных ответов */
@property (assign, nonatomic) NSUInteger soothCount;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *progressViewBorder;

/** Самопальный загрузчик */
@property (weak, nonatomic) IBOutlet UIView *loaderView;
- (void)hideLoaderView;

@end // SWEngineViewController
