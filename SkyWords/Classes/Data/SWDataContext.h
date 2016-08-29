
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SWNetworkStoreCoordinator.h"
#import "SWMeaning.h"
#import "SWAlternative.h"



@class SWDataContext;




@protocol SWDataContextDelegate <NSObject>

/** Инициализация контекста данных, context - main контекст для работы с данными */
- (void)dataContext:(SWDataContext *)dataContext didInitializeWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/** Загрузили данные и приготовились к работе... */
- (void)dataContextDidChangeContent:(SWDataContext *)dataContext;

@end // SWDataContextDelegate




@interface SWDataContext : NSObject <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) id<SWDataContextDelegate> delegate;

/** Основной конструктор */
- (instancetype)initWithDelegate:(id<SWDataContextDelegate>)delegate;

/** Здесь у нас лежат ID слов для загадок... */
@property (strong, nonatomic) NSSet *wordIds;

@property (strong, nonatomic, readonly) NSURL *documentsDirectory;
@property (strong, nonatomic, readonly) NSURL *cachesDirectory;

/** CoreData */

/** 
    Инициализация стека CoreData и создание основного контекста данных managedObjectContext.
    При успешном создании посылается уведомление DCManagedObjectContextDidInitializeNotification
    и вызывается dataContext:didInitializeWithManagedObjectContext:..
*/
- (void)initializeManagedObjectContext;

/** Сохранение контекста данных */
- (void)saveManagedObjectContext;

/** Главный контекст */
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/** Внутренний контекст для сохранения данных */
@property (strong, nonatomic, readonly) NSManagedObjectContext *privateManagedObjectContext;

/** Модель данных */
@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/** Background контекст */
- (NSManagedObjectContext *)backgroundContext;
- (void)saveChangesInBackgroundContext:(NSManagedObjectContext *)backgroundContext;

/** Network */

@property (strong, nonatomic) SWNetworkStoreCoordinator *networkStoreCoordinator;

- (void)initializeNetworkStoreCoordinator;


/** FetchedResultsController */

/** 
    Самый интересный метод, ради которого все и затевалось.
    Смотрим что в базе, запрашиваем данные с сервера... 
*/
@property (strong, nonatomic) NSFetchedResultsController *fetchedMeaningsController;
- (BOOL)loadMeanings;
- (void)shakeMeanings;
- (SWMeaning *)meaningAtIndex:(NSUInteger)index;
- (UIImage *)fetchImageForMeaningAtIndex:(NSUInteger)index;

/** Кэш для изображений */
- (NSCache *)imagesCache;

@end // SWDataContext





#pragma mark - Notifications

/** Инициализация стека CoreData и создание контекста данных */
extern NSString *const DCManagedObjectContextDidInitializeNotification;

/** Сохранение контекста данных */
extern NSString *const DCManagedObjectContextDidSaveSuccessfullyNotification;
