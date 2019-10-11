//
//  TestCollectionViewController.m
//  OCSimpleDemo
//
//  Created by Xiaobin Lin on 2019/1/7.
//  Copyright © 2019年 Felink. All rights reserved.
//

#import "TestCollectionViewController.h"
#import "CollectionViewIconCell.h"
#import "CollectionViewRowCell.h"
#import <Masonry/Masonry.h>
#import <TMCollectionViewTemplate/TMCollectionViewTemplate.h>


@interface TestCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end


@implementation TestCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 20);
    // 必须设置 estimatedItemSize
    layout.estimatedItemSize = CGSizeMake(50, 50);

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    // Register cell classes
    [self.collectionView registerClass:[CollectionViewIconCell class] forCellWithReuseIdentifier:CollectionViewIconCell.reuseIdentifier];
    [self.collectionView registerClass:[CollectionViewRowCell class] forCellWithReuseIdentifier:CollectionViewRowCell.reuseIdentifier];

}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewRowCell.reuseIdentifier forIndexPath:indexPath];

        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewIconCell.reuseIdentifier forIndexPath:indexPath];

        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [collectionView tm_heightForCellWithIdentifier:CollectionViewRowCell.reuseIdentifier
            indexPath:indexPath
              maxSize:CollectionViewRowCell.maxCellSize
        configuration:^(CollectionViewIconCell *cell){

        }];
    } else {
        return [collectionView tm_heightForCellWithIdentifier:CollectionViewIconCell.reuseIdentifier
            indexPath:indexPath
              maxSize:CollectionViewIconCell.maxCellSize
        configuration:^(CollectionViewIconCell *cell){

        }];
    }
}

@end
