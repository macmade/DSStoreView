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
    @objc public private( set ) dynamic var folder:                 Folder
    @objc public private( set ) dynamic var file:                   DSStore?
    @objc public private( set ) dynamic var error:                  NSError?
    @objc public private( set ) dynamic var selectedBlock:          BlockNode?
    @objc public private( set ) dynamic var detailWindowController: NSWindowController?
    
    @IBOutlet private var blocksController:  NSTreeController!
    @IBOutlet private var recordsController: NSArrayController!
    @IBOutlet private var blocksOutlineView: NSOutlineView!
    @IBOutlet private var recordsTableView:  NSTableView!
    
    private var selectionObserver: NSKeyValueObservation?
    
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
        
        self.blocksController.sortDescriptors  = [ NSSortDescriptor( key: "name", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) ) ]
        self.recordsController.sortDescriptors = [ NSSortDescriptor( key: "name", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) ) ]
        
        self.selectionObserver = self.blocksController.observe( \.selectionIndexPaths )
        {
            [ weak self ] _, _ in self?.selectionDidChange()
        }
        
        if let file = self.file
        {
            file.directories.map
            {
                BlockNode( name: $0.key, block: $0.value )
            }
            .forEach
            {
                self.blocksController.addObject( $0 )
            }
            
            DispatchQueue.main.async
            {
                self.blocksOutlineView.expandItem( nil, expandChildren: true )
            }
        }
    }
    
    @IBAction private func showDetails( _ sender: Any? )
    {
        guard let record = self.recordsController.selectedObjects.first as? Record else
        {
            return
        }
        
        guard let data = record.value as? Data, record.dataType == .blob else
        {
            return
        }
        
        self.detailWindowController?.window?.close()
        
        do
        {
            let plist                   = try PropertyListSerialization.propertyList( from: data, options: [], format: nil )
            self.detailWindowController = PropertyListWindowController( plist: plist )
        }
        catch
        {
            self.detailWindowController = DataWindowController( data: data )
        }
        
        self.detailWindowController?.window?.title  = record.name
        
        if self.detailWindowController?.window?.isVisible == false
        {
            self.detailWindowController?.window?.center()
        }
        
        self.detailWindowController?.window?.makeKeyAndOrderFront( sender )
    }
    
    private func selectionDidChange()
    {
        guard let block = self.blocksController.selectedObjects.first as? BlockNode else
        {
            self.selectedBlock = nil
            
            return
        }
        
        self.selectedBlock = block
    }
}
