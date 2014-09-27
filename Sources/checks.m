#import "main.h"

Promise *MMACheckMavericks() {
    return [NSTask:@"/usr/sbin/sysctl kern.osrelease"].promise.then(^(NSString *stdout){
        return [NSStringChomp(stdout).split(@":")[1] intValue];
    }).then(^(NSNumber *code){
        if (code.intValue < 13)
            @throw [NSError errorWithDomain:MMAErrorDomain code:MMADiagnosticFailedRed userInfo:@{
                NSLocalizedDescriptionKey: @"You need to upgrade to at least Mavericks",
                NSLocalizedRecoverySuggestionErrorKey: @"https://itunes.apple.com/us/app/os-x-mavericks/id675248567"
            }];
    });
}

Promise *MMACheckXcode() {
    return mdfind(@"Xcode").then(^(NSString *path){
        path = [path.chuzzle ?: @"" stringByAppendingPathComponent:@"Contents/version.plist"];
        return [NSTask:@[@"/usr/bin/defaults", @"read", path, @"CFBundleVersion"]].promise;
    }).then(^(NSString *stdout){
        if (stdout.intValue < 6528)
            @throw @NO;
    }).catch(^{
        id info = @{
            NSLocalizedDescriptionKey: @"You need to install Xcode 6",
            NSLocalizedRecoverySuggestionErrorKey: @"https://itunes.apple.com/us/app/xcode/id497799835"
        };
        return [NSError errorWithDomain:MMAErrorDomain code:MMADiagnosticFailedRed userInfo:info];
    });
}

Promise *MMACheckGit() {
    return [NSTask:@"/usr/bin/which git"].promise.catch(^{
        @throw @"A working git binary could not be found";
    }).then(^{
        return [NSTask:@"/usr/bin/git config --global core.editor"].promise;
    }).catch(^{
        return [NSTask:@[@"/bin/bash", @"-lc", @"echo $GIT_EDITOR"]].promise;
    });
}

Promise *MMACheckGitX() {
    // checking where we put it as otherwise Spotlight is too slow for us
    id path = [MMAApplicationsDirectory stringByAppendingPathComponent:@"GitX.app"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        return [Promise promiseWithValue:path];

    return mdfind(@"GitX");
}

Promise *MMACheckTextMate() {
    // checking where we put it as otherwise Spotlight is too slow for us
    id path = [MMAApplicationsDirectory stringByAppendingPathComponent:@"TextMate.app"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        return [Promise promiseWithValue:path];

    return mdfind(@"TextMate");
}

Promise *MMACheckGitHub() {
    id p1 = [NSTask:@"/usr/bin/git config credential.helper"].promise.then(^(NSString *stdout){
        if (![stdout.chuzzle isEqualToString:@"cache"]) {
            id info = @{
                NSLocalizedDescriptionKey: @"You need to setup Git’s credential helper. Turn on the big switch"
            };
            @throw [NSError errorWithDomain:MMAErrorDomain code:MMADiagnosticFailedRed userInfo:info];
        }
    });

    id p2 = [NSTask:@"/usr/bin/git config --global user.name"].promise.catch(^{
        id info = @{
            NSLocalizedDescriptionKey: @"You need to set your git username",
            NSLocalizedRecoverySuggestionErrorKey: @"http://help.github.com/articles/setting-your-username-in-git"
        };
        return [NSError errorWithDomain:MMAErrorDomain code:MMADiagnosticFailedRed userInfo:info];
    });

    id p3 = [NSTask:@"/usr/bin/git config --global user.email"].promise.catch(^{
        id info = @{
            NSLocalizedDescriptionKey: @"You’ve set your git username, but you also need to set your git email, USE THE SAME EMAIL AS YOUR GITHUB ACCOUNT",
            NSLocalizedRecoverySuggestionErrorKey: @"http://help.github.com/articles/setting-your-email-in-git"
        };
        return [NSError errorWithDomain:MMAErrorDomain code:MMADiagnosticFailedRed userInfo:info];
    });

    return [Promise when:@[p1, p2, p3]];
}
