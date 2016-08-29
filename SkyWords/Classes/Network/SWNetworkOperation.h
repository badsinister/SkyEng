
/**
 
    Сетевая операция. Базовый класс.
    ================================
 
    Получает данные от удаленного сервера в соответствии с request.
    Обработка данных или в parseHandler, если не определен в методе parseData:managedObjectContext:
*/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



typedef void(^parseHandler)(NSData *data, NSManagedObjectContext *managedObjectContext);



@interface SWNetworkOperation : NSOperation <NSURLSessionDataDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext sessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration request:(NSURLRequest *)request;

/** Конфигурация для построения сессии */
@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfiguration;

/** Сессия */
@property (strong, nonatomic) NSURLSessionTask *sessionDataTask;

/** Запрос */
@property (strong, nonatomic) NSURLRequest *request;

/** Полученные данные */
@property (strong, nonatomic) NSMutableData *data;

/** Контекст для сохранения данных */
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/** Переопределяемый метод разбора данных data. Данные сохраняются в context. */
- (void)parseData:(NSData *)data managedObjectContext:(NSManagedObjectContext *)context;

/** Блок обработки данных. Можно использовать вместо parseData:managedObjectContext: */
@property (copy, nonatomic) parseHandler parse;

@end // SWNetworkOperation
