#import "StringDetectorTest.h"

#define INPUT_SEGMENT_LENGTH 10

@implementation StringDetectorTest

- (void)setUp {
    matchCount = 0;
    prefixCount = 0;
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"KurtStory" ofType:@"txt"];
    kurtStory = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    stringDetector = [[PDFKStringDetector alloc] initWithKeyword:@"Kurt"];
    [stringDetector setDelegate:self];
}

- (void)appendString:(NSString *)string {
    int position = 0;
    while (position < kurtStory.length) {
        NSRange range = NSMakeRange(position, MIN(INPUT_SEGMENT_LENGTH, kurtStory.length - position));
        [stringDetector appendUnicodeString:[kurtStory substringWithRange:range]];
        position = NSMaxRange(range);
    }
}

- (void)testDetectStrings {
    [self appendString:kurtStory];
    XCTAssertEqual(matchCount, 6, @"incorrect number of matches");
    XCTAssertEqual(prefixCount, 11, @"incorrect number of prefixes matched");
}

- (void)testIgnorePrefixes {
    [stringDetector appendUnicodeString:@"KuKuKu"];
    XCTAssertEqual(prefixCount, 3, @"incorrect number of prefixes matched");

    [stringDetector appendUnicodeString:@"KuKurtKurt"];
    XCTAssertEqual(matchCount, 2, @"incorrect number of matches");
}

- (void)testNoMatch {
    [stringDetector setKeyword:@"foobar"];
    [self appendString:kurtStory];
    XCTAssertEqual(matchCount, 0, @"matches found");
}

- (void)detectorDidStartMatching:(PDFKStringDetector *)stringDetector {
    prefixCount++;
}

- (void)detectorFoundString:(PDFKStringDetector *)detector {
    matchCount++;
}


@end
