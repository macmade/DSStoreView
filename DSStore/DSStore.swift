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

/*
 * Reference:
 *  - https://formats.kaitai.io/ds_store/index.html
 *  - https://wiki.mozilla.org/DS_Store_File_Format
 *  - https://0day.work/parsing-the-ds_store-file-format/
 *  - https://metacpan.org/dist/Mac-Finder-DSStore/view/DSStoreFormat.pod
 */

public class DSStore
{
    public private( set ) var header:      Header
    public private( set ) var allocator:   Allocator
    public private( set ) var directories: [ MasterBlock ] = []
    
    public convenience init( path: String ) throws
    {
        try self.init( url: URL( fileURLWithPath: path ) )
    }
    
    public init( url: URL ) throws
    {
        guard let stream = BinaryFileStream( url: url ) else
        {
            throw Error( message: "Cannot read file: \( url.path )" )
        }
        
        self.header    = try Header( stream: stream )
        self.allocator = try Allocator( stream: stream, header: self.header )
        
        for directory in self.allocator.directories
        {
            self.directories.append( try MasterBlock( stream: stream, id: directory.id, allocator: self.allocator ) )
        }
    }
}
