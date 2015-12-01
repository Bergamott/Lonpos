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
//        for (int j=0;j<unique;j++)
//            NSLog(@"Shape %d permutation %d: %ld",i,j,shapes[i][j]);
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
        colors[sb.tag%5][sb.tag/5] = selectedButton;
    }
    else if (selectedButton == 12)
    {
        [but setImage:white forState:UIControlStateNormal];
        colors[sb.tag%5][sb.tag/5] = 12;
    }
    else
    {
        [but setImage:hole forState:UIControlStateNormal];
        colors[sb.tag%5][sb.tag/5] = -1;
    }
}

-(IBAction)clearPressed:(id)sender
{
    [self clearBoard];
}

-(IBAction)solvePressed:(id)sender
{
    waitScreen.hidden = FALSE;
    
    for (int i=0;i<11;i++)
    {
        sideMasks[i] = (1l << (i*5+5)) - 1l;
    }
    
    int usedPieces = 0;
    // Find which pieces have already been used
    for (int i=0;i<5;i++)
        for (int j=0;j<11;j++)
            if (colors[i][j] >= 0 && colors[i][j] < 12)
                usedPieces |= (1 << colors[i][j]);
    
    // Find white area
    fullMask = LONG_MAX;
    long whiteArea = 0;
    for (int i=0;i<5;i++)
        for (int j=0;j<11;j++)
        {
            if (colors[i][j] == 12)
                whiteArea += (1l << (j*5+i));
        }
    
    // Find remaining empty area
    long restArea = 0;
    for (int i=0;i<5;i++)
        for (int j=0;j<11;j++)
        {
            if (colors[i][j] == -1)
                restArea += (1l << (j*5+i));
        }
    remainingHole = fullMask - restArea;

    int piecesRemaining = 4095 - usedPieces;

    long empty = fullMask - whiteArea;
    if ([self fillHole:empty withPieces:piecesRemaining onStage:0])
    {
        NSLog(@"Found a solution");
        [self fillInFromStage:0 intoHole:empty-restArea];
    }
    
    waitScreen.hidden = TRUE;
}

-(void)fillInFromStage:(int)st intoHole:(long)hl
{
    int stageCount = st;
    long holeHolder = hl;
    while (holeHolder != fullMask)
    {
        long piece = shapes[stagePiece[stageCount]][stagePermutation[stageCount]] << (5*stageEdge[stageCount]+stageShift[stageCount]);
        for (int i=0;i<5;i++)
            for (int j=0;j<11;j++)
                if (piece & (1l << (5*j+i)))
                {
                    UIButton *but = [blobs objectAtIndex:j*5+i];
                    [but setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ball%d.png",stagePiece[stageCount]]] forState:UIControlStateNormal];
                }
        
        holeHolder |= piece;
        stageCount++;
    }
}

-(BOOL)fillHole:(long)hl withPieces:(int)pc onStage:(int)st
{
    if (hl == fullMask)
    {
        if (pc == 0)
            return TRUE;
        else
            return [self fillHole:remainingHole withPieces:pc onStage:st];
    }
    BOOL successful = FALSE;
    int edge = 0;
    while (edge < 11 && (hl & sideMasks[edge]) == sideMasks[edge])
        edge++;
    int pieceCount = 0;
    while (pieceCount < 12 && !successful)
    {
        if (pc & (1 << pieceCount))
        {
            int reducedPieces = pc - (1 << pieceCount);
            int permNum = numPermutations[pieceCount];
            int permCount = 0;
            while (permCount < permNum && !successful)
            {
                int w = shapeW[pieceCount][permCount];
                int h = shapeH[pieceCount][permCount];
                if (w+edge <= 11) // Is there room?
                {
                    long basePiece = shapes[pieceCount][permCount] << (5*edge);
                    int vCount = 0;
                    while (vCount + h <= 5 && !successful)
                    {
                        if ((basePiece & hl) == 0)
                        {
                            // Potential solution
                            stagePiece[st] = pieceCount;
                            stagePermutation[st] = permCount;
                            stageShift[st] = vCount;
                            stageEdge[st] = edge;
                            successful |= [self fillHole:hl+basePiece withPieces:reducedPieces onStage:st+1];
                        }
                        vCount++;
                        basePiece = basePiece << 1;
                    }
                }
                permCount++;
            }
        }
        pieceCount++;
    }
    
    return successful;
}



@end
