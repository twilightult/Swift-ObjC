#import "MCMemoryProbe.h"
#import <os/proc.h>
@implementation MCMemoryProbe
+ (NSInteger)availableBytes {
    return (NSInteger)os_proc_available_memory();
}
@end
