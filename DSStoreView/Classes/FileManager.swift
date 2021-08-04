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

public extension FileManager
{
    func directoriesAtURL( _ url: URL ) -> [ URL ]
    {
        guard let enumerator = FileManager.default.enumerator( atPath: url.path ) else
        {
            return []
        }
        
        var folders = [ URL ]()
        
        for obj in enumerator
        {
            enumerator.skipDescendents()
            
            guard let name = obj as? String else
            {
                continue
            }
            
            var isDir: ObjCBool = false
            
            guard FileManager.default.fileExists( atPath: url.appendingPathComponent( name ).path, isDirectory: &isDir ), isDir.boolValue else
            {
                continue
            }
            
            folders.append( url.appendingPathComponent( name ) )
        }
        
        return folders
    }
}
