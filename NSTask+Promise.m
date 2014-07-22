#import "main.h"


@implementation NSTask (MM)

- (Promise *)promise {
    self.standardOutput = [NSPipe pipe];
    [self launch];
    return dispatch_promise(^{
        [self waitUntilExit];
        if (self.terminationStatus == 0) {
            NSData *data = [self.standardOutput fileHandleForReading].readDataToEndOfFile;
            NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return s.chuzzle;
        } else {
            id cmd = @[self.launchPath, self.arguments].flatten.join(@" ");
            @throw [NSString stringWithFormat:@"Failed executing %@ with exit status %d", cmd, self.terminationStatus];
        }
    });
}

+ (instancetype):(NSString *)parsable {
    NSArray *args = [parsable isKindOfClass:[NSArray class]] ? (id)parsable : parsable.split(@" ");

    NSTask *task = [self new];
    task.launchPath = args.firstObject;
    task.arguments = args.skip(1);
    return task;
}

@end
