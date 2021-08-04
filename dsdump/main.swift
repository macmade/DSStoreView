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
    if let value = record.value as? Bool
    {
        return value ? "True" : "False"
    }
    else if let value = record.value as? Int8
    {
        return "\( value )"
    }
    else if let value = record.value as? UInt8
    {
        return "\( value )"
    }
    else if let value = record.value as? Int16
    {
        return "\( value )"
    }
    else if let value = record.value as? UInt16
    {
        return "\( value )"
    }
    else if let value = record.value as? Int32
    {
        return "\( value )"
    }
    else if let value = record.value as? UInt32
    {
        return "\( value )"
    }
    else if let value = record.value as? Int64
    {
        return "\( value )"
    }
    else if let value = record.value as? UInt64
    {
        return "\( value )"
    }
    else if let value = record.value as? Date
    {
        return ISO8601DateFormatter().string( from: value )
    }
    else if let value = record.value as? Data
    {
        if value.count > 0 && value.count > 32
        {
            return "\( value.count ) bytes"
        }
        else if value.count > 0
        {
            var description = ""
            
            for byte in value
            {
                description.append( String( format: "%02X", byte ) )
            }
            
            return description
        }
    }
    else if let value = record.value as? String
    {
        return value
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
