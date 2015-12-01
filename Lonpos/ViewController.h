//
//  ViewController.h
//  Lonpos
//
//  Created by Karl on 2015-12-01.
//  Copyright © 2015 KEP Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    
    long shapes[12][8];
    int shapeW[12][8];
    int shapeH[12][8];
    int numPermutations[12];
    
    IBOutlet UIView *blobView;
    UIImage *hole,*white;
    NSMutableArray *blobs;
    int selectedButton;
    
    int colors[5][11];
    
    IBOutlet UIImageView *outline;
    
    IBOutlet UIView *waitScreen;
    
    long sideMasks[11];
    long fullMask;
}

-(void)calculateShapes;
-(long)computeShapeValue:(BOOL[4][4])holder;
-(void)setBlobs;
-(void)clearBoard;

-(IBAction)ballButtonPressed:(id)sender;
-(IBAction)holePressed:(id)sender;

-(IBAction)clearPressed:(id)sender;
-(IBAction)solvePressed:(id)sender;

-(BOOL)fillHole:(long)hl withPieces:(int)pc;

@end

