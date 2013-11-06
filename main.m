#import "main.h"

static BOOL mdfind(NSString *app) {
    return [NSString stringWithFormat:@"/usr/bin/mdfind %@ kind:app", app].stdout.length;
}



@implementation MMPane {
    IBOutlet __weak MMLED *mavericks;
    IBOutlet __weak MMLED *xcode;
    IBOutlet __weak MMLED *git;
    IBOutlet __weak MMLED *gitx;
    IBOutlet __weak MMLED *github;
    IBOutlet __weak MMLED *dropbox;
    IBOutlet __weak MMLED *ruby;
    IBOutlet __weak MMLED *cocoapods;
    IBOutlet __weak MMLED *mmawe;
}

- (void)mainViewDidLoad {
    #define dispatch(fob) \
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ \
            BOOL result = [self fob]; \
            dispatch_async(dispatch_get_main_queue(), ^{ \
                fob.on = result; \
            }); \
        });

    dispatch(mavericks);
    dispatch(xcode);
    dispatch(git);
    dispatch(gitx);
    dispatch(github);
    dispatch(dropbox);
    dispatch(ruby);
    dispatch(cocoapods);
    dispatch(mmawe);
}

- (BOOL)mavericks {
    return [[@"/usr/sbin/sysctl kern.osrelease".stdout componentsSeparatedByString:@":"][1] intValue] == 13;
}

- (BOOL)xcode {
    return @"/usr/bin/xcode-select --print-path".exitSuccess;
}

- (BOOL)git {
    return @"/usr/bin/which git".exitSuccess
        && [@"/usr/bin/git config --global core.editor".stdout isEqual:@"mate -w"];
}

- (BOOL)gitx {
    return mdfind(@"GitX");
}

- (BOOL)github {
    return (@"~/.ssh/id_rsa".isFile || @"~/.ssh/id_rsa".isFile)
        && @"/usr/bin/git config --global user.name".exitSuccess
        && @"/usr/bin/git config --global user.email".exitSuccess;
}

- (BOOL)dropbox {
    return mdfind(@"Dropbox");
}

- (BOOL)ruby {
    return NO;
}

- (BOOL)cocoapods {
    @try {
        NSTask *task = [NSTask new];
        task.launchPath = @"/bin/bash";
        task.arguments = @[@"-lc", @"/usr/bin/which pod"];
        task.standardOutput = [NSPipe pipe];
        [task launch];
        [task waitUntilExit];

        NSData *data = [task.standardOutput fileHandleForReading].readDataToEndOfFile;
        NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return s.length;
    } @catch (id e) {
        NSLog(@"MM: %@", e);
        return NO;
    }
}

- (BOOL)mmawe {
    return [@"~/.bash_profile".read.lines containsObject:self.source];
}

- (NSString *)source {
    id profile = [self.bundle.bundlePath stringByAppendingPathComponent:@"Contents/etc/profile"];
    profile = [profile stringByReplacingOccurrencesOfString:@"~".stringByExpandingTildeInPath withString:@"~"];
    return [NSString stringWithFormat:@"source %@", profile];
}

@end
