#import "main.h"



@implementation MMLED

- (void)setOn:(BOOL)on {
    _on = on;
    [self setNeedsDisplay:YES];
}

- (NSColor *)stroke {
    return self.on ? [NSColor colorWithRed:0.3 green:0.7 blue:0.3 alpha:1] : [NSColor grayColor];
}

- (NSColor *)fill {
    return self.on ? [NSColor colorWithRed:0 green:1 blue:0 alpha:0.45] : [NSColor colorWithWhite:0 alpha:0.12];
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSGraphicsContext currentContext] saveGraphicsState];

    NSRect rect = NSMakeRect(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2);

    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
    [self.fill setFill];
    [path fill];
    [self.stroke setStroke];
    [path stroke];

	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end