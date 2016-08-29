
#import <UIKit/UIKit.h>
#import "SWEngineViewController.h"
#import "SWMeaning.h"




/** Стиль кнопки при просмотре перевода слова */
typedef NS_ENUM(NSInteger, SWMeaningViewControllerStyle) {
    SWMeaningViewControllerStyleDefault,
    SWMeaningViewControllerStyleRed,
    SWMeaningViewControllerStyleGreen
};




@protocol SWGuessDelegate <NSObject>

/** Предлагаем вариант ответа от 0 до 3 - в ответ результат YES, если ответили правильно */
- (BOOL)answerWithAlternative:(NSString *)alternative;

/** Посмотрели правильный вариант - и SWMeaningViewController
    посылает нас куда подальше... смотреть следующее слово, напр. */
- (void)presentNextGuessViewController;

/** Переходим к просмотру перевода с результатом */
- (void)presentMeaningViewControllerStyle:(SWMeaningViewControllerStyle)style;

/** Список вариантов. Среди них должен быть правильный.. ну или нет, на самом деле. В жизни всегда так, вик угадаешь. */
- (NSArray *)alternatives;

/** Правильный перевод */
- (NSString *)translation;

/** Красивая картинка */
- (UIImage *)image;

@end // SWGuessDelegate




@interface SWGuessViewController : UIViewController <SWGuessDelegate>

@property (weak, nonatomic) id<SWEngineDelegate> delegate;
@property (strong, nonatomic) SWMeaning *meaning;

/** PageViewController в котором живут ViewControllers слов и вариантов */
@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (weak, nonatomic) IBOutlet UILabel *meaningLabel;

@end // SWGuessViewController
