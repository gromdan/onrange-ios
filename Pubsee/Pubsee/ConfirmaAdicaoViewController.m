//
//  ConfirmaAdicaoViewController.m
//  Onrange
//
//  Created by Thiago Castro on 16/05/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "ConfirmaAdicaoViewController.h"

@interface ConfirmaAdicaoViewController ()

@end

@implementation ConfirmaAdicaoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblNomeLocal.text = self.strNomeLocal;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnFechar:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
