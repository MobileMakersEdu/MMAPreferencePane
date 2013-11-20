#import "main.h"


@implementation MMCocoaPodsDiagnostic

- (BOOL)execute:(NSError *__autoreleasing *)error {
    @try {
        NSTask *task = [NSTask new];
        task.launchPath = @"/bin/bash";
        task.arguments = @[@"-lc", @"/usr/bin/which pod"];
        task.standardOutput = [NSPipe pipe];
        [task launch];
        [task waitUntilExit];

        NSData *data = [task.standardOutput fileHandleForReading].readDataToEndOfFile;
        NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!s.length) {
            id info = @{
                NSLocalizedDescriptionKey: @"In Terminal.app type: gem install cocoapods"
            };
            *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:info];
            return NO;
        } else
            return YES;
    } @catch (id e) {
        NSLog(@"MM: %@", e);
        return NO;
    }
}

@end