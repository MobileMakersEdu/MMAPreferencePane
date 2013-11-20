#import "main.h"


@implementation MMTextMateDiagnostic

- (BOOL)execute:(NSError *__autoreleasing *)error {
    if (mdfind(@"TextMate"))
        return YES;
    id info = @{
        NSLocalizedDescriptionKey: @"You need to install TextMate (2 Alpha recommended)",
        NSLocalizedRecoverySuggestionErrorKey: @"http://macromates.com/download"
    };
    *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:info];
    return NO;
}

@end