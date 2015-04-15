Attribute VB_Name = "CleanupMacro"
Option Explicit
Option Base 1
Dim activeRng As Range

Sub MacmillanManuscriptCleanup()

''''''''''''''''''''''''''''''''
'''created by Matt Retzer  - matthew.retzer@macmillan.com
''''''''''''''''''''''''''''''
'version 3.8.2: adding handling of track changes

'version 3.8.1: fixing bug in character styles macro that was causing page breaks to drop out

'version 3.8:
'updated 2015-03-25 by Erica Warren
' Design Note can now contain blank characters
' new char styles "span symbols ital (symi)" and "span symbols bold (symb)" added to existing character styles to tag
'changed way error checks verify that template is attached
'

'version 3.7
'updated 2015-03-04, by Erica Warren
' split Cleanup macro into two macros: cleanup and character styles
' add new character styles (from v. 3.5) to new styles macro
' cleanup now removes space between ellipsis and double or single quote
' cleanup now removes blank paragraph at end of document
' cleanup now converts double periods to single periods
' cleanup now converts double commas to single commas

'''''''''''''''''''''''''''''''''''
' version 3.6 : style updates only, no macro updates

''''''''''''''''''''''''''''''''''''''''''''''''''
'version 3.5
'updated Erica Warren 2015-02-18
''style report opens when complete

'''''''''''''''''''''''''''''''''''''''''''''''''
'version 3.4.3
'last updated 2014-10-20 by Erica Warren
''' - moved StylesHyperlink sub after PreserveWhiteSpaceinBrkStylesA sub to prevent styled blank paragraphs from being removed

'''''''''''''''''''''''''''''''''''''''
'version 3.4.2: template style updates only, not macro updates

''''''''''''''''''''''''''''''''''''''
'version 3.4.1
'last updated 2014-10-08 by Erica Warren
''' - added new Column Break (cbr) style to preserve white space macro

'''''''''''''''''''''''''''''''''''''''
'version 3.4
'last updated 2014-10-07 by Erica Warren
''' - removed Section Break (sbr) from RmNonWildcardItems sub
''' - added RemoveBookmarks sub
''' - added StyleHyperlinks sub, removed hyperlinks stuff from earlier version

'''''''''''''''''''''''''''''''''''''''
'version 3.3.1
'last updated 2014-09-17 by Erica Warren
''' - fixed space break style names that were changed in template
''''''''''''''''''''''''''''''''''''''
'version 3.3
'last updated 2014-09-16 by Erica Warren
''' - added to RmWhiteSpaceB:
'''     - remove space before closing parens, closing bracket, closing braces
'''     - remove space after opening parens, opening bracket, opening braces, dollar sign
''' - added double space to preserve character style search/replace

'''''''''''''''''''''''''''''''''
'version 3.2
'last updated 2014-09-12 by Erica Warren - erica.warren@macmillan.com
''' - changed double- and single- quotes replace to find only straight quotes
''' - added PreserveStyledPageBreaksA and PreserveStyledPageBreaksB, now required for correct InDesign import
''' - added PC_BestStylesView, Mac_BestStylesView, and StylesViewLaunch macros
''' - edited some msgBox text to make it a little more fun

'''''''''''''''''''''''''''''''
'''version 3.1
'''last updated 07/08/14:
''' - split Localstyle replace into to private subs
''' - style report bug fix
''' - adding f/ replace nbs, nbh, oh: to wildcard f/r
''' - added completion message for Cleanup macro
''' - changed TagHyperlink sub to tagexistingchrlinks, added 6 more hyperlink stylesarstyles, including hype
''' - added a backtick on closing tags for preserved break styles, and a call to remove paras trailing these breaks
''' - adding ' endash ' turn to emdash as per EW
''' - added 'save in place' msgbox for Cleanup macro.
''' - fixed embedded filed code hyperlink bug, just giving them a leading space
''' - prepared tagging for 'combinatrions' of local styles
''' - combined highlight removal with local style find loop
''' - combined smart quotes with existing no wildcard sub, made array/loop setup for same
''' - changing default tags for local and char styles to be asymmetrical:  `X|tagged item|X`
''' - updated error check for incidental tags to match asymmetric tags
''' - added in 3 combo styles to LocalFind and LocalReplace
''' - added status bar updates
''' - added additional repair to embedded hyperlink, also related to leading spaces (`Q` tag)
''' - update version in Document properties
'''''''''''''
'''version 3.0
'''last updated 6/10/14:
''' - added Style Report Macro Sub
''' - added srErrorCheck Function
'''version2.1 - 5/27/14:
''' - added 7 styles for preserving white space,
''' - preserving superscript & subscript - converting to char styles.
''' - added prelim checks for protected documents, incidental pre-existing backtick tags
''' - consolidated all preliminary error checks into one function
''' - updating char styles to match new prefixes, in style replacements, hyperlink finds, and errorcheck1
''' - fixed field object hyperlink bug
''' - add find/replace for any extra hyperlink tags `H`
''' - removed .Forward = True from all Find/Replaces as it is redundant when wrap = Continue
''' - made all Subs Private except for the Main one

'-----------run preliminary error checks------------
Dim exitOnError As Boolean

exitOnError = zz_errorChecks()      ''Doc is unsaved, protected, or uses backtick character?
If exitOnError <> False Then
Exit Sub
End If

'-----------Turn off track changes--------
Dim currentTracking As Boolean
currentTracking = ActiveDocument.TrackRevisions
ActiveDocument.TrackRevisions = False

'-----------Remove White Space------------
Application.DisplayStatusBar = True
Application.ScreenUpdating = False


Call zz_clearFind                          'Clear find object

Application.StatusBar = "Fixing quotes, unicode, section breaks": DoEvents
Call RmNonWildcardItems                     'has to be alone b/c Match Wildcards has to be disabled: Smart Quotes, Unicode (ellipse), section break
Call zz_clearFind

Application.StatusBar = "Preserving styled characters": DoEvents
Call PreserveStyledCharactersA              ' EW added v. 3.2, tags styled page breaks, tabs
Call zz_clearFind

Application.StatusBar = "Removing whitespace, fixing ellipses and dashes": DoEvents
Call RmWhiteSpaceB                      'v. 3.7 does NOT remove manual page breaks or multiple paragraph returns
Call zz_clearFind

Application.StatusBar = "Preserving styled white-space": DoEvents
Call PreserveStyledCharactersB              ' EW added v. 3.2, replaces character tags with actual character
Call zz_clearFind

Application.StatusBar = "Removing bookmarks": DoEvents
Call RemoveBookmarks                    'this is in both Cleanup macro and ApplyCharStyles macro
Call zz_clearFind

Application.ScreenUpdating = True
Application.ScreenRefresh

MsgBox "Hurray, the Macmillan Cleanup macro has finished running! Your manuscript looks great!"                                 'v. 3.1 patch / request  v. 3.2 made a little more fun
ActiveDocument.TrackRevisions = currentTracking         'Return track changes to the original setting

End Sub
Sub MacmillanCharStyles()

''-----------------Error checks---------------
Dim exitOnError As Boolean

exitOnError = zz_templateCheck()   '' template is attached?
If exitOnError <> False Then
Exit Sub
End If

exitOnError = zz_errorChecks()   ''Doc is unsaved, protected, or uses backtick character?
If exitOnError <> False Then
Exit Sub
End If

'-----------Turn off track changes--------
Dim currentTracking As Boolean
currentTracking = ActiveDocument.TrackRevisions
ActiveDocument.TrackRevisions = False

'-----------Replace Local Styles-----------
Application.DisplayStatusBar = True
Application.ScreenUpdating = False

Call zz_clearFind                          'Clear find object

Application.StatusBar = "Removing bookmarks": DoEvents
Call RemoveBookmarks                    ' repeated in Cleanup macro
Call zz_clearFind

Application.StatusBar = "Preserving styled whitespace": DoEvents
Call PreserveWhiteSpaceinBrkStylesA     'Part A tags styled blank paragraphs so they don't get deleted
Call zz_clearFind

Application.StatusBar = "Applying styles to hyperlinks": DoEvents
Call StyleHyperlinks                    'Styles hyperlinks, must be performed after PreserveWhiteSpaceinBrkStylesA
Call zz_clearFind

Application.StatusBar = "Removing unstyled breaks": DoEvents
Call RemoveBreaks  ''new sub v. 3.7, removed manual page breaks and multiple paragraph returns
Call zz_clearFind

Application.StatusBar = "Tagging character styles": DoEvents
Call TagExistingCharStyles            'tag existing styled items
Call zz_clearFind

Application.StatusBar = "Tagging and clearing local styles": DoEvents
Call LocalStyleTag                 'tag local styling, reset local styling, remove text highlights
Call zz_clearFind

Application.StatusBar = "Applying Macmillan styles": DoEvents
Call LocalStyleReplace            'reapply local styling through char styles
Call zz_clearFind

Call PreserveWhiteSpaceinBrkStylesB     'Part B removes the tags and reapplies the styles
Call zz_clearFind

Application.ScreenUpdating = True
Application.ScreenRefresh

MsgBox "Macmillan character styles have been applied throughout your manuscript."

ActiveDocument.TrackRevisions = currentTracking         ' return track changes to original setting

End Sub


Private Sub RemoveBookmarks()
Dim bkm As Bookmark
For Each bkm In ActiveDocument.Bookmarks
bkm.Delete
Next bkm
End Sub


Private Sub StyleHyperlinks()
' added by Erica 2014-10-07, v. 3.4
' removes all live hyperlinks but leaves hyperlink text intact
' then styles all URLs as "span hyperlink (url)" style
' -----------------------------------------
' this first bit removes all live hyperlinks from document
' we want to remove these from urls AND text; will add back to just urls later

Set activeRng = ActiveDocument.Range
' remove all embedded hyperlinks regardless of character style
With activeRng
While .Hyperlinks.Count > 0
.Hyperlinks(1).Delete
Wend
End With
'------------------------------------------
'removes all hyperlink styles
Dim HyperlinkStyleArray(3) As String
Dim p As Long

HyperlinkStyleArray(1) = "Hyperlink"        'built-in style applied automatically to links
HyperlinkStyleArray(2) = "FollowedHyperlink"    'built-in style applied automatically
HyperlinkStyleArray(3) = "span hyperlink (url)" 'Macmillan template style for links

For p = 1 To UBound(HyperlinkStyleArray())
    With activeRng.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .Style = HyperlinkStyleArray(p)
        .Replacement.Style = ActiveDocument.Styles("Default Paragraph Font")
        .Text = ""
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindContinue
        .Format = True
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
        .Execute Replace:=wdReplaceAll
    End With
    Next

'--------------------------------------------------
' converts all URLs to hyperlinks with Hyperlink style
' because some show up as plain text
' Note this also removes all blank paragraphs regardless of style, so needs to come after sub PreserveWhiteSpaceinBrkA


  Dim f1 As Boolean, f2 As Boolean, f3 As Boolean
  Dim f4 As Boolean, f5 As Boolean, f6 As Boolean
  Dim f7 As Boolean, f8 As Boolean, f9 As Boolean
  Dim f10 As Boolean
  With Options
    ' Save current AutoFormat settings
    f1 = .AutoFormatApplyHeadings
    f2 = .AutoFormatApplyLists
    f3 = .AutoFormatApplyBulletedLists
    f4 = .AutoFormatApplyOtherParas
    f5 = .AutoFormatReplaceQuotes
    f6 = .AutoFormatReplaceSymbols
    f7 = .AutoFormatReplaceOrdinals
    f8 = .AutoFormatReplaceFractions
    f9 = .AutoFormatReplacePlainTextEmphasis
    f10 = .AutoFormatReplaceHyperlinks
    ' Only convert URLs
    .AutoFormatApplyHeadings = False
    .AutoFormatApplyLists = False
    .AutoFormatApplyBulletedLists = False
    .AutoFormatApplyOtherParas = False
    .AutoFormatReplaceQuotes = False
    .AutoFormatReplaceSymbols = False
    .AutoFormatReplaceOrdinals = False
    .AutoFormatReplaceFractions = False
    .AutoFormatReplacePlainTextEmphasis = False
    .AutoFormatReplaceHyperlinks = True
    ' Perform AutoFormat
    ActiveDocument.Content.AutoFormat
    ' Restore original AutoFormat settings
    .AutoFormatApplyHeadings = f1
    .AutoFormatApplyLists = f2
    .AutoFormatApplyBulletedLists = f3
    .AutoFormatApplyOtherParas = f4
    .AutoFormatReplaceQuotes = f5
    .AutoFormatReplaceSymbols = f6
    .AutoFormatReplaceOrdinals = f7
    .AutoFormatReplaceFractions = f8
    .AutoFormatReplacePlainTextEmphasis = f9
    .AutoFormatReplaceHyperlinks = f10
  End With

'--------------------------------------------------
' apply macmillan URL style to hyperlinks we just tagged

    With activeRng.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .Style = "Hyperlink"
        .Replacement.Style = ActiveDocument.Styles("span hyperlink (url)")
        .Text = ""
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindContinue
        .Format = True
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
        .Execute Replace:=wdReplaceAll
    End With

' -----------------------------------------------
' Removes all hyperlinks from the document (that were added with AutoFormat)
' Text to display is left intact, macmillan style is left intact
With activeRng
While .Hyperlinks.Count > 0
.Hyperlinks(1).Delete
Wend
End With

End Sub


Private Sub RmNonWildcardItems()                                             'v. 3.1 patch : redid this whole thing as an array, addedsmart quotes, wrap toggle var
Set activeRng = ActiveDocument.Range

Dim noWildTagArray(3) As String                                   ' number of items in array should be declared here
Dim noWildReplaceArray(3) As String              ' number of items in array should be declared here
Dim c As Long
Dim wrapToggle As String

wrapToggle = "wdFindContinue"
Application.Options.AutoFormatAsYouTypeReplaceQuotes = True


noWildTagArray(1) = "^u8230"
noWildTagArray(2) = "^39"                       'v. 3.2: EW changed to straight single quote only
noWildTagArray(3) = "^34"                       'v. 3.2: EW changed to straight double quote only

noWildReplaceArray(1) = " . . . "
noWildReplaceArray(2) = "'"
noWildReplaceArray(3) = """"

For c = 1 To UBound(noWildTagArray())
If c = 3 Then wrapToggle = "wdFindStop"
With activeRng.Find
  .ClearFormatting
  .Replacement.ClearFormatting
  .Text = noWildTagArray(c)
  .Replacement.Text = noWildReplaceArray(c)
  .Wrap = wdFindContinue
  .Format = False
  .MatchCase = False
  .MatchWholeWord = False
  .MatchWildcards = False
  .Execute Replace:=wdReplaceAll
End With
Next
End Sub



Private Sub PreserveWhiteSpaceinBrkStylesA()
Set activeRng = ActiveDocument.Range

Dim tagArray(12) As String                                   ' number of items in array should be declared here
Dim StylePreserveArray(12) As String              ' number of items in array should be declared here
Dim e As Long

StylePreserveArray(1) = "Space Break (#)"
StylePreserveArray(2) = "Space Break with Ornament (orn)"
StylePreserveArray(3) = "Space Break with ALT Ornament (orn2)"
StylePreserveArray(4) = "Section Break (sbr)"
StylePreserveArray(5) = "Part Start (pts)"
StylePreserveArray(6) = "Part End (pte)"
StylePreserveArray(7) = "Page Break (pb)"
StylePreserveArray(8) = "Space Break - 1-Line (ls1)"
StylePreserveArray(9) = "Space Break - 2-Line (ls2)"
StylePreserveArray(10) = "Space Break - 3-Line (ls3)"
StylePreserveArray(11) = "Column Break (cbr)"
StylePreserveArray(12) = "Design Note (dn)"

tagArray(1) = "`1`^&`1``"                                       'v. 3.1 patch  added extra backtick on trailing tag for all of these.
tagArray(2) = "`2`^&`2``"
tagArray(3) = "`3`^&`3``"
tagArray(4) = "`4`^&`4``"
tagArray(5) = "`5`^&`5``"
tagArray(6) = "`6`^&`6``"
tagArray(7) = "`7`^&`7``"
tagArray(8) = "`8`^&`8``"
tagArray(9) = "`9`^&`9``"
tagArray(10) = "`0`^&`0``"
tagArray(11) = "`L`^&`L``"
tagArray(12) = "`R`^&`R``"


For e = 1 To UBound(StylePreserveArray())
With activeRng.Find
  .ClearFormatting
  .Replacement.ClearFormatting
  .Text = "^13"
  .Replacement.Text = tagArray(e)
  .Wrap = wdFindContinue
  .Format = True
  .Style = StylePreserveArray(e)
  .MatchCase = False
  .MatchWholeWord = False
  .MatchWildcards = True
  .MatchSoundsLike = False
  .MatchAllWordForms = False
  .Execute Replace:=wdReplaceAll
End With
Next
End Sub

Private Sub PreserveStyledCharactersA()
' added by EW v. 3.2
' replaces correctly styled characters with placeholder so they don't get removed
Set activeRng = ActiveDocument.Range

Dim preserveCharFindArray(3) As String  ' declare number of items in array
Dim preserveCharReplaceArray(3) As String   'delcare number of items in array
Dim preserveCharStyleArray(3) As String ' ditto
Dim m As Long

preserveCharFindArray(1) = "^t" 'tabs
preserveCharFindArray(2) = "  "  ' two spaces
preserveCharFindArray(3) = "   "    'three spaces

preserveCharReplaceArray(1) = "`E|"
preserveCharReplaceArray(2) = "`G|"
preserveCharReplaceArray(3) = "`J|"

preserveCharStyleArray(1) = "span preserve characters (pre)"
preserveCharStyleArray(2) = "span preserve characters (pre)"
preserveCharStyleArray(3) = "span preserve characters (pre)"

For m = 1 To UBound(preserveCharFindArray())
With activeRng.Find
    .ClearFormatting
    .Replacement.ClearFormatting
    .Text = preserveCharFindArray(m)
    .Replacement.Text = preserveCharReplaceArray(m)
    .Wrap = wdFindContinue
    .Format = True
    .Style = preserveCharStyleArray(m)
    .MatchCase = False
    .MatchWholeWord = False
    .MatchWildcards = False
    .MatchSoundsLike = False
    .MatchAllWordForms = False
    .Execute Replace:=wdReplaceAll
End With
Next
End Sub
Private Sub RemoveBreaks()
'Created v. 3.7

Set activeRng = ActiveDocument.Range

Dim wsFindArray(3) As String              'number of items in array should be declared here
Dim wsReplaceArray(3) As String       'and here
Dim q As Long

wsFindArray(1) = "^m^13"              'manual page breaks
wsFindArray(2) = "^13{2,}"          '2 or more paragraphs
wsFindArray(3) = "(`[0-9]``)^13"    'remove para following a preserved break style                     v. 3.1 patch

wsReplaceArray(1) = "^13"
wsReplaceArray(2) = "^13"
wsReplaceArray(3) = "\1"


For q = 1 To UBound(wsFindArray())
With activeRng.Find
  .ClearFormatting
  .Replacement.ClearFormatting
  .Text = wsFindArray(q)
  .Replacement.Text = wsReplaceArray(q)
  .Wrap = wdFindContinue
  .Format = False
  .MatchCase = False
  .MatchWholeWord = False
  .MatchWildcards = True
  .MatchSoundsLike = False
  .MatchAllWordForms = False
  .Execute Replace:=wdReplaceAll
End With
Next

''' the bit below to remove the last paragraph if it's blank
Dim MyRange As Range
Set MyRange = ActiveDocument.paragraphs(1).Range
If MyRange.Text = vbCr Then MyRange.Delete

Set MyRange = ActiveDocument.paragraphs.Last.Range
If MyRange.Text = vbCr Then MyRange.Delete

End Sub
Private Sub RmWhiteSpaceB()
Set activeRng = ActiveDocument.Range

Dim wsFindArray(33) As String              'number of items in array should be declared here
Dim wsReplaceArray(33) As String       'and here
Dim i As Long

wsFindArray(1) = ".{4,}"             '4 or more consecutive periods, into proper 4 dot ellipse
wsFindArray(2) = "..."                  '3 consecutive periods, into 3 dot ellipse
wsFindArray(3) = "^s"                  'non-breaking space replaced with space                                 v. 3.1 patch
wsFindArray(4) = "([! ]). . ."          'add leading space for ellipse if not present
wsFindArray(5) = ". . .([! ])"          'add trailing space for ellipse if not present
wsFindArray(6) = "^t{1,}"             'tabs replace with spaces
wsFindArray(7) = "^l{1,}"               'manual line breaks replaced with hard return
wsFindArray(8) = " {2,}"               '2 or more spaces replaced with single space
wsFindArray(9) = "^13 "               'paragraph, space replaced with just paragraph
wsFindArray(10) = " ^13"               'space, paragraph replaced with just paragraph
wsFindArray(11) = "^-"                     'optional hyphen deleted                                                    v. 3.1 patch
wsFindArray(12) = "^~"                      'non-breaking hyphen replaced with reg hyphen               v. 3.1 patch
wsFindArray(13) = " ^= "                    'endash w/ spaces convert to emdash (no spaces)                                v. 3.1 patch
wsFindArray(14) = "---"                   '3 hyphens to emdash
wsFindArray(15) = "--"                   '2 hyphens to emdash                           v. 3.7 changed from en-dash to em-dash, per usual usage.
wsFindArray(16) = " -"                  'hyphen leading space-remove
wsFindArray(17) = "- "                  'hyphen trailing space-remove
wsFindArray(18) = " ^+"                  'emdash leading space-remove
wsFindArray(19) = "^+ "                  'emdash trailing space-remove
wsFindArray(20) = " ^="                  'endash leading space-remove
wsFindArray(21) = "^= "                  'endash trailing space-remove
wsFindArray(22) = "\( "                     ' remove space after open parens                                                           v. 3.3
wsFindArray(23) = " \)"                     ' removespace before closing parens                                                       v. 3.3
wsFindArray(24) = "\[ "                     ' removespace after opening bracket                                                    v. 3.3
wsFindArray(25) = " \]"                    ' removespace before closing bracket                                                   v. 3.3
wsFindArray(26) = "\{ "                     ' removespace after opening curly bracket                                          v. 3.3
wsFindArray(27) = " \}"                     ' removespace before closing curly bracket                                         v. 3.3
wsFindArray(28) = "$ "                      ' removespace after dollar sign                                                                v. 3.3
wsFindArray(29) = " . . . ."                ' remove space before 4-dot ellipsis (because it's a period)       v 3.7
wsFindArray(30) = ".."                         'replace double period with single period                v. 3.7
wsFindArray(31) = ",,"                          'replace double commas with single comma                v. 3.7

'Test if Mac or PC because character code for closing quotes is different on different platforms            v 3.7
#If Mac Then
    'I am a Mac and will test if it is Word 2011 or higher
    If Val(Application.Version) > 14 Then
            'remove space between ellipsis and closing double quote on Mac
            wsFindArray(32) = ". . . " & Chr(211)
    End If
#Else
    'I am Windows
    ' remove space between ellipsis and closing double quote on Windows
    wsFindArray(32) = ". . . " & Chr(148)
#End If
        
#If Mac Then
    'I am a Mac and will test if it is Word 2011 or higher
    If Val(Application.Version) > 14 Then
            'remove space between ellipsis and closing single quote on Mac
            wsFindArray(33) = ". . . " & Chr(213)
    End If
#Else
    'I am Windows
    ' remove space between ellipsis and closing single quote on Windows
    wsFindArray(33) = ". . . " & Chr(146)
#End If

wsReplaceArray(1) = ". . . . "      ' v. 3.2 EW removed leading space--not needed, 1st dot is a period
wsReplaceArray(2) = " . . . "
wsReplaceArray(3) = " "
wsReplaceArray(4) = "\1 . . ."
wsReplaceArray(5) = ". . . \1"
wsReplaceArray(6) = " "
wsReplaceArray(7) = "^p"
wsReplaceArray(8) = " "
wsReplaceArray(9) = "^p"
wsReplaceArray(10) = "^p"
wsReplaceArray(11) = ""
wsReplaceArray(12) = "-"
wsReplaceArray(13) = "^+"
wsReplaceArray(14) = "^+"
wsReplaceArray(15) = "^+"       'v. 3.7 changed to em-dash per common usage
wsReplaceArray(16) = "-"
wsReplaceArray(17) = "-"
wsReplaceArray(18) = "^+"
wsReplaceArray(19) = "^+"
wsReplaceArray(20) = "^="
wsReplaceArray(21) = "^="
wsReplaceArray(22) = "("
wsReplaceArray(23) = ")"
wsReplaceArray(24) = "["
wsReplaceArray(25) = "]"
wsReplaceArray(26) = "{"
wsReplaceArray(27) = "}"
wsReplaceArray(28) = "$"
wsReplaceArray(29) = ". . . ."
wsReplaceArray(30) = "."
wsReplaceArray(31) = ","

#If Mac Then
    If Val(Application.Version) > 14 Then
            wsReplaceArray(32) = ". . ." & Chr(211)
    End If
#Else
    wsReplaceArray(32) = ". . ." & Chr(148)
#End If

#If Mac Then
    If Val(Application.Version) > 14 Then
            wsReplaceArray(33) = ". . ." & Chr(213)
    End If
#Else
    wsReplaceArray(33) = ". . ." & Chr(146)
#End If

For i = 1 To UBound(wsFindArray())
With activeRng.Find
  .ClearFormatting
  .Replacement.ClearFormatting
  .Text = wsFindArray(i)
  .Replacement.Text = wsReplaceArray(i)
  .Wrap = wdFindContinue
  .Format = False
  .MatchCase = False
  .MatchWholeWord = False
  .MatchWildcards = True
  .MatchSoundsLike = False
  .MatchAllWordForms = False
  .Execute Replace:=wdReplaceAll
End With
Next


End Sub
Private Sub PreserveStyledCharactersB()
' added by EW v. 3.2
' replaces placeholders with original characters
Set activeRng = ActiveDocument.Range

Dim preserveCharFindArray(3) As String  ' declare number of items in array
Dim preserveCharReplaceArray(3) As String   'declare number of items in array
Dim preserveCharStyleArray(3) As String ' ditto
Dim n As Long

preserveCharFindArray(1) = "`E|" 'tabs
preserveCharFindArray(2) = "`G|"    ' two spaces
preserveCharFindArray(3) = "`J|"   'three spaces

preserveCharReplaceArray(1) = "^t"
preserveCharReplaceArray(2) = "  "
preserveCharReplaceArray(3) = "   "

preserveCharStyleArray(1) = "span preserve characters (pre)"
preserveCharStyleArray(2) = "span preserve characters (pre)"
preserveCharStyleArray(3) = "span preserve characters (pre)"

For n = 1 To UBound(preserveCharFindArray())
With activeRng.Find
    .ClearFormatting
    .Replacement.ClearFormatting
    .Text = preserveCharFindArray(n)
    .Replacement.Text = preserveCharReplaceArray(n)
    .Wrap = wdFindContinue
    .Format = True
    .Style = preserveCharStyleArray(n)
    .MatchCase = False
    .MatchWholeWord = False
    .MatchWildcards = False
    .MatchSoundsLike = False
    .MatchAllWordForms = False
    .Execute Replace:=wdReplaceAll
End With
Next
End Sub
Private Sub PreserveWhiteSpaceinBrkStylesB()
Set activeRng = ActiveDocument.Range

Dim tagArrayB(12) As String                                   ' number of items in array should be declared here
Dim f As Long

tagArrayB(1) = "`1`(^13)`1``"                             'v. 3.1 patch  added extra backtick on trailing tag for all of these.
tagArrayB(2) = "`2`(^13)`2``"
tagArrayB(3) = "`3`(^13)`3``"
tagArrayB(4) = "`4`(^13)`4``"
tagArrayB(5) = "`5`(^13)`5``"
tagArrayB(6) = "`6`(^13)`6``"
tagArrayB(7) = "`7`(^13)`7``"
tagArrayB(8) = "`8`(^13)`8``"
tagArrayB(9) = "`9`(^13)`9``"
tagArrayB(10) = "`0`(^13)`0``"
tagArrayB(11) = "`L`(^13)`L``"              ' for new column break, added v. 3.4.1
tagArrayB(12) = "`R`(^13)`R``"

For f = 1 To UBound(tagArrayB())
With activeRng.Find
  .ClearFormatting
  .Replacement.ClearFormatting
  .Text = tagArrayB(f)
  .Replacement.Text = "\1"
  .Wrap = wdFindContinue
  .Format = False
  .MatchCase = False
  .MatchWholeWord = False
  .MatchWildcards = True
  .MatchSoundsLike = False
  .MatchAllWordForms = False
  .Execute Replace:=wdReplaceAll
End With
Next
End Sub

Private Sub TagExistingCharStyles()
Set activeRng = ActiveDocument.Range                        'this whole sub (except last stanza) is basically a v. 3.1 patch.  correspondingly updated sub name, call in main, and replacements go along with bold and common replacements

Dim tagCharStylesArray(13) As String                                   ' number of items in array should be declared here
Dim CharStylePreserveArray(13) As String              ' number of items in array should be declared here
Dim d As Long


CharStylePreserveArray(1) = "span hyperlink (url)"
CharStylePreserveArray(2) = "span symbols (sym)"
CharStylePreserveArray(3) = "span accent characters (acc)"
CharStylePreserveArray(4) = "span cross-reference (xref)"
CharStylePreserveArray(5) = "span material to come (tk)"
CharStylePreserveArray(6) = "span carry query (cq)"
CharStylePreserveArray(7) = "span key phrase (kp)"
CharStylePreserveArray(8) = "span preserve characters (pre)"  'added v. 3.2
CharStylePreserveArray(9) = "bookmaker keep together (kt)"  'added v. 3.7
CharStylePreserveArray(10) = "bookmaker force page break (br)"  'added v. 3.7
CharStylePreserveArray(11) = "span ISBN (isbn)"  'added v. 3.7
CharStylePreserveArray(12) = "span symbols ital (symi)"     'added v. 3.8
CharStylePreserveArray(13) = "span symbols bold (symb)"


tagCharStylesArray(1) = "`H|^&|H`"
tagCharStylesArray(2) = "`Z|^&|Z`"
tagCharStylesArray(3) = "`Y|^&|Y`"
tagCharStylesArray(4) = "`X|^&|X`"
tagCharStylesArray(5) = "`W|^&|W`"
tagCharStylesArray(6) = "`V|^&|V`"
tagCharStylesArray(7) = "`T|^&|T`"
tagCharStylesArray(8) = "`F|^&|F`"
tagCharStylesArray(9) = "`K|^&|K`"
tagCharStylesArray(10) = "`N|^&|N`"
tagCharStylesArray(11) = "`Q|^&|Q`"
tagCharStylesArray(12) = "`E|^&|E`"
tagCharStylesArray(13) = "`G|^&|G`"


For d = 1 To UBound(CharStylePreserveArray())
With activeRng.Find
  .ClearFormatting
  .Replacement.ClearFormatting
  .Text = ""
  .Replacement.Text = tagCharStylesArray(d)
  .Wrap = wdFindContinue
  .Format = True
  .Style = CharStylePreserveArray(d)
  .MatchCase = False
  .MatchWholeWord = False
  .MatchWildcards = True
  .MatchSoundsLike = False
  .MatchAllWordForms = False
  .Execute Replace:=wdReplaceAll
End With
Next


End Sub

Private Sub LocalStyleTag()
Set activeRng = ActiveDocument.Range

'------------tag key styles
Dim tagStyleFindArray(10) As Boolean              ' number of items in array should be declared here
Dim tagStyleReplaceArray(10) As String         'and here
Dim g As Long

tagStyleFindArray(1) = False        'Bold
tagStyleFindArray(2) = False        'Italic
tagStyleFindArray(3) = False        'Underline
tagStyleFindArray(4) = False        'Smallcaps
tagStyleFindArray(5) = False        'Subscript
tagStyleFindArray(6) = False        'Superscript
tagStyleFindArray(7) = False        'Highlights                                                          v. 3.1 update
tagStyleReplaceArray(1) = "`B|^&|B`"
tagStyleReplaceArray(2) = "`I|^&|I`"
tagStyleReplaceArray(3) = "`U|^&|U`"
tagStyleReplaceArray(4) = "`M|^&|M`"
tagStyleReplaceArray(5) = "`S|^&|S`"
tagStyleReplaceArray(6) = "`P|^&|P`"
tagStyleReplaceArray(8) = "`A|^&|A`"
tagStyleReplaceArray(9) = "`C|^&|C`"
tagStyleReplaceArray(10) = "`D|^&|D`"

For g = 1 To UBound(tagStyleFindArray())
tagStyleFindArray(g) = True
If tagStyleFindArray(8) = True Then tagStyleFindArray(1) = True: tagStyleFindArray(2) = True                                                        'bold and italic                        v. 3.1 update
If tagStyleFindArray(9) = True Then tagStyleFindArray(1) = True: tagStyleFindArray(4) = True: tagStyleFindArray(2) = False           'bold and smallcaps                 v. 3.1 update
If tagStyleFindArray(10) = True Then tagStyleFindArray(2) = True: tagStyleFindArray(4) = True: tagStyleFindArray(1) = False           'smallcaps and italic               v. 3.1 update

With activeRng.Find
  .ClearFormatting
  .Replacement.ClearFormatting
  .Text = ""
  .Replacement.Text = tagStyleReplaceArray(g)
  .Wrap = wdFindContinue
  .Format = True
  .Font.Bold = tagStyleFindArray(1)
  .Font.Italic = tagStyleFindArray(2)
  .Font.Underline = tagStyleFindArray(3)
  .Font.SmallCaps = tagStyleFindArray(4)
  .Font.Subscript = tagStyleFindArray(5)
  .Font.Superscript = tagStyleFindArray(6)
  .Highlight = tagStyleFindArray(7)                                                              ' v. 3.1 update
  .Replacement.Highlight = False                                                              ' v. 3.1 update
  .MatchCase = False
  .MatchWholeWord = False
  .MatchWildcards = True
  .MatchSoundsLike = False
  .MatchAllWordForms = False
  .Execute Replace:=wdReplaceAll
End With
tagStyleFindArray(g) = False

Next


'-------------Reset everything
activeRng.Font.Reset

End Sub

Private Sub LocalStyleReplace()
Set activeRng = ActiveDocument.Range

'-------------apply styles to tags
Dim tagFindArray(22) As String              ' number of items in array should be declared here
Dim tagReplaceArray(22) As String         'and here
Dim h As Long

tagFindArray(1) = "`B|(*)|B`"
tagFindArray(2) = "`I|(*)|I`"
tagFindArray(3) = "`U|(*)|U`"
tagFindArray(4) = "`M|(*)|M`"
tagFindArray(5) = "`H|(*)|H`"
tagFindArray(6) = "`S|(*)|S`"
tagFindArray(7) = "`P|(*)|P`"
tagFindArray(8) = "`Z|(*)|Z`"
tagFindArray(9) = "`Y|(*)|Y`"
tagFindArray(10) = "`X|(*)|X`"
tagFindArray(11) = "`W|(*)|W`"
tagFindArray(12) = "`V|(*)|V`"
tagFindArray(13) = "`T|(*)|T`"
tagFindArray(14) = "`A|(*)|A`"                'v. 3.1 patch
tagFindArray(15) = "`C|(*)|C`"                 'v. 3.1 patch
tagFindArray(16) = "`D|(*)|D`"                       'v. 3.1 patch
tagFindArray(17) = "`F|(*)|F`"
tagFindArray(18) = "`K|(*)|K`"          'v. 3.7 added
tagFindArray(19) = "`N|(*)|N`"          'v. 3.7 added
tagFindArray(20) = "`Q|(*)|Q`"          'v. 3.7 added
tagFindArray(21) = "`E|(*)|E`"
tagFindArray(22) = "`G|(*)|G`"          'v. 3.8 added

tagReplaceArray(1) = ActiveDocument.Styles("span boldface characters (bf)")
tagReplaceArray(2) = ActiveDocument.Styles("span italic characters (ital)")
tagReplaceArray(3) = ActiveDocument.Styles("span underscore characters (us)")
tagReplaceArray(4) = ActiveDocument.Styles("span small caps characters (sc)")
tagReplaceArray(5) = ActiveDocument.Styles("span hyperlink (url)")
tagReplaceArray(6) = ActiveDocument.Styles("span subscript characters (sub)")
tagReplaceArray(7) = ActiveDocument.Styles("span superscript characters (sup)")
tagReplaceArray(8) = ActiveDocument.Styles("span symbols (sym)")
' the last 9 items here are of course v. 3.1 patches
tagReplaceArray(9) = ActiveDocument.Styles("span accent characters (acc)")
tagReplaceArray(10) = ActiveDocument.Styles("span cross-reference (xref)")
tagReplaceArray(11) = ActiveDocument.Styles("span material to come (tk)")
tagReplaceArray(12) = ActiveDocument.Styles("span carry query (cq)")
tagReplaceArray(13) = ActiveDocument.Styles("span key phrase (kp)")
tagReplaceArray(14) = ActiveDocument.Styles("span bold ital (bem)")
tagReplaceArray(15) = ActiveDocument.Styles("span smcap bold (scbold)")
tagReplaceArray(16) = ActiveDocument.Styles("span smcap ital (scital)")
tagReplaceArray(17) = ActiveDocument.Styles("span preserve characters (pre)")
tagReplaceArray(18) = ActiveDocument.Styles("bookmaker keep together (kt)")          'v. 3.7 added
tagReplaceArray(19) = ActiveDocument.Styles("bookmaker force page break (br)")          'v. 3.7 added
tagReplaceArray(20) = ActiveDocument.Styles("span ISBN (isbn)")          'v. 3.7 added
tagReplaceArray(21) = ActiveDocument.Styles("span symbols ital (symi)")         ' v. 3.8 added
tagReplaceArray(22) = ActiveDocument.Styles("span symbols bold (symb)")         ' v. 3.8 added


For h = 1 To UBound(tagFindArray())
With activeRng.Find
  .ClearFormatting
  .Replacement.ClearFormatting
  .Text = tagFindArray(h)
  .Replacement.Text = "\1"
  .Wrap = wdFindContinue
  .Format = True
  .Replacement.Style = tagReplaceArray(h)
  .MatchCase = False
  .MatchWholeWord = False
  .MatchWildcards = True
  .MatchSoundsLike = False
  .MatchAllWordForms = False
  .Execute Replace:=wdReplaceAll
End With
Next


End Sub

Private Sub zz_clearFind()

Dim clearRng As Range
Set clearRng = ActiveDocument.Words.First

With clearRng.Find
  .ClearFormatting
  .Replacement.ClearFormatting
  .Text = ""
  .Replacement.Text = ""
  .Wrap = wdFindStop
  .Format = False
  .MatchCase = False
  .MatchWholeWord = False
  .MatchWildcards = False
  .MatchSoundsLike = False
  .MatchAllWordForms = False
  .Execute
End With
End Sub

Function zz_templateCheck()

zz_templateCheck = False
Dim mainDoc As Document
Set mainDoc = ActiveDocument

'-------Check if Macmillan template is attached--------------
Dim currentTemplate As String
Dim ourTemplate1 As String
Dim ourTemplate2 As String
Dim ourTemplate3 As String

currentTemplate = mainDoc.BuiltInDocumentProperties(wdPropertyTemplate)
ourTemplate1 = "macmillan.dotm"
ourTemplate2 = "macmillan_NoColor.dotm"
ourTemplate3 = "MacmillanCoverCopy.dotm"

Debug.Print "Current template is " & currentTemplate & vbNewLine

If currentTemplate <> ourTemplate1 Then
    If currentTemplate <> ourTemplate2 Then
        If currentTemplate <> ourTemplate3 Then
            MsgBox "Please attach the Macmillan Style Template to this document and run the macro again."
            Exit Function
        End If
    End If
End If

End Function

Function zz_errorChecks()

zz_errorChecks = False
Dim mainDoc As Document
Set mainDoc = ActiveDocument
Dim iReply As Integer

'-----make sure document is saved
Dim docSaved As Boolean                                                                                                 'v. 3.1 update
docSaved = mainDoc.Saved
If docSaved = False Then
    iReply = MsgBox("Your document '" & mainDoc & "' contains unsaved changes." & vbNewLine & vbNewLine & _
        "Click OK and I will save your document and run the macro." & vbNewLine & vbNewLine & "Click 'Cancel' to exit.", vbOKCancel, "Alert")
    If iReply = vbOK Then
        mainDoc.Save
    Else
        zz_errorChecks = True
        Exit Function
    End If
End If

'-----test protection
If ActiveDocument.ProtectionType <> wdNoProtection Then
MsgBox "Uh oh ... protection is enabled on document '" & mainDoc & "'." & vbNewLine & "Please unprotect the document and run the macro again." & vbNewLine & vbNewLine & "TIP: If you don't know the protection password, try pasting contents of this file into a new file, and run the macro on that.", , "Error 2"
zz_errorChecks = True
Exit Function
End If

'-----test if backtick style tag already exists
Set activeRng = ActiveDocument.Range
Application.ScreenUpdating = False

Dim existingTagArray(3) As String                                   ' number of items in array should be declared here
Dim b As Long
Dim foundBad As Boolean
foundBad = False

existingTagArray(1) = "`[0-9]`"
existingTagArray(2) = "`[A-Z]|"
existingTagArray(3) = "|[A-Z]`"

For b = 1 To UBound(existingTagArray())
With activeRng.Find
  .ClearFormatting
  .Text = existingTagArray(b)
  .Wrap = wdFindContinue
  .MatchWildcards = True
End With
If activeRng.Find.Execute Then foundBad = True: Exit For
Next

Application.ScreenUpdating = True
Application.ScreenRefresh
If foundBad = True Then                'If activeRng.Find.Execute Then
MsgBox "Something went wrong! The macro cannot be run on Document:" & vbNewLine & "'" & mainDoc & "'" & vbNewLine & vbNewLine & "Please contact Digital Workflow group for support, I am sure they will be happy to help.", , "Error Code: 1"
zz_errorChecks = True
End If
End Function

Sub MacmillanStyleReport()

'-----------run preliminary error checks------------
Dim exitOnError As Boolean
exitOnError = srErrorCheck()

If exitOnError <> False Then
Exit Sub
End If

''''''''''''''''''''''
''Timer opening
'Dim aTime As Double, bTime As Double
'aTime = Timer

'''''''''''''''''''''
Dim activeDoc As Document
Set activeDoc = ActiveDocument
Dim stylesGood() As String
Dim stylesGoodLong As Long
stylesGoodLong = 400                                    'could maybe reduce this number
ReDim stylesGood(stylesGoodLong)
Dim stylesBad(100) As String                            'could maybe reduce this number too
Dim styleGoodCount As Integer
Dim styleBadCount As Integer
Dim styleBadOverflow As Boolean
Dim activeParaCount As Integer
Dim J As Integer, K As Integer, L As Integer
Dim paraStyle As String
'''''''''''''''''''''
Dim activeParaRange As Range
Dim pageNumber As Integer
Dim activeDocName As String
Dim activeDocPath As String
Dim styleReportDoc As String
Dim fnum As Integer
Dim TheOS As String
TheOS = System.OperatingSystem
activeDocName = Left(activeDoc.Name, InStrRev(activeDoc.Name, ".doc") - 1)
activeDocPath = Replace(activeDoc.Path, activeDoc.Name, "")

Application.DisplayStatusBar = True
Application.ScreenUpdating = False

'Alter built-in Normal (Web) style temporarily (later, maybe forever?)
ActiveDocument.Styles("Normal (Web)").NameLocal = "_"

' Collect all styles being used
styleGoodCount = 0
styleBadCount = 0
styleBadOverflow = False
activeParaCount = activeDoc.paragraphs.Count
For J = 1 To activeParaCount
    'Next two lines are for the status bar
    Application.StatusBar = "Checking paragraph: " & J & " of " & activeParaCount
    If J Mod 100 = 0 Then DoEvents
    paraStyle = activeDoc.paragraphs(J).Style
        'If InStrRev(paraStyle, ")", -1, vbTextCompare) Then        'ALT calculation to "Right", can speed test
    If Right(paraStyle, 1) = ")" Then
        For K = 1 To styleGoodCount
            If paraStyle = stylesGood(K) Then                   'stylereport bug fix #1  v. 3.1
                K = styleGoodCount                              'stylereport bug fix #1    v. 3.1
                Exit For                                        'stylereport bug fix #1   v. 3.1
            End If                                              'stylereport bug fix #1   v. 3.1
        Next K
        If K = styleGoodCount + 1 Then
            styleGoodCount = K
            stylesGood(styleGoodCount) = paraStyle
        End If
    Else
        For L = 1 To styleBadCount
            'If paraStyle = stylesBad(L) Then Exit For                  'Not needed, since we want EVERY instance of bad style
        Next L
        If L > 100 Then
                styleBadOverflow = True
            Exit For
        End If
        If L = styleBadCount + 1 Then
            styleBadCount = L
            Set activeParaRange = ActiveDocument.paragraphs(J).Range
            pageNumber = activeParaRange.Information(wdActiveEndPageNumber)                 'alt: (wdActiveEndAdjustedPageNumber)
            stylesBad(styleBadCount) = "Page " & pageNumber & " (Paragraph " & J & "): " & vbTab & paraStyle
        End If
    End If
Next J
 
'Change Normal (Web) back (if you want to)
ActiveDocument.Styles("Normal (Web),_").NameLocal = "Normal (Web)"

'Sort good styles
If K <> 0 Then
ReDim Preserve stylesGood(K)
WordBasic.SortArray stylesGood()
End If

'create text file
styleReportDoc = activeDocPath & activeDocName & "_StyleReport.txt"

''''for 32 char Mc OS bug- could check if this is Mac OS too< PART 1
If Not TheOS Like "*Mac*" Then                      'If Len(activeDocName) > 18 Then        (legacy, does not take path into account)
    styleReportDoc = activeDocPath & "\" & activeDocName & "_StyleReport.txt"
Else
    Dim styleReportDocAlt As String
    Dim placeholdDocName As String
    placeholdDocName = "filenamePlacehold_Styleport.txt"
    styleReportDocAlt = styleReportDoc
    styleReportDoc = "Macintosh HD:private:tmp:" & placeholdDocName
End If

'set and open file for output
fnum = FreeFile()
Open styleReportDoc For Output As fnum
Print #fnum, "-----" & styleGoodCount & " Macmillan Styles In Use: -----"   '"----- Good Styles In Use: -----"
    For J = 1 To styleGoodCount
        Print #fnum, stylesGood(J)
    Next J
Print #fnum, vbCr
Print #fnum, vbCr
If styleBadCount <> 0 Then
    Print #fnum, "----- " & styleBadCount & " PARAGRAPHS WITH BAD STYLES FOUND: ----- " & vbCr
    Print #fnum, "(Please apply Macmillan styles to the following paragraphs:)",
    Print #fnum, vbCr
    For J = 1 To styleBadCount
        Print #fnum, stylesBad(J)
    Next J
Else
    Print #fnum, "----- great job! no bad paragraph styles found ----- "
End If
Close #fnum

Application.ScreenUpdating = True
Application.ScreenRefresh

''''for 32 char Mc OS bug-<PART 2
If styleReportDocAlt <> "" Then
Name styleReportDoc As styleReportDocAlt
End If

If styleBadOverflow = True Then
MsgBox "Macmillan Style Report has finished running." & vbCr & "PLEASE NOTE: more than 100 paragraphs have non-Macmillan styles." & vbCr & "Only the first 100 are shown in the Style report.", , "Alert"
Else
MsgBox "The Macmillan Style Report macro has finished running. Go take a look at the results!"
End If

'open Style Report for user once it is complete.
Dim Shex As Object

If Not TheOS Like "*Mac*" Then
   Set Shex = CreateObject("Shell.Application")
   Shex.Open (styleReportDoc)
Else
    MacScript ("tell application ""Finder"" " & vbCr & _
    "open document file " & """" & styleReportDocAlt & """" & vbCr & _
    "activate" & vbCr & _
    "end tell" & vbCr)
End If

''Timer closing
'bTime = Timer
'MsgBox "CreateStyleListEBranch: " & Format(Round(bTime - aTime, 2), "00:00:00") & " for " & activeParaCount & " paragraphs"
End Sub

Function srErrorCheck()

srErrorCheck = False
Dim mainDoc As Document
Set mainDoc = ActiveDocument
Dim iReply As Integer

'-------Check if Macmillan template is attached--------------
Dim currentTemplate As String
Dim ourTemplate1 As String
Dim ourTemplate2 As String
Dim ourTemplate3 As String

currentTemplate = ActiveDocument.BuiltInDocumentProperties(wdPropertyTemplate)
ourTemplate1 = "macmillan.dotm"
ourTemplate2 = "macmillan_NoColor.dotm"
ourTemplate3 = "MacmillanCoverCopy.dotm"

Debug.Print "Current template is " & currentTemplate & vbNewLine

If currentTemplate <> ourTemplate1 Then
    If currentTemplate <> ourTemplate2 Then
        If currentTemplate <> ourTemplate3 Then
            MsgBox "Please attach the Macmillan Style Template to this document and run the macro again."
            Exit Function
        End If
    End If
End If

'-----make sure document is saved
Dim docSaved As Boolean
docSaved = mainDoc.Saved
If docSaved = False Then
    iReply = MsgBox("Your document '" & mainDoc & "' contains unsaved changes." & vbNewLine & vbNewLine & _
        "Click OK, and I will save the document and run the Style Report." & vbNewLine & vbNewLine & "Click 'Cancel' to exit.", vbOKCancel, "Alert")
    If iReply = vbOK Then
        mainDoc.Save
    Else
        srErrorCheck = True
        Exit Function
    End If
End If

End Function
Sub StylesViewLaunch()
' added by EW for v. 3.2
' runs different macros based on OS
' Set button and keyboard shortcut to run this macro

'Test the conditional compiler constant
    #If Mac Then
        'I am a Mac and will test if it is Word 2011 or higher
        If Val(Application.Version) > 14 Then
            Call Mac_BestStylesView
        End If
    #Else
        'I am Windows
        Call PC_BestStylesView
        #End If

End Sub
Sub PC_BestStylesView()
' added by EW for v. 3.2
' Setup for PC

Application.TaskPanes(wdTaskPaneFormatting).Visible = True          'Opens Styles Pane
Application.TaskPanes(wdTaskPaneStyleInspector).Visible = True     'Opens Style Inspector
ActiveDocument.FormattingShowFont = True                                     'Selects three center boxes in Styles Pane Options
ActiveDocument.FormattingShowParagraph = True
ActiveDocument.FormattingShowNumbering = True
ActiveDocument.FormattingShowFilter = wdShowFilterStylesAll         'Shows all styles
ActiveDocument.StyleSortMethod = wdStyleSortByName                     'Sorts styles alphabetically
ActiveDocument.ActiveWindow.View.ShowAll = True                          'Shows nonprinting characters and hidden text
ActiveDocument.ActiveWindow.View.Type = wdNormalView              'Switches to Normal/Draft view
ActiveDocument.ActiveWindow.StyleAreaWidth = InchesToPoints(1.5)                           'Sets Styles margin area in draft view to 1.5 in.

End Sub
Sub Mac_BestStylesView()
' added by EW for v. 3.2
' Setup for Mac

Application.Dialogs(1755).Display                                                       'opens the Styles Toolbox! Hurray!
ActiveDocument.ActiveWindow.View.ShowAll = True                         'Shows nonprinting characters and hidden text
ActiveDocument.ActiveWindow.View.Type = wdNormalView                'Switches to Normal/Draft view
ActiveDocument.ActiveWindow.StyleAreaWidth = InchesToPoints(1.5)                           'Sets Styles margin area in draft view to 1.5 in.
End Sub
