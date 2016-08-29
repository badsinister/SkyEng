
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>




@interface SWNetworkStoreCoordinator : NSObject

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

/** Конфигурация сессии для запросов */
- (NSURLSessionConfiguration *)sessionConfiguration;

/** Загружаем список слов с сервера */
- (void)fetchWords:(NSSet *)wordIds;

/** */
- (void)downloadImageForURL:(NSURL *)imageURL cache:(NSCache *)imagesCache;

@end // SWNetworkStoreCoordinator




#pragma mark - Notifications

/** Инициализация стека CoreData и создание контекста данных */
extern NSString *const NSCImageDidDownloadNotification;
