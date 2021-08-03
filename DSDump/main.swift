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
import DSStore

guard let path = getFilePath() else
{
    print( "Usage: DSDump /path/to/file" )
    exit( 0 )
}

do
{
    let file = try DSStore( path: path )
    
    printFile( file )
    exit( 0 )
}
catch let error as Error
{
    print( error.localizedDescription )
}
catch let error
{
    print( "Unknown error: \( error.localizedDescription )" )
}

func getFilePath() -> String?
{
    let args = ProcessInfo().arguments
    
    #if DEBUG
    
    if( args.count == 2 )
    {
        return args[ 1 ]
    }
    
    return NSURL( fileURLWithPath: NSHomeDirectory() ).appendingPathComponent( "Desktop/.DS_Store" )?.path
    
    #else
    
    return args.count == 2 ? args[ 1 ] : nil
    
    #endif
}

func hex< T >( _ value: T, size: UInt = 4 ) -> String where T: CVarArg
{
    return String( format: "0x%0*X", size, value )
}

func getNodes( in directories: [ Block ] ) -> [ Block ]
{
    var nodes: [ Block ] = []
    
    for node in directories
    {
        nodes.append( node )
        nodes.append( contentsOf: getNodes( in: node.children ) )
    }
    
    return nodes
}

func valueDescription( _ record: Record ) -> String
{
    if record.dataType == "bool"
    {
        if record.data.count >= 1
        {
            return record.data[ 0 ] == 1 ? "True" : "False"
        }
    }
    else if record.dataType == "long" || record.dataType == "shor"
    {
        if record.data.count >= 4
        {
            let n1 = record.data[ 0 ]
            let n2 = record.data[ 1 ]
            let n3 = record.data[ 2 ]
            let n4 = record.data[ 3 ]
            let n  = ( n1 << 24 ) | ( n2 << 16 ) | ( n3 << 8 ) | n4
            
            return "\( n )"
        }
    }
    else if record.dataType == "type"
    {
        if record.data.count >= 4
        {
            return String( format: "%c%c%c%c", record.data[ 0 ], record.data[ 1 ], record.data[ 2 ], record.data[ 3 ] )
        }
    }
    else if record.dataType == "comp" ||  record.dataType == "dutc"
    {
        if record.data.count >= 8
        {
            let n1 = record.data[ 0 ]
            let n2 = record.data[ 1 ]
            let n3 = record.data[ 2 ]
            let n4 = record.data[ 3 ]
            let n5 = record.data[ 4 ]
            let n6 = record.data[ 5 ]
            let n7 = record.data[ 6 ]
            let n8 = record.data[ 7 ]
            let n  = ( n1 << 56 ) | ( n2 << 48 ) | ( n3 << 40 ) | ( n4 << 32 ) | ( n5 << 24 ) | ( n6 << 16 ) | ( n7 << 8 ) | n8
            
            return "\( n )"
        }
    }
    else if record.dataType == "blob"
    {
        if record.data.count > 0 && record.data.count > 32
        {
            return "\( record.data.count ) bytes"
        }
        else if record.data.count > 0
        {
            var description = ""
            
            for byte in record.data
            {
                description.append( String( format: "%02X", byte ) )
            }
            
            return description
        }
    }
    else if record.dataType == "ustr"
    {
        return String( data: record.data, encoding: .utf16 ) ?? "--"
    }
    
    return "--"
}

func printFile( _ file: DSStore )
{
    print(
        """
        Header:
        {
            - Aligment: \( hex( file.header.alignement, size: 8 ) )
            - Magic:    \( hex( file.header.magic,      size: 8 ) )
            - Offset 1: \( hex( file.header.offset1,    size: 8 ) )
            - Size:     \( hex( file.header.size,       size: 8 ) )
            - Offset 2: \( hex( file.header.offset2,    size: 8 ) )
        }
        Allocator:
        {
            - Blocks:      \( file.allocator.blocks.count )
            - Directories: \( file.allocator.directories.count )
        }
        Directories:
        {
        """
    )
    
    for node in getNodes( in: file.directories.map { $0.rootNode } )
    {
        print(
            """
                {
                    - Mode:     \( hex( node.mode ) )
                    - Children: \( node.children.count )
                    - Records:  \( node.records.count )
            """
        )
        
        if node.records.count > 0
        {
            print( "        {" )
            
            for record in node.records
            {
                print(
                    """
                                {
                                    Name:      \( record.name )
                                    Type:      \( hex( record.type ) )
                                    Data Type: \( record.dataType )
                                    Value:     \( valueDescription( record ) )
                    """
                )
                print( "            }" )
            }
            
            print( "        }" )
        }
        
        print( "    }" )
    }
    
    print( "}" )
}
