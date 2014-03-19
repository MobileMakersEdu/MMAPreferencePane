#import "main.h"

#define MMArgs \
    id args = [self componentsSeparatedByString:@" "]; \
    id cmd = [args firstObject]; \
    args = [args subarrayWithRange:NSMakeRange(1, [args count] - 1)]


@implementation NSArray (MM)

- (void)exec {
    @try {
        NSTask *task = [NSTask new];
        task.launchPath = self.firstObject;
        task.arguments = self.skip(1);
        [task launch];
        [task waitUntilExit];
    } @catch (id e) {
        NSLog(@"MM: %@", e);
    }
}

@end


@implementation NSString (MM)

- (void)exec {
    (void)[self exitSuccess];
}

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
        NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return s.strip;
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
        [lines addObject:line.strip];
    return lines;
}

- (NSString *)append:(NSString *)contents {
    id path = [self stringByExpandingTildeInPath];

    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if (fh == nil) {
        [contents writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return self;
    }

    [fh truncateFileAtOffset:[fh seekToEndOfFile]];
    NSData *encoded = [contents dataUsingEncoding:NSUTF8StringEncoding];

    if (encoded) {
        [fh writeData:encoded];
        return self;
    } else
        return nil;
}

@end
