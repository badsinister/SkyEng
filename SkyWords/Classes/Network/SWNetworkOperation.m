
#import "SWNetworkOperation.h"




@implementation SWNetworkOperation
{
    BOOL _executing;
    BOOL _finished;
}

// ===================================================================================
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext sessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration request:(NSURLRequest *)request
{
    if (self = [super init]) {
        _managedObjectContext = managedObjectContext;
        _sessionConfiguration = sessionConfiguration;
        _request = request;
        _executing = NO;
        _finished = NO;
    }
    return self;
} // initWithManagedObjectContext



#pragma mark - KVO

// ===================================================================================
- (BOOL)isExecuting
{
    return _executing;
} // isExecuting

// ===================================================================================
- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
} // setExecuting

// ===================================================================================
- (BOOL)isFinished
{
    return _finished;
} // isFinished

// ===================================================================================
- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
} // setFinished

// ===================================================================================
- (BOOL)isConcurrent
{
    return YES;
} // isConcurrent



#pragma mark - Live Cilce

// ===================================================================================
- (void)start
{
    if ([self isCancelled]) {
        // операцию отменили, - попрощаемся
        self.finished = YES;
    }

    self.executing = YES;
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
} // start

// ===================================================================================
- (void)main
{
    //NSLog(@"EDNetworkOperation Start Load Data in %@ [%@]", [NSThread currentThread], [NSThread mainThread]);

    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:nil];
    self.sessionDataTask = [session dataTaskWithRequest:self.request];

    self.data = [[NSMutableData alloc] init];

    [self.sessionDataTask resume];
} // main



#pragma mark - NSURLSession Delegate

// ===================================================================================
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // посмотрим, не отменена ли операция
    if ([self isCancelled]) {
        // операцию отменили, - попрощаемся
        [self.sessionDataTask cancel];
        // посигналим о завершении
        self.executing = NO;
        self.finished = YES;
        return;
    }

    // продолжим операцию
    completionHandler(NSURLSessionResponseAllow);
} // didReceiveResponse

// ===================================================================================
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // посмотрим, не отменена ли операция
    if ([self isCancelled]) {
        // операцию отменили, - попрощаемся
        [self.sessionDataTask cancel];
        // посигналим о завершении
        self.executing = NO;
        self.finished = YES;
        return;
    }

    // добавим данные
    [self.data appendData:data];
} // didReceiveData

// ===================================================================================
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // посмотрим, не отменена ли операция
    if ([self isCancelled]) {
        // операцию отменили, - попрощаемся
        [self.sessionDataTask cancel];
        // посигналим о завершении
        self.executing = NO;
        self.finished = YES;
        return;
    }

    //NSLog(@"EDNetworkOperation didCompleteWith data %@ error %@", [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingMutableLeaves error:nil], error);
    
    if (error) {
        // ошибка во время выполнения
        // посигналим о завершении
        self.executing = NO;
        self.finished = YES;
        return;
    }

    // парсим данные
    if (self.parse != nil) {
        self.parse(self.data, self.managedObjectContext);
    } else {
        [self parseData:self.data managedObjectContext:self.managedObjectContext];
    }
    
    // завершаем работу
    // Сохраним данные в контекст
    if (self.managedObjectContext.hasChanges) {
        [self.managedObjectContext performBlock:^{
            NSError *error;
            [self.managedObjectContext save:&error];
        }];
    }

    // посигналим о завершении
    self.executing = NO;
    self.finished = YES;
} // didCompleteWithError



#pragma mark - Parse Data : Override this

// ===================================================================================
- (void)parseData:(NSData *)data managedObjectContext:(NSManagedObjectContext *)context
{
    NSLog(@"parseData: %@ in context: %@", [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil], context);
} // parseData:managedObjectContext

@end // SWNetworkOperation
