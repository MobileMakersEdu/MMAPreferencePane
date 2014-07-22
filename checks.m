#import "main.h"

Promise *MMCheckMavericks() {
    return [NSTask:@"/usr/sbin/sysctl kern.osrelease"].promise.then(^(NSString *stdout){
        return [stdout.split(@":")[1] intValue];
    }).then(^(NSNumber *code){
        if (code.intValue < 13)
            @throw [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:@{
                NSLocalizedDescriptionKey: @"You need to upgrade to at least Mavericks",
                NSLocalizedRecoverySuggestionErrorKey: @"https://itunes.apple.com/us/app/os-x-mavericks/id675248567"
            }];
    });
}

Promise *MMCheckXcode() {
    return [NSTask:@"/usr/bin/xcode-select --print-path"].promise.catch(^{
        id info = @{
            NSLocalizedDescriptionKey: @"You need to install Xcode",
            NSLocalizedRecoverySuggestionErrorKey: @"https://itunes.apple.com/us/app/xcode/id497799835"
        };
        return [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:info];
    });
}

Promise *MMCheckGit() {
    return [NSTask:@"/usr/bin/which git"].promise.catch(^{
        @throw @"A working git binary could not be found";
    }).then(^{
        return [NSTask:@"/usr/bin/git config --global core.editor"].promise;
    }).catch(^{
        return [NSTask:@[@"/bin/bash", @"-lc", @"echo $GIT_EDITOR"]].promise;
    });
}

Promise *MMCheckGitX() {
    return mdfind(@"GitX");
}

Promise *MMCheckTextMate() {
    return mdfind(@"TextMate");
}

Promise *MMCheckGitHub() {
    id p1 = [NSTask:@"/usr/bin/git config credential.helper"].promise.then(^(NSString *stdout){
        if (![stdout isEqualToString:@"cache"]) {
            id info = @{
                NSLocalizedDescriptionKey: @"You need to setup Git’s credential helper. Turn on the big switch"
            };
            @throw [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:info];
        }
    });

    id p2 = [NSTask:@"/usr/bin/git config --global user.name"].promise.catch(^{
        id info = @{
            NSLocalizedDescriptionKey: @"You need to set your git username",
            NSLocalizedRecoverySuggestionErrorKey: @"http://help.github.com/articles/setting-your-username-in-git"
        };
        return [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:info];
    });

    id p3 = [NSTask:@"/usr/bin/git config --global user.email"].promise.catch(^{
        id info = @{
            NSLocalizedDescriptionKey: @"You’ve set your git username, but you also need to set your git email, USE THE SAME EMAIL AS YOUR GITHUB ACCOUNT",
            NSLocalizedRecoverySuggestionErrorKey: @"http://help.github.com/articles/setting-your-email-in-git"
        };
        return [NSError errorWithDomain:MMErrorDomain code:MMDiagnosticFailedRed userInfo:info];
    });

    return [Promise when:@[p1, p2, p3]];
}
