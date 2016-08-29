
/**
 
    Загрузка чего то большого и красивого.
    ======================================

    Жалко времени нехватает выписать красивый загрузчик...
 
*/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



typedef void(^parseDownloadHandler)(NSURL *dataURL);



@interface SWDownloadOperation : NSOperation <NSURLSessionDataDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration request:(NSURLRequest *)request;

/** Конфигурация для построения сессии */
@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfiguration;

/** Сессия */
@property (strong, nonatomic) NSURLSessionTask *sessionDownloadTask;

/** Запрос */
@property (strong, nonatomic) NSURLRequest *request;

/** Полученные данные */
@property (strong, nonatomic) NSMutableData *data;

/** Переопределяемый метод разбора данных dataURL. */
- (void)parseDataForURL:(NSURL *)dataURL;

/** Блок обработки данных. Можно использовать вместо parseDataForURL: */
@property (copy, nonatomic) parseDownloadHandler parse;

@end // SWDownloadOperation
