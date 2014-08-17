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

// TVLMainWindowController class
@implementation TVLMainWindowController

@synthesize _mainWindow;

// Data source
@synthesize _pics;

@synthesize _picsTableView;
@synthesize _importPicsButton;
@synthesize _importPicsOpenPanel;

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
    NSButton* button = [ [ [ NSButton alloc ] init ] autorelease ];
    [ button setBezelStyle: NSRecessedBezelStyle ];

    NSString* columnID = [ _Column identifier ];
    if ( [ columnID isEqualToString: NSLocalizedString( @"Pic Name", nil ) ] )
        {
        [ button setImage: [ self._pics[ _Row ] _image ] ];
        [ button setTitle: [ self._pics[ _Row ] _name ] ];
        [ button setImagePosition: NSImageLeft ];
        }
    else if ( [ columnID isEqualToString: NSLocalizedString( @"Absolute Path", nil ) ] )
        {
        [ button setTitle: [ self._pics[ _Row ] _absolutePath ].absoluteString ];
        }

    return button;
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
                    if ( ![ [ url pathExtension ] isEqualToString: @"png" ]
                            || ![ [ url pathExtension ] isEqualToString: @"jpeg" ]
                            || ![ [ url pathExtension ] isEqualToString: @"jpg" ] )
                        [ dirEnumerator skipDescendents ];

                    [ self._pics addObject: [ TVLPic picWithURL: url ] ];
                    }

                [ self._picsTableView reloadData ];
                }
            } ];
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