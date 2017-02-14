//
//  ViewController.m
//  QRCodeiOSNative
//
//  Created by fanshengli on 16/4/1.
//  Copyright © 2016年 min. All rights reserved.
//
//  iOS 原生代码操作二维码

#import "ViewController.h"
#import <CoreImage/CoreImage.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 260, 260)];
    [self.view addSubview:iv];
    
    iv.image = [ViewController QRImageFromString:@"lalala,这是一个测试/啦啦啦/lalalalla"];
    NSLog(@"%@", [ViewController stringFromCiImage]);
}

//在解析指定image的时候，可以用 CIDetector（这个类还可以进行人脸识别等功能）来进行，主要解析的过程，代码比较简单，如下
+ (NSString *)stringFromCiImage {
    
    NSString *content = @"" ;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"qr_image.png" withExtension:nil];
    CIImage *ciimage = [CIImage imageWithContentsOfURL:url];
    
    if (!ciimage) {
        return content;
    }
    
    //[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @YES}]
    //CIDetectorTypeQRCode 在iOS8以后才能用
    CIDetector *detector = [CIDetector detectorOfType: CIDetectorTypeQRCode
                                              context: nil
                                              options: @{CIDetectorAccuracy: CIDetectorAccuracyHigh}];//高容错率
    
    NSArray *features = [detector featuresInImage:ciimage];
    
    NSLog(@"-- %lu", (unsigned long)features.count);
    if (features.count) {
        for (CIFeature *feature in features) {
            if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
                content = ((CIQRCodeFeature *)feature).messageString;
                break;
            }
        }
    } else {
        //貌似5s的8.1模拟器也不能解析
        NSLog(@"未正常解析二维码图片, 请确保iphone5s及以上的设备");
    }
    
    return content;
}

// 生成不带图片的二维码
+ (UIImage *)QRImageFromString:(NSString *)text {
    
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    UIColor *onColor = [UIColor blackColor];
    UIColor *offColor = [UIColor whiteColor];
    
    //上色, 如果只是黑白色，这一步就不用了
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    
    //绘制
    CGSize size = CGSizeMake(300, 300);
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return codeImage;
}

@end
