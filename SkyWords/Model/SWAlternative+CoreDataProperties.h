//
//  Alternative+CoreDataProperties.h
//  SkyWords
//
//  Created by Arcady Morozov on 26.08.16.
//  Copyright © 2016 Arcady Morozov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SWAlternative.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWAlternative (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *translation;
@property (nullable, nonatomic, retain) SWMeaning *meaning;

@end

NS_ASSUME_NONNULL_END
