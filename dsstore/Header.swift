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

@objc public class Header: NSObject
{
    @objc public private( set ) dynamic var alignement: UInt32
    @objc public private( set ) dynamic var magic:      UInt32
    @objc public private( set ) dynamic var offset1:    UInt32
    @objc public private( set ) dynamic var size:       UInt32
    @objc public private( set ) dynamic var offset2:    UInt32
    
    public init( stream: BinaryStream ) throws
    {
        try stream.seek( offset: 0, from: .begin )
        
        self.alignement = try stream.readUInt32( endianness: .big )
        self.magic      = try stream.readUInt32( endianness: .big )
        self.offset1    = try stream.readUInt32( endianness: .big )
        self.size       = try stream.readUInt32( endianness: .big )
        self.offset2    = try stream.readUInt32( endianness: .big )
        
        guard self.alignement == 0x01, self.magic == 0x42756431 else
        {
            throw Error( message: "Invalid header magic bytes" )
        }
        
        guard self.offset1 == self.offset2, self.offset1 > 0 else
        {
            throw Error( message: "Invalid allocator offset" )
        }
        
        guard self.size > 0 else
        {
            throw Error( message: "Invalid allocator size" )
        }
    }
}
