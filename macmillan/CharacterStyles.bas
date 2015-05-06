Attribute VB_Name = "CharacterStyles"
Option Explicit
Option Base 1
Dim activeRng As Range
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Sub Doze(ByVal lngPeriod As Long)
DoEvents
Sleep lngPeriod
' Call it in desired location to sleep for 1 seconds like this:
' Doze 1000
End Sub
Sub MacmillanCharStyles()
'Created by Erica Warren -- erica.warren@macmillan.com
'Split off from MacmillanCleanupMacro: https://github.com/macmillanpublishers/Word-template/blob/master/macmillan/CleanupMacro.bas

'------------------Time Start-----------------
'Dim StartTime As Double
'Dim SecondsElapsed As Double

'Remember time when macro starts
'StartTime = Timer

''-----------------Error checks---------------
Dim exitOnError As Boolean

exitOnError = zz_errorChecks()   ''Doc is unsaved, protected, or uses backtick character?
If exitOnError = True Then
Exit Sub
End If

exitOnError = zz_templateCheck()   '' template is attached?
If exitOnError = True Then
Exit Sub
End If

'------------record status of current status bar and then turn on-------
Dim currentStatusBar As Boolean
currentStatusBar = Application.DisplayStatusBar
Application.DisplayStatusBar = True

'--------Progress Bar------------------------------
'Percent complete and status for progress bar (PC) and status bar (Mac)
'Requires ProgressBar custom UserForm and Class
Dim sglPercentComplete As Single
Dim strStatus As String
Dim strTitle As String

'First status shown will be randomly pulled from array, for funzies
Dim funArray() As String
ReDim funArray(1 To 10)      'Declare bounds of array here

funArray(1) = "* Mixing metaphors..."
funArray(2) = "* Arguing about the serial comma..."
funArray(3) = "* Un-mixing metaphors..."
funArray(4) = "* Avoiding the passive voice..."
funArray(5) = "* Ending sentences in prepositions..."
funArray(6) = "* Splitting infinitives..."
funArray(7) = "* Ooh, what an interesting manuscript..."
funArray(8) = "* Un-dangling modifiers..."
funArray(9) = "* Jazzing up author bio..."
funArray(10) = "* Filling in plot holes..."

Dim x As Integer

'Rnd returns random number between (0,1], rest of expression is to return an integer (1,10)
Randomize           'Sets seed for Rnd below to value of system timer
x = Int(UBound(funArray()) * Rnd()) + 1

'Debug.Print x

strTitle = "Macmillan Character Styles Macro"
sglPercentComplete = 0.05
strStatus = funArray(x)

'All Progress Bar statements for PC only because won't run modeless on Mac
Dim TheOS As String
TheOS = System.OperatingSystem

If Not TheOS Like "*Mac*" Then
    Dim oProgressChar As ProgressBar
    Set oProgressChar = New ProgressBar

    oProgressChar.Title = strTitle
    oProgressChar.Show

    oProgressChar.Increment sglPercentComplete, strStatus
    Doze 50 'Wait 50 milliseconds for progress bar to update
Else
    'Mac will just use status bar
    Application.StatusBar = strTitle & " " & (100 * sglPercentComplete) & "% complete | " & strStatus
    DoEvents
End If

Application.ScreenUpdating = False

'--------save the current cursor location in a bookmark---------------------------
ActiveDocument.Bookmarks.Add Name:="OriginalInsertionPoint", Range:=Selection.Range

'-----------Turn off track changes--------
Dim currentTracking As Boolean
currentTracking = ActiveDocument.TrackRevisions
ActiveDocument.TrackRevisions = False

'===================== Replace Local Styles Start ========================


'-----------------------Tag space break styles----------------------------
Call zz_clearFind                          'Clear find object

sglPercentComplete = 0.15
strStatus = "* Preserving styled whitespace..." & vbCr & strStatus

If Not TheOS Like "*Mac*" Then
    oProgressChar.Increment sglPercentComplete, strStatus
    Doze 50 'Wait 50 milliseconds for progress bar to update
Else
    'Mac will just use status bar
    Application.StatusBar = strTitle & " " & (100 * sglPercentComplete) & "% complete | " & strStatus
    DoEvents
End If

Call PreserveWhiteSpaceinBrkStylesA     'Part A tags styled blank paragraphs so they don't get deleted
Call zz_clearFind

'----------------------------Fix hyperlinks---------------------------------------
sglPercentComplete = 0.25
strStatus = "* Applying styles to hyperlinks..." & vbCr & strStatus

If Not TheOS Like "*Mac*" Then
    oProgressChar.Increment sglPercentComplete, strStatus
    Doze 50 'Wait 50 milliseconds for progress bar to update
Else
    'Mac will just use status bar
    Application.StatusBar = strTitle & " " & (100 * sglPercentComplete) & "% complete | " & strStatus
    DoEvents
End If

Call StyleHyperlinks                    'Styles hyperlinks, must be performed after PreserveWhiteSpaceinBrkStylesA
Call zz_clearFind

'--------------------------Remove unstyled space breaks---------------------------
sglPercentComplete = 0.4
strStatus = "* Removing unstyled breaks..." & vbCr & strStatus

If Not TheOS Like "*Mac*" Then
    oProgressChar.Increment sglPercentComplete, strStatus
    Doze 50 'Wait 50 milliseconds for progress bar to update
Else
    'Mac will just use status bar
    Application.StatusBar = strTitle & " " & (100 * sglPercentComplete) & "% complete | " & strStatus
    DoEvents
End If

Application.ScreenUpdating = False
Call RemoveBreaks  ''new sub v. 3.7, removed manual page breaks and multiple paragraph returns
Call zz_clearFind
Application.ScreenUpdating = True
'--------------------------Tag existing character styles------------------------
sglPercentComplete = 0.55
strStatus = "* Tagging character styles..." & vbCr & strStatus

If Not TheOS Like "*Mac*" Then
    oProgressChar.Increment sglPercentComplete, strStatus
    Doze 50     'Wait 50 milliseconds for progress bar to update
Else
    'Mac will just use status bar
    Application.StatusBar = strTitle & " " & (100 * sglPercentComplete) & "% complete | " & strStatus
    DoEvents
End If

Application.ScreenUpdating = False
DoEvents
Call TagExistingCharStyles            'tag existing styled items
Call zz_clearFind
Application.ScreenUpdating = True
DoEvents

'-------------------------Tag direct formatting----------------------------------
sglPercentComplete = 0.7
strStatus = "* Tagging direct formatting..." & vbCr & strStatus

If Not TheOS Like "*Mac*" Then
    oProgressChar.Increment sglPercentComplete, strStatus
    Doze 50 'Wait 50 milliseconds for progress bar to update
Else
    'Mac will just use status bar
    Application.StatusBar = strTitle & " " & (100 * sglPercentComplete) & "% complete | " & strStatus
    DoEvents
End If

Call LocalStyleTag                 'tag local styling, reset local styling, remove text highlights
Call zz_clearFind

'----------------------------Apply Macmillan character styles to tagged text--------
sglPercentComplete = 0.85
strStatus = "* Applying Macmillan character styles..." & vbCr & strStatus

If Not TheOS Like "*Mac*" Then
    oProgressChar.Increment sglPercentComplete, strStatus
    Doze 50 'Wait 50 milliseconds for progress bar to update
Else
    'Mac will just use status bar
    Application.StatusBar = strTitle & " " & (100 * sglPercentComplete) & "% complete | " & strStatus
    DoEvents
End If

Call LocalStyleReplace            'reapply local styling through char styles
Call zz_clearFind

'---------------------------Remove tags from styled space breaks---------------------
sglPercentComplete = 0.95
strStatus = "* Cleaning up styled whitespace..." & vbCr & strStatus

If Not TheOS Like "*Mac*" Then
    oProgressChar.Increment sglPercentComplete, strStatus
    Doze 50 'Wait 50 milliseconds for progress bar to update
Else
    'Mac will just use status bar
    Application.StatusBar = strTitle & " " & (100 * sglPercentComplete) & "% complete | " & strStatus
    DoEvents
End If

Call PreserveWhiteSpaceinBrkStylesB     'Part B removes the tags and reapplies the styles
Call zz_clearFind

'---------------------------Return settings to original------------------------------
sglPercentComplete = 1
strStatus = "* Finishing up..." & vbCr & strStatus

If Not TheOS Like "*Mac*" Then
    oProgressChar.Increment sglPercentComplete, strStatus
    Doze 50 'Wait 50 milliseconds for progress bar to update
Else
    'Mac will just use status bar
    Application.StatusBar = strTitle & " " & (100 * sglPercentComplete) & "% complete | " & strStatus
    DoEvents
End If

'Go back to original insertion point and delete bookmark
Selection.GoTo what:=wdGoToBookmark, Name:="OriginalInsertionPoint"
ActiveDocument.Bookmarks("OriginalInsertionPoint").Delete

ActiveDocument.TrackRevisions = currentTracking         ' return track changes to original setting
Application.DisplayStatusBar = currentStatusBar
Application.ScreenUpdating = True
Application.ScreenRefresh

If Not TheOS Like "*Mac*" Then
    Unload oProgressChar
End If

MsgBox "Macmillan character styles have been applied throughout your manuscript."


'----------------------Timer End-------------------------------------------
'Determine how many seconds code took to run
'  SecondsElapsed = Round(Timer - StartTime, 2)

'Notify user in seconds
'  Debug.Print "This code ran successfully in " & SecondsElapsed & " seconds"

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

Private Sub RemoveBreaks()
'Created v. 3.7


Set activeRng = ActiveDocument.Range

Dim wsFindArray(3) As String              'number of items in array should be declared here
Dim wsReplaceArray(3) As String       'and here
Dim q As Long

wsFindArray(1) = "^m^13"              'manual page breaks
wsFindArray(2) = "^13{2,}"          '2 or more paragraphs
wsFindArray(3) = "(`[0-9]``)^13"    'remove para following a preserved break style                     v. 3.1 patch

wsReplaceArray(1) = "^p"
wsReplaceArray(2) = "^p"
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

'Debug.Print "Current template is " & currentTemplate & vbNewLine

If currentTemplate <> ourTemplate1 Then
    If currentTemplate <> ourTemplate2 Then
        If currentTemplate <> ourTemplate3 Then
            MsgBox "Please attach the Macmillan Style Template to this document and run the macro again."
            zz_templateCheck = True
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

End Function