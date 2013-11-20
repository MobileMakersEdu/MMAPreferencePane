#import "main.h"

static BOOL GIT_EDITOR() {
    NSTask *task = [NSTask new];
    task.launchPath = @"/bin/bash";
    task.arguments = @[@"-lc", @"echo $GIT_EDITOR"];
    task.standardOutput = [NSPipe pipe];
    [task launch];
    [task waitUntilExit];

    NSData *data = [task.standardOutput fileHandleForReading].readDataToEndOfFile;
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding].strip;
    return s.length > 0;
}


@implementation MMGitDiagnostic

- (BOOL)execute:(NSError *__autoreleasing *)error {
    if (!@"/usr/bin/which git".exitSuccess) {
        *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:@{
            NSLocalizedDescriptionKey: @"A working git binary could not be found"
        }];
        return NO;
    }

    if (@"/usr/bin/git config --global core.editor".exitSuccess || GIT_EDITOR())
        return YES;

    *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedAmber userInfo:nil];
    return NO;
}

@end