#import "main.h"

#define MMArgs \
    id args = [self componentsSeparatedByString:@" "]; \
    id cmd = [args firstObject]; \
    args = [args subarrayWithRange:NSMakeRange(1, [args count] - 1)]


@implementation NSString (MM)

- (BOOL)exitSuccess {
    @try {
        MMArgs;

        NSTask *task = [NSTask new];
        task.launchPath = cmd;
        task.arguments = args;
        [task launch];
        [task waitUntilExit];
        return task.terminationStatus == 0;
    } @catch (id e) {
        NSLog(@"MM: %@", e);
        return NO;
    }
}

- (NSString *)stdout {
    @try {
        MMArgs;

        NSTask *task = [NSTask new];
        task.launchPath = cmd;
        task.arguments = args;
        task.standardOutput = [NSPipe pipe];
        [task launch];
        [task waitUntilExit];

        NSData *data = [task.standardOutput fileHandleForReading].readDataToEndOfFile;
        id s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    } @catch (id e) {
        NSLog(@"MM: %@", e);
        return nil;
    }
}

- (BOOL)isFile {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.stringByExpandingTildeInPath];
}

- (NSString *)read {
    return [NSString stringWithContentsOfFile:self.stringByExpandingTildeInPath encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)strip {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSArray *)lines {
    NSMutableArray *lines = @[].mutableCopy;
    for (NSString *line in [self componentsSeparatedByString:@"\n"])
        if (line.strip.length > 0)
            [lines addObject:line];
    return lines;
}

@end
