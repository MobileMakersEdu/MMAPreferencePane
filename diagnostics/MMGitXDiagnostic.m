#import "main.h"


@implementation MMGitXDiagnostic

- (BOOL)execute:(NSError **)error {
    if (mdfind(@"GitX"))
        return YES;

    id info = @{
        NSLocalizedDescriptionKey: @"You need to install GitX (after downloading, make sure to drag and drop the application to your /Applications folder!)",
        NSLocalizedRecoverySuggestionErrorKey: @"http://rowanj.github.io/gitx/"
    };
    *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedAmber userInfo:info];
    return NO;
}

@end