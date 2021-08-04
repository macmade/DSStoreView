/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation
import DSStore

@objc( RecordValue )
public class RecordValue: ValueTransformer
{
    public override class func transformedValueClass() -> AnyClass
    {
        NSString.self
    }
    
    public override class func allowsReverseTransformation() -> Bool
    {
        false
    }
    
    public override func transformedValue( _ value: Any? ) -> Any?
    {
        guard let record = value as? Record else
        {
            return "--"
        }
        
        if record.dataType == .bool
        {
            return record.value as? Bool == true ? "True" : "False"
        }
        else if record.dataType == .long
        {
            return "\( record.value as? Int32 ?? 0 )"
        }
        else if record.dataType == .shor
        {
            return "\( record.value as? Int32 ?? 0 )"
        }
        else if record.dataType == .comp
        {
            return "\( record.value as? Int32 ?? 0 )"
        }
        else if record.dataType == .ustr
        {
            return record.value as? String ?? "--"
        }
        else if record.dataType == .type
        {
            guard let type = record.value as? UInt32 else
            {
                return "--"
            }
            
            let c1 = type >> 24 & 0xFF
            let c2 = type >> 16 & 0xFF
            let c3 = type >>  8 & 0xFF
            let c4 = type >>  0 & 0xFF
            
            return String(
                format: "%c%c%c%c",
                isprint( Int32( c1 ) ) == 1 ? c1 : ".",
                isprint( Int32( c2 ) ) == 1 ? c2 : ".",
                isprint( Int32( c3 ) ) == 1 ? c3 : ".",
                isprint( Int32( c4 ) ) == 1 ? c4 : "."
            )
        }
        else if record.dataType == .blob
        {
            guard let data = record.value as? Data else
            {
                return "--"
            }
            
            if data.count == 0
            {
                return "0 bytes"
            }
            
            var str   = "\( data.count ) bytes: "
            let bytes = data.prefix( 64 )
            
            bytes.forEach { str.append( String( format: "%02X", $0 ) ) }
            
            return str
        }
        else if record.dataType == .dutc
        {
            guard let date = record.value as? Date else
            {
                return "--"
            }
            
            return ISO8601DateFormatter().string( from: date )
        }
        
        return "--"
    }
}
