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

public class BinaryFileStream: BinaryStream
{
    private var handle: UnsafeMutablePointer< FILE >
    private var pos:    size_t
    private var size:   size_t
    
    public convenience init?( path: String )
    {
        self.init( url: URL( fileURLWithPath: path ) )
    }
    
    public init?( url: URL )
    {
        var isDir: ObjCBool = false
        
        guard FileManager.default.fileExists( atPath: url.path, isDirectory: &isDir ), isDir.boolValue == false else
        {
            return nil
        }
        
        guard let handle = fopen( url.path, "rb" ) else
        {
            return nil
        }
        
        self.handle = handle
        
        fseek( handle, 0, SEEK_END )
        
        let size = ftell( handle )
        
        guard size > 0 else
        {
            return nil
        }
        
        self.size = size
        self.pos  = 0
        
        fseek( handle, 0, SEEK_SET )
    }
    
    deinit
    {
        fclose( self.handle )
    }
    
    public func read( buffer: UnsafeMutableBufferPointer< UInt8 >, size: size_t ) throws
    {
        if size > self.size - self.pos
        {
            throw NSError( title: "Invalid Read", message: "Not enough data available" )
        }
        
        if size > buffer.count
        {
            throw NSError( title: "Invalid Read", message: "Buffer size is too small" )
        }
        
        fread( buffer.baseAddress, 1, size, self.handle )
        
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
            
            pos = self.size - abs( offset )
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
        
        if pos > self.size
        {
            throw NSError( title: "Invalid Seek", message: "Cannot seek past the end of data" )
        }
        
        self.pos = pos
        
        fseek( self.handle, pos, SEEK_SET )
    }
    
    public func tell() -> size_t
    {
        ftell( self.handle )
    }
}
