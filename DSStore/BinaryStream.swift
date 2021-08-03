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

public enum SeekDirection
{
    case current
    case begin
    case end
}

public enum Endianness
{
    case little
    case big
}

public protocol BinaryStream
{
             func tell() -> size_t
    mutating func seek( offset: ssize_t, direction: SeekDirection ) throws
    mutating func read( buffer: UnsafeMutableBufferPointer< UInt8 >, size: size_t ) throws
    
    mutating func hasBytesAvailable() -> Bool
    mutating func availableBytes() -> size_t
    mutating func seek( offset: ssize_t ) throws
    mutating func read( size: size_t ) throws -> [ UInt8 ]
    mutating func readAll() throws -> [ UInt8 ]
    mutating func readUInt8() throws -> UInt8
    mutating func readInt8() throws -> Int8
    mutating func readUInt16( endianness: Endianness ) throws -> UInt16
    mutating func readInt16( endianness: Endianness ) throws -> Int16
    mutating func readUInt32( endianness: Endianness ) throws -> UInt32
    mutating func readInt32( endianness: Endianness ) throws -> Int32
    mutating func readUInt64( endianness: Endianness ) throws -> UInt64
    mutating func readInt64( endianness: Endianness ) throws -> Int64
    mutating func readString( length: size_t, encoding: String.Encoding ) throws -> String?
    mutating func readNULLTerminatedString( encoding: String.Encoding ) throws -> String?
}

public extension BinaryStream
{
    mutating func hasBytesAvailable() -> Bool
    {
        self.availableBytes() > 0
    }
    
    mutating func availableBytes() -> size_t
    {
        do
        {
            let current = self.tell()
            
            try self.seek( offset: 0, direction: .end )
            
            let end = self.tell()
            
            try self.seek( offset: current, direction: .begin )
            
            return end - current
        }
        catch
        {
            return 0
        }
    }
    
    mutating func seek( offset: ssize_t ) throws
    {
        try self.seek( offset: offset, direction: .current )
    }
    
    mutating func read( size: size_t ) throws -> [ UInt8 ]
    {
        if size == 0
        {
            return []
        }
        
        let buffer = UnsafeMutableBufferPointer< UInt8 >.allocate( capacity: size )
        
        defer
        {
            buffer.deallocate()
        }
        
        try self.read( buffer: buffer, size: size )
        
        return buffer.toArray()
    }
    
    mutating func readAll() throws -> [ UInt8 ]
    {
        try self.read( size: self.availableBytes() )
    }
    
    mutating func readUInt8() throws -> UInt8
    {
        var n: UInt8 = 0
        
        try withUnsafePointer( to: &n )
        {
            try self.read( buffer: UnsafeMutableBufferPointer( mutating: UnsafeBufferPointer( start: $0, count: 1 ) ), size: 1 )
        }
        
        return n
    }
    
    mutating func readInt8() throws -> Int8
    {
        try Int8( bitPattern: self.readUInt8() )
    }
    
    mutating func readUInt16( endianness: Endianness ) throws -> UInt16
    {
        let buffer = UnsafeMutableBufferPointer< UInt8 >.allocate( capacity: MemoryLayout< UInt16 >.size )
        
        try self.read( buffer: buffer, size: MemoryLayout< UInt16 >.size )
        
        let n1 = Int16( buffer[ 0 ] ) << ( endianness == .big ? 8 : 0 )
        let n2 = Int16( buffer[ 1 ] ) << ( endianness == .big ? 0 : 8 )
        
        return UInt16( bitPattern: n1 | n2 )
    }
    
    mutating func readInt16( endianness: Endianness ) throws -> Int16
    {
        try Int16( bitPattern: self.readUInt16( endianness: endianness ) )
    }
    
    mutating func readUInt32( endianness: Endianness ) throws -> UInt32
    {
        let buffer = UnsafeMutableBufferPointer< UInt8 >.allocate( capacity: MemoryLayout< UInt32 >.size )
        
        try self.read( buffer: buffer, size: MemoryLayout< UInt32 >.size )
        
        let n1 = Int32( buffer[ 0 ] ) << ( endianness == .big ? 24 :  0 )
        let n2 = Int32( buffer[ 1 ] ) << ( endianness == .big ? 16 :  8 )
        let n3 = Int32( buffer[ 2 ] ) << ( endianness == .big ?  8 : 16 )
        let n4 = Int32( buffer[ 3 ] ) << ( endianness == .big ?  0 : 24 )
        
        return UInt32( bitPattern: n1 | n2 | n3 | n4 )
    }
    
    mutating func readInt32( endianness: Endianness ) throws -> Int32
    {
        try Int32( bitPattern: self.readUInt32( endianness: endianness ) )
    }
    
    mutating func readUInt64( endianness: Endianness ) throws -> UInt64
    {
        let buffer = UnsafeMutableBufferPointer< UInt8 >.allocate( capacity: MemoryLayout< UInt64 >.size )
        
        try self.read( buffer: buffer, size: MemoryLayout< UInt64 >.size )
        
        let n1 = Int64( buffer[ 0 ] ) << ( endianness == .big ? 56 :  0 )
        let n2 = Int64( buffer[ 1 ] ) << ( endianness == .big ? 48 :  8 )
        let n3 = Int64( buffer[ 2 ] ) << ( endianness == .big ? 40 : 16 )
        let n4 = Int64( buffer[ 3 ] ) << ( endianness == .big ? 32 : 24 )
        let n5 = Int64( buffer[ 4 ] ) << ( endianness == .big ? 24 : 32 )
        let n6 = Int64( buffer[ 5 ] ) << ( endianness == .big ? 16 : 40 )
        let n7 = Int64( buffer[ 6 ] ) << ( endianness == .big ?  8 : 48 )
        let n8 = Int64( buffer[ 7 ] ) << ( endianness == .big ?  0 : 56 )
        
        return UInt64( bitPattern: n1 | n2 | n3 | n4 | n5 | n6 | n7 | n8 )
    }
    
    mutating func readInt64( endianness: Endianness ) throws -> Int64
    {
        try Int64( bitPattern: self.readUInt64( endianness: endianness ) )
    }
    
    mutating func readString( length: size_t, encoding: String.Encoding ) throws -> String?
    {
        return String( bytes: try self.read( size: length ), encoding: encoding )
    }
    
    mutating func readNULLTerminatedString( encoding: String.Encoding ) throws -> String?
    {
        var bytes = [ UInt8 ]()
        
        repeat
        {
            bytes.append( try self.readUInt8() )
        }
        while bytes.last != 0
        
        return String( bytes: bytes, encoding: encoding )
    }
}
