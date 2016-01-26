#Copyright (c) 2015,2016 Serguei Kouzmine
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

# origin : http://www.codeproject.com/Articles/20731/Gantt-Chart
Add-Type -Language 'VisualBasic' -TypeDefinition @"

Imports System.Drawing.Drawing2D

Imports System.Drawing ''' explicit import is required for Pen
Imports System.Windows.Forms ''' explicit import required for Control
Imports System ''' explcit import required for TimeSpan
Imports System.Collections.Generic ''' explcit import required for List 

Public Class GanttChart
    Inherits Control

    Private mouseHoverPart As MouseOverPart = MouseOverPart.Empty
    Private mouseHoverBarIndex As Integer = -1

    Private bars As New List(Of ChartBarDate)
    Private headerFromDate As Date = Nothing
    Private headerToDate As Date = Nothing

    Private barIsChanging As Integer = -1

    Private barStartRight As Integer = 20
    Private barStartLeft As Integer = 100
    Private headerTimeStartTop As Integer = 30
    Private shownHeaderList As List(Of Header)

    Private barStartTop As Integer = 50
    Private barHeight As Integer = 9
    Private barSpace As Integer = 5

    Private widthPerItem As Integer

    Private _mouseOverColumnValue As Date = Nothing
    Private _mouseOverRowText As String = ""
    Private _mouseOverRowValue As Object = Nothing

    Private lineColor As Pen = Pens.Bisque
    Private dateTextFont As Font = New Font("VERDANA", 8.0, FontStyle.Regular, GraphicsUnit.Point)
    Private timeTextFont As Font = New Font("VERDANA", 8.0, FontStyle.Regular, GraphicsUnit.Point)
    Private rowTextFont As Font = New Font("VERDANA", 8.0, FontStyle.Regular, GraphicsUnit.Point)

    Friend WithEvents ToolTip As New System.Windows.Forms.ToolTip()

    Private _allowEditBarWithMouse As Boolean = False

    Public Event MouseDragged(ByVal sender As Object, ByVal e As System.Windows.Forms.MouseEventArgs)
    Public Event BarChanged(ByVal sender As Object, ByRef barValue As Object)

    Private objBmp As Bitmap
    Private objGraphics As Graphics

    Public Property AllowManualEditBar() As Boolean
        Get
            Return _allowEditBarWithMouse
        End Get
        Set(ByVal value As Boolean)
            _allowEditBarWithMouse = value
        End Set
    End Property

    Public Property FromDate() As Date
        Get
            Return headerFromDate
        End Get
        Set(ByVal value As Date)
            headerFromDate = value
        End Set
    End Property

    Public Property ToDate() As Date
        Get
            Return headerToDate
        End Get
        Set(ByVal value As Date)
            headerToDate = value
        End Set
    End Property

    Public ReadOnly Property MouseOverRowText() As String
        Get
            Return _mouseOverRowText
        End Get
    End Property

    Public ReadOnly Property MouseOverRowValue() As Object
        Get
            Return _mouseOverRowValue
        End Get
    End Property

    Public ReadOnly Property MouseOverColumnDate() As Date
        Get
            Return _mouseOverColumnValue
        End Get
    End Property

    Public Property GridColor() As System.Drawing.Pen
        Get
            Return lineColor
        End Get
        Set(ByVal value As System.Drawing.Pen)
            lineColor = value
        End Set
    End Property

    Public Property RowFont() As Font
        Get
            Return rowTextFont
        End Get
        Set(ByVal value As Font)
            rowTextFont = value
        End Set
    End Property

    Public Property DateFont() As Font
        Get
            Return dateTextFont
        End Get
        Set(ByVal value As Font)
            dateTextFont = value
        End Set
    End Property

    Public Property TimeFont() As Font
        Get
            Return timeTextFont
        End Get
        Set(ByVal value As Font)
            timeTextFont = value
        End Set
    End Property

    Public Sub New()
        ToolTip.AutoPopDelay = 15000
        ToolTip.InitialDelay = 250
        ToolTip.OwnerDraw = True

        objBmp = New Bitmap(1280, 1024, Imaging.PixelFormat.Format24bppRgb)
        objGraphics = Graphics.FromImage(objBmp)

        ' Flicker free drawing

        Me.SetStyle(ControlStyles.DoubleBuffer Or ControlStyles.UserPaint Or ControlStyles.AllPaintingInWmPaint, True)
    End Sub

    Private Sub SetBarStartLeft(ByVal rowText As String)
        Dim gfx As Graphics = Me.CreateGraphics

        Dim length As Integer = gfx.MeasureString(rowText, rowTextFont, 500).Width

        If length > barStartLeft Then
            barStartLeft = length
        End If
    End Sub

    Public Sub AddChartBar(ByVal barInformation As BarInformation)
        Dim bar As New ChartBarDate
        bar.Text = barInformation.RowText
        bar.Value = barInformation
        bar.StartValue = barInformation.FromTime
        bar.EndValue = barInformation.ToTime
        bar.Color = barInformation.Color
        bar.HoverColor = barInformation.HoverColor
        bar.RowIndex = barInformation.Index
        bars.Add(bar)

        SetBarStartLeft(bar.Text)
    End Sub
 
    Public Sub AddChartBar(ByVal rowText As String, ByVal barValue As Object, ByVal fromTime As Date, ByVal toTime As Date, ByVal color As Color, ByVal hoverColor As Color, ByVal rowIndex As Integer)
        Dim bar As New ChartBarDate
        bar.Text = rowText
        bar.Value = barValue
        bar.StartValue = fromTime
        bar.EndValue = toTime
        bar.Color = color
        bar.HoverColor = hoverColor
        bar.RowIndex = rowIndex
        bars.Add(bar)

        SetBarStartLeft(rowText)
    End Sub

    Public Sub AddChartBar(ByVal rowText As String, ByVal barValue As Object, ByVal fromTime As Date, ByVal toTime As Date, ByVal color As Color, ByVal hoverColor As Color, ByVal rowIndex As Integer, ByVal hideFromMouseMove As Boolean)
        Dim bar As New ChartBarDate
        bar.Text = rowText
        bar.Value = barValue
        bar.StartValue = fromTime
        bar.EndValue = toTime
        bar.Color = color
        bar.HoverColor = hoverColor
        bar.RowIndex = rowIndex
        bar.HideFromMouseMove = hideFromMouseMove
        bars.Add(bar)

        SetBarStartLeft(rowtext)
    End Sub

    Public Function GetIndexChartBar(ByVal rowText As String) As Integer
        Dim index As Integer = -1

        For Each bar As ChartBarDate In bars
            If bar.Text.Equals(rowText) = True Then
                Return bar.RowIndex
            End If
            If bar.RowIndex > index Then
                index = bar.RowIndex
            End If
        Next

        Return index + 1
    End Function

    Public Sub RemoveBars()
        bars = New List(Of ChartBarDate)

        barStartLeft = 100
    End Sub

    Public Sub PaintChart()
        Me.Invalidate()
    End Sub

    Private Sub PaintChart(ByVal gfx As Graphics)
        gfx.Clear(Me.BackColor)

        If headerFromDate = Nothing Or headerToDate = Nothing Then Exit Sub

        DrawScrollBar(gfx)
        DrawHeader(gfx, Nothing)
        DrawNetHorizontal(gfx)
        DrawNetVertical(gfx)
        DrawBars(gfx)

        objBmp = New Bitmap(Me.Width - barStartRight, lastLineStop, Imaging.PixelFormat.Format24bppRgb)
        objGraphics = Graphics.FromImage(objBmp)
    End Sub

    Protected Overrides Sub OnPaint(ByVal pe As System.Windows.Forms.PaintEventArgs)
        MyBase.OnPaint(pe)

        PaintChart(pe.Graphics)
    End Sub

    Private Sub DrawHeader(ByVal gfx As Graphics, ByVal headerList As List(Of Header))
        If headerList Is Nothing Then
            headerList = GetFullHeaderList()
        End If

        If headerList.Count = 0 Then Exit Sub

        Dim availableWidth = Me.Width - 10 - barStartLeft - barStartRight
        widthPerItem = availableWidth / headerList.Count

        If widthPerItem < 40 Then
            Dim newHeaderList As New List(Of Header)

            Dim showNext As Boolean = True

            ' If there's not enough room for all headers remove 50%

            For Each header As Header In headerList
                If showNext = True Then
                    newHeaderList.Add(header)
                    showNext = False
                Else
                    showNext = True
                End If
            Next

            DrawHeader(gfx, newHeaderList)
            Exit Sub
        End If

        Dim index As Integer = 0
        Dim headerStartPosition As Integer = -1
        Dim lastHeader As Header = Nothing

        For Each header As Header In headerList
            Dim startPos As Integer = barStartLeft + (index * widthPerItem)
            Dim showDateHeader As Boolean = False

            header.StartLocation = startPos

            ' Checks whether to show the date or not

            If lastHeader Is Nothing Then
                showDateHeader = True
            ElseIf header.Time.Hour < lastHeader.Time.Hour Then
                showDateHeader = True
            ElseIf header.Time.Minute = lastHeader.Time.Minute Then
                showDateHeader = True
            End If

            ' Show date

            If showDateHeader = True Then
                Dim str As String = ""

                If header.HeaderTextInsteadOfTime.Length > 0 Then
                    str = header.HeaderTextInsteadOfTime
                Else
                    str = header.Time.ToString("d-MMM")
                End If
                gfx.DrawString(str, dateTextFont, Brushes.Black, startPos, 0)
            End If

            ' Show time

            gfx.DrawString(header.HeaderText, timeTextFont, Brushes.Black, startPos, headerTimeStartTop)
            index += 1

            lastHeader = header
        Next

        shownHeaderList = headerList
        widthPerItem = (Me.Width - 10 - barStartLeft - barStartRight) / shownHeaderList.Count
    End Sub

    Private Sub DrawBars(ByVal grfx As Graphics, Optional ByVal ignoreScrollAndMousePosition As Boolean = False)
        If shownHeaderList Is Nothing Then Exit Sub
        If shownHeaderList.Count = 0 Then Exit Sub

        Dim index As Integer = 0

        ' Finds pixels per minute

        Dim timeBetween As TimeSpan = shownHeaderList(1).Time - shownHeaderList(0).Time
        Dim minutesBetween As Integer = CInt(timeBetween.TotalMinutes) '(timeBetween.Days * 1440) + (timeBetween.Hours * 60) + timeBetween.Minutes
        Dim widthBetween = (shownHeaderList(1).StartLocation - shownHeaderList(0).StartLocation)
        Dim perMinute As Decimal = widthBetween / minutesBetween

        ' Draws each bar

        For Each bar As ChartBarDate In bars
            index = bar.RowIndex

            Dim startLocation As Integer
            Dim width As Integer
            Dim startMinutes As Integer ' Number of minutes from start of the gantt chart
            Dim startTimeSpan As TimeSpan
            Dim lengthMinutes As Integer ' Number of minutes from bar start to bar end
            Dim lengthTimeSpan As TimeSpan

            Dim scrollPos As Integer = 0

            If ignoreScrollAndMousePosition = False Then
                scrollPos = scrollPosition
            End If

            ' Calculates where the bar should be located

            startTimeSpan = bar.StartValue - FromDate
            startMinutes = (startTimeSpan.Days * 1440) + (startTimeSpan.Hours * 60) + startTimeSpan.Minutes

            startLocation = perMinute * startMinutes

            Dim endValue As Date = bar.EndValue

            If endValue = Nothing Then
                endValue = Date.Now
            End If

            lengthTimeSpan = endValue - bar.StartValue
            lengthMinutes = (lengthTimeSpan.Days * 1440) + (lengthTimeSpan.Hours * 60) + lengthTimeSpan.Minutes

            width = perMinute * lengthMinutes

            Dim a As Integer = barStartLeft + startLocation
            Dim b As Integer = barStartTop + (barHeight * (index - scrollPos)) + (barSpace * (index - scrollPos)) + 2
            Dim c As Integer = width
            Dim d As Integer = barHeight

            If c = 0 Then c = 1

            ' Stops a bar from going into the row-text area

            If a - barStartLeft < 0 Then
                a = barStartLeft
            End If

            Dim color As System.Drawing.Color

            ' If mouse is over bar, set the color to be hovercolor

            If MouseOverRowText = bar.Text And bar.StartValue <= _mouseOverColumnValue And bar.EndValue >= _mouseOverColumnValue Then
                color = bar.HoverColor
            Else
                color = bar.Color
            End If

            ' Set the location for the graphics

            bar.TopLocation.Left = New Point(a, b)
            bar.TopLocation.Right = New Point(a + c, b)
            bar.BottomLocation.Left = New Point(a, b + d)
            bar.BottomLocation.Right = New Point(a, b + d)

            Dim obBrush As LinearGradientBrush
            Dim obRect As New Rectangle(a, b, c, d)

            If bar.StartValue <> Nothing And endValue <> Nothing Then
                If (index >= scrollPos And index < barsViewable + scrollPos) Or ignoreScrollAndMousePosition = True Then

                    ' Makes the bar gradient

                    obBrush = New LinearGradientBrush(obRect, color, color.Gray, LinearGradientMode.Vertical)

                    ' Draws the bar

                    grfx.DrawRectangle(Pens.Black, obRect)
                    grfx.FillRectangle(obBrush, obRect)

                    ' Draws the rowtext

                    grfx.DrawString(bar.Text, rowTextFont, Brushes.Black, 0, barStartTop + (barHeight * (index - scrollPos)) + (barSpace * (index - scrollPos)))

                    obBrush = Nothing
                    obRect = Nothing
                    obBrush = Nothing
                End If
            End If

            color = Nothing
        Next
    End Sub

    Public Sub DrawNetVertical(ByVal grfx As Graphics)
        If shownHeaderList Is Nothing Then Exit Sub
        If shownHeaderList.Count = 0 Then Exit Sub

        Dim index As Integer = 0
        Dim availableWidth As Integer = Me.Width - 10 - barStartLeft - barStartRight
        Dim lastHeader As Header = Nothing

        For Each header As Header In shownHeaderList
            Dim headerLocationY As Integer = 0

            If lastHeader Is Nothing Then
                headerLocationY = 0
            ElseIf header.Time.Hour < lastHeader.Time.Hour Then
                headerLocationY = 0
            Else
                headerLocationY = headerTimeStartTop
            End If

            grfx.DrawLine(Pens.Bisque, barStartLeft + (index * widthPerItem), headerLocationY, barStartLeft + (index * widthPerItem), lastLineStop)
            index += 1

            lastHeader = header
        Next

        grfx.DrawLine(lineColor, barStartLeft + (index * widthPerItem), headerTimeStartTop, barStartLeft + (index * widthPerItem), lastLineStop)
    End Sub

    Public Sub DrawNetHorizontal(ByVal grfx As Graphics)
        If shownHeaderList Is Nothing Then Exit Sub
        If shownHeaderList.Count = 0 Then Exit Sub

        Dim index As Integer = 0
        Dim width As Integer = (widthPerItem * shownHeaderList.Count) + barStartLeft

        For index = 0 To GetIndexChartBar("QQQQQQ") ' Last used index. Hopefully nobody will make a row named QQQ :o)
            For Each bar As ChartBarDate In bars
                grfx.DrawLine(lineColor, 0, barStartTop + (barHeight * index) + (barSpace * index), width, barStartTop + (barHeight * index) + (barSpace * index))
            Next
        Next

        lastLineStop = barStartTop + (barHeight * (index - 1)) + (barSpace * (index - 1))
    End Sub

    ' This is the position (in pixels, from top) of the last line. Used for drawing lines

    Private lastLineStop As Integer = 0

    Private Function GetFullHeaderList() As List(Of Header)
        Dim result As New List(Of Header)
        Dim newFromTime As New Date(FromDate.Year, FromDate.Month, FromDate.Day)
        Dim item As String

        Dim interval As TimeSpan = ToDate - FromDate

        If interval.TotalDays < 1 Then
            With newFromTime
                newFromTime = .AddHours(FromDate.Hour)

                If headerFromDate.Minute < 59 And headerFromDate.Minute > 29 Then
                    newFromTime = .AddMinutes(30)
                Else
                    newFromTime = .AddMinutes(0)
                End If
            End With

            While newFromTime <= ToDate
                item = newFromTime.Hour & ":"

                If newFromTime.Minute < 10 Then
                    item += "0" & newFromTime.Minute
                Else
                    item += "" & newFromTime.Minute
                End If

                Dim header As New Header

                header.HeaderText = item
                header.HeaderTextInsteadOfTime = ""
                header.Time = New Date(newFromTime.Year, newFromTime.Month, newFromTime.Day, newFromTime.Hour, newFromTime.Minute, 0)
                result.Add(header)

                newFromTime = newFromTime.AddMinutes(5) ' The minimum interval of time between the headers
            End While
        ElseIf interval.TotalDays < 60 Then
            While newFromTime <= ToDate
                Dim header As New Header

                header.HeaderText = ""
                header.HeaderTextInsteadOfTime = ""
                header.Time = New Date(newFromTime.Year, newFromTime.Month, newFromTime.Day, 0, 0, 0)
                result.Add(header)

                newFromTime = newFromTime.AddDays(1) ' The minimum interval of time between the headers
            End While
        Else
            While newFromTime <= ToDate
                Dim header As New Header

                header.HeaderText = ""
                header.Time = New Date(newFromTime.Year, newFromTime.Month, newFromTime.Day, 0, 0, 0)
                header.HeaderTextInsteadOfTime = newFromTime.ToString("MMM")
                result.Add(header)

                newFromTime = newFromTime.AddMonths(1) ' The minimum interval of time between the headers
            End While
        End If

        Return result
    End Function

    Private Sub GanttChart_MouseMove(ByVal sender As System.Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles MyBase.MouseMove
        If shownHeaderList Is Nothing Then Exit Sub
        If shownHeaderList.Count = 0 Then Exit Sub

        If e.Button <> MouseButtons.Left Then
            mouseHoverPart = MouseOverPart.Empty

            ' If bar has changed manually, but left mouse button is no longer pressed the BarChanged event will be raised

            If AllowManualEditBar = True Then
                If barIsChanging >= 0 Then
                    RaiseEvent BarChanged(Me, bars(barIsChanging).Value)
                    barIsChanging = -1
                End If
            End If
        End If

        mouseHoverBarIndex = -1

        Dim LocalMousePosition As Point

        LocalMousePosition = Me.PointToClient(Cursor.Position)

        ' Finds pixels per minute

        Dim timeBetween As TimeSpan = shownHeaderList(1).Time - shownHeaderList(0).Time
        Dim minutesBetween As Integer = (timeBetween.Days * 1440) + (timeBetween.Hours * 60) + timeBetween.Minutes
        Dim widthBetween = (shownHeaderList(1).StartLocation - shownHeaderList(0).StartLocation)
        Dim perMinute As Decimal = widthBetween / minutesBetween

        ' Finds the time at mousepointer

        Dim minutesAtCursor As Integer = 0

        If LocalMousePosition.X > barStartLeft Then
            minutesAtCursor = (LocalMousePosition.X - barStartLeft) / perMinute
            _mouseOverColumnValue = FromDate.AddMinutes(minutesAtCursor)
        Else
            _mouseOverColumnValue = Nothing
        End If

        ' Finds the row at mousepointer

        Dim rowText As String = ""
        Dim rowValue As Object = Nothing
        Dim columnText As String = ""

        ' Tests to see if the mouse pointer is hovering above the scrollbar

        Dim scrollBarStatusChanged As Boolean = False

        ' Tests to see if the mouse is hovering over the scroll-area bottom-arrow

        If LocalMousePosition.X > BottomPart.Left And LocalMousePosition.Y < BottomPart.Right And LocalMousePosition.Y < BottomPart.Bottom And LocalMousePosition.Y > BottomPart.Top Then
            If mouseOverBottomPart = False Then
                scrollBarStatusChanged = True
            End If

            mouseOverBottomPart = True
        Else
            If mouseOverBottomPart = False Then
                scrollBarStatusChanged = True
            End If

            mouseOverBottomPart = False
        End If

        ' Tests to see if the mouse is hovering over the scroll-area top-arrow

        If LocalMousePosition.X > topPart.Left And LocalMousePosition.Y < topPart.Right And LocalMousePosition.Y < topPart.Bottom And LocalMousePosition.Y > topPart.Top Then
            If mouseOverTopPart = False Then
                scrollBarStatusChanged = True
            End If

            mouseOverTopPart = True
        Else
            If mouseOverTopPart = False Then
                scrollBarStatusChanged = True
            End If

            mouseOverTopPart = False
        End If

        ' Tests to see if the mouse is hovering over the scroll

        If LocalMousePosition.X > scroll.Left And LocalMousePosition.Y < scroll.Right And LocalMousePosition.Y < scroll.Bottom And LocalMousePosition.Y > scroll.Top Then
            If mouseOverScrollBar = False Then
                scrollBarStatusChanged = True
            End If

            mouseOverScrollBar = True
            mouseOverScrollBarArea = True
        Else
            If mouseOverScrollBar = False Then
                scrollBarStatusChanged = True
            End If

            mouseOverScrollBar = False
            mouseOverScrollBarArea = False
        End If

        ' If the mouse is not above the scroll, test if it's over the scroll area (no need to test if it's not above the scroll)

        If mouseOverScrollBarArea = False Then
            If LocalMousePosition.X > scrollBarArea.Left And LocalMousePosition.Y < scrollBarArea.Right And LocalMousePosition.Y < scrollBarArea.Bottom And LocalMousePosition.Y > scrollBarArea.Top Then
                mouseOverScrollBarArea = True
            End If
        End If


        ' Tests to see if the mouse pointer is hovering above a bar

        Dim index As Integer = 0

        For Each bar As ChartBarDate In bars

            ' If the bar is set to be hidden from mouse move, the current bar will be ignored

            If bar.HideFromMouseMove = False Then
                If bar.EndValue = Nothing Then
                    bar.EndValue = Date.Now
                End If

                ' Mouse pointer needs to be inside the X and Y positions of the bar

                If LocalMousePosition.Y > bar.TopLocation.Left.Y And LocalMousePosition.Y < bar.BottomLocation.Left.Y Then
                    If LocalMousePosition.X > bar.TopLocation.Left.X And LocalMousePosition.X < bar.TopLocation.Right.X Then

                        ' If the current bar is the one where the mouse is above, the rowText and rowValue needs to be set correctly

                        rowText = bar.Text
                        rowValue = bar.Value
                        mouseHoverBarIndex = index

                        If mouseHoverPart <> MouseOverPart.BarLeftSide And mouseHoverPart <> MouseOverPart.BarRightSide Then
                            mouseHoverPart = MouseOverPart.Bar
                        End If
                    End If

                    ' If mouse pointer is near the edges of the bar it will open up for editing the bar

                    If AllowManualEditBar = True Then
                        Dim areaSize As Integer = 5

                        If e.Button = MouseButtons.Left Then
                            areaSize = 50
                        End If

                        If LocalMousePosition.X > bar.TopLocation.Left.X - areaSize And LocalMousePosition.X < bar.TopLocation.Left.X + areaSize And mouseHoverPart <> MouseOverPart.BarRightSide Then
                            Me.Cursor = Cursors.VSplit
                            mouseHoverPart = MouseOverPart.BarLeftSide
                            mouseHoverBarIndex = index
                        ElseIf LocalMousePosition.X > bar.TopLocation.Right.X - areaSize And LocalMousePosition.X < bar.TopLocation.Right.X + areaSize And mouseHoverPart <> MouseOverPart.BarLeftSide Then
                            Me.Cursor = Cursors.VSplit
                            mouseHoverPart = MouseOverPart.BarRightSide
                            mouseHoverBarIndex = index
                        Else
                            Me.Cursor = Cursors.Default
                        End If
                    End If
                End If
            End If

            index += 1
        Next

        ' Sets the mouseover row value and text

        _mouseOverRowText = rowText
        _mouseOverRowValue = rowValue

        If e.Button = MouseButtons.Left Then
            RaiseEvent MouseDragged(sender, e)
        Else

            ' A simple test to see if the mousemovement has caused any changes to how it should be displayed 
            ' It only redraws if mouse moves from a bar to blank area or from blank area to a bar
            ' This increases performance compared to having a redraw every time a mouse moves

            If (_mouseOverRowValue Is Nothing And Not rowValue Is Nothing) Or (Not _mouseOverRowValue Is Nothing And rowValue Is Nothing) Or scrollBarStatusChanged = True Then
                PaintChart()
            End If
        End If
    End Sub

    Private Sub GanttChart_MouseLeave(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.MouseLeave
        _mouseOverRowText = Nothing
        _mouseOverRowValue = Nothing
        mouseHoverPart = MouseOverPart.Empty

        PaintChart()
    End Sub

    Public Sub GanttChart_MouseDragged(ByVal sender As Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles Me.MouseDragged
        If mouseOverScrollBarArea = True Then
            ScrollPositionY = e.Location.Y
        End If

        If AllowManualEditBar = True Then
            If mouseHoverBarIndex > -1 Then
                If mouseHoverPart = MouseOverPart.BarLeftSide Then
                    barIsChanging = mouseHoverBarIndex
                    bars(mouseHoverBarIndex).StartValue = _mouseOverColumnValue
                    PaintChart()
                ElseIf mouseHoverPart = MouseOverPart.BarRightSide Then
                    barIsChanging = mouseHoverBarIndex
                    bars(mouseHoverBarIndex).EndValue = _mouseOverColumnValue
                    PaintChart()
                End If
            End If
        End If
    End Sub


    Private _toolTipText As New List(Of String)
    Private _toolTipTextTitle As String = ""

    Private MyPoint As New Point(0, 0)

    Public Property ToolTipTextTitle() As String
        Get
            Return _toolTipTextTitle
        End Get
        Set(ByVal value As String)
            _toolTipTextTitle = value
        End Set
    End Property

    Public Property ToolTipText() As List(Of String)
        Get
            If _toolTipText Is Nothing Then _toolTipText = New List(Of String)
            Return _toolTipText
        End Get
        Set(ByVal value As List(Of String))
            _toolTipText = value

            Dim LocalMousePosition As Point

            LocalMousePosition = Me.PointToClient(Cursor.Position)


            If LocalMousePosition = MyPoint Then Exit Property

            MyPoint = LocalMousePosition

            ToolTip.SetToolTip(Me, ".")
        End Set
    End Property

    Private Sub ToolTipText_Draw(ByVal sender As System.Object, ByVal e As System.Windows.Forms.DrawToolTipEventArgs) Handles ToolTip.Draw
        If ToolTipText Is Nothing Then
            ToolTipText = New List(Of String)
            Exit Sub
        End If

        If ToolTipText.Count = 0 Then
            Exit Sub
        ElseIf ToolTipText(0).Length = 0 Then
            Exit Sub
        End If

        Dim x As Integer
        Dim y As Integer

        e.Graphics.FillRectangle(Brushes.AntiqueWhite, e.Bounds)
        e.DrawBorder()

        Dim titleHeight As Integer = 14
        Dim fontHeight As Integer = 12

        ' Draws the line just below the title

        e.Graphics.DrawLine(Pens.Black, 0, titleHeight, e.Bounds.Width, titleHeight)

        Dim lines As Integer = 1
        Dim text As String = ToolTipTextTitle

        ' Draws the title

        Using font As New Font(e.Font, FontStyle.Bold)
            x = (e.Bounds.Width - e.Graphics.MeasureString(text, font).Width) \ 2
            y = (titleHeight - e.Graphics.MeasureString(text, font).Height) \ 2
            e.Graphics.DrawString(text, font, Brushes.Black, x, y)
        End Using

        ' Draws the lines

        For Each str As String In ToolTipText
            Dim font As New Font(e.Font, FontStyle.Regular)

            If str.Contains("[b]") Then
                font = New Font(font.FontFamily, font.Size, FontStyle.Bold, font.Unit)
                str = str.Replace("[b]", "")
            End If

            Using font
                x = 5
                y = (titleHeight - fontHeight - e.Graphics.MeasureString(str, font).Height) \ 2 + 10 + (lines * 14)
                e.Graphics.DrawString(str, font, Brushes.Black, x, y)
            End Using

            lines += 1
        Next
    End Sub

    Private Sub ToolTipText_Popup(ByVal sender As System.Object, ByVal e As System.Windows.Forms.PopupEventArgs) Handles ToolTip.Popup
        If ToolTipText Is Nothing Then
            ToolTipText = New List(Of String)
        End If

        If ToolTipText.Count = 0 Then
            e.ToolTipSize = New Size(0, 0)
            Exit Sub
        ElseIf ToolTipText(0).Length = 0 Then
            e.ToolTipSize = New Size(0, 0)
            Exit Sub
        End If

        ' resizes the ToolTip window

        Dim height As Integer = 18 + (ToolTipText.Count * 15)
        e.ToolTipSize = New Size(200, height)
    End Sub

    Private Class ChartBarDate

        Friend Class Location

            Private _right As New Point(0, 0)
            Private _left As New Point(0, 0)

            Public Property Right() As Point
                Get
                    Return _right
                End Get
                Set(ByVal value As Point)
                    _right = value
                End Set
            End Property

            Public Property Left() As Point
                Get
                    Return _left
                End Get
                Set(ByVal value As Point)
                    _left = value
                End Set
            End Property

        End Class

        Private _startValue As Date
        Private _endValue As Date

        Private _color As Color
        Private _hoverColor As Color

        Private _text As String
        Private _value As Object

        Private _rowIndex As Integer

        Private _topLocation As New Location
        Private _bottomLocation As New Location

        Private _hideFromMouseMove As Boolean = False

        Public Property StartValue() As Date
            Get
                Return _startValue
            End Get
            Set(ByVal value As Date)
                _startValue = value
            End Set
        End Property

        Public Property EndValue() As Date
            Get
                Return _endValue
            End Get
            Set(ByVal value As Date)
                _endValue = value
            End Set
        End Property

        Public Property Color() As Color
            Get
                Return _color
            End Get
            Set(ByVal value As Color)
                _color = value
            End Set
        End Property

        Public Property HoverColor() As Color
            Get
                Return _hoverColor
            End Get
            Set(ByVal value As Color)
                _hoverColor = value
            End Set
        End Property

        Public Property Text() As String
            Get
                Return _text
            End Get
            Set(ByVal value As String)
                _text = value
            End Set
        End Property

        Public Property Value() As Object
            Get
                Return _value
            End Get
            Set(ByVal value As Object)
                _value = value
            End Set
        End Property

        Public Property RowIndex() As Integer
            Get
                Return _rowIndex
            End Get
            Set(ByVal value As Integer)
                _rowIndex = value
            End Set
        End Property

        Public Property HideFromMouseMove() As Boolean
            Get
                Return _hideFromMouseMove
            End Get
            Set(ByVal value As Boolean)
                _hideFromMouseMove = value
            End Set
        End Property

        Friend Property TopLocation() As Location
            Get
                Return _topLocation
            End Get
            Set(ByVal value As Location)
                _topLocation = value
            End Set
        End Property

        Friend Property BottomLocation() As Location
            Get
                Return _bottomLocation
            End Get
            Set(ByVal value As Location)
                _bottomLocation = value
            End Set
        End Property

    End Class

    Private Class Header

        Private _headerText As String
        Private _startLocation As Integer
        Private _headerTextInsteadOfTime As String = ""
        Private _time As Date = Nothing

        Public Property HeaderText() As String
            Get
                Return _headerText
            End Get
            Set(ByVal value As String)
                _headerText = value
            End Set
        End Property

        Public Property StartLocation() As Integer
            Get
                Return _startLocation
            End Get
            Set(ByVal value As Integer)
                _startLocation = value
            End Set
        End Property

        Public Property HeaderTextInsteadOfTime() As String
            Get
                Return _headerTextInsteadOfTime
            End Get
            Set(ByVal value As String)
                _headerTextInsteadOfTime = value
            End Set
        End Property

        Public Property Time() As Date
            Get
                Return _time
            End Get
            Set(ByVal value As Date)
                _time = value
            End Set
        End Property

    End Class

    Protected Overrides Sub OnResize(ByVal e As System.EventArgs)
        MyBase.OnResize(e)

        scrollPosition = 0

        ' Used for when the Gantt Chart is saved as an image

        If lastLineStop > 0 Then
            objBmp = New Bitmap(Me.Width - barStartRight, lastLineStop, Imaging.PixelFormat.Format24bppRgb)
            objGraphics = Graphics.FromImage(objBmp)
        End If

        PaintChart()
    End Sub

    Private barsViewable As Integer = -1
    Private scrollPosition As Integer = 0
    Private topPart As Rectangle = Nothing
    Private BottomPart As Rectangle = Nothing
    Private scroll As Rectangle = Nothing
    Private scrollBarArea As Rectangle = Nothing

    Private mouseOverTopPart As Boolean = False
    Private mouseOverBottomPart As Boolean = False
    Private mouseOverScrollBar As Boolean = False
    Private mouseOverScrollBarArea As Boolean = False

    Private Sub DrawScrollBar(ByVal grfx As Graphics)
        barsViewable = (Me.Height - barStartTop) / (barHeight + barSpace)
        Dim barCount As Integer = GetIndexChartBar("QQQWWW")
        If barCount = 0 Then Exit Sub

        Dim maxHeight As Integer = Me.Height - 30
        Dim scrollHeight As Decimal = (maxHeight / barCount) * barsViewable

        ' If the scroll area is filled there's no need to show the scrollbar

        If scrollHeight >= maxHeight Then Exit Sub

        Dim scrollSpeed As Decimal = (maxHeight - scrollHeight) / (barCount - barsViewable)

        scrollBarArea = New Rectangle(Me.Width - 20, 19, 12, maxHeight)
        scroll = New Rectangle(Me.Width - 20, 19 + (scrollPosition * scrollSpeed), 12, scrollHeight)

        topPart = New Rectangle(Me.Width - 20, 10, 12, 8)
        BottomPart = New Rectangle(Me.Width - 20, Me.Height - 10, 12, 8)

        Dim colorTopPart As Brush
        Dim colorBottomPart As Brush
        Dim colorScroll As Brush

        If mouseOverTopPart = True Then
            colorTopPart = Brushes.Black
        Else
            colorTopPart = Brushes.Gray
        End If

        If mouseOverBottomPart = True Then
            colorBottomPart = Brushes.Black
        Else
            colorBottomPart = Brushes.Gray
        End If

        If mouseOverScrollBar = True Then
            colorScroll = New LinearGradientBrush(scroll, Color.Bisque, Color.Gray, LinearGradientMode.Horizontal)
        Else
            colorScroll = New LinearGradientBrush(scroll, Color.White, Color.Gray, LinearGradientMode.Horizontal)
        End If

        ' Draws the top and bottom part of the scrollbar

        grfx.DrawRectangle(Pens.Black, topPart)
        grfx.FillRectangle(Brushes.LightGray, topPart)

        grfx.DrawRectangle(Pens.Black, BottomPart)
        grfx.FillRectangle(Brushes.LightGray, BottomPart)

        ' Draws arrows

        Dim points(2) As PointF
        points(0) = New PointF(topPart.Left, topPart.Bottom - 1)
        points(1) = New PointF(topPart.Right, topPart.Bottom - 1)
        points(2) = New PointF((topPart.Left + topPart.Right) / 2, topPart.Top + 1)

        grfx.FillPolygon(colorTopPart, points)

        points(0) = New PointF(BottomPart.Left, BottomPart.Top + 1)
        points(1) = New PointF(BottomPart.Right, BottomPart.Top + 1)
        points(2) = New PointF((BottomPart.Left + BottomPart.Right) / 2, BottomPart.Bottom - 1)

        grfx.FillPolygon(colorBottomPart, points)

        ' Draws the scroll area

        grfx.DrawRectangle(Pens.Black, scrollBarArea)
        grfx.FillRectangle(Brushes.DarkGray, scrollBarArea)

        ' Draws the actual scrollbar

        grfx.DrawRectangle(Pens.Black, scroll)
        grfx.FillRectangle(colorScroll, scroll)
    End Sub

    Private Property ScrollPositionY() As Integer
        Get
            If scroll = Nothing Then Return -1
            Return ((scroll.Height / 2) + scroll.Location.Y) + 19
        End Get
        Set(ByVal value As Integer)
            Dim barCount As Integer = GetIndexChartBar("QQQWWW")
            Dim maxHeight As Integer = Me.Height - 30
            Dim scrollHeight As Decimal = (maxHeight / barCount) * barsViewable
            Dim scrollSpeed As Decimal = (maxHeight - scrollHeight) / (barCount - barsViewable)
            Dim index As Integer = 0
            Dim distanceFromLastPosition = 9999

            ' Tests to see what scrollposition is the closest to the set position

            While index < barCount
                Dim newPositionTemp As Integer = (index * scrollSpeed) + (scrollHeight / 2) + (30 / 2)
                Dim distanceFromCurrentPosition = newPositionTemp - value

                If distanceFromLastPosition < 0 Then
                    If distanceFromCurrentPosition < distanceFromLastPosition Then
                        scrollPosition = index - 1
                        PaintChart()
                        Exit Property
                    End If
                Else
                    If distanceFromCurrentPosition > distanceFromLastPosition Then
                        scrollPosition = index - 1

                        ' A precaution to make sure the scroll bar doesn't go too far down

                        If scrollPosition + barsViewable > GetIndexChartBar("QQQWWW") Then
                            scrollPosition = GetIndexChartBar("QQQWWW") - barsViewable
                        End If

                        PaintChart()
                        Exit Property
                    End If
                End If

                distanceFromLastPosition = distanceFromCurrentPosition

                index += 1
            End While
        End Set
    End Property

    Public Sub ScrollOneup()
        If scrollPosition = 0 Then Exit Sub

        scrollPosition -= 1

        PaintChart()
    End Sub

    Public Sub ScrollOneDown()
        If scrollPosition + barsViewable >= GetIndexChartBar("QQQWWW") Then Exit Sub

        scrollPosition += 1

        PaintChart()
    End Sub

    Private Sub GanttChart_Click(ByVal sender As System.Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles MyBase.MouseClick
        If e.Button = MouseButtons.Left Then
            If mouseOverBottomPart = True Then
                ScrollOneDown()
            ElseIf mouseOverTopPart = True Then
                ScrollOneup()
            End If
        End If
    End Sub

    Private Sub GanttChart_MouseWheel(ByVal sender As Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles Me.MouseWheel
        If e.Delta > 0 Then
            ScrollOneup()
        Else
            ScrollOneDown()
        End If
    End Sub

    Public Sub SaveImage(ByVal filePath As String)
        objGraphics.SmoothingMode = SmoothingMode.HighSpeed
        objGraphics.Clear(Me.BackColor)

        If headerFromDate = Nothing Or headerToDate = Nothing Then Exit Sub

        DrawHeader(objGraphics, Nothing)
        DrawNetHorizontal(objGraphics)
        DrawNetVertical(objGraphics)
        DrawBars(objGraphics, True)

        objBmp.Save(filePath)
    End Sub

    Private Enum MouseOverPart

        Empty
        Bar
        BarLeftSide
        BarRightSide

    End Enum

End Class
Public Class BarInformation

    Private _rowText As String
    Private _fromTime As Date
    Private _toTime As Date
    Private _color As Color
    Private _hoverColor As Color
    Private _index As Integer

    Public Property RowText() As String
        Get
            Return _rowText
        End Get
        Set(ByVal value As String)
            _rowText = value
        End Set
    End Property

    Public Property FromTime() As Date
        Get
            Return _fromTime
        End Get
        Set(ByVal value As Date)
            _fromTime = value
        End Set
    End Property

    Public Property ToTime() As Date
        Get
            Return _toTime
        End Get
        Set(ByVal value As Date)
            _toTime = value
        End Set
    End Property

    Public Property Color() As Color
        Get
            Return _color
        End Get
        Set(ByVal value As Color)
            _color = value
        End Set
    End Property

    Public Property HoverColor() As Color
        Get
            Return _hoverColor
        End Get
        Set(ByVal value As Color)
            _hoverColor = value
        End Set
    End Property

    Public Property Index() As Integer
        Get
            Return _index
        End Get
        Set(ByVal value As Integer)
            _index = value
        End Set
    End Property

    Public Sub New(ByVal rowText As String, ByVal fromTime As Date, ByVal totime As Date, ByVal color As Color, ByVal hoverColor As Color, ByVal index As Integer)
        Me.RowText = rowText
        Me.FromTime = fromTime
        Me.ToTime = totime
        Me.Color = color
        Me.HoverColor = hoverColor
        Me.Index = index
    End Sub

End Class
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Drawing.dll'

# http://msdn.microsoft.com/en-us/library/system.windows.forms.iwin32window%28v=vs.110%29.aspx
Add-Type -Language 'VisualBasic' -TypeDefinition @"
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

@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

$f = New-Object System.Windows.Forms.Form
$f.MaximizeBox = $false
$f.MinimizeBox = $false

$c = New-Object -TypeName 'GanttChart'

$c.AllowManualEditBar = $true
$c.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$c.BackColor = [System.Drawing.Color]::White
$c.ContextMenuStrip = $null
$c.DateFont = New-Object System.Drawing.Font ('Verdana',8.0)
$c.Location = New-Object System.Drawing.Point (12,12)
$c.Name = "GanttChart3"
$c.RowFont = New-Object System.Drawing.Font ('Verdana',8.0)
$c.Size = New-Object System.Drawing.Size (933,223)
$c.TabIndex = 3
$c.Text = "GanttChart3"
$c.TimeFont = New-Object System.Drawing.Font ('Verdana',8.0)

@(

  (New-Object -TypeName 'BarInformation' -ArgumentList ('Step 1',(New-Object System.DateTime (2015,4,27,8,6,0)),(New-Object System.DateTime (2015,4,27,8,7,0)),[System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,0)),
  (New-Object -TypeName 'BarInformation' -ArgumentList ('Step 2',(New-Object System.DateTime (2015,4,27,8,7,0)),(New-Object System.DateTime (2015,4,27,8,9,0)),[System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,1)),
  (New-Object -TypeName 'BarInformation' -ArgumentList ('Step 3',(New-Object System.DateTime (2015,4,27,8,9,0)),(New-Object System.DateTime (2015,4,27,8,11,0)),[System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,2)),
  (New-Object -TypeName 'BarInformation' -ArgumentList ('Step 4',(New-Object System.DateTime (2015,4,27,8,14,0)),(New-Object System.DateTime (2015,4,27,8,15,0)),[System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,3)),
  (New-Object -TypeName 'BarInformation' -ArgumentList ('Step 5',(New-Object System.DateTime (2015,4,27,8,16,0)),(New-Object System.DateTime (2015,4,27,8,19,0)),[System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,4)),
  (New-Object -TypeName 'BarInformation' -ArgumentList ('Step 6',(New-Object System.DateTime (2015,4,27,8,20,0)),(New-Object System.DateTime (2015,4,27,8,23,0)),[System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,5)),
  (New-Object -TypeName 'BarInformation' -ArgumentList ('Step 7',(New-Object System.DateTime (2015,4,27,8,28,0)),(New-Object System.DateTime (2015,4,27,8,40,0)),[System.Drawing.Color]::Maroon,[System.Drawing.Color]::Khaki,6)),
  (New-Object -TypeName 'BarInformation' -ArgumentList ('Step 7',(New-Object System.DateTime (2015,4,27,8,40,0)),(New-Object System.DateTime (2015,4,27,8,43,0)),[System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,7)),
  (New-Object -TypeName 'BarInformation' -ArgumentList ('Step 7',(New-Object System.DateTime (2015,4,27,8,43,0)),(New-Object System.DateTime (2015,4,27,8,55,0)),[System.Drawing.Color]::Maroon,[System.Drawing.Color]::Khaki,8))


) | ForEach-Object { $b = $_; $c.AddChartBar($b) }

$c.FromDate = New-Object System.DateTime (2015,4,27,8,5,0)
$c.ToDate = New-Object System.DateTime (2015,4,27,8,40,0)

$t = New-Object System.Windows.Forms.TextBox
$t.Anchor = [System.Windows.Forms.AnchorStyles](`
     [System.Windows.Forms.AnchorStyles]::Bottom `
     -bor `
     [System.Windows.Forms.AnchorStyles]::Left `
     -bor `
     [System.Windows.Forms.AnchorStyles]::Right `
  )
$t.Enabled = $false
$t.Location = New-Object System.Drawing.Point (12,395)
$t.Multiline = $true
$t.Name = "txtLog"
$t.ScrollBars = [System.Windows.Forms.ScrollBars]::Horizontal
$t.Size = New-Object System.Drawing.Size (933,89)
$t.TabIndex = 2

# $c.ToDate = New-Object  Date(CType(0, Long))
# $c.ToolTipText = CType(resources.GetObject("GanttChart3.ToolTipText"), System.Collections.Generic.List(Of String))
$c.ToolTipTextTitle = ""
$co = New-Object System.ComponentModel.Container
$me = New-Object System.Windows.Forms.ContextMenuStrip ($co)
$me.Name = "ContextMenuGanttChart1"
$me.Size = New-Object System.Drawing.Size (141,26)

$mes = New-Object System.Windows.Forms.ToolStripMenuItem
$mes.Name = "SaveImageToolStripMenuItem"
$mes.Size = New-Object System.Drawing.Size (140,22)
$mes.Text = "Save image"

$me.Items.AddRange([System.Windows.Forms.ToolStripItem[]]@( $mes))
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.ClientSize = New-Object System.Drawing.Size (957,487)
$f.Controls.Add($c)
$f.Controls.Add($t)
$f.MinimumSize = New-Object System.Drawing.Size (300,277)
$f.Name = "Form1"
$f.Text = "Gantt Chart Tester"
$c.ResumeLayout($false)
$f.ResumeLayout($false)
$f.PerformLayout()

$f.Topmost = $true
$c.Add_MouseMove({
    param(
      [System.Object]$sender,
      [System.Windows.Forms.MouseEventArgs]$e
    )
    [ganttchart]$b = [ganttchart]($sender)
    $toolTipText = @()
    if ($b.MouseOverRowText.Length -gt 0) {

      [barinformation]$val = [barinformation]($b.MouseOverRowValue)
      $toolTipText += "[b]Date:"
      $toolTipText += "From "
      $toolTipText += ($val.FromTime.ToLongDateString() + " - " + $val.FromTime.ToString("HH:mm"))
      $toolTipText += "To "
      $toolTipText += ($val.ToTime.ToLongDateString() + " - " + $val.ToTime.ToString("HH:mm"))

    } else {
      $toolTipText += ""
    }
    $b.ToolTipTextTitle = $b.MouseOverRowText
    $b.ToolTipText = $toolTipText

  })
$c.Add_BarChanged({
    param(
      [System.Object]$sender,
      [System.Object]$value
    )
    [barinformation]$b = [barinformation]($value)
    [string]$lineToAdd = ($b.RowText + " has changed")
    $t.Text = ($lineToAdd + "`r`n" + $t.Text)
  })
$f.Add_Shown({ $f.Activate() })
$f.KeyPreview = $True
$caller = New-Object -TypeName 'MyWin32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

[void]$f.ShowDialog([mywin32window]($caller))

$f.Dispose()

