#import "main.h"


@implementation MMRubyDiagnostic

- (BOOL)execute:(NSError *__autoreleasing *)error {
    if ([@"~/.gemrc".read.lines containsObject:@"gem: --user-install"])
        return YES;
    *error = [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedAmber userInfo:nil];
    return NO;
}

@end