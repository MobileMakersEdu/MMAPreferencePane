#import "main.h"


@implementation NSTask (MM)

+ (instancetype):(NSString *)parsable {
    NSArray *args = [parsable isKindOfClass:[NSArray class]] ? (id)parsable : parsable.split(@" ");

    NSTask *task = [self new];
    task.launchPath = args.firstObject;
    task.arguments = args.skip(1);
    return task;
}

@end
