//
//  Meaning.m
//  SkyWords
//
//  Created by Arcady Morozov on 26.08.16.
//  Copyright © 2016 Arcady Morozov. All rights reserved.
//

#import "SWMeaning.h"
#import "SWAlternative.h"

@implementation SWMeaning

- (NSArray *)diversity
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (SWAlternative *alternative in self.alternatives) {
        if ([alternative.translation length]) {
            [items addObject:alternative.translation];
        }
    }
    // Тщательно перемещаем...
    NSUInteger countOfItems = [items count];
    for (NSUInteger i = 0; i < countOfItems; ++i) {
        NSUInteger index = (arc4random() % countOfItems - i) + i;
        [items exchangeObjectAtIndex:i withObjectAtIndex:index];
    }
    return [NSArray arrayWithArray:items];
} // diversity

@end // SWMeaning
