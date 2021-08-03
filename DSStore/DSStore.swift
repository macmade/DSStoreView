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

public class DSStore
{
    public private( set ) var header:    Header
    public private( set ) var rootBlock: RootBlock
    
    public convenience init?( path: String ) throws
    {
        try self.init( url: URL( fileURLWithPath: path ) )
    }
    
    public init?( url: URL ) throws
    {
        guard let stream = BinaryFileStream( url: url ) else
        {
            return nil
        }
        
        self.header = try Header( stream: stream )
        
        guard self.header.alignement == 0x01, self.header.magic == 0x42756431 else
        {
            throw NSError( title: "Cannot Read File", message: "Invalid header magic bytes" )
        }
        
        guard self.header.offset1 == self.header.offset2, self.header.offset1 > 0 else
        {
            throw NSError( title: "Cannot Read File", message: "Invalid root block offset" )
        }
        
        guard self.header.size > 0 else
        {
            throw NSError( title: "Cannot Read File", message: "Invalid root block size" )
        }
        
        self.rootBlock = try RootBlock( stream: stream, offset: size_t( self.header.offset1 ), size: size_t( self.header.size ) )
        
        /*
        for table in self.rootBlock.tables
        {
            let offset = self.rootBlock.offsets[ Int( table.value ) ] & ~0x1F
            let size   = 1 << ( self.rootBlock.offsets[ Int( table.value ) ] & 0x1F )
            
            NSLog( "0x%04X", size )
            
            try stream.seek( offset: size_t( offset + 4 ), from: .begin )
            
            let dataID      = try stream.readUInt32( endianness: .big )
            let levels      = try stream.readUInt32( endianness: .big )
            let recordCount = try stream.readUInt32( endianness: .big )
            let blockCount  = try stream.readUInt32( endianness: .big )
            let _          = try stream.readUInt32( endianness: .big )
            
            NSLog( "Data ID: 0x%04X", dataID )
            NSLog( "Levels:  0x%04X", levels )
            NSLog( "Records: 0x%04X", recordCount )
            NSLog( "Blocks:  0x%04X", blockCount )
            
            let dataOffset = self.rootBlock.offsets[ Int( dataID ) ] & ~0x1F
            let dataSize   = 1 << ( self.rootBlock.offsets[ Int( dataID ) ] & 0x1F )
            
            NSLog( "0x%04X", dataOffset )
            NSLog( "0x%04X", dataSize )
        }
        */
    }
}
