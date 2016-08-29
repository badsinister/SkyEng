
#import "SWNetworkStoreCoordinator.h"
#import "SWNetworkOperation.h"
#import "SWDownloadOperation.h"
#import "SWMeaning.h"
#import "SWAlternative.h"
#import <UIKit/UIKit.h>




static NSString const *baseURI = @"http://dictionary.skyeng.ru/api/v1";




@implementation SWNetworkStoreCoordinator

// ===================================================================================
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
    if (self = [super init]) {
        _managedObjectContext = managedObjectContext;
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
} // initWithManagedObjectContext

// ===================================================================================
- (NSURLSessionConfiguration *)sessionConfiguration
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    return sessionConfiguration;
} // sessionConfiguration

// ===================================================================================
- (void)fetchWords:(NSSet *)wordIds
{
    NSMutableString *ids = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < [wordIds count]; i++) {
        NSNumber *item = [wordIds allObjects][i];
        [ids appendString:[item stringValue]];
        if (i < [wordIds count] - 1) {
            [ids appendString:@","];
        }
    }

    NSMutableURLRequest *wordsRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/wordtasks?width=640&meaningIds=%@", baseURI, ids]]];
    [wordsRequest setHTTPMethod:@"GET"];
    
    SWNetworkOperation *wordsNetworkOperation = [[SWNetworkOperation alloc] initWithManagedObjectContext:self.managedObjectContext sessionConfiguration:self.sessionConfiguration request:wordsRequest];
    
    NSLog(@"fetchWords: %@", wordsRequest);
    
    wordsNetworkOperation.parse = ^(NSData *data, NSManagedObjectContext *managedObjectContext) {
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"Load words!");
        
        for (NSDictionary *item in params) {
            NSNumber *meaningId = item[@"meaningId"];
            NSString *text = item[@"text"];
            NSString *translation = item[@"translation"];
            NSString *imageURL = item[@"images"][0]; // возьмем первое что попалось..
            NSArray *alternatives = item[@"alternatives"];

            // Посмотрим, есть ли уже такое слово в базе
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Meaning"];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"meaningId == %d", [meaningId integerValue]]];
            
            NSArray *objects = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
            
            SWMeaning *meaning = nil;
            
            if ([objects count]) {
                // Есть такое слово!
                // Нам тонко намекают что слово могло измениться, и присылают updatedAt
                // Безопаснее и быстрее считать итерации обновления (каждое обновление счетчик +1)
                meaning = objects[0];
                // Удалим что нибудь
                for (NSManagedObject *alternative in meaning.alternatives) {
                    [managedObjectContext deleteObject:alternative];
                }
            } else {
                meaning = [NSEntityDescription insertNewObjectForEntityForName:@"Meaning" inManagedObjectContext:managedObjectContext];
            }
            
            meaning.meaningId = @([meaningId integerValue]);
            meaning.text = text;
            meaning.translation = translation;
            meaning.imageURL = imageURL;
            
            // займемся переводами
            for (NSDictionary *item in alternatives) {
                SWAlternative *alternative = [NSEntityDescription insertNewObjectForEntityForName:@"Alternative" inManagedObjectContext:managedObjectContext];
                alternative.text = item[@"text"];
                alternative.translation = item[@"translation"];
                [meaning addAlternativesObject:alternative];
            }
        }
    };
    
    [self.operationQueue addOperation:wordsNetworkOperation];
} // fetchWords

// ===================================================================================
- (void)downloadImageForURL:(NSURL *)imageURL cache:(NSCache *)imagesCache
{
    NSMutableURLRequest *imageRequest = [[NSMutableURLRequest alloc] initWithURL:imageURL];
    [imageRequest setHTTPMethod:@"GET"];

    SWDownloadOperation *downloadOperation = [[SWDownloadOperation alloc] initWithSessionConfiguration:self.sessionConfiguration request:imageRequest];

    downloadOperation.parse = ^(NSURL *dataURL) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:dataURL]];
        
        // Поуму, картики надо сохранять на диск - в свой NSCache складывать их адреса...
        // А контроллер данных пусть их держит в памяти, если ему нравится побыстрее...

        //NSString *imageName = [[NSProcessInfo processInfo] globallyUniqueString];
        
        // Create path.
        //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
        
        // Save image.
        //[UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];

        dispatch_async(dispatch_get_main_queue(), ^{
            [imagesCache setObject:image forKey:imageURL];
            [[NSNotificationCenter defaultCenter] postNotificationName:NSCImageDidDownloadNotification object:imageURL];
        });
    };

    // Вообще их надо в свою очередь.. но, пусть здесь поживут.
    [self.operationQueue addOperation:downloadOperation];
} // downloadImageForURL

@end // SWNetworkStoreCoordinator




// Notifications

NSString *const NSCImageDidDownloadNotification = @"NSCImageDidDownloadNotification";
