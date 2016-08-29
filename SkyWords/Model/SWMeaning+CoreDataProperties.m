//
//  Meaning+CoreDataProperties.m
//  SkyWords
//
//  Created by Arcady Morozov on 26.08.16.
//  Copyright © 2016 Arcady Morozov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SWMeaning+CoreDataProperties.h"

@implementation SWMeaning (CoreDataProperties)

@dynamic meaningId;
@dynamic sortOrder;
@dynamic text;
@dynamic translation;
@dynamic imageURL;
@dynamic alternatives;

@end
