#Copyright (c) 2014 Serguei Kouzmine
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.


Add-Type -Language 'VisualBasic' -TypeDefinition @"

' origin: 
' http://www.codeproject.com/Articles/7456/Drawing-a-Bar-Chart


Imports Microsoft.VisualBasic
Imports System
Imports System.Drawing
Imports System.Drawing.Drawing2D
Imports System.Collections
Imports System.Windows.Forms

Public Class BarChart

    Inherits System.Windows.Forms.Form

    Public Sub New()
        MyBase.New()
        InitializeComponent()
    End Sub

    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    Private components As System.ComponentModel.IContainer

    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(344, 302)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Sizable
        Me.Name = "BarChart"
        Me.Text = "BarChart"
        Me.components = New System.ComponentModel.Container
        Me.ttHint = New System.Windows.Forms.ToolTip(Me.components)
    End Sub

    Dim blnFormLoaded As Boolean = False
    Dim objHashTableG As New Hashtable(100)

    Dim objColorArray(150) As Brush
    Private Sub BarChart_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

    End Sub

    Public Sub LoadData(ByVal objCallerHashTable As Hashtable )
       objHashTableG =  objCallerHashTable.Clone()
    End Sub


    Public Sub RenderData '' see also http://www.java2s.com/Code/VB/GUI/GetOtherFormPaintevent.htm
        Me.BarChart_Paint(Nothing, New System.Windows.Forms.PaintEventArgs( _
        CreateGraphics(), _
	New System.Drawing.Rectangle(0, 0, Me.Width, Me.Height) _
        )) 
    End Sub

    Private Sub BarChart_Paint(ByVal sender As Object, _
                               ByVal e As System.Windows.Forms.PaintEventArgs _
                               ) Handles MyBase.Paint
        Try
            Dim intMaxWidth As Integer
            Dim intMaxHeight As Integer
            Dim intXaxis As Integer
            Dim intYaxis As Integer
            Me.SuspendLayout()
            Me.LoadColorArray()
            intMaxHeight = CType((Me.Height / 2) - (Me.Height / 12), Integer)
            intMaxWidth = CType(Me.Width - (Me.Width / 4), Integer)
            intXaxis = CType(Me.Width / 12, Integer)
            intYaxis = CType(Me.Height / 2, Integer)
            drawBarChart(objHashTableG.GetEnumerator , _
                         objHashTableG.Count, _
                         "Graph 1", _
                         intXaxis, _
                         intYaxis, _
                         intMaxWidth, _
                         intMaxHeight, _
                         True, _
                         False)
            blnFormLoaded = True
            Me.ResumeLayout(False)
        Catch ex As Exception
            Throw ex
        End Try
        
    End Sub

    Public Sub drawBarChart(ByVal objEnum As IDictionaryEnumerator, _
                            ByVal intItemCount As Integer, _
                            ByVal strGraphTitle As String, _
                            ByVal Xaxis As Integer, _
                            ByVal Yaxis As Integer, _
                            ByVal MaxWidth As Int16, _
                            ByVal MaxHt As Int16, _
                            ByVal clearForm As Boolean, _
                            Optional ByVal SpaceRequired As Boolean = False)

        Dim intGraphXaxis As Integer = Xaxis
        Dim intGraphYaxis As Integer = Yaxis
        Dim intWidthMax As Integer = MaxWidth
        Dim intHeightMax As Integer = MaxHt
        Dim intSpaceHeight As Integer
        Dim intMaxValue As Integer = 0
        Dim intCounter As Integer
        Dim intBarWidthMax
        Dim intBarHeight
        Dim strText As String
        Try
            Dim grfx As Graphics = CreateGraphics()
            If clearForm = True Then
                grfx.Clear(BackColor)
            End If

            grfx.DrawString(strGraphTitle, New Font("Verdana", 12.0, FontStyle.Bold, GraphicsUnit.Point), Brushes.DeepPink, intGraphXaxis + (intWidthMax / 4), (intGraphYaxis - intHeightMax) - 40)

            'Get the Height of the Bar        
            intBarHeight = CInt(intHeightMax / intItemCount)

            'Get the space Height of the Bar 
            intSpaceHeight = CInt((intHeightMax / (intItemCount - 1)) - intBarHeight)

            'Find Maximum of the input value
            If Not objEnum Is Nothing Then
                While objEnum.MoveNext = True
                    If objEnum.Value > intMaxValue Then
                        intMaxValue = objEnum.Value
                    End If
                End While
            End If

            'Get the Maximum Width of the Bar
            intBarWidthMax = CInt(intWidthMax / intMaxValue)

            ' Obtain the Graphics object exposed by the Form.
            If Not objEnum Is Nothing Then
                intCounter = 1
                objEnum.Reset()
                'Draw X axis and Y axis lines
                'grfx.DrawLine(Pens.Black, intGraphXaxis, intGraphYaxis, intGraphXaxis + intWidthMax, intGraphYaxis)
                'grfx.DrawLine(Pens.Black, intGraphXaxis, intGraphYaxis, intGraphXaxis, (intGraphYaxis - intHeightMax) - 25)

                While objEnum.MoveNext = True
                    'Get new Y axis
                    intGraphYaxis = intGraphYaxis - intBarHeight

                    Dim objRec as Rectangle
                    objRec = New System.Drawing.Rectangle(intGraphXaxis, intGraphYaxis, intBarWidthMax * objEnum.Value, intBarHeight)
                    'Draw Rectangle
                    grfx.DrawRectangle(Pens.Black, objRec)
                    'Fill Rectangle
                    grfx.FillRectangle(objColorArray(intCounter), objRec )
                    'Display Text and value
                    ' http://www.java2s.com/Tutorial/VB/0300__2D-Graphics/Measurestringanddrawstring.htm
                    strText =  objEnum.Key & "=" & objEnum.Value 
                    Dim objLabelFont as Font
                    objLabelFont = New Font("Verdana", 7.2, FontStyle.Regular, GraphicsUnit.Point) 
                    Dim textLabelArea As SizeF
                    textLabelArea = grfx.MeasureString(strText, objLabelFont)

                    Dim linePen As Pen  
                    linePen = New Pen(Color.Gray, 1)
                    linePen.DashStyle = Drawing2D.DashStyle.Dash

                    Dim fontRatio As Single 
                    fontRatio = objLabelFont.Height / objLabelFont.FontFamily.GetLineSpacing(FontStyle.Regular)
 
                    Dim ascentSize As Single
                    ascentSize = objLabelFont.FontFamily.GetCellAscent(FontStyle.Regular) * fontRatio
                    Dim descentSize As Single
                    descentSize = objLabelFont.FontFamily.GetCellDescent(FontStyle.Regular) * fontRatio
                    Dim emSize As Single
                    emSize = objLabelFont.FontFamily.GetEmHeight(FontStyle.Regular) * fontRatio
                    Dim cellHeight As Single
                    cellHeight = ascentSize + descentSize
                    Dim internalLeading As Single
                    internalLeading = cellHeight - emSize
                    Dim externalLeading As Single
                    externalLeading = (objLabelFont.FontFamily.GetLineSpacing(FontStyle.Regular) * fontRatio) - cellHeight


                    Dim labelLeft As Single : labelLeft = intGraphXaxis + (intBarWidthMax * objEnum.Value)
                    labelLeft = intGraphXaxis
                    Dim labelBottom As Single:  labelBottom =  intGraphYaxis
                    Dim labelRight As Single : labelRight = labelLeft + textLabelArea.Width
                    Dim labelTop As Single : labelTop = textLabelArea.Height + labelBottom

                    Dim objLabelRec as Rectangle
                    objLabelRec = New System.Drawing.Rectangle(labelLeft, labelBottom, textLabelArea.Width , textLabelArea.Height )
                 
                    grfx.DrawRectangle(Pens.Black, objLabelRec)
                    'Fill Rectangle
                    grfx.FillRectangle(Brushes.White, objLabelRec )

                    grfx.DrawLine(linePen, labelLeft, labelTop, labelLeft , labelBottom)
                    grfx.DrawLine(linePen, labelRight, labelTop, labelRight , labelBottom)
                    grfx.DrawLine(linePen, labelLeft, labelTop, labelRight , labelTop)
                    grfx.DrawLine(linePen, labelLeft, labelBottom, labelRight , labelBottom)
                    grfx.DrawString(strText, objLabelFont, Brushes.Black, labelLeft, labelBottom)

                    intCounter += 1
                    If SpaceRequired = True Then
                        intGraphYaxis = intGraphYaxis - intSpaceHeight
                    End If
                    If intCounter > objColorArray.GetUpperBound(0) Then
                        intCounter = 1
                    End If
                End While
                If clearForm = True Then
                    grfx.Dispose()
                End If
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Sub LoadColorArray()
        objColorArray(1) = Brushes.Blue
        objColorArray(2) = Brushes.Pink
        objColorArray(3) = Brushes.Brown
        objColorArray(4) = Brushes.BurlyWood
        objColorArray(5) = Brushes.CadetBlue
        objColorArray(6) = Brushes.Chartreuse
        objColorArray(7) = Brushes.Chocolate
        objColorArray(8) = Brushes.Coral
        objColorArray(9) = Brushes.CornflowerBlue
        objColorArray(10) = Brushes.Cornsilk
        objColorArray(11) = Brushes.Crimson
        objColorArray(12) = Brushes.Cyan
        objColorArray(13) = Brushes.DarkBlue
        objColorArray(14) = Brushes.DarkCyan
        objColorArray(15) = Brushes.DarkGoldenrod
        objColorArray(16) = Brushes.DarkGray
        objColorArray(17) = Brushes.DarkGreen
        objColorArray(18) = Brushes.DarkKhaki
        objColorArray(19) = Brushes.DarkMagenta
        objColorArray(20) = Brushes.DarkOliveGreen
        objColorArray(21) = Brushes.DarkOrange
        objColorArray(22) = Brushes.DarkOrchid
        objColorArray(23) = Brushes.DarkRed
        objColorArray(24) = Brushes.DarkSalmon
        objColorArray(25) = Brushes.DarkSeaGreen
        objColorArray(26) = Brushes.DarkSlateBlue
        objColorArray(27) = Brushes.DarkSlateGray
        objColorArray(28) = Brushes.DarkTurquoise
        objColorArray(29) = Brushes.DarkViolet
        objColorArray(30) = Brushes.DeepPink
        objColorArray(31) = Brushes.DeepSkyBlue
        objColorArray(32) = Brushes.DimGray
        objColorArray(33) = Brushes.DodgerBlue
        objColorArray(34) = Brushes.Firebrick
        objColorArray(35) = Brushes.FloralWhite
        objColorArray(36) = Brushes.ForestGreen
        objColorArray(37) = Brushes.Fuchsia
        objColorArray(38) = Brushes.Gainsboro
        objColorArray(39) = Brushes.GhostWhite
        objColorArray(40) = Brushes.Gold
        objColorArray(41) = Brushes.Goldenrod
        objColorArray(42) = Brushes.Gray
        objColorArray(43) = Brushes.Green
        objColorArray(44) = Brushes.GreenYellow
        objColorArray(45) = Brushes.Honeydew
        objColorArray(46) = Brushes.HotPink
        objColorArray(47) = Brushes.IndianRed
        objColorArray(48) = Brushes.Indigo
        objColorArray(49) = Brushes.Ivory
        objColorArray(50) = Brushes.Khaki
        objColorArray(51) = Brushes.Lavender
        objColorArray(52) = Brushes.LavenderBlush
        objColorArray(53) = Brushes.LawnGreen
        objColorArray(54) = Brushes.LemonChiffon
        objColorArray(55) = Brushes.LightBlue
        objColorArray(56) = Brushes.LightCoral
        objColorArray(57) = Brushes.LightCyan
        objColorArray(58) = Brushes.LightGoldenrodYellow
        objColorArray(59) = Brushes.LightGray
        objColorArray(60) = Brushes.LightGreen
        objColorArray(61) = Brushes.LightPink
        objColorArray(62) = Brushes.LightSalmon
        objColorArray(63) = Brushes.LightSeaGreen
        objColorArray(64) = Brushes.LightSkyBlue
        objColorArray(65) = Brushes.LightSlateGray
        objColorArray(66) = Brushes.LightSteelBlue
        objColorArray(67) = Brushes.LightYellow
        objColorArray(68) = Brushes.Lime
        objColorArray(69) = Brushes.LimeGreen
        objColorArray(70) = Brushes.Linen
        objColorArray(71) = Brushes.Magenta
        objColorArray(72) = Brushes.Maroon
        objColorArray(73) = Brushes.MediumAquamarine
        objColorArray(74) = Brushes.MediumBlue
        objColorArray(75) = Brushes.MediumOrchid
        objColorArray(76) = Brushes.MediumPurple
        objColorArray(77) = Brushes.MediumSeaGreen
        objColorArray(78) = Brushes.MediumSlateBlue
        objColorArray(79) = Brushes.MediumSpringGreen
        objColorArray(80) = Brushes.MediumTurquoise
        objColorArray(81) = Brushes.MediumVioletRed
        objColorArray(82) = Brushes.MidnightBlue
        objColorArray(83) = Brushes.MintCream
        objColorArray(84) = Brushes.MistyRose
        objColorArray(85) = Brushes.Moccasin
        objColorArray(86) = Brushes.NavajoWhite
        objColorArray(87) = Brushes.Navy
        objColorArray(88) = Brushes.OldLace
        objColorArray(89) = Brushes.Olive
        objColorArray(90) = Brushes.OliveDrab
        objColorArray(91) = Brushes.Orange
        objColorArray(92) = Brushes.OrangeRed
        objColorArray(93) = Brushes.Orchid
        objColorArray(94) = Brushes.PaleGoldenrod
        objColorArray(95) = Brushes.PaleGreen
        objColorArray(96) = Brushes.PaleTurquoise
        objColorArray(97) = Brushes.PaleVioletRed
        objColorArray(98) = Brushes.PapayaWhip
        objColorArray(99) = Brushes.PeachPuff
        objColorArray(100) = Brushes.Peru
        objColorArray(101) = Brushes.Pink
        objColorArray(102) = Brushes.Plum
        objColorArray(103) = Brushes.PowderBlue
        objColorArray(104) = Brushes.Purple
        objColorArray(105) = Brushes.Red
        objColorArray(106) = Brushes.RosyBrown
        objColorArray(107) = Brushes.RoyalBlue
        objColorArray(108) = Brushes.SaddleBrown
        objColorArray(109) = Brushes.Salmon
        objColorArray(110) = Brushes.SandyBrown
        objColorArray(111) = Brushes.SeaGreen
        objColorArray(112) = Brushes.SeaShell
        objColorArray(113) = Brushes.Sienna
        objColorArray(114) = Brushes.Silver
        objColorArray(115) = Brushes.SkyBlue
        objColorArray(116) = Brushes.SlateBlue
        objColorArray(117) = Brushes.SlateGray
        objColorArray(118) = Brushes.Snow
        objColorArray(119) = Brushes.SpringGreen
        objColorArray(120) = Brushes.SteelBlue
        objColorArray(121) = Brushes.Tan
        objColorArray(122) = Brushes.Teal
        objColorArray(123) = Brushes.Thistle
        objColorArray(124) = Brushes.Tomato
        objColorArray(125) = Brushes.Transparent
        objColorArray(126) = Brushes.Turquoise
        objColorArray(127) = Brushes.Violet
        objColorArray(128) = Brushes.Wheat
        objColorArray(129) = Brushes.White
        objColorArray(130) = Brushes.WhiteSmoke
        objColorArray(131) = Brushes.Yellow
        objColorArray(132) = Brushes.YellowGreen
    End Sub
    Private Sub BarChart_Resize(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Resize
        If blnFormLoaded = True Then
            BarChart_Paint(Me, New System.Windows.Forms.PaintEventArgs(CreateGraphics(), New System.Drawing.Rectangle(0, 0, Me.Width, Me.Height)))
        End If
    End Sub
    Friend WithEvents ttHint As System.Windows.Forms.ToolTip
    ' Friend WithEvents RecLabel As System.Windows.Forms.Label
    '' need to draw System.Windows.Forms.Control
End Class
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Drawing.dll'

# http://www.outlookcode.com/codedetail.aspx?id=1428
Add-Type -Language 'VisualBasic' -TypeDefinition @"

' http://msdn.microsoft.com/en-us/library/system.windows.forms.iwin32window%28v=vs.110%29.aspx

Public Class MyWin32Window 
Implements System.Windows.Forms.IWin32Window

    Dim _hWnd As System.IntPtr

    Public Sub New(ByVal handle As System.IntPtr)

       _hWnd = handle

    End Sub

    Public ReadOnly Property Handle() As System.IntPtr Implements System.Windows.Forms.IWin32Window.Handle
        Get
            Handle = _hWnd
        End Get
    End Property
 
End Class

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

$caller = New-Object -TypeName 'MyWin32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$object = New-Object -TypeName 'BarChart'

$data1 = New-Object System.Collections.Hashtable (10)
$data1_json = @"
{
    "Product1":  26,
    "Product2":  15,
    "Product3":  35
}
"@
# http://stackoverflow.com/questions/3740128/pscustomobject-to-hashtable
($data1_json -join '' | ConvertFrom-Json).psobject.properties | ForEach-Object {
  $data1.Add($_.Name,$_.Value)
}


$object.LoadData([System.Collections.Hashtable]$data1)

# not necessary for the example at hand but may be necessary 
# [void]$object.ShowDialog([System.Windows.Forms.IWin32Window] ($caller) )

[void]$object.Show()
Start-Sleep -Seconds 5

$data2 = New-Object System.Collections.Hashtable (100)

$data2_json = @"
{
    "Item9":  267,
    "Item8":  199,
    "Item3":  250,
    "Item2":  150,
    "Item1":  50,
    "Item7":  148,
    "Item6":  125,
    "Item5":  100,
    "Item4":  20
}
"@

($data2_json -join '' | ConvertFrom-Json).psobject.properties | ForEach-Object {
  $data2.Add($_.Name,$_.Value)
}

$object.LoadData([System.Collections.Hashtable]$data2)

$object.RenderData()
Start-Sleep -Seconds 5

$object.Close()
$object.Dispose()

