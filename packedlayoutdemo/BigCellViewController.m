//
//  BigCellViewController.m
//  packedlayoutdemo
//
//  Created by Guy Umbright on 8/19/15.
//  Copyright (c) 2015 Umbright Consulting, Inc. All rights reserved.
//

#import "BigCellViewController.h"
#import "UIXPackedLayout.h"

#define NUM_ITEMS 30
#define NUM_DATA_ITEMS 10
#define COLUMN_WIDTH 100

@interface BigCellViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView* collection;
@property (nonatomic, strong) NSMutableArray* theData;
@property (nonatomic, strong) NSArray* colors;
@end

@implementation BigCellViewController

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    srandom((unsigned int) time(NULL));
    
    
    self.colors = [NSArray arrayWithObjects:[UIColor purpleColor],[UIColor orangeColor],[UIColor magentaColor],[UIColor cyanColor],[UIColor blueColor],[UIColor greenColor], [UIColor redColor],[UIColor purpleColor],nil];
    
    //    [self.collection registerNib:[UINib nibWithNibName:@"Cell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    NSMutableArray* arr = [NSMutableArray array];
    for (int ndx = 0; ndx < NUM_ITEMS; ++ndx)
    {
        CGFloat h = random() % 400;
        CGFloat w = (random() % 200)+10;
        
        [arr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:h],@"height",
                        [NSNumber numberWithInteger:w],@"width",
                        self.colors[random() % self.colors.count],@"color",nil]];
    }
    self.theData = arr;
    
    
    UIXPackedLayout* layout = [[UIXPackedLayout alloc] initWithOrientation:UIXPackedLayoutOrientationVertical];
    self.collection.collectionViewLayout = layout;
    
    layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    layout.cellSpacing = 20;
    layout.sliceSpacing = 20;
    layout.minimumSliceWidth = COLUMN_WIDTH;
    layout.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
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
    
    NSNumber* h = self.theData[indexPath.item][@"height"];
    NSNumber* w = self.theData[indexPath.item][@"width"];
    result = CGSizeMake([w floatValue], [h floatValue]);
    
    return result;
}

- (IBAction)sizeChanged:(UISegmentedControl*) sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        [self normalCells];
    }
    else
    {
        [self bigCells];
    }
}

- (void) normalCells
{
    [self.collection performBatchUpdates:^{
        for (NSInteger ndx = 5; ndx < self.theData.count; ndx += 5)
        {
            NSMutableDictionary* dict = self.theData[ndx];
            dict[@"height"] = [NSNumber numberWithFloat:50.0];
            dict[@"width"] = [NSNumber numberWithFloat:50.0];
        }
    } completion:^(BOOL finished) {
    }];
}

- (void) bigCells
{
    [self.collection performBatchUpdates:^{
        for (NSInteger ndx = 5; ndx < self.theData.count; ndx += 5)
        {
            NSMutableDictionary* dict = self.theData[ndx];
            dict[@"height"] = [NSNumber numberWithFloat:700.0];
            dict[@"width"] = [NSNumber numberWithFloat:700.0];
        }
    } completion:^(BOOL finished) {
    }];
}
@end
