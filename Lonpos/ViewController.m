//
//  ViewController.m
//  Lonpos
//
//  Created by Karl on 2015-12-01.
//  Copyright © 2015 KEP Games. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self calculateShapes];
    [self setBlobs];
    [self clearBoard];
}

-(void)calculateShapes
{
    NSArray *structures = @[
                            @[@"..#",
                              @"###"],
                            @[@".##",
                              @"###"],
                            @[@"...#",
                              @"####"],
                            @[@"..#.",
                              @"####"],
                            @[@"##..",
                              @".###"],
                            @[@".#",
                              @"##"],
                            @[@"..#",
                              @"..#",
                              @"###"],
                            @[@"..#",
                              @".##",
                              @"##."],
                            @[@"#.#",
                              @"###"],
                            @[@"####"],
                            @[@"##",
                              @"##"],
                            @[@".#.",
                              @"###",
                              @".#."]
                            ];
    BOOL holder[4][4];
    BOOL mirror[4][4];
    for (int i=0;i<12;i++)
    {
        NSArray *shA = [structures objectAtIndex:i];
        for (int j=0;j<4;j++)
            for (int k=0;k<4;k++)
            {
                holder[j][k] = FALSE;
                mirror[j][k] = FALSE;
            }
        int h = (int)[shA count];
        int w = (int)[(NSString*)[shA objectAtIndex:0] length];
        for (int j=0;j<4;j++)
        {
            shapeH[i][j] = h;
            shapeW[i][j] = w;
            shapeH[i][j+4] = w;
            shapeW[i][j+4] = h;
        }
        for (int j=0;j<h;j++)
        {
            NSString *tmpS = [shA objectAtIndex:j];
            for (int k=0;k<w;k++)
            {
                holder[j][k] = ([tmpS characterAtIndex:k] == '#');
            }
        }
        for (int j=0;j<4;j++)
            for (int k=0;k<4;k++)
                mirror[k][j] = holder[j][k];
        shapes[i][0] = [self computeShapeValue:holder];
        shapes[i][4] = [self computeShapeValue:mirror];
        
        // Flip vertical
        for (int j=0;j<h/2;j++)
        {
            for (int k=0;k<w;k++)
            {
                BOOL l = holder[j][k];
                holder[j][k] = holder[h-1-j][k];
                holder[h-1-j][k] = l;
            }
        }
        for (int j=0;j<4;j++)
            for (int k=0;k<4;k++)
                mirror[k][j] = holder[j][k];
        shapes[i][1] = [self computeShapeValue:holder];
        shapes[i][5] = [self computeShapeValue:mirror];
        
        // Flip Horizontal
        for (int j=0;j<h;j++)
        {
            for (int k=0;k<w/2;k++)
            {
                BOOL l = holder[j][k];
                holder[j][k] = holder[j][w-1-k];
                holder[j][w-1-k] = l;
            }
        }
        for (int j=0;j<4;j++)
            for (int k=0;k<4;k++)
                mirror[k][j] = holder[j][k];
        shapes[i][2] = [self computeShapeValue:holder];
        shapes[i][6] = [self computeShapeValue:mirror];
        
        // Flip vertical again
        for (int j=0;j<h/2;j++)
        {
            for (int k=0;k<w;k++)
            {
                BOOL l = holder[j][k];
                holder[j][k] = holder[h-1-j][k];
                holder[h-1-j][k] = l;
            }
        }
        for (int j=0;j<4;j++)
            for (int k=0;k<4;k++)
                mirror[k][j] = holder[j][k];
        shapes[i][3] = [self computeShapeValue:holder];
        shapes[i][7] = [self computeShapeValue:mirror];
        
        int unique = 1;
        for (int j=1;j<8;j++)
        {
            BOOL duplicate = FALSE;
            for (int k=0;k<unique;k++)
                duplicate |= (shapes[i][k] == shapes[i][j]);
            if (!duplicate)
            {
                shapes[i][unique] = shapes[i][j];
                shapeW[i][unique] = shapeW[i][j];
                shapeH[i][unique] = shapeH[i][j];
                unique++;
            }
        }
        numPermutations[i] = unique;
//        NSLog(@"Shape %d has %d permutations",i,unique);
    }
}

-(long)computeShapeValue:(BOOL[4][4])holder
{
    long res = 0;
    for (int i=0;i<4;i++)
    {
        for (int j=0;j<4;j++)
        {
            if (holder[i][j])
                res += (1<<(j*5+i));
        }
    }
    return res;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setBlobs
{
    hole = [UIImage imageNamed:@"hole.png"];
    white = [UIImage imageNamed:@"white.png"];
    blobs = [NSMutableArray arrayWithCapacity:55];
    for (int j=0;j<11;j++)
        for (int i=0;i<5;i++)
        {
            UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
            [but addTarget:self action:@selector(holePressed:) forControlEvents:UIControlEventTouchDown];
            but.frame = CGRectMake(464.0-40.0*j, 180.0-40.0*i, 40.0, 40.0);
            but.tag = j*5+i;
            [blobView addSubview:but];
            [blobs addObject:but];
        }
}

-(void)clearBoard
{
    for (int i=0;i<5;i++)
        for (int j=0;j<11;j++)
            colors[i][j] = -1;
    for (UIButton *but in blobs)
        [but setImage:hole forState:UIControlStateNormal];
}

-(IBAction)ballButtonPressed:(id)sender
{
    UIButton *but = (UIButton*)sender;
    outline.center = but.center;
    outline.hidden = FALSE;
    selectedButton = (int)but.tag;
}

-(IBAction)holePressed:(id)sender
{
    UIButton *sb = (UIButton*)sender;
    UIButton *but = [blobs objectAtIndex:sb.tag];
    if (selectedButton < 12)
    {
        [but setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ball%d.png",selectedButton]] forState:UIControlStateNormal];
        colors[sb.tag/5][sb.tag%5] = selectedButton;
    }
    else if (selectedButton == 12)
    {
        [but setImage:white forState:UIControlStateNormal];
        colors[sb.tag/5][sb.tag%5] = 12;
    }
    else
    {
        [but setImage:hole forState:UIControlStateNormal];
        colors[sb.tag/5][sb.tag%5] = -1;
    }
}

-(IBAction)clearPressed:(id)sender
{
    [self clearBoard];
}

-(IBAction)solvePressed:(id)sender
{
    waitScreen.hidden = FALSE;
}



@end
