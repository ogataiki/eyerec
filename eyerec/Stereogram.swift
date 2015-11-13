import UIKit
import CoreGraphics

private let d_t: UInt8 = 72;
private let d_u: UInt8 = 214;

class Stereogram
{
    enum ColorPattern: Int {
        case p1
        case p2
        case p3
        case p4
        case random1
    }
    
    struct OPT {
        var origImage: UIImage!
        var depthImage: UIImage!
        var colorPattern: ColorPattern = .p1
    };
    
    func generateStereogramImage(origImage: UIImage, depthImage: UIImage, colorPattern: ColorPattern = .p1)
        -> UIImage?
    {
        let data = generatePixelData(OPT(origImage: origImage, depthImage: depthImage, colorPattern: colorPattern));
        //print("out data w,h,c,len:\(data.width),\(data.height),\(data.colorSize),\(data.data.count)");
        
        let cgImage = origImage.CGImage;
        
        let origAlphaInfo = CGImageGetAlphaInfo(cgImage);
        let origBitmapInfo = CGImageGetBitmapInfo(cgImage);
        let origColorSpace = CGImageGetColorSpace(cgImage);
        print("origAlphaInfo:\(origAlphaInfo.rawValue)");
        print("origBitmapInfo:\(origBitmapInfo.rawValue)");
        print("origColorSpace:\(origColorSpace)");

        // こっちだとイメージ作り終わるまでインスタンスが保持できないっぽい
        //let provider = CGDataProviderCreateWithData(nil, data.data, data.data.count, nil);
        let nsdata = NSData(bytes: data.data, length: data.data.count);
        let provider = CGDataProviderCreateWithCFData(nsdata);
        let bitsPerComponent: Int = 8;
        let bitsPerPixel: Int = bitsPerComponent * data.colorSize;
        let bytesPerRow: Int = data.width * data.colorSize;
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        let bitmapInfo = CGBitmapInfo.ByteOrderDefault; // CGBitmapInfo(rawValue: origAlphaInfo.rawValue);
        let renderingIntent = CGColorRenderingIntent.RenderingIntentDefault;
        print("colorSpaceRef:\(colorSpaceRef)");
        print("bitmapInfo:\(bitmapInfo.rawValue)");
        print("renderingIntent:\(renderingIntent.rawValue)");

        let outImage = CGImageCreate(data.width, data.height
            , bitsPerComponent
            , bitsPerPixel
            , bytesPerRow
            , colorSpaceRef
            , bitmapInfo
            , provider
            , nil
            , false
            , renderingIntent);
        if let cg = outImage {
            return UIImage(CGImage: cg);
        }
        return nil;
    }
    
    func generatePixelData(opts: OPT) -> (data: [UInt8], width: Int, height: Int, colorSize: Int) {
    
        let origcgImage = opts.origImage.CGImage;
        let cgImage = opts.depthImage.CGImage;

        let origAlphaInfo = CGImageGetAlphaInfo(origcgImage);
        let alphaInfo = CGImageGetAlphaInfo(cgImage);

        var outCol: (r: Int, g: Int, b: Int, a: Int) = (r: 0, g:1, b:2, a:3);
        
        let origColorSize: Int;
        let origCol: (r: Int, g: Int, b: Int, a: Int);
        switch origAlphaInfo {
        case .Last:                 // RGBA
            print("origAlphaInfo.Last");
            fallthrough;
        case .PremultipliedLast:    // RGBA
            print("origAlphaInfo.PremultipliedLast");
            origCol = (r: 3, g:2, b:1, a:0);
            origColorSize = 4;
            break;
            
        case .First:                // ARGB
            print("origAlphaInfo.First");
            fallthrough;
        case .PremultipliedFirst:   // ARGB
            print("origAlphaInfo.PremultipliedFirst");
            origCol = (r: 2, g:1, b:0, a:3);
            origColorSize = 4;
            break;
            
        default:    // non alpha channel
            print("origAlphaInfo.Other");
            outCol = (r: 0, g:1, b:2, a:-1);
            origCol = (r: 2, g:1, b:0, a:-1);
            origColorSize = 3;
            break;
        }
        
        // GPUImage処理後のカラー配列は端末のエンディアンに置き換わってるぽい
        let byteOrder = CFByteOrderGetCurrent();
        print("byteOrder:\(byteOrder)");
        
        let colorSize: Int;
        let col: (r: Int, g: Int, b: Int, a: Int);
        switch alphaInfo {
        case .Last:                 // RGBA
            print("alphaInfo.Last");
            fallthrough;
        case .PremultipliedLast:    // RGBA
            print("alphaInfo.PremultipliedLast");
            col = (r: 3, g:2, b:1, a:0);
            colorSize = 4;
            break;
            
        case .First:                // ARGB
            print("alphaInfo.First");
            fallthrough;
        case .PremultipliedFirst:   // ARGB
            print("alphaInfo.PremultipliedFirst");
            col = (r: 2, g:1, b:0, a:3);
            colorSize = 4;
            break;
            
        default:    // non alpha channel
            print("alphaInfo.Other");
            col = (r: 0, g:1, b:2, a:-1);
            colorSize = 3;
            break;
        }

        
        let origImageData = CGDataProviderCopyData(CGImageGetDataProvider(origcgImage));
        let origSource : UnsafePointer = CFDataGetBytePtr(origImageData);
        
        let imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
        let source : UnsafePointer = CFDataGetBytePtr(imageData);

        let width = Int(opts.origImage.size.width);
        let height = Int(opts.origImage.size.height);
        //let inSize = width * height * colorSize;
        
        // ずらし幅はランダムカラーの時は分かりづらくなるので強めにする
        let rzure: Int;
        if  opts.colorPattern == ColorPattern.p1 ||
            opts.colorPattern == ColorPattern.p2
        {
            rzure = (width <= 100) ? 1 : width / 50;
        }
        else {
            rzure = (width <= 100) ? 1 : width / 80;
        }

        // 上、左、中央、右、下に余白をとって画像の崩れを予防
        let margin: Int = rzure*2;
        
        // 左右に同じ画像を配置するため2倍の幅をとる
        let maxWidth = Int(width*2) + (margin*2);       // 作成される画像の幅
        let maxHeight = Int(height) + (margin*2);       // 作成される画像の高さ
        let outSize = maxWidth * maxHeight * origColorSize;
        
        print("size:\(width),\(height), maxSize:\(maxWidth),\(maxHeight), outSize:\(outSize)");

        
        var out: [UInt8] = Array(count: outSize, repeatedValue: 0);
        
        let offset = margin * maxWidth + margin;     // 左画像の左上位置
        let pairpos = width;                // 隣の対応する点までの距離
        var pos: Int = 0;                   // 操作点
        
        let colors: [(r: UInt8, g: UInt8, b: UInt8)] = [
            (r: 255, g: 128, b: 128),
            (r: 128, g: 255, b: 128),
            (r: 128, g: 128, b: 255),
            (r: 255, g: 255, b: 128),
            (r: 255, g: 128, b: 255),
            (r: 128, g: 255, b: 255)
        ];
        
        // 背景作成
        for var y: Int = 0; y < height; y++ {
            for var x: Int = 0; x < width; x++ {

                let sourcePos = y * width + x;
                
                pos = offset + y * maxWidth + x;
                
                //print("sourcePos:\(sourcePos), pos:\(pos)");
                
                if opts.colorPattern == ColorPattern.random1 {
                    let color = colors[Int(arc4random()) % colors.count];
                    out[pos * origColorSize + outCol.r] = color.r;
                    out[pos * origColorSize + outCol.g] = color.g;
                    out[pos * origColorSize + outCol.b] = color.b;
                }
                else {
                    out[pos * origColorSize + outCol.r] = origSource[sourcePos * origColorSize + origCol.r];
                    out[pos * origColorSize + outCol.g] = origSource[sourcePos * origColorSize + origCol.g];
                    out[pos * origColorSize + outCol.b] = origSource[sourcePos * origColorSize + origCol.b];
                }
                out[(pairpos + pos) * origColorSize + outCol.r] = out[pos * origColorSize + outCol.r];
                out[(pairpos + pos) * origColorSize + outCol.g] = out[pos * origColorSize + outCol.g];
                out[(pairpos + pos) * origColorSize + outCol.b] = out[pos * origColorSize + outCol.b];
                
                if origCol.a >= 0 {
                    if opts.colorPattern == ColorPattern.random1 {
                        out[pos * origColorSize + outCol.a] = UInt8(128 + arc4random() % 128);
                        out[(pairpos + pos) * origColorSize + outCol.a] = out[pos * origColorSize + outCol.a];
                    }
                    else {
                        out[pos * origColorSize + outCol.a] = origSource[sourcePos * origColorSize + origCol.a];
                        out[(pairpos + pos) * origColorSize + outCol.a] = out[pos * origColorSize + outCol.a];
                    }
                }
            }
        }
        
        // 浮き出る部分作成
        for var y: Int = 0; y < height; y++ {
            for var x: Int = 0; x < width; x++ {
                
                let sourcePos = y * width + x;
                
                pos = offset + y * maxWidth + x;

                //print("sourcePos:\(sourcePos), pos:\(pos)");

                // 白い部分を浮き上がらせる
                //print("source[sourcePos * colorSize + col.r]:\(source[sourcePos * colorSize + col.r])");
                //print("source[sourcePos * colorSize + col.g]:\(source[sourcePos * colorSize + col.g])");
                //print("source[sourcePos * colorSize + col.b]:\(source[sourcePos * colorSize + col.b])");
                let depth = getDepthMap(
                    (r:source[sourcePos * colorSize + col.r], g:source[sourcePos * colorSize + col.g], b:source[sourcePos * colorSize + col.b]),
                    zure: rzure, colorPattern: opts.colorPattern);
                if depth > 0 {
                    if opts.colorPattern == ColorPattern.random1 {
                        let color = colors[Int(arc4random()) % colors.count];
                        out[(pos + depth) * origColorSize + outCol.r] = color.r;
                        out[(pos + depth) * origColorSize + outCol.g] = color.g;
                        out[(pos + depth) * origColorSize + outCol.b] = color.b;
                        
                        out[(pairpos + pos - depth) * origColorSize + outCol.r] = out[(pos + depth) * origColorSize + outCol.r];
                        out[(pairpos + pos - depth) * origColorSize + outCol.g] = out[(pos + depth) * origColorSize + outCol.g];
                        out[(pairpos + pos - depth) * origColorSize + outCol.b] = out[(pos + depth) * origColorSize + outCol.b];
                    }
                    else {
                        out[(pos + depth) * origColorSize + outCol.r] = origSource[sourcePos * origColorSize + origCol.r];
                        out[(pos + depth) * origColorSize + outCol.g] = origSource[sourcePos * origColorSize + origCol.g];
                        out[(pos + depth) * origColorSize + outCol.b] = origSource[sourcePos * origColorSize + origCol.b];
                        
                        //out[(pairpos + pos - depth) * origColorSize + outCol.r] = out[(pos + depth) * origColorSize + outCol.r];
                        //out[(pairpos + pos - depth) * origColorSize + outCol.g] = out[(pos + depth) * origColorSize + outCol.g];
                        //out[(pairpos + pos - depth) * origColorSize + outCol.b] = out[(pos + depth) * origColorSize + outCol.b];
                        
                        if x >= depth {
                            out[pos * origColorSize + outCol.r] = origSource[(sourcePos - depth) * origColorSize + origCol.r];
                            out[pos * origColorSize + outCol.g] = origSource[(sourcePos - depth) * origColorSize + origCol.g];
                            out[pos * origColorSize + outCol.b] = origSource[(sourcePos - depth) * origColorSize + origCol.b];
                        }
                    }
                }
                
                if  opts.colorPattern == ColorPattern.p1 ||
                    opts.colorPattern == ColorPattern.p2
                {
                    if x < depth {
                        out[pos * origColorSize + outCol.r] = 0;
                        out[pos * origColorSize + outCol.g] = 0;
                        out[pos * origColorSize + outCol.b] = 0;
                    }
                }
            }
        }
        
        return (out, maxWidth, maxHeight, colorSize);
    }
    
    struct DepthRange {
        var r: (t: UInt8, u: UInt8) = (t: 255, u: 128);
        var g: (t: UInt8, u: UInt8) = (t: 255, u: 128);
        var b: (t: UInt8, u: UInt8) = (t: 255, u: 128);
    }
    struct DepthStrength {
        var range = DepthRange();
        var ratio: Int = 1;
    }
    var depth_p1: [DepthStrength] = [
        DepthStrength(range: DepthRange(r: (t: 255, u: d_u), g: (t: 255, u: d_u), b: (t: 255, u: d_u)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 255, u: d_u), g: (t: 255, u: d_u), b: (t: 128, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 128, u:   0), g: (t: 255, u: d_u), b: (t: 255, u: d_u)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 255, u: d_u), g: (t: 128, u:   0), b: (t: 255, u: d_u)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 255, u: d_u), g: (t: 128, u:   0), b: (t: 128, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 128, u:   0), g: (t: 255, u: d_u), b: (t: 128, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 128, u:   0), g: (t: 128, u:   0), b: (t: 255, u: d_u)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: d_t, u:   0), g: (t: d_t, u:   0), b: (t: 128, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 128, u:   0), g: (t: d_t, u:   0), b: (t: d_t, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: d_t, u:   0), g: (t: 128, u:   0), b: (t: d_t, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: d_t, u:   0), g: (t: 128, u:   0), b: (t: 128, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 128, u:   0), g: (t: d_t, u:   0), b: (t: 128, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 128, u:   0), g: (t: 128, u:   0), b: (t: d_t, u:   0)), ratio: 1)
    ];
    var depth_p2: [DepthStrength] = [
        DepthStrength(range: DepthRange(r: (t: d_t, u:   0), g: (t: d_t, u:   0), b: (t: d_t, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: d_t, u:   0), g: (t: d_t, u:   0), b: (t: 255, u: d_t)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 255, u: d_t), g: (t: d_t, u:   0), b: (t: d_t, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: d_t, u:   0), g: (t: 255, u: d_t), b: (t: d_t, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: d_t, u:   0), g: (t: 255, u: d_t), b: (t: 255, u: d_t)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 255, u: d_t), g: (t: d_t, u:   0), b: (t: 255, u: d_t)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 255, u: d_t), g: (t: 255, u: d_t), b: (t: d_t, u:   0)), ratio: 1)
    ];
    var depth_p3: [DepthStrength] = [
        DepthStrength(range: DepthRange(r: (t: 255, u: d_u), g: (t: 255, u: d_u), b: (t: d_u, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: d_u, u:   0), g: (t: 255, u: d_u), b: (t: 255, u: d_u)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 255, u: d_u), g: (t: d_u, u:   0), b: (t: 255, u: d_u)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: 255, u: d_u), g: (t: d_u, u:   0), b: (t: d_u, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: d_u, u:   0), g: (t: 255, u: d_u), b: (t: d_u, u:   0)), ratio: 1),
        DepthStrength(range: DepthRange(r: (t: d_u, u:   0), g: (t: d_u, u:   0), b: (t: 255, u: d_u)), ratio: 1)
    ];
    var depth_p4: [DepthStrength] = [
        DepthStrength(range: DepthRange(r: (t: d_u, u: d_t), g: (t: d_u, u: d_t), b: (t: d_u, u: d_t)), ratio: 1)
    ];
    func getDepthMap(color: (r: UInt8, g: UInt8, b: UInt8), zure: Int, colorPattern: ColorPattern = .p1) -> Int {
        var ret = 0;
        let depth: [DepthStrength];
        switch colorPattern {
        case .p1:
            depth = depth_p1;
        case .p2:
            depth = depth_p2;
        case .p3:
            depth = depth_p3;
        case .p4:
            depth = depth_p4;
        case .random1:
            depth = depth_p1;
        }
        for var i in 0 ..< depth.count {
            let d = depth[i];
            if  (color.r <= d.range.r.t && color.r >= d.range.r.u) &&
                (color.g <= d.range.g.t && color.g >= d.range.g.u) &&
                (color.b <= d.range.b.t && color.b >= d.range.b.u)
            {
                ret = zure * d.ratio;
                break;
            }
        }
        return ret;
    }
}
