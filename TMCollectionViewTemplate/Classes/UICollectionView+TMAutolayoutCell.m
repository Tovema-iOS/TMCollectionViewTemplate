//
//  UICollectionView+TMAutolayoutCell.m
//  OCSimpleDemo
//
//  Created by Xiaobin Lin on 2019/1/8.
//  Copyright © 2019年 Felink. All rights reserved.
//

#import "UICollectionView+TMAutolayoutCell.h"
#import <objc/runtime.h>

@implementation UICollectionView (TMAutolayoutCell)

- (CGSize)tm_heightForCellWithIdentifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath maxSize:(CGSize)maxSize configuration:(void (^)(id cell))configuration
{
    if (!identifier) {
        return CGSizeZero;
    }

    if ([self.tm_indexPathSizeCache existsSizeAtIndexPath:indexPath]) {
        return [self.tm_indexPathSizeCache heightForIndexPath:indexPath];
    }

    UICollectionViewCell *templateLayoutCell = [self tm_templateCellForReuseIdentifier:identifier];
    if (configuration) {
        configuration(templateLayoutCell);
    }

    CGSize size = [self tm_systemFittingHeightForConfiguratedCell:templateLayoutCell indexPath:indexPath maxSize:maxSize];
    [self.tm_indexPathSizeCache cacheSize:size byIndexPath:indexPath];
    return size;
}

- (__kindof UICollectionViewCell *)tm_templateCellForReuseIdentifier:(NSString *)identifier
{
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);

    NSMutableDictionary<NSString *, UICollectionViewCell *> *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    UICollectionViewCell *templateCell = templateCellsByIdentifiers[identifier];
    if (!templateCell) {
        templateCell = [self tm_generateTempleteCell:identifier];
        NSAssert(templateCell != nil, @"Cell must be registered to collection view for identifier - %@", identifier);
        templateCellsByIdentifiers[identifier] = templateCell;
    }

    return templateCell;
}

- (UICollectionViewCell *)tm_generateTempleteCell:(NSString *)identifier
{
    Class cls = NSClassFromString(identifier);
    if (cls == nil) {
        return nil;
    }
    if ([cls instancesRespondToSelector:@selector(initWithFrame:)]) {
        UICollectionViewCell *cell = [[cls alloc] initWithFrame:CGRectZero];
        if ([cell isKindOfClass:[UICollectionViewCell class]]) {
            return cell;
        }
    }

    return nil;
}

- (CGSize)tm_systemFittingHeightForConfiguratedCell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath maxSize:(CGSize)maxSize
{
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:maxSize];
    return size;
}


@end
