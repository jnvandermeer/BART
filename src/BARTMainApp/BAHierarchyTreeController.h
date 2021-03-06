//
//  BAHierarchyTreeController.h
//  BARTApplication
//
//  Created by Torsten Schlumm on 5/15/12.
//  Copyright (c) 2012 MPI Cognitive and Human Brain Sciences Leipzig. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BAHierarchyElement.h"



@interface BAHierarchyTreeController : NSTreeController <NSOutlineViewDelegate, NSMenuDelegate, NSOutlineViewDataSource> {

@private
    IBOutlet NSOutlineView *_hierarchyTreeView;

}



- (IBAction)openTreeWithEDL:(id)sender;
- (IBAction)selectTreeElement:(id)sender;


- (IBAction)contextMenuExecuteAction:(id)sender;


- (void)outlineViewSelectionDidChange:(NSNotification *)notification;


@end


static NSDictionary *elementIconNames;

