#import "main.h"


@implementation MMMavericksDiagnostic

- (BOOL)execute:(NSError **)error {
    BOOL ok = [[@"/usr/sbin/sysctl kern.osrelease".stdout componentsSeparatedByString:@":"][1] intValue] == 13;
    if (!ok)
        *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:@{
            NSLocalizedDescriptionKey: @"You need to upgrade to Mavericks",
            NSLocalizedRecoverySuggestionErrorKey: @"https://itunes.apple.com/us/app/os-x-mavericks/id675248567#"
        }];
    return ok;
}

@end