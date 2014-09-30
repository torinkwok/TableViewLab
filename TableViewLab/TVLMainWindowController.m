///:
/*****************************************************************************
 **                                                                         **
 **                               .======.                                  **
 **                               | INRI |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                      .========'      '========.                         **
 **                      |   _      xxxx      _   |                         **
 **                      |  /_;-.__ / _\  _.-;_\  |                         **
 **                      |     `-._`'`_/'`.-'     |                         **
 **                      '========.`\   /`========'                         **
 **                               | |  / |                                  **
 **                               |/-.(  |                                  **
 **                               |\_._\ |                                  **
 **                               | \ \`;|                                  **
 **                               |  > |/|                                  **
 **                               | / // |                                  **
 **                               | |//  |                                  **
 **                               | \(\  |                                  **
 **                               |  ``  |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                   \\    _  _\\| \//  |//_   _ \// _                     **
 **                  ^ `^`^ ^`` `^ ^` ``^^`  `^^` `^ `^                     **
 **                                                                         **
 **                       Copyright (c) 2014 Tong G.                        **
 **                          ALL RIGHTS RESERVED.                           **
 **                                                                         **
 ****************************************************************************/

#import "TVLMainWindowController.h"
#import "TVLPic.h"
#import "TVLEnableSelectionButton.h"

// Constants
NSString* kTableViewColumnPicNameIdentifier = @"Pic Name";
NSString* kTableViewColumnAbsolutePathIdentifier = @"Absolute Path";

// TVLMainWindowController class
@implementation TVLMainWindowController

@synthesize _mainWindow;

// Data source
@synthesize _pics;

@synthesize _picsTableView;
@synthesize _importPicsButton;
@synthesize _importPicsOpenPanel;

@synthesize _enableSelectionButton;

#pragma mark Initializers
+ ( id ) mainWindowController
    {
    return [ [ [ [ self class ] alloc ] init ] autorelease ];
    }

- ( id ) init
    {
    if ( self = [ super initWithWindowNibName: @"TVLMainWindow" ] )
        {
        self._pics = [ NSMutableArray array ];
        }

    return self;
    }

#pragma mark Conforms <NSNibAwaking> protocol
- ( void ) awakeFromNib
    {
    }

#pragma mark Conforms <NSTableViewDataSource> protocol
- ( NSInteger ) numberOfRowsInTableView: ( NSTableView* )_TableView
    {
    return [ self._pics count ];
    }

#pragma mark Conforms <NSTableViewDelegate> protocol
- ( NSView* ) tableView: ( NSTableView* )_TableView
     viewForTableColumn: ( NSTableColumn* )_Column
                    row: ( NSInteger )_Row
    {
    id cellInPicNameColumn = [ _TableView makeViewWithIdentifier: kTableViewColumnPicNameIdentifier owner: self ];
    id cellInAbsoultePathColumn = [ _TableView makeViewWithIdentifier: kTableViewColumnAbsolutePathIdentifier owner: self ];

    NSString* columnID = [ _Column identifier ];
    if ( [ columnID isEqualToString: kTableViewColumnPicNameIdentifier ] )
        {
        [ cellInPicNameColumn setImage: [ self._pics[ _Row ] _image ] ];
        [ cellInPicNameColumn setTitle: [ self._pics[ _Row ] _name ] ];
        [ cellInPicNameColumn setImagePosition: NSImageLeft ];

        return cellInPicNameColumn;
        }
    else if ( [ columnID isEqualToString: kTableViewColumnAbsolutePathIdentifier ] )
        {
        [ cellInAbsoultePathColumn setTitle: [ self._pics[ _Row ] _absolutePath ].absoluteString ];

        return cellInAbsoultePathColumn;
        }

    return nil;
    }

- ( BOOL ) selectionShouldChangeInTableView: ( NSTableView* )_TableView
    {
    if ( [ self._enableSelectionButton state ] == NSOnState )
        return YES;
    else
        return NO;
    }

- ( void ) tableViewSelectionIsChanging: ( NSNotification* )_Notif
    {
    __CAVEMEN_DEBUGGING__PRINT_WHICH_METHOD_INVOKED__;
    }

- ( void ) tableViewSelectionDidChange: ( NSNotification* )_Notif
    {
    __CAVEMEN_DEBUGGING__PRINT_WHICH_METHOD_INVOKED__;
    }

#pragma mark IBActions
- ( IBAction ) importPics: ( id )_Sender
    {
    if ( !self._importPicsOpenPanel )
        {
        self._importPicsOpenPanel = [ NSOpenPanel openPanel ];

        [ self._importPicsOpenPanel setCanChooseDirectories: YES ];
        [ self._importPicsOpenPanel setCanChooseFiles: NO ];
        [ self._importPicsOpenPanel setPrompt: NSLocalizedString( @"Choose", nil ) ];
        [ self._importPicsOpenPanel setMessage: NSLocalizedString( @"Choose a Directory", nil ) ];
        }

    [ self._importPicsOpenPanel beginSheetModalForWindow: [ self window ]
                       completionHandler:
        ^( NSInteger _UserSelection )
            {
            [ self._importPicsOpenPanel orderOut: self ];

            if ( _UserSelection == NSFileHandlingPanelOKButton )
                {
                [ self._pics removeAllObjects ];

                NSDirectoryEnumerator* dirEnumerator =
                    [ [ NSFileManager defaultManager ] enumeratorAtURL: [ self._importPicsOpenPanel URL ]
                                            includingPropertiesForKeys: nil
                                                               options: NSDirectoryEnumerationSkipsHiddenFiles
                                                          errorHandler:
                    ^BOOL ( NSURL* _URLEncounteredError, NSError* _Error )
                        {
                        [ self presentError: _Error
                             modalForWindow: [ self window ]
                                   delegate: self
                         didPresentSelector: @selector( didPresentRecoveryWithRecovery:contextInfo: )
                                contextInfo: nil ];

                        return NO;
                        } ];

                for ( NSURL* url in dirEnumerator )
                    {
                    if ( [ [ url pathExtension ] caseInsensitiveCompare: @"png" ] == NSOrderedSame
                            || [ [ url pathExtension ] caseInsensitiveCompare: @"jpeg" ] == NSOrderedSame
                            || [ [ url pathExtension ] caseInsensitiveCompare: @"jpg" ] == NSOrderedSame )
                        [ self._pics addObject: [ TVLPic picWithURL: url ] ];
                    else
                        [ dirEnumerator skipDescendents ];
                    }

                [ self._picsTableView reloadData ];
                }
            } ];
    }

- ( IBAction ) changedEnableSelection: ( id )_Sender
    {
    [ USER_DEFAULTS setBool: self._enableSelectionButton.state forKey: TVLEnableSelectionButtonState ];
    }

#pragma mark Errors Handling
- ( void ) didPresentRecoveryWithRecovery: ( BOOL )_DidRecover
                              contextInfo: ( void* )_ContextInfo
    {
    // TODO:
    }

- ( void ) attemptRecoveryFromError: ( NSError* )_Error
                        optionIndex: ( NSUInteger )_RecoveryOptionIndex
                           delegate: ( id )_Delegate
                 didRecoverSelector: ( SEL )_DidRecoverySelector
                        contextInfo: ( void* )_ContextData
    {
    BOOL success = NO;
    NSError* error = nil;
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: [ self methodSignatureForSelector: @selector( didPresentRecoveryWithRecovery:contextInfo: ) ] ];
    [ invocation setSelector: _DidRecoverySelector ];

    if ( [ _Error.domain isEqualToString: NSCocoaErrorDomain ] )
        {
        switch ( [ _Error code ] )
            {
        case NSFileReadNoSuchFileError:
                {
                if ( _RecoveryOptionIndex == 0 )    // Try again...
                    {
                    [ NSApp sendAction: @selector( importPics: ) to: self from: self._importPicsButton ];
                    success = YES;
                    }
                }
            }
        }

    [ invocation setArgument: ( void* )&success atIndex: 2 ];
    [ invocation setArgument: ( void* )&error atIndex: 3 ];

    [ invocation invokeWithTarget: _Delegate ];
    }

- ( NSError* ) willPresentError: ( NSError* )_IncomingError
    {
    if ( [ _IncomingError.domain isEqualToString: NSCocoaErrorDomain ] )
        {
        switch ( [ _IncomingError code ] )
            {
        case NSFileReadNoSuchFileError:
                {
                NSMutableDictionary* userInfo = [ [ _IncomingError userInfo ] mutableCopy ];
                userInfo[ NSLocalizedRecoverySuggestionErrorKey ] = NSLocalizedString( @"Would you like to choose a correct directory and try again?", nil );
                userInfo[ NSLocalizedRecoveryOptionsErrorKey ] = @[ NSLocalizedString( @"Try Again", nil ), NSLocalizedString( @"Cancel", nil ) ];
                userInfo[ NSRecoveryAttempterErrorKey ] = self;

                return [ NSError errorWithDomain: [ _IncomingError domain ]
                                            code: [ _IncomingError code ]
                                        userInfo: userInfo ];
                } break;
            }
        }

    return [ super willPresentError: _IncomingError ];
    }

#pragma mark NSTableView
- ( IBAction ) testingForRowSelection: ( id )_Sender
    {
    NSIndexSet* indexes = [ self._picsTableView selectedRowIndexes ];
    NSLog( @"selectedRowIndexes: %@", indexes );

    NSLog( @"selectedRow: %ld", [ self._picsTableView selectedRow ] );

    NSLog( @"numberOfSelectedRows: %ld", [ self._picsTableView numberOfSelectedRows ] );

    NSLog( @"isRowSelected: %@", [ self._picsTableView isRowSelected: 5 ] ? @"YES" : @"NO" );

    printf( "\n\n" );
    }

- ( void ) keyDown: ( NSEvent* )_Event
    {
    NSString* charactersIngoringModifiers = [ _Event charactersIgnoringModifiers ];
    NSUInteger modifierFlags = [ _Event modifierFlags ];

    if ( [ charactersIngoringModifiers caseInsensitiveCompare: @"a" ] == NSOrderedSame
            && ( ( modifierFlags & NSCommandKeyMask ) && modifierFlags & NSShiftKeyMask ) )
        {
        [ self._picsTableView selectAll: self ];

        return;
        }
    else if ( [ charactersIngoringModifiers caseInsensitiveCompare: @"d" ] == NSOrderedSame
            && ( ( modifierFlags & NSCommandKeyMask ) && modifierFlags & NSShiftKeyMask ) )
        {
        [ self._picsTableView deselectAll: self ];

        return;
        }

    [ super keyDown: _Event ];
    }

- ( IBAction ) testingForSelectingAndDeselecting: ( id )_Sender
    {

    }

- ( IBAction ) logItems: ( id )_Sender
    {

    }

- ( BOOL ) validateUserInterfaceItem: ( id <NSValidatedUserInterfaceItem> )_Item
    {
    NSLog( @"Selected row indexes: %@", [ self._picsTableView selectedRowIndexes ] );
    if ( [ _Item action ] == @selector( logItems: )
            && [ self._picsTableView clickedRow ] == -1
            && ![ [ self._picsTableView selectedRowIndexes ] containsIndex: [ self._picsTableView clickedRow ] ] )
        return NO;

    return YES;
    }

@end // TVLMainWindowController

/////////////////////////////////////////////////////////////////////////////

/****************************************************************************
 **                                                                        **
 **      _________                                      _______            **
 **     |___   ___|                                   / ______ \           **
 **         | |     _______   _______   _______      | /      |_|          **
 **         | |    ||     || ||     || ||     ||     | |    _ __           **
 **         | |    ||     || ||     || ||     ||     | |   |__  \          **
 **         | |    ||     || ||     || ||     ||     | \_ _ __| |  _       **
 **         |_|    ||_____|| ||     || ||_____||      \________/  |_|      **
 **                                           ||                           **
 **                                    ||_____||                           **
 **                                                                        **
 ***************************************************************************/
///:~