//
//  VerticalWithHeadersViewController.m
//  packedlayoutdemo
//
//  Created by Guy Umbright on 8/20/15.
//  Copyright (c) 2015 Umbright Consulting, Inc. All rights reserved.
//

#import "VerticalWithHeadersViewController.h"
#import "UIXPackedLayout.h"
#import "VerticalHeaderView.h"

#define NUM_SECTIONS 3
#define NUM_ITEMS 30
#define NUM_DATA_ITEMS 10
#define COLUMN_WIDTH 100

@interface VerticalWithHeadersViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView* collection;
@property (nonatomic, strong) NSArray* theData;
@property (nonatomic, strong) NSArray* colors;

@end

@implementation VerticalWithHeadersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    srandom((unsigned int) time(NULL));
    
    self.colors = [NSArray arrayWithObjects:[UIColor purpleColor],[UIColor orangeColor],[UIColor magentaColor],[UIColor cyanColor],[UIColor blueColor],[UIColor greenColor], [UIColor redColor],[UIColor purpleColor],nil];
    
    //    [self.collection registerNib:[UINib nibWithNibName:@"Cell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    NSMutableArray* data = [NSMutableArray arrayWithCapacity:NUM_SECTIONS];
    for (int sectNdx = 0; sectNdx < NUM_SECTIONS; ++sectNdx)
    {
        NSMutableArray* arr = [NSMutableArray array];
        for (int ndx = 0; ndx < NUM_ITEMS; ++ndx)
        {
            [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:random() % 400],@"height",
                        self.colors[random() % self.colors.count],@"color",nil]];
        }
        [data addObject:arr];
    }
    self.theData = data;
    
    UIXPackedLayout* layout = [[UIXPackedLayout alloc] initWithOrientation:UIXPackedLayoutOrientationVertical];
    self.collection.collectionViewLayout = layout;
    
    layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    layout.cellSpacing = 20;
    layout.sliceSpacing = 20;
    layout.minimumSliceWidth = COLUMN_WIDTH;
    layout.delegate = self;
    
    [self.collection registerClass:[VerticalHeaderView class] forSupplementaryViewOfKind:UIXPackedLayoutHeader withReuseIdentifier:@"header"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* arr = self.theData[indexPath.section];
    NSDictionary* data = arr[indexPath.item];
    //    NSNumber* n = data[@"height"];
    
    UICollectionViewCell* cell = [self.collection dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor=data[@"color"];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView* view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    return view;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray* arr = self.theData[section];
    return arr.count;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView*) collectinView
{
    return self.theData.count;
}

- (CGSize) UIXPackedLayout: (UIXPackedLayout*) layout sizeForItemAtIndex:(NSIndexPath*) indexPath
{
    CGSize result = CGSizeZero;
    
    NSArray* arr = self.theData[indexPath.section];
    
    NSNumber* n = arr[indexPath.item][@"height"];
    result = CGSizeMake(COLUMN_WIDTH, [n floatValue]);
    
    return result;
}

- (CGSize) UIXPackedLayout:(UIXPackedLayout*) layout sizeOfHeaderForSection:(NSInteger)section
{
    return CGSizeMake(50, 400);
}
@end
