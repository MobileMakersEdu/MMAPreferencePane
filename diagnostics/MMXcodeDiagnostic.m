#import "main.h"


@implementation MMXcodeDiagnostic

- (BOOL)execute:(NSError *__autoreleasing *)error {
    BOOL ok = @"/usr/bin/xcode-select --print-path".exitSuccess;
    if (!ok) {
        id info = @{
            NSLocalizedDescriptionKey: @"You need to install Xcode",
            NSLocalizedRecoverySuggestionErrorKey: @"https://itunes.apple.com/us/app/xcode/id497799835#"
        };
        *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:info];
    }
    return ok;
}

@end
