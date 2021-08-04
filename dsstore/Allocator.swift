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

@objc public class Allocator: NSObject
{
    public private( set ) var blocks      = [ ( offset: UInt32, size: UInt32 ) ]()
    public private( set ) var directories = [ ( name: String, id: UInt32 ) ]()
    public private( set ) var freeList    = [ [ UInt32 ] ]()
    
    public init( stream: BinaryStream, header: Header ) throws
    {
        try stream.seek( offset: size_t( header.offset1 ) + 4, from: .begin )
        
        let n = try stream.readUInt32( endianness: .big )
        
        try stream.seek( offset: 4, from: .current )
        
        for _ in 0 ..< n
        {
            self.blocks.append( Allocator.decodeOffsetAndSize( try stream.readUInt32( endianness: .big ) ) )
        }
        
        let remaining = 256 - ( n % 256 )
        
        try stream.seek( offset: size_t( remaining * 4 ), from: .current )
        
        super.init()
        
        try self.readDirectories( stream: stream )
        try self.readFreeList( stream: stream )
    }
    
    private func readDirectories( stream: BinaryStream ) throws
    {
        let n = try stream.readUInt32( endianness: .big )
        
        for _ in 0 ..< n
        {
            let name = try stream.readString( length: size_t( try stream.readUInt8() ), encoding: .utf8 ) ?? ""
            let id   = try stream.readUInt32( endianness: .big )
            
            self.directories.append( ( name: name, id: id ) )
        }
    }
    
    private func readFreeList( stream: BinaryStream ) throws
    {
        for _ in 0 ..< 32
        {
            let n      = try stream.readUInt32( endianness: .big )
            var values = [ UInt32 ]()
            
            for _ in 0 ..< n
            {
                values.append( try stream.readUInt32( endianness: .big ) )
            }
            
            self.freeList.append( values )
        }
    }
    
    public class func decodeOffsetAndSize( _ value: UInt32 ) -> ( offset: UInt32, size: UInt32 )
    {
        let offset: UInt32 = value & ~0x1F
        let size:   UInt32 = 1 << ( value & 0x1F )
        
        return ( offset: offset, size: size )
    }
}
