#import "main.h"

#define NSColorGreenStroke [NSColor colorWithRed:0.3 green:0.7 blue:0.3 alpha:1]
#define NSColorGreenFill [NSColor colorWithRed:0 green:1 blue:0 alpha:0.45]
#define NSColorAmberStroke [NSColor colorWithRed:0.3 green:0.3 blue:0 alpha:1]
#define NSColorAmberFill [NSColor colorWithRed:1 green:1 blue:0 alpha:0.45]
#define NSColorRedStroke [NSColor colorWithRed:0.7 green:0.3 blue:0 alpha:1]
#define NSColorRedFill [NSColor colorWithRed:1 green:0 blue:0 alpha:0.45]
#define NSColorGrayStroke [NSColor grayColor]
#define NSColorGrayFill [NSColor colorWithWhite:0 alpha:0.12];


@implementation MMLED {
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

- (void)checkWith:(id<MMDiagnostic>)diagnostic {
    NSError *error = nil;
    BOOL ok = [diagnostic execute:&error];

    [self setNeedsDisplay:YES];

    if (ok) {
        fill = NSColorGreenFill;
        stroke = NSColorGreenStroke;
    } else {
        if (error.code == MMDiagnosticFailedAmber) {
            fill = NSColorAmberFill;
            stroke = NSColorAmberStroke;
        } else {
            fill = NSColorRedFill;
            stroke = NSColorRedStroke;
        }
        if (error)
            @throw error;
        else
            @throw [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:nil];
    }
}

@end