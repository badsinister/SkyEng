
#import "SWMeaningViewController.h"
#import "SWNetworkStoreCoordinator.h"




@implementation SWMeaningViewController

// ===================================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];
    switch (self.style) {
        case SWMeaningViewControllerStyleDefault:
            break;
            
        case SWMeaningViewControllerStyleRed:
            self.forwardButton.redButton = YES;
            break;
            
        case SWMeaningViewControllerStyleGreen:
            self.forwardButton.greenButton = YES;
            break;
            
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(translation)]) {
        self.translationLabel.text = [self.delegate translation];
    }

    self.imageView.image = nil;
    if ([self.delegate respondsToSelector:@selector(image)]) {
        [self.imageView setImage:[self.delegate image]];
    }
} // viewDidLoad

// ===================================================================================
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
} // didReceiveMemoryWarning

// ===================================================================================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newImageDidLoadNotification:) name:NSCImageDidDownloadNotification object:nil];
} // viewWillAppear

// ===================================================================================
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
} // viewWillDisappear

// ===================================================================================
- (void)newImageDidLoadNotification:(NSNotification *)notification
{
    NSLog(@"newImageDidLoadNotification %@", notification);
    
    // Просто обновим изображение - вдруг наше...
    self.imageView.image = nil;
    if ([self.delegate respondsToSelector:@selector(image)]) {
        [self.imageView setImage:[self.delegate image]];
    }
    
} // newImageDidLoadNotification



#pragma mark - Actions

// ===================================================================================
- (IBAction)doForward:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(presentNextGuessViewController)]) {
        [self.delegate presentNextGuessViewController];
    }
} // doForward

@end // SWMeaningViewController
