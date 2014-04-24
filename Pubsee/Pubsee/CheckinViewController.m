//
//  CheckinViewController.m
//  Onrange
//
//  Created by Thiago Castro on 24/03/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "CheckinViewController.h"
#import "PointLocais.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"
#import "Usuario.h"
#import "Checkin.h"
#import "ConfirmaCheckinViewController.h"
#import <SVProgressHUD.h>

@interface CheckinViewController (){
    int id_usuario;
}

@property (nonatomic, strong) NSMutableArray *arrUsuarios;
@property (nonatomic, assign) bool usuarioEstaNoLocal;

@end

@implementation CheckinViewController

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
    
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    self.navigationController.navigationBar.topItem.title = @"•";
    
    self.btnCheckin.faceColor = [UIColor colorWithRed:0.333 green:0.631 blue:0.851 alpha:1.0];
    self.btnCheckin.sideColor = [UIColor colorWithRed:0.310 green:0.498 blue:0.702 alpha:1.0];
    
    self.btnCheckin.radius = 8.0;
    self.btnCheckin.margin = 4.0;
    self.btnCheckin.depth = 3.0;
    
    self.lblNomeLocal.text = self.local.nome.uppercaseString;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    id_usuario = [def integerForKey:@"id_usuario"];
    
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [self.local.latitude doubleValue];
    theCoordinate.longitude = [self.local.longitude doubleValue];
    
    CLLocationCoordinate2D startCoord = theCoordinate;
    MKCoordinateRegion adjustedRegion = [self.mapLocal regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 400, 400)];
    [self.mapLocal setRegion:adjustedRegion animated:YES];

    MKAnnotationView *viewPoint = [MKAnnotationView new];
    viewPoint.image = [UIImage imageNamed:@"pin-balada-1"];
                                   
    PointLocais *point = [[PointLocais alloc]initWithCoordenada:startCoord nome:self.local.nome];
    [self.mapLocal addAnnotation:point];
    [self.btnCheckin setTitle:@"Checkin" forState: UIControlStateNormal];
    [self carregaUsuarios];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCheckin:(id)sender {
    
    if (self.usuarioEstaNoLocal == YES){
        UIActionSheet* actionCheckout = [[UIActionSheet alloc]
                                 initWithTitle:[NSString stringWithFormat:@"Confirmar checkout em %@?", self.local.nome]
                                 delegate:(id<UIActionSheetDelegate>)self
                                 cancelButtonTitle:@"Sim"
                                 destructiveButtonTitle:@"Não"
                                 otherButtonTitles:nil];
        [actionCheckout setTag:2];
        [actionCheckout showInView:self.view];
    }else{
        UIActionSheet* actionCheckin = [[UIActionSheet alloc]
                                        initWithTitle:[NSString stringWithFormat:@"Confirmar checkin em %@?", self.local.nome]
                                        delegate:(id<UIActionSheetDelegate>)self
                                        cancelButtonTitle:@"Sim"
                                        destructiveButtonTitle:@"Não"
                                        otherButtonTitles:nil];
        [actionCheckin setTag:1];
        [actionCheckin showInView:self.view];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:   (NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0: //Não
                break;
            case 1: //Sim
                NSLog(@"Tentativa de checkin!");
                [SVProgressHUD showWithStatus:@"Aguarde" maskType:SVProgressHUDMaskTypeBlack];
                [self fazCheckin];
                break;
        }
    }else{
        switch (buttonIndex) {
            case 0: //Não
                break;
            case 1: //Sim
                NSLog(@"Tentativa de checkout!");
//                [SVProgressHUD showWithStatus:@"Aguarde" maskType:SVProgressHUDMaskTypeBlack];
//                [self fazCheckin];
                break;
        }
    }
}

-(void)fazCheckin{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"id_usuario", @"id_local"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Checkin class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_usuario", @"id_local", @"id_checkin", @"checkin_vigente", @"id_checkin_anterior", @"id_local_anterior", @"id_output"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Checkin class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:@"Checkin"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url
    = [NSURL URLWithString:API];
    NSString  *path= @"checkin/adicionacheckin";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    Checkin *checkin= [Checkin new];
    
    checkin.id_usuario = id_usuario;
    checkin.id_local = self.local.id_local;
    
    [objectManager postObject:checkin
                         path:path
                   parameters:nil
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          if(mappingResult != nil){
                              NSLog(@"Dados de checkin enviados e recebidos com sucesso!");
                              Checkin *checkinefetuado = [mappingResult firstObject];
                              [SVProgressHUD dismiss];
                              if (checkinefetuado.id_output == 1) {
                                  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                  ConfirmaCheckinViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ConfirmaCheckinViewController"];
                                  [self presentViewController:vc animated:YES completion:nil];
                                  [self.view setNeedsLayout];

                                  self.usuarioEstaNoLocal = YES;
                                  [self.btnCheckin setTitle:@"Checkout" forState: UIControlStateNormal];
                                  
                              }else if(checkinefetuado.id_output == 2){
                                  [self alert:@"Ocorreu um erro na tentativa de efetuar checkin. Tente novamente em alguns segundos":@"Erro"];
                              }else if(checkinefetuado.id_output == 3){
                                  [self alert:@"O tempo mínimo para fazer um novo checkin é de 5 minutos":@"Erro"];
                              }else{
                                  NSLog(@"Ocorreu um erro ao efetuar o checkin");
                              }
                          }else{
                              NSLog(@"Falha ao tentar fazer checkin");
                          }
                      }
                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"Error: %@", error);
                          NSLog(@"Falha ao tentar enviar dados de checkin");
                      }];
}

- (void)carregaUsuarios {
    
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider usuarioMapping];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:false pathPattern:nil keyPath:@"Usuarios" statusCodes:statusCodeSet];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@checkin/listaUsuariosCheckin/%d",API,self.local.id_local]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request
                                                                        responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.arrUsuarios = [NSMutableArray arrayWithArray:mappingResult.array];
        
        for (int i=0; i<[self.arrUsuarios count]; i++) {
            Usuario *usuario = [self.arrUsuarios objectAtIndex:i];
            
            if (usuario.id_usuario == id_usuario) {
                NSLog(@"O usuário está no local");
                self.usuarioEstaNoLocal = YES;
               [self.btnCheckin setTitle:@"Checkout" forState: UIControlStateNormal];
            }
        }

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {

        NSLog(@"ERROR: %@", error);
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(NSLocalizedString(@"Ocorreu um erro",nil));
    }];
    
    [operation start];
}

- (void) alert:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alertView show];
}

@end