
#import "Chat.h"

@implementation Chat


@synthesize chatId;
@synthesize fromPhone;
@synthesize toPhone;
@synthesize contentType;

@synthesize chatText;
@synthesize chatVideo;
@synthesize chatTime;
@synthesize mergedVideo;


-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        self.chatId = 0;
        self.fromPhone = 0;
        self.toPhone = 0;
        self.contentType = 0;

        self.chatText = @"";
        self.chatVideo = @"";
        self.chatTime = @"";
        self.mergedVideo =@"";

    }
    return self;
}


@end
