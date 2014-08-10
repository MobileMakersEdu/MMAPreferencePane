#import "main.h"
#import "YOLO.h"

#define MMBundlePathPlus(x) [self.bundle.bundlePath stringByAppendingPathComponent:x]

Promise *mdfind(NSString *app) {
    return [NSTask:@[@"/usr/bin/mdfind", app, @"kind:app"]].promise;
}

static Promise *MMSyncPrefs(id domain) {
    id fmt = @"from Foundation import CFPreferencesAppSynchronize\nCFPreferencesAppSynchronize('%@')";
    id py = [NSString stringWithFormat:fmt, domain];
    return [NSTask:@[@"/usr/bin/python", @"-c", py]].promise;
}

static Promise *MMWritePrefs(NSArray *args) {
    NSMutableArray *ma = [NSMutableArray arrayWithObjects:@"write", nil];
    [ma addObjectsFromArray:args];

    NSTask *task = [NSTask new];
    task.launchPath = @"/usr/bin/defaults";
    task.arguments = ma;
    return task.promise;
}

#define MMWritePrefs(...) MMWritePrefs(@[__VA_ARGS__])



@implementation MMAPreferencePane {
    IBOutlet MMALED *mavericks;
    IBOutlet MMALED *xcode;
    IBOutlet MMALED *git;
    IBOutlet MMALED *gitx;
    IBOutlet MMALED *github;
    IBOutlet MMALED *textmate;
    IBOutlet MMASwitchView *bigSwitch;
    IBOutlet NSButton *refresh;
    IBOutlet NSProgressIndicator *spinner;

    Promise *switcher;
    Promise *checker;
}

- (NSString *)bashProfileLine {
    id profile = [self.bundle.bundlePath stringByAppendingPathComponent:@"Contents/etc/profile"];
    profile = [profile stringByReplacingOccurrencesOfString:@"~".stringByExpandingTildeInPath withString:@"~"];
    return [NSString stringWithFormat:@"source %@", profile];
}

- (void)mainViewDidLoad {
    bigSwitch.state  = NSOffState;
    bigSwitch.target = self;
    bigSwitch.action = @selector(onSwitchToggled);

    refresh.target = self;
    refresh.action = @selector(check);

    [spinner startAnimation:self];
    [self check];
    checker.finally(^{
        [spinner stopAnimation:self];
    });

    NSString *path = @"~/.bash_profile".stringByExpandingTildeInPath;
    NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = contents.split(@"\n").chuzzle;
    bigSwitch.state = lines.has(self.bashProfileLine) ? NSOnState : NSOffState;
}

- (void)awakeFromNib {
    bigSwitch.target = self;
    bigSwitch.action = @selector(onSwitchToggled);
}

- (IBAction)check {
    if (checker)
        return;

    [@[mavericks, xcode, git, gitx, github, textmate] makeObjectsPerformSelector:@selector(reset)];

    id p1, p2, p3, p4, p5, p6;

    [mavericks check:p1 = MMACheckMavericks()];
    [xcode check:p2 = MMACheckXcode()];
    [git check:p3 = MMACheckGit()];
    [gitx check:p4 = MMACheckGitX()];
    [github check:p5 = MMACheckGitHub()];
    [textmate check:p6 = MMACheckTextMate()];

    checker = [Promise when:@[p1, p2, p3, p4, p5, p6]].finally(^{
        checker = nil;
    });
}

- (void)activate {
    if (switcher)
        return;

    id terminalPromises = @[
        [NSTask:@[@"/usr/bin/open", @"-g", MMBundlePathPlus(@"Contents/Resources/MobileMakers.terminal")]].promise,
        MMWritePrefs(@"com.apple.Terminal", @"Default Window Settings", @"MobileMakers"),
        MMWritePrefs(@"com.apple.Terminal", @"Startup Window Settings", @"MobileMakers")
    ];

    id xcodePromises = @[
        dispatch_promise(^id{
            id err = nil;
            id mgr = [NSFileManager defaultManager];
            id dst = @"~/Library/Developer/Xcode/UserData/FontAndColorThemes".stringByExpandingTildeInPath;
            id src = [self.bundle.bundlePath stringByAppendingString:@"/Contents/Resources/MobileMakers.dvtcolortheme"];
            [mgr createDirectoryAtPath:dst withIntermediateDirectories:YES attributes:nil error:nil];
            [mgr copyItemAtPath:src toPath:[dst stringByAppendingString:@"/MobileMakers.dvtcolortheme"] error:&err];
            if ([err code] == 516 || !err)
                return MMWritePrefs(@"com.apple.dt.Xcode", @"DVTFontAndColorCurrentTheme", @"MobileMakers.dvtcolortheme");
            return nil;
        }),
        MMWritePrefs(@"com.apple.dt.Xcode", @"DVTTextEditorTrimWhitespaceOnlyLines", @"-bool", @"YES"),
        MMWritePrefs(@"com.apple.dt.Xcode", @"DVTTextShowLineNumbers", @"-bool", @"YES"),
        MMWritePrefs(@"com.apple.dt.Xcode", @"DVTTextEditorTrimTrailingWhitespace", @"-bool", @"YES"),
    ];

    id gitxPromise = [NSTask:@[@"/usr/bin/tar",
        @"xf", MMBundlePathPlus(@"/Contents/Resources/GitX.tbz"),
        @"-C", @"~/Applications".stringByExpandingTildeInPath,
    ]].promise;

    // doing these sequentially or git freaks out
    id gitPromise = [NSTask:@"/usr/bin/git config --global color.ui auto"].promise.then(^{
        return [NSTask:@"/usr/bin/git config --global push.default simple"].promise;
    }).then(^{
        return [NSTask:@"/usr/bin/git config --global credential.helper cache"].promise;
    }).then(^{
        id args = @[@"/usr/bin/git", @"config", @"--global", @"core.excludesfile", MMBundlePathPlus(@"Contents/etc/gitignore")];
        return [NSTask:args].promise;
    });

    id promises = @[
        gitxPromise,
        gitPromise,
        [Promise when:terminalPromises].then(^{
            return MMSyncPrefs(@"com.apple.Terminal");
        }),
        [Promise when:xcodePromises].then(^{
            return MMSyncPrefs(@"com.apple.dt.Xcode");
        })
    ];

    NSString *bashProfilePath = @"~/.bash_profile".stringByExpandingTildeInPath;

    [spinner startAnimation:self];
    bigSwitch.enabled = NO;

    switcher = [Promise when:promises].then(^{
        return [NSString pmk_stringWithContentsOfFile:bashProfilePath];
    }).then(^(NSString *contents) {
        if (!contents.split(@"\n").chuzzle.has(self.bashProfileLine)) {
            contents = [contents stringByAppendingFormat:@"\n\n%@\n", self.bashProfileLine];
            [contents writeToFile:bashProfilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }).then(^{
        [self check];
        return checker;
    }).catch(^(NSError *error){
        [spinner stopAnimation:self];
        [[NSAlert alertWithError:error] runModal];
        [bigSwitch setState:NSOffState animate:YES];
    }).finally(^{
        bigSwitch.enabled = YES;
        [spinner stopAnimation:self];
        switcher = nil;
    });
}

- (void)deactivate {
    if (switcher)
        return;

    NSString *path = @"~/.bash_profile".stringByExpandingTildeInPath;
    switcher = [NSString pmk_stringWithContentsOfFile:path].then(^(NSString *bashProfile){
        NSMutableArray *lines = bashProfile.split(@"\n").chuzzle.mutableCopy;
        [lines removeObject:self.bashProfileLine];
        [lines.join(@"\n") writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }).finally(^{
        switcher = nil;
    });
}

- (IBAction)onSwitchToggled {
    if (switcher)
        return;

    if (bigSwitch.state == NSOnState) {
        [self activate];
    } else
        [self deactivate];
}

@end


@implementation NSString (MM)

+ (Promise *)pmk_stringWithContentsOfFile:(NSString *)path {
    return dispatch_promise(^{
        id err;
        id str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
        if (err)
            @throw err;
        else
            return str ?: @"";
    });
}

@end
