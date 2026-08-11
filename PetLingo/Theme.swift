import SwiftUI

enum PLColor {
    static let primary=Color(red:0x5B/255,green:0x42/255,blue:0x96/255)
    static let background=Color(red:1.0,green:0xFB/255,blue:0xF3/255)
    static let purpleSoft=Color(red:0xEA/255,green:0xE1/255,blue:1.0)
    static let greenSoft=Color(red:0xE8/255,green:0xF2/255,blue:0xD9/255)
    static let pinkSoft=Color(red:1.0,green:0xE5/255,blue:0xE0/255)
    static let blueSoft=Color(red:0xE2/255,green:0xEF/255,blue:0xF9/255)
    static let yellowSoft=Color(red:1.0,green:0xF0/255,blue:0xD5/255)
}
extension View { func cardStyle(_ color:Color=Color(.secondarySystemBackground), radius:CGFloat=20)->some View { self.padding().background(color).clipShape(RoundedRectangle(cornerRadius:radius,style:.continuous)).shadow(color:.black.opacity(0.08),radius:4,y:2) } }
