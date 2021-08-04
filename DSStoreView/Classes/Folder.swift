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

import Cocoa

@objc public class Folder: NSObject
{
    private static var queue = DispatchQueue( label: "com.xs-labs.DSStoreView.FolderQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil )
    
    @objc public private( set ) dynamic var url:            URL
    @objc public private( set ) dynamic var name:           String
    @objc public private( set ) dynamic var icon:           NSImage?
    @objc public private( set ) dynamic var hasDSStoreFile: Bool
    @objc public private( set ) dynamic var children:       [ Folder ] = []
    
    public init?( url: URL )
    {
        var isDir: ObjCBool = false
        
        guard FileManager.default.fileExists( atPath: url.path, isDirectory: &isDir ), isDir.boolValue else
        {
            return nil
        }
        
        self.url            = url
        self.name           = FileManager.default.displayName( atPath: url.path )
        self.icon           = NSWorkspace.shared.icon( forFile: url.path )
        self.hasDSStoreFile = FileManager.default.fileExists( atPath: url.appendingPathComponent( ".DS_Store" ).path )
        
        super.init()
        
        Folder.queue.async
        {
            let children = FileManager.default.directoriesAtURL( self.url ).compactMap { Folder( url: $0 ) }
            
            DispatchQueue.main.async
            {
                self.children = children
            }
        }
    }
    
    public override func isEqual( _ object: Any? ) -> Bool
    {
        guard let folder = object as? Folder else
        {
            return false
        }
        
        return self.url == folder.url
    }
    
    public override func isEqual( to object: Any? ) -> Bool
    {
        self.isEqual( object )
    }
}
