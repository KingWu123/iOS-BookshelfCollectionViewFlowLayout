//
//  BookShelfGroupMainView.m
//  ShelfCollectionView
//
//  Created by king.wu on 8/18/16.
//  Copyright © 2016 king.wu. All rights reserved.
//

#import "BookShelfGroupMainView.h"
#import "BookCollectionViewCell.h"
#import "BookShelfGroupViewFlowLayout.h"

@interface BookShelfGroupMainView ()<BookShelfGroupViewDataSource, BookShelfGroupViewDelegateFlowLayout>


@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *groupTitleTextFiled;

@property (weak, nonatomic) IBOutlet UIView *tabExitView;

@property (nonatomic, strong)BookShelfGroupViewFlowLayout *groupFlowLayout;
@property (nonatomic, strong)NSMutableArray<ItemData *> * allGroupItems;


@end


@implementation BookShelfGroupMainView

+ (instancetype)loadFromNib{
    return [[[NSBundle mainBundle]loadNibNamed:@"BookShelfGroupMainView" owner:nil options:nil] objectAtIndex:0];
}

- (void)awakeFromNib{
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookCollectionViewCell"];


    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleExitTapGesture:)];
    [self.tabExitView addGestureRecognizer:tapGestureRecognizer];
    
    self.groupFlowLayout = [[BookShelfGroupViewFlowLayout alloc]init];
    [self.collectionView setCollectionViewLayout:self.groupFlowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    self.allGroupItems = [[NSMutableArray alloc]init];
}

//书架界面分组时的初始化方法
- (void)initWithItemData:(ItemData *)itemData groupedItemData:(NSArray<ItemData *> *)groupedItemData snapView:(UIView *)snapView{

    [self.allGroupItems removeAllObjects];
    [self.allGroupItems addObjectsFromArray:groupedItemData];
    [self.allGroupItems addObject:itemData];
    
   
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.allGroupItems.count - 1 inSection:0];
    
    [self.groupFlowLayout initSelectSnapShotViewIfNeeded:snapView selectedIndexPath:lastIndexPath];
}

//直接打开分组界面的初始化方法
- (void)initWithItemsData:(NSArray<ItemData *> *)groupedItemData{
    [self.allGroupItems removeAllObjects];
    [self.allGroupItems addObjectsFromArray:groupedItemData];
}

- (void)dealloc{
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;

    self.delegate = nil;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.allGroupItems count];;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookCollectionViewCell" forIndexPath:indexPath];
    
    [cell initCellWithItemData:[self.allGroupItems objectAtIndex:indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath{
    
    id sourceObject = [self.allGroupItems objectAtIndex:sourceIndexPath.row];
    [self.allGroupItems removeObjectAtIndex:sourceIndexPath.row];
    [self.allGroupItems insertObject:sourceObject atIndex:destinationIndexPath.row];
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self.allGroupItems objectAtIndex:indexPath.row].itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}


#pragma mark - BookShelfGroupViewDelegateFlowLayout
//begin movement
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout beginMovementForItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

//end movement
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout endMovementForItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

//当拖动的item不再collectionView范围内时，取消分组
- (void)cancelGroupSelectedItemAtIndexPath:(NSIndexPath *)itemIndexPath withSnapShotView:(UIView *)snapShotView{
    
    ItemData *itemData = [self.allGroupItems objectAtIndex:itemIndexPath.row];
    [self cancelGroupWithItemData:itemData withSnapShotView:snapShotView];
}


#pragma mark - gesture
- (void)handleExitTapGesture:(UITapGestureRecognizer *)recognizer{
    
    [self finishedGroup];
}


//进行分组时，分组界面需要利用书架界面传过来的手势进行处理。
#pragma mark - BookShelfCollectionViewGestureDelegate

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer inGestureView:(UIView*)view{
   
    [self.groupFlowLayout handleLongPressGesture:gestureRecognizer];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer inGestureView:(UIView *)view{
    
    [self.groupFlowLayout handlePanGesture:gestureRecognizer];
}


#pragma mark - exit group view
- (void)finishedGroup{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(finishGroupInGroupViewWithGroupData:)]){
        [self.delegate finishGroupInGroupViewWithGroupData:self.allGroupItems];
    }
}

- (void)cancelGroupWithItemData:(ItemData *)itemData withSnapShotView:(UIView *)snapShotView{
    
    NSMutableArray *groupItems = [NSMutableArray arrayWithArray:self.allGroupItems];
    [groupItems removeObject:itemData];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(cancelGroupInGroupViewWithItemData:withGroupData:withSnapShotView:)]){
        [self.delegate cancelGroupInGroupViewWithItemData:itemData withGroupData:groupItems withSnapShotView:snapShotView];
    }
}

@end
