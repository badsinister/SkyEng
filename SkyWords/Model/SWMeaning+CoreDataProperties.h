//
//  Meaning+CoreDataProperties.h
//  SkyWords
//
//  Created by Arcady Morozov on 26.08.16.
//  Copyright © 2016 Arcady Morozov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SWMeaning.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWMeaning (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *meaningId;
@property (nullable, nonatomic, retain) NSNumber *sortOrder;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *translation;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSSet<SWAlternative *> *alternatives;

@end

@interface SWMeaning (CoreDataGeneratedAccessors)

- (void)addAlternativesObject:(SWAlternative *)value;
- (void)removeAlternativesObject:(SWAlternative *)value;
- (void)addAlternatives:(NSSet<SWAlternative *> *)values;
- (void)removeAlternatives:(NSSet<SWAlternative *> *)values;

@end

NS_ASSUME_NONNULL_END
