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

@objc public class Block: NSObject
{
    @objc public private( set ) dynamic var id:       UInt32
    @objc public private( set ) dynamic var mode:     UInt32
    @objc public private( set ) dynamic var children: [ Block ]  = []
    @objc public private( set ) dynamic var records:  [ Record ] = []
    
    public init( stream: BinaryStream, id: UInt32, allocator: Allocator ) throws
    {
        self.id = id
        
        if id >= allocator.blocks.count || id > Int.max
        {
            throw Error( message: "Invalid directory ID" )
        }
        
        let ( offset, _ ) = allocator.blocks[ Int( id ) ]
        
        try stream.seek( offset: size_t( offset + 4 ), from: .begin )
        
        self.mode = try stream.readUInt32( endianness: .big )
        let count = try stream.readUInt32( endianness: .big )
        
        if self.mode == 0
        {
            for _ in 0 ..< count
            {
                self.records.append( try Record( stream: stream ) )
            }
        }
        else
        {
            for _ in 0 ..< count
            {
                let blockID = try stream.readUInt32( endianness: .big )
                let pos     = stream.tell()
                
                self.children.append( try Block( stream: stream, id: blockID, allocator: allocator ) )
                try stream.seek( offset: pos, from: .begin )
                self.records.append( try Record( stream: stream ) )
            }
        }
    }
}
