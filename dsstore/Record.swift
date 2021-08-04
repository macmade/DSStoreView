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

@objc public class Record: NSObject
{
    @objc public private( set ) dynamic var name:     String
    @objc public private( set ) dynamic var type:     UInt32
    @objc public private( set ) dynamic var dataType: String
    @objc public private( set ) dynamic var value:    Any?
    
    public init( stream: BinaryStream ) throws
    {
        let nameLength = try stream.readUInt32( endianness: .big )
        
        guard let name = try stream.readString( length: size_t( nameLength * 2 ), encoding: .utf16 ) else
        {
            throw Error( message: "Invalid record name" )
        }
        
        self.name = name
        self.type = try stream.readUInt32( endianness: .big )
        
        guard let dataType = try stream.readString( length: 4, encoding: .utf8 ) else
        {
            throw Error( message: "Invalid record data-type" )
        }
        
        self.dataType = dataType
        
        if self.dataType == "bool"
        {
            self.value = try stream.readUInt8() == 1
        }
        else if self.dataType == "long"
        {
            self.value = try stream.readInt32( endianness: .big )
        }
        else if self.dataType == "shor"
        {
            self.value = try stream.readInt32( endianness: .big )
        }
        else if self.dataType == "type"
        {
            self.value = try stream.readUInt32( endianness: .big )
        }
        else if self.dataType == "comp"
        {
            self.value = try stream.readInt64( endianness: .big )
        }
        else if self.dataType == "dutc"
        {
            let ts     = try stream.readInt64( endianness: .big )
            self.value = Date( timeIntervalSinceReferenceDate: Double( ts ) )
        }
        else if self.dataType == "blob"
        {
            let length = try stream.readUInt32( endianness: .big )
            self.value = Data( try stream.read( size: size_t( length ) ) )
        }
        else if self.dataType == "ustr"
        {
            let length = try stream.readUInt32( endianness: .big )
            self.value = try stream.readString( length: size_t( length * 2 ), encoding: .utf16 )
        }
        else
        {
            throw Error( message: "Unknown record data-type" )
        }
    }
}
