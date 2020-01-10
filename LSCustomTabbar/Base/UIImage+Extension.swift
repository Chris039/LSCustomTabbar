//
//  UIImage+Extension.swift
//  RabbitBuy
//
//  Created by 菜小兔 on 2019/6/11.
//  Copyright © 2019 菅帅博. All rights reserved.
//

import Foundation
import UIKit


//水印位置枚举
enum WaterMarkCorner {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
}

extension UIImage {
    
    class func getImageWithColor(_ color: UIColor, _ height: CGFloat) -> UIImage? {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    // 生成条形码
    class func creat_barCode(content: String?, size: CGSize) -> UIImage? {
        
        // iOS 8.0以上的系统才支持条形码的生成，iOS8.0以下需要使用第三方控件生成
        if #available(iOS 8.0, *) {
            // 注意生成条形码的编码方式
            let data = content?.data(using: String.Encoding.ascii, allowLossyConversion: false)
            let filter = CIFilter(name: "CICode128BarcodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue(NSNumber(value: 0), forKey: "inputQuietSpace")
            let outputImage = filter?.outputImage
            // 创建一个颜色滤镜,黑白色
            let colorFilter = CIFilter(name: "CIFalseColor")!
            colorFilter.setDefaults()
            colorFilter.setValue(outputImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
            colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1, alpha: 0), forKey: "inputColor1")
            // 返回条形码image
            let codeImage = UIImage(ciImage: (colorFilter.outputImage!.transformed(by: CGAffineTransform(scaleX: 10, y: 10))))
            return self.scaleImage(image: codeImage, size: size, orientation: .left)
        }else {
            return nil
        }
        
    }
    
    
    class func creat_QR_Code(content: String?, size: CGSize) -> UIImage? {
        // iOS 8.0以上的系统才支持条形码的生成，iOS8.0以下需要使用第三方控件生成
        if #available(iOS 8.0, *) {
            // 注意生成条形码的编码方式
            let data = content!.data(using: String.Encoding.ascii)
            guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
            
            return self.scaleImage(image: UIImage(ciImage: output), size: size, orientation: .left)
        }else {
            return nil
        }
    }
    
    
    class func scaleImage(image: UIImage, size: CGSize, orientation: Orientation? = nil) -> UIImage {
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let newOrientation = orientation {
            let newImage = UIImage.init(cgImage: scaleImage!.cgImage!, scale: scaleImage!.scale, orientation: newOrientation)
            return newImage
        } else {
            return scaleImage!
        }
    }
    
    
    func waterMarkedImage(waterMarkImage: UIImage, corner: WaterMarkCorner = .BottomRight,
                          margin: CGPoint = CGPoint(x: 20, y: 20), alpha: CGFloat = 1) -> UIImage {
        
        var markFrame = CGRect(x: 0, y: 0, width: waterMarkImage.size.width, height: waterMarkImage.size.height)
        let imageSize = self.size
        
        switch corner {
        case.TopLeft:
            markFrame.origin = margin
        case.TopRight:
            markFrame.origin = CGPoint(x: imageSize.width - waterMarkImage.size.width - margin.x, y: margin.y)
        case.BottomLeft:
            markFrame.origin = CGPoint(x: margin.x, y: imageSize.height - waterMarkImage.size.height - margin.y)
        case.BottomRight:
            markFrame.origin = CGPoint(x: imageSize.width - waterMarkImage.size.width - margin.x, y: imageSize.height - waterMarkImage.size.height - margin.y)
        }
        
        // 开始给图片添加图片
        UIGraphicsBeginImageContext(imageSize)
        self.draw( in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        waterMarkImage.draw( in: markFrame, blendMode: .normal, alpha: alpha)
        let waterMarkedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return waterMarkedImage!
    }
    
    
    //添加水印方法
    func waterMarkedText(waterMarkText:String, corner: WaterMarkCorner = .BottomRight, margin:CGPoint = CGPoint(x: 20, y: 20), waterMarkTextColor: UIColor = UIColor.white, waterMarkTextFont: UIFont = UIFont.systemFont(ofSize: 20), backgroundColor: UIColor = UIColor.clear, strikeStyle: NSNumber = NSNumber(value: 0)) -> UIImage {
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: waterMarkTextColor, NSAttributedString.Key.font: waterMarkTextFont, NSAttributedString.Key.backgroundColor: backgroundColor, NSAttributedString.Key.strikethroughStyle: strikeStyle]
        let textSize = NSString(string: waterMarkText).size(withAttributes: textAttributes)
        var textFrame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
        
        let imageSize = self.size
        switch corner {
        case .TopLeft:
            textFrame.origin = margin
        case .TopRight:
            textFrame.origin = CGPoint(x: imageSize.width - textSize.width - margin.x, y: margin.y)
        case .BottomLeft:
            textFrame.origin = CGPoint(x: margin.x, y: imageSize.height - textSize.height - margin.y)
        case .BottomRight:
            textFrame.origin = CGPoint(x: imageSize.width - textSize.width - margin.x, y: imageSize.height - textSize.height - margin.y)
        }
        
        // 开始给图片添加文字水印
        UIGraphicsBeginImageContext(imageSize)
        self.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        NSString(string: waterMarkText).draw(in: textFrame, withAttributes: textAttributes)
        
        
        let waterMarkedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return waterMarkedImage
    }
    
}
