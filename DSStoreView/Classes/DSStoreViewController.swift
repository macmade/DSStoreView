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
import DSStore

public class DSStoreViewController: NSViewController
{
    @objc public private( set ) dynamic var folder: Folder
    @objc public private( set ) dynamic var file:   DSStore?
    @objc public private( set ) dynamic var error:  NSError?
    
    public init( folder: Folder )
    {
        self.folder = folder
        
        super.init( nibName: nil, bundle: nil )
        
        if folder.hasDSStoreFile
        {
            do
            {
                try self.file = DSStore( url: folder.url.appendingPathComponent( ".DS_Store" ) )
            }
            catch let error as Error
            {
                self.error = NSError( title: "Cannot Read File", message: error.message )
            }
            catch let error
            {
                self.error = NSError( title: "Cannot Read File", message: error.localizedDescription )
            }
        }
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var nibName: NSNib.Name?
    {
        "DSStoreViewController"
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}
