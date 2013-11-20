#import "main.h"


@implementation MMmmmmDiagnostic {
    NSBundle *_bundle;
}

- (id)initWithBundle:(NSBundle *)bundle {
    _bundle = bundle;
    return self;
}

- (BOOL)execute:(NSError *__autoreleasing *)error {
    return [@"~/.bash_profile".read.lines containsObject:self.bashProfileSourceLine];
}

- (NSString *)bashProfileSourceLine {
    id profile = [_bundle.bundlePath stringByAppendingPathComponent:@"Contents/etc/profile"];
    profile = [profile stringByReplacingOccurrencesOfString:@"~".stringByExpandingTildeInPath withString:@"~"];
    return [NSString stringWithFormat:@"source %@", profile];
}

@end
