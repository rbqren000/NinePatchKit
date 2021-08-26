//
//  NPPngModel.m
//  Test
//
//  Created by Theo on 2021/7/9.
//

#import "NPPngModel.h"
#import "NSData+BytesUtils.h"
#import "NPPngNptcChunkModel.h"



@interface NPPngModel()

@property (nonatomic, strong, readwrite) NSArray<NPPngChunkModel *> * chunkList;
@property (nonatomic, assign, readwrite) BOOL isNinePatch;
@property (nonatomic, strong, readwrite) NSData * pngData;

@end

@implementation NPPngModel

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        self.pngData = data;
        [self analyzeWithData:data];
    }
    return self;
}

+ (BOOL)isPngFile:(NSData * )data {
    NSRange range = NSMakeRange(0, kPngSingnatureLen);
    NSString * headStr = [data hexStrWithRange:range];
    return [headStr isEqualToString:@"89504e470d0a1a0a"];
}


#pragma mark - Private Methods
- (void)analyzeWithData:(NSData *)data {
    
    if (![NPPngModel isPngFile:data]) {
        return;
    }
    
    // Png数据由 文件署名(8 bytes) + 多个数据块组成
    // 每个数据块Chunk由 Length(chunk data长度 4 bytes) + Chunk Type Code(4 bytes) + Chunk Data + CRC(循环冗余检测 4 bytes) 组成
    NSMutableArray * chunkList = [NSMutableArray array];
    NSInteger beginIndex = kPngSingnatureLen;
    NSInteger dataLen = data.length;
    while (YES) {
        
        NPPngChunkModel * model = nil;
        NSString * typeCode = [NPPngChunkModel codeTypeWithData:data beginIndex:beginIndex];
        if ([typeCode isEqualToString:npTcTypeCode]) {
            model = [[NPPngNptcChunkModel alloc] initWithData:data beginIndex:beginIndex];
            self.isNinePatch = YES;
        } else {
            model = [[NPPngChunkModel alloc] initWithData:data beginIndex:beginIndex];
        }
        
        [chunkList addObject:model];
        beginIndex += model.totalLength;
        if (beginIndex >= dataLen) {
            break;
        }
    }
       
    self.chunkList = chunkList;
}

@end