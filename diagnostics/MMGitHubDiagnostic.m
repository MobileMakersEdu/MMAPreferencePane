#import "main.h"

static BOOL credhelp() {
    return [@"/usr/bin/git config credential.helper".stdout isEqualToString:@"cache"];
}


@implementation MMGitHubDiagnostic

- (BOOL)execute:(NSError *__autoreleasing *)error {
    if (!@"~/.ssh/id_rsa".isFile && !@"~/.ssh/id_rsa".isFile && !credhelp()) {
        id info = @{
            NSLocalizedDescriptionKey: @"You need to setup Git’s credential helper. Turn on the big switch"
        };
        *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:info];
        return NO;
    }
    if (!@"/usr/bin/git config --global user.name".exitSuccess) {
        id info = @{
            NSLocalizedDescriptionKey: @"You need to set your git username",
            NSLocalizedRecoverySuggestionErrorKey: @"http://help.github.com/articles/setting-your-username-in-git"
        };
        *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:info];
        return NO;
    }
    if (!@"/usr/bin/git config --global user.email".exitSuccess) {
        id info = @{
            NSLocalizedDescriptionKey: @"You need to set your git email",
            NSLocalizedRecoverySuggestionErrorKey: @"http://help.github.com/articles/setting-your-email-in-git"
        };
        *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:info];
        return NO;
    }
    return YES;
}

@end