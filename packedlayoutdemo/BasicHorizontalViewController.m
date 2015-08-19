//
//  BasicVerticalViewController.m
//  packedlayoutdemo
//
//  Created by Guy Umbright on 8/17/15.
//  Copyright (c) 2015 Umbright Consulting, Inc. All rights reserved.
//

#import "BasicHorizontalViewController.h"
#import "UIXPackedLayout.h"

#define NUM_ITEMS 30
#define NUM_DATA_ITEMS 10
#define ROW_HEIGHT 100

@interface BasicHorizontalViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView* collection;
@property (nonatomic, strong) NSArray* theData;
@property (nonatomic, strong) NSArray* colors;

@end

@implementation BasicHorizontalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    srandom((unsigned int) time(NULL));
    
    
    self.colors = [NSArray arrayWithObjects:[UIColor purpleColor],[UIColor orangeColor],[UIColor magentaColor],[UIColor cyanColor],[UIColor blueColor],[UIColor greenColor], [UIColor redColor],[UIColor purpleColor],nil];
    
//    [self.collection registerNib:[UINib nibWithNibName:@"Cell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    NSMutableArray* arr = [NSMutableArray array];
    for (int ndx = 0; ndx < NUM_ITEMS; ++ndx)
    {
        [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:random() % 400],@"width",
                        self.colors[random() % self.colors.count],@"color",nil]];
    }
    self.theData = arr;
    
    UIXPackedLayout* layout = [[UIXPackedLayout alloc] initWithOrientation:UIXPackedLayoutOrientationHorizontal];
    self.collection.collectionViewLayout = layout;
    
    layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    layout.cellSpacing = 20;
    layout.sliceSpacing = 20;
    layout.minimumSliceWidth = ROW_HEIGHT;
    layout.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* data = self.theData[indexPath.item];
    //    NSNumber* n = data[@"height"];
    
    UICollectionViewCell* cell = [self.collection dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor=data[@"color"];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return NUM_ITEMS;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView*) collectinView
{
    return 1;
}

- (CGSize) UIXPackedLayout: (UIXPackedLayout*) layout sizeForItemAtIndex:(NSIndexPath*) indexPath
{
    CGSize result = CGSizeZero;
    
    NSNumber* n = self.theData[indexPath.item][@"width"];
    result = CGSizeMake([n floatValue],ROW_HEIGHT);
    
    return result;
}
@end
