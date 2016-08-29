
#import "SWDownloadOperation.h"




@implementation SWDownloadOperation
{
    BOOL _executing;
    BOOL _finished;
}

// ===================================================================================
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration request:(NSURLRequest *)request
{
    if (self = [super init]) {
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
    //NSLog(@"SWDownloadOperation Start Load Data %@ in %@ [%@]", self.request, [NSThread currentThread], [NSThread mainThread]);
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:nil];
    self.sessionDownloadTask = [session downloadTaskWithRequest:self.request];
    
    self.data = [[NSMutableData alloc] init];
    
    [self.sessionDownloadTask resume];
} // main



#pragma mark - NSURLSession Delegate

// ===================================================================================
- (void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location
{
    // посмотрим, не отменена ли операция
    if ([self isCancelled]) {
        // операцию отменили, - попрощаемся
        [downloadTask cancel];
        // посигналим о завершении
        self.executing = NO;
        self.finished = YES;
        return;
    }
    
    //NSLog(@"SWDownloadOperation didCompleteWithURL %@", location);
    
    if (!location) {
        // ошибка во время выполнения
        // посигналим о завершении
        self.executing = NO;
        self.finished = YES;
        return;
    }
    
    // парсим данные
    if (self.parse != nil) {
        self.parse(location);
    } else {
        [self parseDataForURL:location];
    }

    // посигналим о завершении
    self.executing = NO;
    self.finished = YES;
} // didCompleteWithError



#pragma mark - Parse Data : Override this

// ===================================================================================
- (void)parseDataForURL:(NSURL *)dataURL
{
    NSLog(@"parseDownloadData: %@", dataURL);
} // parseDataForURL

@end // SWDownloadOperation
