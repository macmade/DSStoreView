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

public class Record
{
    public private( set ) var name:     String
    public private( set ) var type:     UInt32
    public private( set ) var dataType: String
    public private( set ) var data:     Data
    
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
            self.data = Data( try stream.read( size: 1 ) )
        }
        else if self.dataType == "long"
        {
            self.data = Data( try stream.read( size: 4 ) )
        }
        else if self.dataType == "shor"
        {
            self.data = Data( try stream.read( size: 4 ) )
        }
        else if self.dataType == "type"
        {
            self.data = Data( try stream.read( size: 4 ) )
        }
        else if self.dataType == "comp"
        {
            self.data = Data( try stream.read( size: 8 ) )
        }
        else if self.dataType == "dutc"
        {
            self.data = Data( try stream.read( size: 8 ) )
        }
        else if self.dataType == "blob"
        {
            let length = try stream.readUInt32( endianness: .big )
            self.data  = Data( try stream.read( size: size_t( length ) ) )
        }
        else if self.dataType == "ustr"
        {
            let length = try stream.readUInt32( endianness: .big )
            self.data  = Data( try stream.read( size: size_t( length * 2 ) ) )
        }
        else
        {
            throw Error( message: "Unknown record data-type" )
        }
    }
}
