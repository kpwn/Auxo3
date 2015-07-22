#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#define kPackageIdentifier @"com.a3tweaks.auxo3"
#define kPackageVersion @"1.1"

typedef struct OSObject * io_object_t;
typedef io_object_t io_service_t;
typedef io_object_t io_registry_entry_t;
typedef UInt32 IOOptionBits;

#ifdef __cplusplus
extern "C" {
#endif
	mach_port_t kIOMasterPortDefault;
    CFMutableDictionaryRef IOServiceMatching(const char *name);
    io_service_t IOServiceGetMatchingService(mach_port_t masterPort, CFDictionaryRef matching);
    CFTypeRef IORegistryEntryCreateCFProperty(io_registry_entry_t entry, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options);
    kern_return_t IORegistryEntryCreateCFProperties(io_registry_entry_t entry, CFMutableDictionaryRef * properties, CFAllocatorRef allocator, IOOptionBits options);
    kern_return_t IOObjectRelease(io_object_t object);
#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
extern "C" {
#endif
    int xpc_connection_get_pid(id connection);
    CFPropertyListRef MGCopyAnswer(CFStringRef property);
#ifdef __cplusplus
}
#endif

__attribute__((always_inline))
static inline NSString *getMD5(const void *data, NSUInteger length)
{
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    CC_MD5((const uint8_t *)data, (CC_LONG)length, hash);
    return [NSString stringWithFormat:
        @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
        hash[0], hash[1], hash[2], hash[3], 
        hash[4], hash[5], hash[6], hash[7],
        hash[8], hash[9], hash[10], hash[11],
        hash[12], hash[13], hash[14], hash[15]
    ];
}

__attribute__((always_inline))
static inline NSData *getBase64(const void *data, NSUInteger length)
{
    static const char Base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    NSMutableData *outputData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)outputData.mutableBytes;
    for (NSUInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & ((const uint8_t *)data)[j]);
            }
        }
        NSInteger index = (i / 3) * 4;
        output[index + 0] = Base64EncodingTable[(value >> 18) & 0x3F];
        output[index + 1] = Base64EncodingTable[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? Base64EncodingTable[(value >> 6) & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? Base64EncodingTable[(value >> 0) & 0x3F] : '=';
    }
    return outputData;
}

__attribute__((always_inline))
static inline BOOL checkLicense(NSArray *license)
{
    NSString *serial = license.firstObject;
    NSString *nonce = license.lastObject;
    if (serial.length != 33) {
    	return NO;
    }
    NSString *result = [serial substringToIndex:1];
    NSString *signature = [serial substringFromIndex:1];
    NSData *data = [[NSString stringWithFormat:@"%@%@%@", nonce, @"rkQhttN0cM2vS9aL", result]dataUsingEncoding:NSUTF8StringEncoding];
    NSString *verification = getMD5(data.bytes, data.length).uppercaseString;
    if ([signature isEqualToString:verification]) {
    	return [result isEqualToString:@"1"];
    } else {
    	return NO;
    }
}

__attribute__((always_inline))
static inline BOOL downloadLicense(NSArray **license)
{
	NSString *udid = CFBridgingRelease(MGCopyAnswer(CFSTR("UniqueDeviceID")));
    NSString *device = CFBridgingRelease(MGCopyAnswer(CFSTR("ProductType")));
    NSString *firmware = CFBridgingRelease(MGCopyAnswer(CFSTR("ProductVersion")));
    NSString *nonce = @([NSDate date].timeIntervalSinceReferenceDate).stringValue;
   	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://cydia.a3tweaks.com/api/v2/check.php?urluuid=%@&product_name=%@&device_name=%@&firmware_version=%@&version=%@&check=%@", udid, kPackageIdentifier, device, firmware, kPackageVersion, nonce]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    NSHTTPURLResponse *reponse = nil;
    NSString *serial = [[NSString alloc]initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&reponse error:nil] encoding:NSUTF8StringEncoding];
    if (reponse.statusCode == 200 && serial.length == 33) {
        *license = @[serial, nonce];
        return YES;
    } else {
        *license = nil;
        return NO;
    }
}
