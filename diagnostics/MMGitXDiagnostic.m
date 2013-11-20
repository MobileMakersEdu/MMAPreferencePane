#import "main.h"


@implementation MMGitXDiagnostic

- (BOOL)execute:(NSError **)error {
    if (mdfind(@"GitX"))
        return YES;

    id info = @{
        NSLocalizedDescriptionKey: @"You need to install GitX",
        NSLocalizedRecoverySuggestionErrorKey: @"http://rowanj.github.io"
    };
    *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedAmber userInfo:info];
    return NO;
}

@end