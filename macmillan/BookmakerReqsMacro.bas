Attribute VB_Name = "Reports"
Option Explicit

Sub BookmakerReqs()
'-----------------------------------------------------------

'Created by Erica Warren - erica.warren@macmillan.com
'4/10/2015: adding handling of track changes
'4/3/2015: adding Imprint Line requirement
'3/27/2015: converts solo CNs to CTs
'           page numbers added to Illustrations List
'           Added style report WITH character styles
'3/20/2015: Added check if template is attached
'3/17/2015: Added Illustrations List
'3/16/2015: Fixed error creating text file, added title/author/isbn confirmation

'------------------------------------------------------------


Application.ScreenUpdating = False

'-------Check if Macmillan template is attached--------------

Dim currentTemplate As String
Dim ourTemplate1 As String
Dim ourTemplate2 As String

currentTemplate = ActiveDocument.BuiltInDocumentProperties(wdPropertyTemplate)
ourTemplate1 = "macmillan.dotm"
ourTemplate2 = "macmillan_NoColor.dotm"

Debug.Print "Current template is " & currentTemplate & vbNewLine

If currentTemplate <> ourTemplate1 Then
    If currentTemplate <> ourTemplate2 Then
        MsgBox "Please attach the Macmillan Style Template to this document and run the macro again."
        Exit Sub
    End If
End If


'-----make sure document is saved--------------------------

Dim mainDoc As Document
Set mainDoc = ActiveDocument
Dim iReply As Integer
Dim docSaved As Boolean

docSaved = mainDoc.Saved
If docSaved = False Then
    iReply = MsgBox("Your document '" & mainDoc & "' contains unsaved changes." & vbNewLine & vbNewLine & _
        "Click OK and I will save your document and run the macro." & vbNewLine & vbNewLine & "Click 'Cancel' to exit.", _
            vbOKCancel, "Alert")
    If iReply = vbOK Then
        mainDoc.Save
    Else
        Exit Sub
    End If
End If

'-------Delete content controls on PC------------------------
'Has to be a separate sub because objects don't exist in Word 2011 Mac and it breaks
Dim TheOS As String
TheOS = System.OperatingSystem

If Not TheOS Like "*Mac*" Then
    Call DeleteContentControlPC
End If


'-------Deal with Track Changes and Comments----------------
Dim n As Long
Dim oComments As Comments
Set oComments = ActiveDocument.Comments

Application.DisplayAlerts = False

'Turn off track changes
ActiveDocument.TrackRevisions = False

'See if there are tracked changes or comments in document
On Error Resume Next
Selection.HomeKey Unit:=wdStory   'start search at beginning of doc
WordBasic.NextChangeOrComment       'search for a tracked change or comment. error if none are found.

'If there are changes, ask user if they want macro to accept changes or cancel
If Err = 0 Then
    If MsgBox("Bookmaker doesn't like comments or tracked changes, but it appears that you have some in your document." _
        & vbCr & vbCr & "Click OK to ACCEPT ALL CHANGES and DELETE ALL COMMENTS right now and continue with the Bookmaker Requirements Check." _
        & vbCr & vbCr & "Click CANCEL to stop the Bookmaker Requirements Check and deal with the tracked changes and comments on your own.", _
        273, "Are those tracked changes I see?") = vbCancel Then           '273 = vbOkCancel(1) + vbCritical(16) + vbDefaultButton2(256)
            Exit Sub
    Else 'User clicked OK, so accept all tracked changes and delete all comments
        ActiveDocument.AcceptAllRevisions
        For n = oComments.Count To 1 Step -1
            oComments(n).Delete
        Next n
        Set oComments = Nothing
    End If
End If

On Error GoTo 0
Application.DisplayAlerts = True

'-------Check that only approved tor.com styles are used-----
Dim paraStyle As String
Dim activeParaCount As Integer
Dim badStyles(100) As String        'Increase number if want to count more bad styles
Dim badCount As Integer
Dim activeParaRange As Range
Dim pageNumber As Integer
Dim d As Integer

badCount = 0
activeParaCount = ActiveDocument.Paragraphs.Count

For d = 1 To activeParaCount
    paraStyle = ActiveDocument.Paragraphs(d).Style
    
    'Debug.Print ActiveDocument.Paragraphs(A).Style & vbNewLine
    
     'Broken down into multiple statements because max 24 line continuation characters in a statement
     'And also most common styles listed in first IF-THEN so it won't have to search all most of the time
    If paraStyle <> "Text - Standard (tx)" And _
        paraStyle <> "Text - Standard Space After (tx#)" And _
        paraStyle <> "Text - Standard Space Before (#tx)" And _
        paraStyle <> "Text - Standard Space Around (#tx#)" And _
        paraStyle <> "Text - Std No-Indent (tx1)" And _
        paraStyle <> "Text - Std No-Indent Space Before (#tx1)" And _
        paraStyle <> "Text - Std No-Indent Space After (tx1#)" And _
        paraStyle <> "Text - Std No-Indent Space Around (#tx1#)" And _
        paraStyle <> "Chap Number (cn)" And _
        paraStyle <> "Chap Title (ct)" And _
        paraStyle <> "Chap Opening Text No-Indent (cotx1)" And _
        paraStyle <> "Chap Opening Text No-Indent Space After (cotx1#)" And _
        paraStyle <> "Space Break (#)" And _
        paraStyle <> "Page Break (pb)" And _
        paraStyle <> "Halftitle Book Title (htit)" And _
        paraStyle <> "Titlepage Book Title (tit)" And _
        paraStyle <> "Titlepage Book Subtitle (stit)" And _
        paraStyle <> "Titlepage Author Name (au)" And _
        paraStyle <> "Titlepage Imprint Line (imp)" And _
        paraStyle <> "Titlepage Cities (cit)" And _
        paraStyle <> "Copyright Text single space (crtx)" And _
        paraStyle <> "Copyright Text double space (crtxd)" And _
        paraStyle <> "Space Break with Ornament (orn)" And _
        paraStyle <> "Dedication (ded)" And _
        paraStyle <> "Dedication Author (dedau)" Then
            If paraStyle <> "Ad Card Main Head (acmh)" And _
                paraStyle <> "Ad Card Subhead (acsh)" And _
                paraStyle <> "Ad Card List of Titles (acl)" And _
                paraStyle <> "Extract Head (exth)" And _
                paraStyle <> "Extract-No Indent (ext1)" And _
                paraStyle <> "Extract (ext)" And _
                paraStyle <> "Illustration holder (ill)" And _
                paraStyle <> "Caption (cap)" And _
                paraStyle <> "Illustration Source (is)" And _
                paraStyle <> "Part Number (pn)" And _
                paraStyle <> "Part Title (pt)" And _
                paraStyle <> "Front Sales Title (fst)" And _
                paraStyle <> "Front Sales Quote NoIndent (fsq1)" And _
                paraStyle <> "Front Sales Quote (fsq)" And _
                paraStyle <> "Front Sales Quote Source (fsqs)" And _
                paraStyle <> "Epigraph – non-verse (epi)" And _
                paraStyle <> "Epigraph – verse (epiv)" And _
                paraStyle <> "Epigraph Source (eps)" And _
                paraStyle <> "Chap Epigraph – non-verse (cepi)" And _
                paraStyle <> "Chap Epigraph – verse (cepiv)" And _
                paraStyle <> "Chap Epigraph Source (ceps)" And _
                paraStyle <> "Text - Standard ALT (atx)" And _
                paraStyle <> "Text - Std No-Indent ALT (atx1)" And _
                paraStyle <> "Text - Computer Type No-Indent (com1)" And _
                paraStyle <> "Text - Computer Type (com)" Then
                    If paraStyle <> "Titlepage Contributor Name (con)" And _
                        paraStyle <> "Titlepage Translator Name (tran)" And _
                        paraStyle <> "FM Head (fmh)" And _
                        paraStyle <> "FM Subhead (fmsh)" And _
                        paraStyle <> "FM Epigraph – non-verse (fmepi)" And _
                        paraStyle <> "FM Epigraph – verse (fmepiv)" And _
                        paraStyle <> "FM Epigraph Source (fmeps)" And _
                        paraStyle <> "FM Text (fmtx)" And _
                        paraStyle <> "FM Text Space After (fmtx#)" And _
                        paraStyle <> "FM Text Space Before (#fmtx)" And _
                        paraStyle <> "FM Text Space Around (#fmtx#)" And _
                        paraStyle <> "FM Text No-Indent (fmtx1)" And _
                        paraStyle <> "FM Text No-Indent Space Before (#fmtx1)" And _
                        paraStyle <> "FM Text No-Indent Space After (fmtx1#)" And _
                        paraStyle <> "FM Text No-Indent Space Around (#fmtx1#)" And _
                        paraStyle <> "Chap Ornament (corn)" And _
                        paraStyle <> "Chap Ornament ALT (corn2)" And _
                        paraStyle <> "Space Break - 3-Line (ls3)" And _
                        paraStyle <> "Space Break - 2-Line (ls2)" And _
                        paraStyle <> "Space Break - 1-Line (ls1)" And _
                        paraStyle <> "Space Break with ALT Ornament (orn2)" And _
                        paraStyle <> "Chap Title Nonprinting (ctnp)" And _
                        paraStyle <> "Front Sales Text (fstx)" And _
                        paraStyle <> "Chap Opening Text Space After (cotx#)" And _
                        paraStyle <> "Chap Opening Text (cotx)" Then
                            
                            badCount = badCount + 1
                            Set activeParaRange = ActiveDocument.Paragraphs(d).Range
                            pageNumber = activeParaRange.Information(wdActiveEndPageNumber)
                            badStyles(badCount) = "**ERROR: Bad style on page " & pageNumber & " (Paragraph " & d & "): " & _
                                vbTab & paraStyle & vbNewLine & vbNewLine
                    End If
            End If
    End If
Next



'-------Count number of occurences of each required style----

Dim styleName(7) As String                      ' Declare number of items in array
Dim styleCount(7) As Integer                    ' ditto
Dim A As Long
Dim xCount As Integer

styleName(1) = "Titlepage Book Title (tit)"
styleName(2) = "Titlepage Author Name (au)"
styleName(3) = "span ISBN (isbn)"
styleName(4) = "Chap Number (cn)"
styleName(5) = "Chap Title (ct)"
styleName(6) = "Chap Title Nonprinting (ctnp)"
styleName(7) = "Titlepage Imprint Line (imp)"

For A = 1 To UBound(styleName())
    xCount = 0
    
    With ActiveDocument.Range.Find
        .ClearFormatting
        .Text = ""
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindStop
        .Format = True
        .Style = ActiveDocument.Styles(styleName(A))
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
    Do While .Execute(Forward:=True) = True And xCount < 100   'xCount < 100 to precent infinite loop, especially if content controls in title or author blocks
        styleCount(A) = styleCount(A) + 1
        xCount = xCount + 1
    Loop
    End With
Next

Debug.Print styleName(1) & ": " & styleCount(1) & vbNewLine _
            ; styleName(2) & ": " & styleCount(2) & vbNewLine _
            ; styleName(3) & ": " & styleCount(3) & vbNewLine _
            ; styleName(4) & ": " & styleCount(4) & vbNewLine _
            ; styleName(5) & ": " & styleCount(5) & vbNewLine _
            ; styleName(6) & ": " & styleCount(6) & vbNewLine _
            ; styleName(7) & ": " & styleCount(7) & vbNewLine
            
'------------Exit Sub if exactly 10 Titles styled, suggests hidden content controls-----
If styleCount(1) = 100 Then
    
    MsgBox "Something went wrong!" & vbCr & vbCr & "It looks like you might have content controls (form fields or drop downs) in your document, but Word for Mac doesn't play nicely with these." _
    & vbCr & vbCr & "Try running this macro on a PC or contact workflows@macmillan.com for assistance.", vbCritical, "OH NO!!"

    Exit Sub
    
End If
    
            
'------------Convert solo Chap Number paras to Chap Title-------

If styleCount(4) > 0 And styleCount(5) = 0 Then         'If Chap Num > 0 and Chap Title = 0

'Move selection to start of document
Selection.HomeKey Unit:=wdStory

    Selection.Find.ClearFormatting
    Selection.Find.Style = ActiveDocument.Styles("Chap Number (cn)")
    Selection.Find.Replacement.ClearFormatting
    Selection.Find.Replacement.Style = ActiveDocument.Styles("Chap Title (ct)")
    With Selection.Find
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
    End With
    Selection.Find.Execute Replace:=wdReplaceAll
    
End If

'--------Get title/author/isbn/illustration text from document-----------

Dim styleNameB(4) As String         ' must declare number of items in array here
Dim bString(4) As String            ' and here
Dim b As Integer

styleNameB(1) = "Titlepage Book Title (tit)"
styleNameB(2) = "Titlepage Author Name (au)"
styleNameB(3) = "span ISBN (isbn)"
styleNameB(4) = "Titlepage Imprint Line (imp)"

For b = 1 To UBound(styleNameB())
    bString(b) = GetText(styleNameB(b))
Next b

Debug.Print "Title: " & vbNewLine & _
            bString(1) & vbNewLine & _
            "Author: " & vbNewLine & _
            bString(2) & vbNewLine & _
            "ISBN: " & vbNewLine & _
            bString(3) & vbNewLine & _
            "Imprint: " & vbNewLine & _
            bString(4) & vbNewLine
            
'-------------------Get Illustrations List from Document-----------

Dim cString(1000) As String             'Max number of illustrations. Could be lower than 1000.
Dim cCount As Integer
Dim pageNumberC As Integer

cCount = 0

'Move selection to start of document
Selection.HomeKey Unit:=wdStory

    Selection.Find.ClearFormatting
    With Selection.Find
        .Text = ""
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindStop
        .Format = True
        .Style = ActiveDocument.Styles("Illustration holder (ill)")
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
    End With

Do While Selection.Find.Execute = True And cCount < 1000            'cCount < 1000 so we don't get an infinite loop
    cCount = cCount + 1
    pageNumberC = Selection.Information(wdActiveEndPageNumber)
    
    'If paragraph return exists in selection, don't select last character (the last paragraph return)
    If InStr(Selection.Text, Chr(13)) > 0 Then
        Selection.MoveEnd Unit:=wdCharacter, Count:=-1
    End If
    
    cString(cCount) = "Page " & pageNumberC & ": " & Selection.Text
    
    'If the next character is a paragraph return, add that to the selection
    'Otherwise the next Find will just select the same text with the paragraph return
    Selection.MoveEndWhile Cset:=Chr(13), Count:=wdForward
    
Loop

'Move selection back to start of document
Selection.HomeKey Unit:=wdStory

If cCount > 1000 Then
    MsgBox "You have more than 1,000 illustrations tagged in your manuscript." & vbNewLine & _
    "Please contact workflows@macmillan.com to complete your illustration list."
End If

If cCount = 0 Then
    cCount = 1
    cString(1) = "no illustrations detected" & vbNewLine
End If

Debug.Print cString(1) & cString(2) & cString(3)

'-------------------Get list of good paragraph styles from document---------

Dim activeDoc As Document
Set activeDoc = ActiveDocument
Dim stylesGood() As String
Dim stylesGoodLong As Long
stylesGoodLong = 100
ReDim stylesGood(stylesGoodLong)
Dim styleGoodCount As Integer
Dim activeParaCountJ As Integer
Dim J As Integer, K As Integer
Dim paraStyleGood As String

Application.DisplayStatusBar = True
Application.ScreenUpdating = False

'Alter built-in Normal (Web) style temporarily (later, maybe forever?)
ActiveDocument.Styles("Normal (Web)").NameLocal = "_"

' Collect all styles being used
styleGoodCount = 0
activeParaCountJ = activeDoc.Paragraphs.Count
For J = 1 To activeParaCountJ
    'Next two lines are for the status bar
    Application.StatusBar = "Checking paragraph: " & J & " of " & activeParaCount
    If J Mod 100 = 0 Then DoEvents
    
    paraStyleGood = activeDoc.Paragraphs(J).Style
    
    If Right(paraStyleGood, 1) = ")" Then
        For K = 1 To styleGoodCount
            If paraStyleGood = stylesGood(K) Then
                K = styleGoodCount
                Exit For
            End If
        Next K
        If K = styleGoodCount + 1 Then
            styleGoodCount = K
            stylesGood(styleGoodCount) = paraStyleGood
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

For K = 1 To styleGoodCount
    Debug.Print stylesGood(K)
Next

'-------------------get list of good character styles--------------

Dim charStyles As String
Dim styleNameM(21) As String        'declare number in array
Dim m As Integer

styleNameM(1) = "span italic characters (ital)"
styleNameM(2) = "span boldface characters (bf)"
styleNameM(3) = "span small caps characters (sc)"
styleNameM(4) = "span underscore characters (us)"
styleNameM(5) = "span superscript characters (sup)"
styleNameM(6) = "span subscript characters (sub)"
styleNameM(7) = "span bold ital (bem)"
styleNameM(8) = "span smcap ital (scital)"
styleNameM(9) = "span smcap bold (scbold)"
styleNameM(10) = "span symbols (sym)"
styleNameM(11) = "span accent characters (acc)"
styleNameM(12) = "span cross-reference (xref)"
styleNameM(13) = "span hyperlink (url)"
styleNameM(14) = "span material to come (tk)"
styleNameM(15) = "span carry query (cq)"
styleNameM(16) = "span preserve characters (pre)"
styleNameM(17) = "bookmaker force page break (br)"
styleNameM(18) = "bookmaker keep together (kt)"
styleNameM(19) = "span ISBN (isbn)"
styleNameM(20) = "span symbols ital (symi)"
styleNameM(21) = "span symbols bold (symb)"

'Move selection back to start of document
Selection.HomeKey Unit:=wdStory

For m = 1 To UBound(styleNameM())
    With Selection.Find
        .Style = ActiveDocument.Styles(styleNameM(m))
        .Wrap = wdFindContinue
        .Format = True
    End With
    If Selection.Find.Execute = True Then
        charStyles = charStyles & styleNameM(m) & vbNewLine
    End If
Next m

'Move selection back to start of document
Selection.HomeKey Unit:=wdStory

Debug.Print charStyles

'-------------------Create error report----------------------------

' Prepare error message
Dim errorList As String
errorList = ""
If styleCount(1) = 0 Then errorList = errorList & "**ERROR: No styled title detected." & vbNewLine & vbNewLine
If styleCount(1) > 1 Then errorList = errorList & "**ERROR: Too many title paragraphs detected. Only 1 allowed." & vbNewLine & vbNewLine
If styleCount(2) = 0 Then errorList = errorList & "**ERROR: No styled author name detected." & vbNewLine & vbNewLine
If styleCount(3) = 0 Then errorList = errorList & "**ERROR: No styled ISBN detected." & vbNewLine & vbNewLine
If styleCount(4) > 0 And styleCount(5) = 0 Then errorList = errorList & _
    "**ERROR: Chap Number (cn) cannot be the main heading for" & vbNewLine _
    & vbTab & "a chapter. Every chapter must start with Chapter Title (ct)" & vbNewLine _
    & vbTab & "style. Chap Number (cn) paragraphs have been converted to the" & vbNewLine _
    & vbTab & "Chap Title (ct) style." & vbNewLine & vbNewLine
If styleCount(4) = 0 And styleCount(5) = 0 And styleCount(6) = 0 Then errorList = errorList & _
    "**ERROR: No tagged chapter openers detected. If your book does" & vbNewLine _
    & vbTab & "not have chapter openers, use the Chap Title Nonprinting" & vbNewLine _
    & vbTab & "(ctnp) style at the start of each section." & vbNewLine & vbNewLine
If styleCount(4) > styleCount(5) And styleCount(5) > 0 Then errorList = errorList & _
    "**ERROR: More Chap Number (cn) paragraphs than Chap Title (ct)" & vbNewLine _
    & vbTab & "paragraphs found. Each Chap Number (cn) paragraph MUST be" & vbNewLine _
    & vbTab & "followed by a Chap Title (ct) paragraph." & vbNewLine & vbNewLine
If styleCount(7) = 0 Then errorList = errorList & "**ERROR: No styled Imprint Line detected." & vbNewLine & vbNewLine
If styleCount(7) > 1 Then errorList = errorList & "**ERROR: Too many Imprint Line paragraphs detected. Only 1 allowed." & vbNewLine & vbNewLine
If (styleCount(4) > 0 And styleCount(5) = 0) Or (styleCount(4) = 0 And styleCount(5) > 0) Then errorList = errorList & CheckPrevStyle("Chap Title (ct)", "Page Break (pb)")
If styleCount(4) = 0 And styleCount(5) = 0 And styleCount(6) > 0 Then errorList = errorList & CheckPrevStyle("Chap Title Nonprinting (ctnp)", "Page Break (pb)")
If styleCount(4) >= styleCount(5) Then errorList = errorList & CheckPrevStyle("Chap Number (cn)", "Page Break (pb)")
If styleCount(4) >= styleCount(5) And styleCount(5) <> 0 Then errorList = errorList & CheckPrevStyle("Chap Title (ct)", "Chap Number (cn)")

errorList = errorList & CheckAfterPB

'Add bad styles to error message
For d = 1 To badCount
    errorList = errorList & badStyles(d)
Next d

If errorList <> "" Then
    errorList = errorList & vbNewLine & "If you have any questions about how to handle these errors, " & vbNewLine & _
        "please contact workflows@macmillan.com." & vbNewLine
End If

Debug.Print errorList

'Create report file
Dim activeRng As Range
Set activeDoc = ActiveDocument
Set activeRng = ActiveDocument.Range
Dim activeDocName As String
Dim activeDocPath As String
Dim reqReportDoc As String
Dim reqReportDocAlt As String
Dim fnum As Integer

'activeDocName below works for .doc and .docx
activeDocName = Left(activeDoc.Name, InStrRev(activeDoc.Name, ".doc") - 1)
activeDocPath = Replace(activeDoc.Path, activeDoc.Name, "")

'create text file
reqReportDoc = activeDocPath & activeDocName & "_BookmakerReport.txt"

''''for 32 char Mc OS bug- could check if this is Mac OS too < PART 1
If Not TheOS Like "*Mac*" Then                      'If Len(activeDocName) > 18 Then        (legacy, does not take path into account)
    reqReportDoc = activeDocPath & "\" & activeDocName & "_BookmakerReport.txt"
Else
    Dim placeholdDocName As String
    placeholdDocName = "filenamePlacehold_Report.txt"
    reqReportDocAlt = reqReportDoc
    reqReportDoc = "Macintosh HD:private:tmp:" & placeholdDocName
End If
'''end ''''for 32 char Mc OS bug part 1

'set and open file for output
Dim e As Integer

fnum = FreeFile()
Open reqReportDoc For Output As fnum
If errorList = "" And badCount = 0 Then
    Print #fnum, vbCr
    Print #fnum, "                 CONGRATULATIONS! YOU PASSED!" & vbCr
    Print #fnum, " But you're not done yet. Please check the info listed below." & vbCr
    Print #fnum, vbCr

Else
    Print #fnum, vbCr
    Print #fnum, "                             OOPS!" & vbCr
    Print #fnum, "     Problems were found with the styles in your document." & vbCr
    Print #fnum, vbCr
    Print #fnum, vbCr
    Print #fnum, "--------------------------- ERRORS ---------------------------" & vbCr
    Print #fnum, errorList
    Print #fnum, vbCr
    Print #fnum, vbCr
End If
    Print #fnum, "--------------------------- METADATA -------------------------" & vbCr
    Print #fnum, "If any of the information below is wrong, please fix the" & vbCr
    Print #fnum, "associated styles in the manuscript." & vbCr
    Print #fnum, vbCr
    Print #fnum, "* TITLE *" & vbCr
    Print #fnum, bString(1) & vbCr
    Print #fnum, "* AUTHOR *" & vbCr
    Print #fnum, bString(2) & vbCr
    Print #fnum, "* ISBN *" & vbCr
    Print #fnum, bString(3) & vbCr
    Print #fnum, "* IMPRINT *" & vbCr
    Print #fnum, bString(4) & vbCr
    Print #fnum, vbCr
    Print #fnum, vbCr
    Print #fnum, "----------------------- ILLUSTRATION LIST ---------------------" & vbCr
    
    If cString(1) <> "no illustrations detected" & vbNewLine Then
        Print #fnum, "Verify that this list of illustrations includes only the file" & vbCr
        Print #fnum, "names of your illustrations. Be sure to place these files in" & vbCr
        Print #fnum, "the submitted_images folder BEFORE you run the bookmaker tool." & vbCr
        Print #fnum, vbCr
    End If
    
    For e = 1 To cCount
        Print #fnum, cString(e)
    Next e
       
    Print #fnum, vbCr
    Print #fnum, "----------------------- GOOD STYLES IN USE --------------------" & vbCr
    
    For K = 1 To styleGoodCount
        Print #fnum, stylesGood(K)
    Next K
    Print #fnum, charStyles

Close #fnum

''''for 32 char Mc OS bug-<PART 2
If reqReportDocAlt <> "" Then
Name reqReportDoc As reqReportDocAlt
End If
''''END for 32 char Mac OS bug-<PART 2

'----------------open Bookmaker Report for user once it is complete--------------------------.
Dim Shex As Object

If Not TheOS Like "*Mac*" Then
   Set Shex = CreateObject("Shell.Application")
   Shex.Open (reqReportDoc)
Else
    MacScript ("tell application ""TextEdit"" " & vbCr & _
    "open " & """" & reqReportDocAlt & """" & " as alias" & vbCr & _
    "activate" & vbCr & _
    "end tell" & vbCr)
End If

Application.ScreenUpdating = True

End Sub
Private Function GetText(styleName As String)
Dim fString As String
Dim fCount As Integer

fCount = 0

'Move selection to start of document
Selection.HomeKey Unit:=wdStory

    Selection.Find.ClearFormatting
    With Selection.Find
        .Text = ""
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindStop
        .Format = True
        .Style = ActiveDocument.Styles(styleName)
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
    End With

Do While Selection.Find.Execute = True And fCount < 1000            'fCount < 1000 so we don't get an infinite loop
    fCount = fCount + 1
    
    'If paragraph return exists in selection, don't select last character (the last paragraph retunr)
    If InStr(Selection.Text, Chr(13)) > 0 Then
        Selection.MoveEnd Unit:=wdCharacter, Count:=-1
    End If
    
    'Assign selected text to variable
    fString = fString & Selection.Text & vbNewLine
    
    'If the next character is a paragraph return, add that to the selection
    'Otherwise the next Find will just select the same text with the paragraph return
    Selection.MoveEndWhile Cset:=Chr(13), Count:=wdForward
Loop

'Move selection back to start of document
Selection.HomeKey Unit:=wdStory

If fCount = 0 Then
    GetText = ""
Else
    GetText = fString
End If

End Function
Function CheckPrevStyle(findStyle As String, prevStyle As String)
Dim jString As String
Dim jCount As Integer
Dim pageNum As Integer

jCount = 0
jString = ""

'Move selection to start of document
Selection.HomeKey Unit:=wdStory

'select paragraph with that style
    Selection.Find.ClearFormatting
    With Selection.Find
        .Text = ""
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindStop
        .Format = True
        .Style = ActiveDocument.Styles(findStyle)
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
    End With

Do While Selection.Find.Execute = True And jCount < 1000            'jCount < 1000 so we don't get an infinite loop
    jCount = jCount + 1
    
    'select preceding paragraph
    Selection.Previous(Unit:=wdParagraph, Count:=1).Select
    pageNum = Selection.Information(wdActiveEndPageNumber)
    
        'Check if preceding paragraph style is correct
        If Selection.Style <> prevStyle Then
            jString = jString & "**ERROR: Missing or incorrect " & prevStyle & " style on page " & pageNum & "." & vbNewLine & vbNewLine
        End If
        
        'If you're searching for a page break before, also check if manual page break is in paragraph
        If prevStyle = "Page Break (pb)" Then
            If InStr(Selection.Text, Chr(12)) = 0 Then
                jString = jString & "**ERROR: Missing manual page break on page " & pageNum & "." & vbNewLine & vbNewLine
            End If
        End If
        
    'Debug.Print jString
    
    'move the selection back to original paragraph, so it won't be
    'selected again on next search
    Selection.Next(Unit:=wdParagraph, Count:=1).Select
Loop

'Debug.Print jString

CheckPrevStyle = jString

'Move selection back to start of document
Selection.HomeKey Unit:=wdStory

End Function
Function CheckAfterPB()
Dim kString As String
Dim kCount As Integer
Dim pageNumK As Integer
Dim nextStyle As String

kCount = 0
kString = ""

'Move selection to start of document
Selection.HomeKey Unit:=wdStory

'select paragraph with that style
    Selection.Find.ClearFormatting
    With Selection.Find
        .Text = ""
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindStop
        .Format = True
        .Style = ActiveDocument.Styles("Page Break (pb)")
        .MatchCase = False
        .MatchWholeWord = False
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
    End With

Do While Selection.Find.Execute = True And kCount < 1000            'jCount < 1000 so we don't get an infinite loop
    kCount = kCount + 1
    
    'select preceding paragraph
    Selection.Next(Unit:=wdParagraph, Count:=1).Select
    pageNumK = Selection.Information(wdActiveEndPageNumber)
    
        'Check if preceding paragraph style is correct
        If Selection.Style <> "Chap Title (ct)" And _
            Selection.Style <> "Chap Number (cn)" And _
            Selection.Style <> "Chap Title Nonprinting (ctnp)" And _
            Selection.Style <> "Halftitle Book Title (htit)" And _
            Selection.Style <> "Titlepage Book Title (tit)" And _
            Selection.Style <> "Copyright Text single space (crtx)" And _
            Selection.Style <> "Copyright Text double space (crtxd)" And _
            Selection.Style <> "Dedication (ded)" And _
            Selection.Style <> "Ad Card Main Head (acmh)" And _
            Selection.Style <> "Ad Card List of Titles (acl)" And _
            Selection.Style <> "Part Title (pt)" And _
            Selection.Style <> "Part Number (pn)" And _
            Selection.Style <> "Front Sales Title (fst)" And _
            Selection.Style <> "Front Sales Quote (fsq)" And _
            Selection.Style <> "Front Sales Quote NoIndent (fsq1)" And _
            Selection.Style <> "Epigraph – non-verse (epi)" And _
            Selection.Style <> "Epigraph – verse (epiv)" And _
            Selection.Style <> "FM Head (fmh)" And _
            Selection.Style <> "Illustration holder (ill)" And _
            Selection.Style <> "Page Break (pb)" Then
                nextStyle = Selection.Style
                kString = kString & "**ERROR: Missing or incorrect Page Break or " & nextStyle & " style on page " & pageNumK & "." & vbNewLine & vbNewLine
        End If
                
    'Debug.Print kString
    
    'move the selection back to original paragraph, so it won't be
    'selected again on next search
    Selection.Previous(Unit:=wdParagraph, Count:=1).Select
Loop

'Debug.Print kString

CheckAfterPB = kString

'Move selection back to start of document
Selection.HomeKey Unit:=wdStory

End Function
Sub DeleteContentControlPC()
Dim cc As ContentControl

For Each cc In ActiveDocument.ContentControls
    cc.Delete
Next
End Sub
