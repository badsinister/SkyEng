
#import "SWButton.h"




@implementation SWButton

// ===================================================================================
- (void)awakeFromNib
{
    [super awakeFromNib];

    // перерисовка после поворота устройства
    self.contentMode = UIViewContentModeRedraw;
    
    [self setTitleShadowColor:nil forState:(UIControlStateHighlighted | UIControlStateNormal)];
} // awakeFromNib

// ===================================================================================
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
} // setHighlighted

// ===================================================================================
- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.5, 0.5, CGRectGetWidth(rect) - 1, CGRectGetHeight(rect) - 1) cornerRadius:(CGRectGetHeight(rect) - 1) / 2.0];

    UIColor *backgroundColor;
    UIColor *borderColor;
    if (self.redButton) {
        backgroundColor = self.highlighted ? [UIColor colorWithRed:252.0/255.0 green:110.0/255.0 blue:81.0/255.0 alpha:0.6] : [UIColor colorWithRed:252.0/255.0 green:110.0/255.0 blue:81.0/255.0 alpha:1];
        borderColor = [UIColor clearColor];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        path.lineWidth = 0;
    } else if (self.greenButton) {
        backgroundColor = self.highlighted ? [UIColor colorWithRed:140.0/255.0 green:193.0/255.0 blue:82.0/255.0 alpha:0.6] : [UIColor colorWithRed:140.0/255.0 green:193.0/255.0 blue:82.0/255.0 alpha:1];
        borderColor = [UIColor clearColor];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        path.lineWidth = 0;
    } else {
        backgroundColor = self.highlighted ? [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6] : [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
        borderColor = self.highlighted ? [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:0.4] : [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        path.lineWidth = 1;
    }
    
    [backgroundColor setFill];
    [borderColor setStroke];

    [path fill];
    [path stroke];
} // drawRect

@end // SWButton
