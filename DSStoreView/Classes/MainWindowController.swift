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

public class MainWindowController: NSWindowController, NSOutlineViewDelegate, NSOutlineViewDataSource
{
    @IBOutlet private var foldersOutlineView: NSOutlineView!
    @IBOutlet private var foldersController:  NSTreeController!
    @IBOutlet private var contentContainer:   NSView!
    
    @objc public private( set ) dynamic var loading          = true
    @objc public private( set ) dynamic var selectedFolder:    Folder?
    @objc public private( set ) dynamic var contentController: DSStoreViewController?
    
    private var selectionObserver: NSKeyValueObservation?
    
    public override var windowNibName: NSNib.Name?
    {
        "MainWindowController"
    }
    
    public override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.foldersController.sortDescriptors = [ NSSortDescriptor( key: "name", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) ) ]
        
        self.selectionObserver = self.foldersController.observe( \.selectionIndexPaths )
        {
            [ weak self ] _, _ in self?.selectionDidChange()
        }
        
        DispatchQueue.global( qos: .userInitiated ).async
        {
            let home = ( NSUserName(), URL( fileURLWithPath: NSHomeDirectory() ) )
            let root = ( FileManager.default.displayName( atPath: "/" ), URL( fileURLWithPath: "/" ) )
            
            let homeGroup = FolderGroup( name: home.0, url: home.1 )
            let rootGroup = FolderGroup( name: root.0, url: root.1 )
            
            DispatchQueue.main.async
            {
                self.foldersController.addObject( homeGroup )
                self.foldersController.addObject( rootGroup )
                
                DispatchQueue.main.async
                {
                    for node in self.foldersController.arrangedObjects.children ?? []
                    {
                        self.foldersOutlineView.expandItem( node )
                    }
                    
                    self.loading = false
                }
            }
        }
    }
    
    private func selectionDidChange()
    {
        self.contentContainer.subviews.forEach { $0.removeFromSuperview() }
        
        guard let selected = self.foldersController.selectedNodes.first?.representedObject as? Folder else
        {
            self.window?.title     = "DSStoreView"
            self.contentController = nil
            self.selectedFolder    = nil
            
            return
        }
        
        if selected == self.selectedFolder
        {
            return
        }
        
        self.window?.title = "DSStoreView - \( selected.name )"
        let controller     = DSStoreViewController( folder: selected )
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.frame                                     = self.contentContainer.bounds
        
        self.contentContainer.addSubview( controller.view )
        
        self.contentContainer.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .width,   relatedBy: .equal, toItem: self.contentContainer, attribute: .width,   multiplier: 1, constant: 0 ) )
        self.contentContainer.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .height,  relatedBy: .equal, toItem: self.contentContainer, attribute: .height,  multiplier: 1, constant: 0 ) )
        self.contentContainer.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .centerX, relatedBy: .equal, toItem: self.contentContainer, attribute: .centerX, multiplier: 1, constant: 0 ) )
        self.contentContainer.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .centerY, relatedBy: .equal, toItem: self.contentContainer, attribute: .centerY, multiplier: 1, constant: 0 ) )
        
        self.selectedFolder    = selected
        self.contentController = controller
        
        if let error = controller.error
        {
            let alert = NSAlert( error: error )
            
            if let window = self.window
            {
                alert.beginSheetModal( for: window, completionHandler: nil )
            }
            else
            {
                alert.runModal()
            }
        }
    }
    
    public func outlineView( _ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any ) -> NSView?
    {
        guard let node = item as? NSTreeNode else
        {
            return nil
        }
        
        if node.representedObject is FolderGroup
        {
            return outlineView.makeView( withIdentifier: NSUserInterfaceItemIdentifier( "HeaderCell" ), owner: self )
        }
        
        return outlineView.makeView( withIdentifier: NSUserInterfaceItemIdentifier( "DataCell" ), owner: self )
    }
    
    public func outlineView( _ outlineView: NSOutlineView, isGroupItem item: Any ) -> Bool
    {
        guard let node = item as? NSTreeNode else
        {
            return false
        }
        
        return node.representedObject is FolderGroup
    }
    
    public func outlineView( _ outlineView: NSOutlineView, shouldSelectItem item: Any ) -> Bool
    {
        guard let node = item as? NSTreeNode else
        {
            return false
        }
        
        return node.representedObject is Folder
    }
}
