//
//  UICollectionView+TMIndexPathCache.m
//  WeGamers
//
//  Created by Xiaobin Lin on 2019/1/8.
//  Copyright © 2019年 TM. All rights reserved.
//

#import "UICollectionView+TMIndexPathCache.h"
#import <objc/runtime.h>

typedef NSMutableArray<NSMutableArray<NSValue *> *> FDIndexPathHeightsBySection;

static NSValue *s_tm_empty_size = nil;

@interface TMIndexPathSizeCache()
@property (nonatomic, strong) FDIndexPathHeightsBySection *heightsBySectionForPortrait;
@property (nonatomic, strong) FDIndexPathHeightsBySection *heightsBySectionForLandscape;
@end

@implementation TMIndexPathSizeCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _heightsBySectionForPortrait = [NSMutableArray array];
        _heightsBySectionForLandscape = [NSMutableArray array];

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            s_tm_empty_size = [NSValue valueWithCGSize:CGSizeMake(-1, -1)];
        });
    }
    return self;
}

- (FDIndexPathHeightsBySection *)heightsBySectionForCurrentOrientation
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.heightsBySectionForPortrait : self.heightsBySectionForLandscape;
}

- (void)enumerateAllOrientationsUsingBlock:(void (^)(FDIndexPathHeightsBySection *heightsBySection))block
{
    block(self.heightsBySectionForPortrait);
    block(self.heightsBySectionForLandscape);
}

- (BOOL)existsSizeAtIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSValue *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];

    return number != s_tm_empty_size;
}

- (void)cacheSize:(CGSize)height byIndexPath:(NSIndexPath *)indexPath
{
    self.automaticallyInvalidateEnabled = YES;
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row] = [NSValue valueWithCGSize:height];
}

- (CGSize)heightForIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSValue *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
    return number.CGSizeValue;
}

- (void)invalidateSizeAtIndexPath:(NSIndexPath *)indexPath
{
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
        heightsBySection[indexPath.section][indexPath.row] = @-1;
    }];
}

- (void)invalidateAllHeightCache
{
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)indexPaths
{
    // Build every section array or row array which is smaller than given index path.
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:indexPath.section];
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection
{
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count) {
                heightsBySection[section] = [NSMutableArray array];
            }
        }
    }];
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section
{
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
        NSMutableArray<NSValue *> *heightsByRow = heightsBySection[section];
        for (NSInteger row = 0; row <= targetRow; ++row) {
            if (row >= heightsByRow.count) {
                heightsByRow[row] = s_tm_empty_size;
            }
        }
    }];
}

@end

@implementation UICollectionView (TMIndexPathSizeCache)

- (TMIndexPathSizeCache *)tm_indexPathSizeCache
{
    TMIndexPathSizeCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [TMIndexPathSizeCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

// We just forward primary call, in crash report, top most method in stack maybe FD's,
// but it's really not our bug, you should check whether your table view's data source and
// displaying cells are not matched when reloading.
static void __FD_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(void (^callout)(void))
{
    callout();
}

#define FDPrimaryCall(...)                                                             \
    do {                                                                               \
        __FD_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(^{__VA_ARGS__}); \
    } while (0)

@implementation UICollectionView (TMIndexPathSizeCacheInvalidation)

- (void)tm_reloadDataWithoutInvalidateIndexPathHeightCache
{
    FDPrimaryCall([self tm_reloadData];);
}

+ (void)load
{
    // All methods that trigger height cache's invalidation
    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:),
        @selector(deleteSections:),
        @selector(reloadSections:),
        @selector(moveSection:toSection:),
        @selector(insertItemsAtIndexPaths:),
        @selector(deleteItemsAtIndexPaths:),
        @selector(reloadItemsAtIndexPaths:),
        @selector(moveItemAtIndexPath:toIndexPath:)};

    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"tm_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)tm_reloadData
{
    if (self.tm_indexPathSizeCache.automaticallyInvalidateEnabled) {
        [self.tm_indexPathSizeCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
            [heightsBySection removeAllObjects];
        }];
    }
    FDPrimaryCall([self tm_reloadData];);
}

- (void)tm_insertSections:(NSIndexSet *)sections
{
    if (self.tm_indexPathSizeCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.tm_indexPathSizeCache buildSectionsIfNeeded:section];
            [self.tm_indexPathSizeCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection insertObject:[NSMutableArray array] atIndex:section];
            }];
        }];
    }
    FDPrimaryCall([self tm_insertSections:sections];);
}

- (void)tm_deleteSections:(NSIndexSet *)sections
{
    if (self.tm_indexPathSizeCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.tm_indexPathSizeCache buildSectionsIfNeeded:section];
            [self.tm_indexPathSizeCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection removeObjectAtIndex:section];
            }];
        }];
    }
    FDPrimaryCall([self tm_deleteSections:sections];);
}

- (void)tm_reloadSections:(NSIndexSet *)sections
{
    if (self.tm_indexPathSizeCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.tm_indexPathSizeCache buildSectionsIfNeeded:section];
            [self.tm_indexPathSizeCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[section] removeAllObjects];
            }];
        }];
    }
    FDPrimaryCall([self tm_reloadSections:sections];);
}

- (void)tm_moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    if (self.tm_indexPathSizeCache.automaticallyInvalidateEnabled) {
        [self.tm_indexPathSizeCache buildSectionsIfNeeded:section];
        [self.tm_indexPathSizeCache buildSectionsIfNeeded:newSection];
        [self.tm_indexPathSizeCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
            [heightsBySection exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    FDPrimaryCall([self tm_moveSection:section toSection:newSection];);
}

- (void)tm_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (self.tm_indexPathSizeCache.automaticallyInvalidateEnabled) {
        [self.tm_indexPathSizeCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.tm_indexPathSizeCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[indexPath.section] insertObject:@-1 atIndex:indexPath.row];
            }];
        }];
    }
    FDPrimaryCall([self tm_insertItemsAtIndexPaths:indexPaths];);
}

- (void)tm_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (self.tm_indexPathSizeCache.automaticallyInvalidateEnabled) {
        [self.tm_indexPathSizeCache buildCachesAtIndexPathsIfNeeded:indexPaths];

        NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
            if (!mutableIndexSet) {
                mutableIndexSet = [NSMutableIndexSet indexSet];
                mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
            }
            [mutableIndexSet addIndex:indexPath.row];
        }];

        [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSIndexSet *indexSet, BOOL *stop) {
            [self.tm_indexPathSizeCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[key.integerValue] removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    FDPrimaryCall([self tm_deleteItemsAtIndexPaths:indexPaths];);
}

- (void)tm_reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (self.tm_indexPathSizeCache.automaticallyInvalidateEnabled) {
        [self.tm_indexPathSizeCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.tm_indexPathSizeCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                heightsBySection[indexPath.section][indexPath.row] = @-1;
            }];
        }];
    }
    FDPrimaryCall([self tm_reloadItemsAtIndexPaths:indexPaths];);
}

- (void)tm_moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (self.tm_indexPathSizeCache.automaticallyInvalidateEnabled) {
        [self.tm_indexPathSizeCache buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
        [self.tm_indexPathSizeCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
            NSMutableArray<NSValue *> *sourceRows = heightsBySection[sourceIndexPath.section];
            NSMutableArray<NSValue *> *destinationRows = heightsBySection[destinationIndexPath.section];
            NSValue *sourceValue = sourceRows[sourceIndexPath.row];
            NSValue *destinationValue = destinationRows[destinationIndexPath.row];
            sourceRows[sourceIndexPath.row] = destinationValue;
            destinationRows[destinationIndexPath.row] = sourceValue;
        }];
    }
    FDPrimaryCall([self tm_moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];);
}

@end
