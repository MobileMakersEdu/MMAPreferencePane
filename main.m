#import "main.h"

BOOL mdfind(NSString *app) {
    return [NSString stringWithFormat:@"/usr/bin/mdfind %@ kind:app", app].stdout.length;
}



@implementation MMPane {
    IBOutlet MMLED *mavericks;
    IBOutlet MMLED *xcode;
    IBOutlet MMLED *git;
    IBOutlet MMLED *gitx;
    IBOutlet MMLED *github;
    IBOutlet MMLED *textmate;
    IBOutlet MMLED *mmmmmm;
    IBOutlet NSTextView *textView;
    IBOutlet MMSwitchView *bigSwitch;
    IBOutlet NSButton *refresh;
}

- (void)mainViewDidLoad {
    textView.font = [NSFont systemFontOfSize:13];
    [textView setAutomaticLinkDetectionEnabled:YES];

    bigSwitch.state = [[[MMmmmmDiagnostic alloc] initWithBundle:self.bundle] execute:nil] ? NSOnState : NSOffState;
    bigSwitch.target = self;
    bigSwitch.action = @selector(onSwitchToggled);

    refresh.target = self;
    refresh.action = @selector(check);

    [self check];
}

- (void)awakeFromNib {
    bigSwitch.target = self;
    bigSwitch.action = @selector(onSwitchToggled);
}

- (IBAction)check {
    [@[mavericks, xcode, git, gitx, github, textmate, mmmmmm] makeObjectsPerformSelector:@selector(reset)];
    textView.string = @"";

    MMmmmmDiagnostic *mmmmmmdiagnostic = [[MMmmmmDiagnostic alloc] initWithBundle:self.bundle];

    @try {
        [mavericks checkWith:[MMMavericksDiagnostic new]];
        [xcode checkWith:[MMXcodeDiagnostic new]];
        [git checkWith:[MMGitDiagnostic new]];
        [gitx checkWith:[MMGitXDiagnostic new]];
        [github checkWith:[MMGitHubDiagnostic new]];
        [textmate checkWith:[MMTextMateDiagnostic new]];
        [mmmmmm checkWith:mmmmmmdiagnostic];
    }
    @catch (NSError *e) {
        NSMutableString *s = @"HOW TO BE GREEN:\n".mutableCopy;
        id ss = e.userInfo[NSLocalizedDescriptionKey]
            ?: e.code == MMDiagnosticFailedAmber
                ? @"Please turn the big switch on. You may also need to open Xcode and accept its license."
                : @"Unexpected error, please email max@mobilemakers.co";
        [s appendString:ss];
        ss = e.userInfo[NSLocalizedRecoverySuggestionErrorKey];
        if (ss) {
            [s appendString:@", visit this URL:\n\n"];
            [s appendString:ss];
        }
        textView.string = s;
        [textView setEnabledTextCheckingTypes:NSTextCheckingTypeLink];
        [textView checkTextInDocument:nil];
        textView.string = s;
    }

    int state = [mmmmmmdiagnostic execute:nil] == NO ? NSOffState : NSOnState;
    [bigSwitch setState:state animate:YES];
}

- (void)activate {
    [@"/usr/bin/git config --global color.ui auto" exec];
    [@"/usr/bin/git config --global push.default simple" exec];  // squelch warning and be forward thinking
    [@"/usr/bin/git config --global credential.helper cache" exec];

    NSTask *task = [NSTask new];
    task.launchPath = @"/usr/bin/defaults";
    task.arguments = @[@"write", @"com.apple.Terminal", @"Default Window Settings", @"Silver Aerogel"];
    [task launch];
    [task waitUntilExit];

    task = [NSTask new];
    task.launchPath = @"/usr/bin/defaults";
    task.arguments = @[@"write", @"com.apple.Terminal", @"Startup Window Settings", @"Silver Aerogel"];
    [task launch];
    [task waitUntilExit];

    NSString *sourceLine = [[MMmmmmDiagnostic alloc] initWithBundle:self.bundle].bashProfileSourceLine;
    NSMutableString *bashProfile = @"~/.bash_profile".read.strip.mutableCopy;

    if (![bashProfile.lines containsObject:sourceLine])
        [[[@"~/.bash_profile" append:@"\n\n"] append:sourceLine] append:@"\n"];

    [@"/usr/bin/killall Terminal" exec];
}

- (void)deactivate {
    NSString *sourceLine = [[MMmmmmDiagnostic alloc] initWithBundle:self.bundle].bashProfileSourceLine;
    NSMutableString *bashProfile = @"~/.bash_profile".read.strip.mutableCopy;
    NSMutableArray *lines = bashProfile.lines.mutableCopy;

    NSUInteger ii = [lines indexOfObject:sourceLine];
    if (ii != NSNotFound) {
        [lines removeObjectAtIndex:ii];
        id path = [@"~/.bash_profile" stringByExpandingTildeInPath];
        id text = [lines componentsJoinedByString:@"\n"].strip;
        [text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (IBAction)onSwitchToggled {
    if (bigSwitch.state == NSOnState)
        [self activate];
    else
        [self deactivate];

    [self check];
}

@end
