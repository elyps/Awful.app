//  HTMLPreprocessedInputStream.m
//
//  Public domain. https://github.com/nolanw/HTMLReader

#import "HTMLPreprocessedInputStream.h"
#import "HTMLString.h"

@implementation HTMLPreprocessedInputStream
{
    NSUInteger _scanLocation;
    CFStringInlineBuffer _buffer;
    BOOL _reconsume;
    UTF32Char _currentInputCharacter;
}

- (id)initWithString:(NSString *)string
{
    self = [super init];
    if (!self) return nil;
    _string = [string copy];
    CFStringInitInlineBuffer((__bridge CFStringRef)_string, &_buffer, CFRangeMake(0, _string.length));
    return self;
}

- (BOOL)consumeString:(NSString *)string matchingCase:(BOOL)caseSensitive
{
    NSScanner *scanner = [self unprocessedScanner];
    scanner.caseSensitive = caseSensitive;
    BOOL ok = [scanner scanString:string intoString:nil];
    if (ok) {
        _scanLocation = scanner.scanLocation;
    }
    return ok;
}

- (NSString *)consumeCharactersUpToFirstPassingTest:(BOOL(^)(UTF32Char character))test
{
    NSMutableString *consumed = [NSMutableString new];
    for (;;) {
        UTF32Char c = [self consumeNextInputCharacter];
        if (c == (UTF32Char)EOF) break;
        if (test(c)) {
            [self reconsumeCurrentInputCharacter];
            break;
        }
        AppendLongCharacter(consumed, c);
    }
    if (consumed.length > 0) {
        return consumed;
    } else {
        return nil;
    }
}

- (BOOL)consumeHexInt:(out unsigned int *)number
{
    // NSScanner's -scanHexInt: allows for a leading "0x" or "0X", while the HTML spec does not.
    NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"];
    BOOL justHexDigits = [[self unprocessedScanner] scanCharactersFromSet:hexSet intoString:nil];
    if (!justHexDigits) return NO;
    NSScanner *scanner = [self unprocessedScanner];
    BOOL ok = [scanner scanHexInt:number];
    if (ok) {
        _scanLocation = scanner.scanLocation;
    }
    return ok;
}

- (BOOL)consumeUnsignedInt:(out unsigned int *)number
{
    NSScanner *scanner = [self unprocessedScanner];
    unsigned long long bigNumber;
    BOOL ok = [scanner scanUnsignedLongLong:&bigNumber];
    if (!ok) return NO;
    _scanLocation = scanner.scanLocation;
    if (number) {
        if (bigNumber > UINT_MAX) {
            *number = UINT_MAX;
        } else {
            *number = (unsigned int)bigNumber;
        }
    }
    return ok;
}

- (NSScanner *)unprocessedScanner
{
    NSScanner *scanner = [NSScanner scannerWithString:_string];
    scanner.charactersToBeSkipped = nil;
    scanner.scanLocation = _scanLocation;
    return scanner;
}

- (UTF32Char)nextInputCharacter
{
    return [self nextInputCharacterAndConsume:NO];
}

- (UTF32Char)consumeNextInputCharacter
{
    return [self nextInputCharacterAndConsume:YES];
}

- (UTF32Char)nextInputCharacterAndConsume:(BOOL)consume
{
    if (_reconsume) {
        if (consume) {
            _reconsume = NO;
        }
        return _currentInputCharacter;
    }
    NSUInteger advance = 0;
    UTF32Char c = CFStringGetCharacterFromInlineBuffer(&_buffer, _scanLocation + advance);
    if (c == 0 && _scanLocation + advance >= _string.length) {
        c = EOF;
    } else {
        advance++;
    }
    if (CFStringIsSurrogateHighCharacter(c)) {
        unichar low = CFStringGetCharacterFromInlineBuffer(&_buffer, _scanLocation + advance);
        if (CFStringIsSurrogateLowCharacter(low)) {
            advance++;
            unichar high = c;
            c = CFStringGetLongCharacterForSurrogatePair(high, low);
        } else {
            if (self.errorBlock) {
                self.errorBlock(@"Isolated lead surrogate");
            }
            // SPEC The spec does not say to emit a replacement character here. We'll do so anyway because of html5lib-tests.
            c = 0xFFFD;
        }
    } else if (CFStringIsSurrogateLowCharacter(c)) {
        if (self.errorBlock) {
            self.errorBlock(@"Isloated trail surrogate");
        }
        // SPEC The spec does not say to emit a replacement character here. We'll do so anyway because of html5lib-tests.
        c = 0xFFFD;
    } else if (c == '\r') {
        c = '\n';
        if (CFStringGetCharacterFromInlineBuffer(&_buffer, _scanLocation + advance) == '\n') {
            advance++;
        }
    }
    if (is_undefined_or_disallowed(c)) {
        if (self.errorBlock) {
            self.errorBlock(@"Noncharacter or disallowed control character");
        }
    }
    if (consume) {
        _scanLocation += advance;
        _currentInputCharacter = c;
    }
    return c;
}

- (NSString *)nextUnprocessedCharactersWithMaximumLength:(NSUInteger)length
{
    NSRange range = NSMakeRange(_scanLocation, length);
    if (NSMaxRange(range) > _string.length) {
        range.length = _string.length - range.location;
    }
    if (range.length > 0) {
        return [_string substringWithRange:range];
    } else {
        return nil;
    }
}

- (void)reconsumeCurrentInputCharacter
{
    _reconsume = YES;
}

- (void)unconsumeInputCharacters:(NSUInteger)numberOfCharactersToUnconsume
{
    // TODO skip over ignored carriage returns
    // TODO skip over surrogate second halves
    // TODO bounds checking
    // TODO consider reconsume
    _scanLocation -= numberOfCharactersToUnconsume;
}

@end
