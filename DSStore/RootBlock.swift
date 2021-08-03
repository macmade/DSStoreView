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

public class RootBlock
{
    public private( set ) var offsets = [ UInt32 ]()
    public private( set ) var tables  = [ ( name: String, value: UInt32 ) ]()
    
    public init( stream: BinaryStream, offset: size_t, size: size_t ) throws
    {
        try stream.seek( offset: offset + 4, from: .begin )
        
        let offsetCount = try stream.readUInt32( endianness: .big )
        
        try stream.seek( offset: 4, from: .current )
        
        for _ in 0 ..< offsetCount
        {
            self.offsets.append( try stream.readUInt32( endianness: .big ) )
        }
        
        let pos       = stream.tell()
        let tocOffset = pos + ( -pos & 1023 ) + 12
        
        try stream.seek( offset: tocOffset, from: .begin )
        
        let tocCount = try stream.readUInt32( endianness: .big )
        
        for _ in 0 ..< tocCount
        {
            let name  = try stream.readString( length: size_t( try stream.readUInt8() ), encoding: .utf8 ) ?? ""
            let value = try stream.readUInt32( endianness: .big )
            
            self.tables.append( ( name: name, value: value ) )
        }
    }
}
