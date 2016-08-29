
#import "SWDataContext.h"




static NSString *const SWModelNameKey = @"SkyWords";




@implementation SWDataContext

// ===================================================================================
- (NSSet *)wordIds
{
    if (_wordIds == nil) {
        _wordIds = [NSSet setWithObjects:@(211138),@(226138),@(177344),@(196957),@(224324),@(89785),@(79639),@(173148),@(136709),@(158582),@(92590),@(135793),@(68068),@(64441),@(46290),@(128173),@(51254),@(55112),@(222435), nil];
    }
    return _wordIds;
} // wordIds

// ===================================================================================
- (instancetype)initWithDelegate:(id<SWDataContextDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
} // initWithDelegate



#pragma mark - SWNetworkStoreCoordinator

// ===================================================================================
- (void)initializeNetworkStoreCoordinator
{
    _networkStoreCoordinator = [[SWNetworkStoreCoordinator alloc] initWithManagedObjectContext:self.backgroundContext];
} // initializeNetworkStoreCoordinator



#pragma mark - Directory -

@synthesize documentsDirectory = _documentsDirectory;
@synthesize cachesDirectory = _cachesDirectory;

// ===================================================================================
- (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
} // documentsDirectory

// ===================================================================================
- (NSURL *)cachesDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
} // cachesDirectory



#pragma mark - CoreData -

// ===================================================================================
- (void)initializeManagedObjectContext
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // DataModel

        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:SWModelNameKey withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

        // StoreCoordinator
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSURL *storeURL = [self.documentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", SWModelNameKey]];
        NSError *error;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            // Ошибка при иницифлизации хранилища
            // Обрабатываем Error
            abort();
        }
        
        // DataContext
        
        // создаем приватный контекст для затратных работ в фоне
        _privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_privateManagedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            // создаем главный контекст приложения
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_managedObjectContext setParentContext:_privateManagedObjectContext];

            // рассылаем уведомление о готовности - вдруг кому интересно
            [[NSNotificationCenter defaultCenter] postNotificationName:DCManagedObjectContextDidInitializeNotification object:_managedObjectContext];
            
            // уведомляем делегата что все готово
            
            if ([_delegate respondsToSelector:@selector(dataContext:didInitializeWithManagedObjectContext:)]) {
                [_delegate dataContext:self didInitializeWithManagedObjectContext:_managedObjectContext];
            }

        });
    });
} // initializeManagedObjectContext

// ===================================================================================
- (void)saveManagedObjectContext
{
    if (_managedObjectContext.hasChanges) {
        // сохраним изменения из главного контекста в приватный
        NSError *error;
        if ([_managedObjectContext save:&error]) {
            // Сохраним приватный контекст
            [_privateManagedObjectContext performBlock:^{
                NSError *error;
                [_privateManagedObjectContext save:&error];
                
                // Уведомление об окончании сохранения
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:DCManagedObjectContextDidSaveSuccessfullyNotification object:nil];
                });
            }];
        };
    }
} // saveManagedObjectContext



#pragma mark - BackgroundContext

// ===================================================================================
- (NSManagedObjectContext *)backgroundContext
{
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundContext setParentContext:_managedObjectContext];
    //[backgroundContext setParentContext:_privateManagedObjectContext];
    return backgroundContext;
} // backgroundContext

// ===================================================================================
- (void)saveChangesInBackgroundContext:(NSManagedObjectContext *)backgroundContext
{
    if (backgroundContext.hasChanges) {
        [backgroundContext performBlock:^{
            NSError *error;
            [backgroundContext save:&error];
            // Не забываем сохранить родительский контекст
            [self saveManagedObjectContext];
            //[_privateManagedObjectContext performBlock:^{
            //    NSError *error;
            //    [_privateManagedObjectContext save:&error];
            //}];
        }];
    }
} // saveChangesInBackgroundContext



#pragma mark - 

// ===================================================================================
- (BOOL)loadMeanings
{
    // Создадим NSFetchedResultsController и подпишемся на его события..
    // ядерной ракетой по воробьям - но, удобно, на самом деле

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Meaning"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES]; // нельзя без сортировки
    [fetchRequest setSortDescriptors:@[sortDescriptor]];

    self.fetchedMeaningsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedMeaningsController.delegate = self;
    [self.fetchedMeaningsController performFetch:nil];
    
    // Теперь не грех и новых данных с сервера попросить
    [self initializeNetworkStoreCoordinator];
    [self.networkStoreCoordinator fetchWords:self.wordIds];
    
    if ([self.fetchedMeaningsController.sections count] && [[self.fetchedMeaningsController.sections objectAtIndex:0] numberOfObjects]) {
        return YES;
    }
    
    return NO;
} // loadMeanings

// ===================================================================================
- (void)shakeMeanings
{
    self.fetchedMeaningsController.delegate = nil;
    
    // Возьмем слова... их может быть и много, - тогда неплохо бы брать только NSManagedObjectID
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[[self.fetchedMeaningsController.sections objectAtIndex:0] objects]];
    
    // Тщательно перемещаем...
    NSUInteger countOfItems = [items count];
    for (NSUInteger i = 0; i < countOfItems; ++i) {
        NSUInteger index = (arc4random() % countOfItems - i) + i;
        [items exchangeObjectAtIndex:i withObjectAtIndex:index];
    }
    
    // Запомним что получилось
    for (NSUInteger i = 0; i < countOfItems; ++i) {
        SWMeaning *meaning = items[i];
        meaning.sortOrder = @(i);
    }
    
    [self saveManagedObjectContext];
    
    self.fetchedMeaningsController.delegate = self;
    [self.fetchedMeaningsController performFetch:nil];
} // shakeMeanings

// ===================================================================================
- (SWMeaning *)meaningAtIndex:(NSUInteger)index
{
    return (SWMeaning *)[self.fetchedMeaningsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
} // meaningAtIndex

// ===================================================================================
- (UIImage *)fetchImageForMeaningAtIndex:(NSUInteger)index;
{
    SWMeaning *meaning = [self meaningAtIndex:index];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http:%@", meaning.imageURL]];
    if ([self.imagesCache objectForKey:url]) {
        return [self.imagesCache objectForKey:url];
    }

    [self.networkStoreCoordinator downloadImageForURL:url cache:self.imagesCache];
    return nil;
} // fetchImageForMeaning



#pragma mark - Images

// ===================================================================================
- (NSCache *)imagesCache
{
    static NSCache *imagesCache = nil;
    if (imagesCache == nil) {
        imagesCache = [[NSCache alloc] init];
    }
    return imagesCache;
} // imagesCache



#pragma mark - NSFetchedResultsControllerDelegate

// ===================================================================================
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Появились новые (или хорошо забытые старые) слова...

    [self shakeMeanings];

    // Усе готово!
    if ([self.delegate respondsToSelector:@selector(dataContextDidChangeContent:)]) {
        [self.delegate dataContextDidChangeContent:self];
    }
    
} // controllerDidChangeContent

@end // EDDataContext



// Notifications

NSString *const DCManagedObjectContextDidInitializeNotification = @"DCManagedObjectContextDidInitializeNotification";
NSString *const DCManagedObjectContextDidSaveSuccessfullyNotification = @"DCManagedObjectContextDidSaveSuccessfullyNotification";
