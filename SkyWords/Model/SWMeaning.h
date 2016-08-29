//
//  Meaning.h
//  SkyWords
//
//  Created by Arcady Morozov on 26.08.16.
//  Copyright © 2016 Arcady Morozov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SWAlternative;

NS_ASSUME_NONNULL_BEGIN

@interface SWMeaning : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

- (NSArray *)diversity;

@end

NS_ASSUME_NONNULL_END

#import "SWMeaning+CoreDataProperties.h"
