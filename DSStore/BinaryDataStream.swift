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

public class BinaryDataStream: BinaryStream
{
    private var bytes: [ UInt8 ]
    private var pos:   size_t
    
    public init( bytes: [ UInt8 ] )
    {
        self.bytes = bytes
        self.pos   = 0
    }
    
    public init( data: Data )
    {
        self.bytes = []
        self.pos   = 0
        
        self.bytes.append( contentsOf: data )
    }
    
    public func read( buffer: UnsafeMutableBufferPointer< UInt8 >, size: size_t ) throws
    {
        if size > self.bytes.count - self.pos
        {
            throw NSError( title: "Invalid Read", message: "Not enough data available" )
        }
        
        if size > buffer.count
        {
            throw NSError( title: "Invalid Read", message: "Buffer size is too small" )
        }
        
        let _     = buffer.initialize( from: self.bytes.dropFirst( self.pos ).prefix( size ) )
        self.pos += size;
    }
    
    public func seek( offset: ssize_t, direction: SeekDirection ) throws
    {
        var pos: size_t = 0
        
        if direction == .begin
        {
            if offset < 0
            {
                throw NSError( title: "Invalid Seek", message: "Seek offset cannot be smaller than 0" )
            }
            
            pos = offset
        }
        else if direction == .end
        {
            if offset > 0
            {
                throw NSError( title: "Invalid Seek", message: "Seek offset cannot be greater than 0" )
            }
            
            pos = self.bytes.count - abs( offset )
        }
        else if offset < 0
        {
            pos = self.pos - abs( offset )
        }
        else
        {
            pos = self.pos + offset
        }
        
        if pos < 0
        {
            throw NSError( title: "Invalid Seek", message: "Cannot seek before the start of data" )
        }
        
        if pos > self.bytes.count
        {
            throw NSError( title: "Invalid Seek", message: "Cannot seek past the end of data" )
        }
        
        self.pos = pos
    }
    
    public func tell() -> size_t
    {
        self.pos
    }
}
