#import "main.h"

#define NSColorGreenStroke [NSColor colorWithRed:0.3 green:0.7 blue:0.3 alpha:1]
#define NSColorGreenFill [NSColor colorWithRed:0 green:1 blue:0 alpha:0.45]
#define NSColorAmberStroke [NSColor colorWithRed:0.3 green:0.3 blue:0 alpha:1]
#define NSColorAmberFill [NSColor colorWithRed:1 green:1 blue:0 alpha:0.45]
#define NSColorRedStroke [NSColor colorWithRed:0.7 green:0.3 blue:0 alpha:1]
#define NSColorRedFill [NSColor colorWithRed:1 green:0 blue:0 alpha:0.45]
#define NSColorGrayStroke [NSColor grayColor]
#define NSColorGrayFill [NSColor colorWithDeviceWhite:0 alpha:0.12];


@implementation MMALED {
    NSColor *fill;
    NSColor *stroke;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    [self reset];
    return self;
}

- (void)reset {
    fill = NSColorGrayFill;
    stroke = NSColorGrayStroke;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSGraphicsContext currentContext] saveGraphicsState];

    NSRect rect = NSMakeRect(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2);

    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
    [fill setFill];
    [path fill];
    [stroke setStroke];
    [path stroke];

	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)check:(Promise *)diagnostic {
    diagnostic.then(^{
        fill = NSColorGreenFill;
        stroke = NSColorGreenStroke;
    }).catch(^(NSError *error){
        if (error.code == MMADiagnosticFailedAmber) {
            fill = NSColorAmberFill;
            stroke = NSColorAmberStroke;
        } else {
            fill = NSColorRedFill;
            stroke = NSColorRedStroke;
        }

        return error;
    }).finally(^{
        [self setNeedsDisplay:YES];
    });
}

@end
