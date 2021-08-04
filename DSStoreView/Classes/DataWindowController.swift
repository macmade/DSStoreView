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

public class DataWindowController: NSWindowController
{
    @objc public private( set ) dynamic var loading:     Bool = false
    @objc public private( set ) dynamic var showAscii:   Bool = false
    @objc public private( set ) dynamic var data:        Data
    @objc public private( set ) dynamic var binary:      String?
    @objc public private( set ) dynamic var ascii:       String?
    @objc public private( set ) dynamic var font:        NSFont?
    
    @IBOutlet private var textView1: NSTextView!
    @IBOutlet private var textView2: NSTextView!
    
    public init( data: Data )
    {
        self.data = data
        
        super.init( window: nil )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var windowNibName: NSNib.Name?
    {
        "DataWindowController"
    }
    
    public override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.font                         = NSFont.userFixedPitchFont( ofSize: 11 )
        self.textView1.textContainerInset = NSSize( width: 10, height: 10 )
        self.textView2.textContainerInset = NSSize( width: 10, height: 10 )
        
        self.showBinary( nil )
    }
    
    @IBAction private func showBinary( _ sender: Any? )
    {
        if let _ = self.ascii, let _ = self.binary
        {
            return
        }
        
        self.loading = true
        
        DispatchQueue.global( qos: .userInitiated ).async
        {
            let binary = NSMutableString()
            let ascii  = NSMutableString()
            
            if self.data.count > 0
            {
                self.data.withUnsafeBytes
                {
                    bytes in
                    
                    for i in 0 ..< self.data.count
                    {
                        let byte = bytes[ i ]
                        
                        binary.appendFormat( "%02X ", byte )
                        
                        if byte >= 33 && byte <= 126
                        {
                            ascii.appendFormat( "%c", byte )
                        }
                        else
                        {
                            ascii.append( "." )
                        }
                    }
                    
                    binary.deleteCharacters( in: NSMakeRange( binary.length - 1, 1 ) )
                }
            }
            
            DispatchQueue.main.async
            {
                self.binary  = binary as String
                self.ascii   = ascii  as String
                self.loading = false
            }
        }
    }
    
    @IBAction private func changeView( _ sender: Any? )
    {
        guard let control = sender as? NSSegmentedControl else
        {
            return
        }
        
        self.showAscii = control.selectedSegment == 1
    }
}
