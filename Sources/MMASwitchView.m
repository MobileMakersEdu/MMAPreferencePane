#import "main.h"

#define KNOB_WIDTH 38
#define KNOB_MIN_X 1
#define KNOB_MAX_X (self.bounds.size.width-KNOB_WIDTH-1)

@interface MMASwitchView () <NSAnimationDelegate>
@end

@interface MBKnobAnimation : NSAnimation {
    int start, range;
    id delegate;
}
@end

@implementation MBKnobAnimation
- (id)initWithStart:(int)begin end:(int)end {
    self = [super init];
    start = begin;
    range = end - begin;
    return self;
}
- (void)setCurrentProgress:(NSAnimationProgress)progress {
    int x = start + progress * range;
    [super setCurrentProgress:progress];
    [delegate performSelector:@selector(setPosition:) withObject:[NSNumber numberWithInteger:x]];
}
- (void)setDelegate:(id)d {
    delegate = d;
}
@end



@implementation MMASwitchView {
    NSPoint location;
    bool state;
    SEL action;
    id target;
}

- (void)setTarget:(id)anObject {
    target = anObject;
}

- (void)setAction:(SEL)aSelector {
    action = aSelector;
}

- (void)awakeFromNib {
    location.x = KNOB_MIN_X;
    state = false;
}

- (void)drawRect:(NSRect)rect
{
	NSGraphicsContext *context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];

    const float WIDTH = self.bounds.size.width;
    const float HEIGHT = self.bounds.size.height;
    float RADIUS = 3.5;

    //TODO clear background first

    NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0.5, 0.5, self.bounds.size.width-1, self.bounds.size.height-1) xRadius:RADIUS yRadius:RADIUS];
    [clipPath addClip];

    NSColor* darkGreen = [NSColor colorWithCalibratedHue:0.551 saturation:0.690 brightness:0.406 alpha:1];
    NSColor* lightGreen = [NSColor colorWithCalibratedHue:0.551 saturation:0.710 brightness:0.506 alpha:1];
    NSColor* darkGray = [NSColor colorWithDeviceRed:0.59 green:0.59 blue:0.59 alpha:1.0];
    NSColor* lightGray = [NSColor colorWithDeviceRed:0.7 green:0.7 blue:0.7 alpha:1.0];

    NSGradient* green_gradient = [[NSGradient alloc] initWithStartingColor:darkGreen endingColor:lightGreen];
    NSGradient* gray_gradient = [[NSGradient alloc] initWithStartingColor:darkGray endingColor:lightGray];

    [green_gradient drawInRect:NSMakeRect(0, 0, location.x + KNOB_WIDTH/2, HEIGHT) angle:270];

    NSString *s = @"ON";
    NSMutableDictionary *attrs = @{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:15.0],
        NSForegroundColorAttributeName: [NSColor colorWithCalibratedHue:0.534 saturation:0.990 brightness:0.204 alpha:1]
    }.mutableCopy;

    NSSize sz = [s sizeWithAttributes:attrs];
    NSPoint pt;
    pt.x = (KNOB_MAX_X-sz.width)/2 - (KNOB_MAX_X-location.x);
    pt.y = HEIGHT/2 - sz.height/2;
    [s drawAtPoint:pt withAttributes:attrs];

    int x = location.x+KNOB_WIDTH/2;
    [gray_gradient drawInRect:NSMakeRect(x, 0, WIDTH-x, HEIGHT) angle:270];

    s = @"OFF";
    attrs[NSForegroundColorAttributeName] = [NSColor colorWithDeviceWhite:0.2 alpha:0.66];
    sz = [s sizeWithAttributes:attrs];
    pt.x = location.x+KNOB_WIDTH+(KNOB_MAX_X-sz.width)/2;
    [s drawAtPoint:pt withAttributes:attrs];

    [[NSColor colorWithCalibratedWhite:0.66 alpha:1] setFill];
    [[NSBezierPath bezierPathWithRect:NSMakeRect(location.x + 3, 0, KNOB_WIDTH-6, HEIGHT)] fill];

//////// KNOB
    NSRect thumbFrame = (NSRect){location.x, 1, KNOB_WIDTH, HEIGHT - 2};
	NSBezierPath *thumbPath = [NSBezierPath bezierPathWithRoundedRect:thumbFrame xRadius:RADIUS-1 yRadius:RADIUS-1];

	NSShadow *thumbShadow = [NSShadow new];
	[thumbShadow setShadowColor:[NSColor colorWithCalibratedWhite:0 alpha:0.33]];
	[thumbShadow setShadowBlurRadius:3];
	[thumbShadow setShadowOffset:NSZeroSize];
	[thumbShadow set];
	[[NSColor whiteColor] setFill];

	[thumbPath fill];
	NSGradient *thumbGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0f] endingColor:[NSColor colorWithCalibratedWhite:0.75 alpha:1.0f]];
	[thumbGradient drawInBezierPath:thumbPath angle:270];

//////// BORDER
    [[NSColor colorWithCalibratedWhite:0 alpha:0.66] setStroke];
    [clipPath stroke];

    [context restoreGraphicsState];
}

- (BOOL)isOpaque {
    return YES;
}

- (NSInteger)state {
    return state ? NSOnState : NSOffState;
}

- (void)animateTo:(int)x {
    MBKnobAnimation* a = [[MBKnobAnimation alloc] initWithStart:location.x end:x];
    [a setDelegate:self];
    if (location.x == KNOB_MIN_X || location.x == KNOB_MAX_X){
        [a setDuration:0.20];
        [a setAnimationCurve:NSAnimationEaseInOut];
    }else{
        [a setDuration:0.35 * ((fabs(location.x-x))/KNOB_MAX_X)];
        [a setAnimationCurve:NSAnimationLinear];
    }

    [a setAnimationBlockingMode:NSAnimationBlocking];
    [a startAnimation];
}

-(void)setPosition:(NSNumber*)x
{
    location.x = [x intValue];
    [self display];
}

-(void)setState:(NSInteger)newstate
{
    [self setState:newstate animate:true];
}

-(void)setState:(NSInteger)newstate animate:(bool)animate
{
    if(newstate == [self state])
        return;

    int x = newstate == NSOnState ? KNOB_MAX_X : KNOB_MIN_X;

    //TODO animate if  we are visible and otherwise don't
    if(animate)
        [self animateTo:x];
    else
        [self setNeedsDisplay:YES];

    state = newstate == NSOnState ? true : false;
    location.x = x;
}

-(void)offsetLocationByX:(float)x
{
    location.x = location.x + x;

    if (location.x < KNOB_MIN_X) location.x = KNOB_MIN_X;
    if (location.x > KNOB_MAX_X) location.x = KNOB_MAX_X;

    [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)event
{
    BOOL loop = YES;

    // convert the initial click location into the view coords
    NSPoint clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];

    // did the click occur in the draggable item?
    if (NSPointInRect(clickLocation, [self bounds])) {

        NSPoint newDragLocation;

        // the tight event loop pattern doesn't require the use
        // of any instance variables, so we'll use a local
        // variable localLastDragLocation instead.
        NSPoint localLastDragLocation;

        // save the starting location as the first relative point
        localLastDragLocation=clickLocation;

        while (loop) {
            // get the next event that is a mouse-up or mouse-dragged event
            NSEvent *localEvent;
            localEvent= [[self window] nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask];


            switch ([localEvent type]) {
                case NSLeftMouseDragged:

                    // convert the new drag location into the view coords
                    newDragLocation = [self convertPoint:[localEvent locationInWindow]
                                                fromView:nil];


                    // offset the item and update the display
                    [self offsetLocationByX:(newDragLocation.x-localLastDragLocation.x)];

                    // update the relative drag location;
                    localLastDragLocation = newDragLocation;

                    // support automatic scrolling during a drag
                    // by calling NSView's autoscroll: method
                    [self autoscroll:localEvent];

                    break;
                case NSLeftMouseUp:
                    // mouse up has been detected,
                    // we can exit the loop
                    loop = NO;

                    if (memcmp(&clickLocation, &localLastDragLocation, sizeof(NSPoint)) == 0)
                        [self animateTo:state ? KNOB_MIN_X : KNOB_MAX_X];
                    else if (location.x > KNOB_MIN_X && location.x < KNOB_MAX_X)
                        [self animateTo:state ? KNOB_MAX_X : KNOB_MIN_X];

                    //TODO if let go of it halfway then slide to non destructive side

                    if (location.x == KNOB_MIN_X && state || location.x == KNOB_MAX_X && !state) {
                        state = !state;

                        IMP imp = [target methodForSelector:action];
                        void (*func)(id, SEL) = (void *)imp;
                        func(target, action);
                    }

                    // the rectangle has moved, we need to reset our cursor
                    // rectangle
                    [[self window] invalidateCursorRectsForView:self];

                    break;
                default:
                    // Ignore any other kind of event.
                    break;
            }
        }
    };
    return;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (IBAction)moveLeft:(id)sender
{
    [self offsetLocationByX:-10.0];
    [[self window] invalidateCursorRectsForView:self];
}

- (IBAction)moveRight:(id)sender
{
    [self offsetLocationByX:10.0];
    [[self window] invalidateCursorRectsForView:self];
}

@end
