#Copyright (c) 2015 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
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


# https://www.codeproject.com/script/Membership/LogOn.aspx?rp=%2fArticles%2f6994%2fMRU-Menu-Class

Add-Type -Language 'VisualBasic' -TypeDefinition @"


Imports System.Windows.Forms
Imports System.Collections.Generic     ''' explicit import statement is required for .List
Imports System.Collections             ''' .ArrayList
Imports System                         ''' Math.Round
Namespace CjsDen
  Public Class MruList

#Region "Property Variables"
    Private mruPath_1, mruPath_2, mruPath_3, mruPath_4, mruPath_5 As String
    Private mruList As ArrayList
    Private mruMaxLen As Integer = 35
#End Region

#Region "Public Properties"
    Public Property MruItemLength() As Integer
      Get
        Return mruMaxLen
      End Get
      Set(ByVal Value As Integer)
        mruMaxLen = Value
      End Set
    End Property

    Public ReadOnly Property MruListArray() As ArrayList
      Get
        Return mruList
      End Get
    End Property

    Public ReadOnly Property MruPath1() As String
      Get
        Return mruPath_1
      End Get
    End Property

    Public ReadOnly Property MruPath2() As String
      Get
        Return mruPath_2
      End Get
    End Property

    Public ReadOnly Property MruPath3() As String
      Get
        Return mruPath_3
      End Get
    End Property

    Public ReadOnly Property MruPath4() As String
      Get
        Return mruPath_4
      End Get
    End Property

    Public ReadOnly Property MruPath5() As String
      Get
        Return mruPath_5
      End Get
    End Property

    Public ReadOnly Property menuList() As MenuItem
      Get
        Return mruMenu
      End Get
    End Property

#End Region

#Region "Components"
    Private components As System.ComponentModel.IContainer
    Private WithEvents mruMenu As MenuItem
    Private WithEvents mruItem1 As MenuItem
    Private WithEvents mruItem2 As MenuItem
    Private WithEvents mruItem3 As MenuItem
    Private WithEvents mruItem4 As MenuItem
    Private WithEvents mruItem5 As MenuItem

#End Region

#Region "Initialization"

    Public Sub New(ByVal mruMenuItem As MenuItem)
      'mruMenuItem is the menu item that will be used as the parent
      'menuItem for the MRU or 'Recent' menu
      mruList = New ArrayList(5)
      InitializeMru()
      mruMenuItem.MergeMenu(Me.mruMenu)
    End Sub

    Private Sub InitializeMru()
      'Setup each menu item that will be used
      Me.components = New System.ComponentModel.Container()
      Me.mruMenu = New MenuItem(MenuMerge.Replace, 0, Nothing, "Recent Files", Nothing, Nothing, Nothing, Nothing)
      Me.mruItem1 = New MenuItem()
      Me.mruItem2 = New MenuItem()
      Me.mruItem3 = New MenuItem()
      Me.mruItem4 = New MenuItem()
      Me.mruItem5 = New MenuItem()

      '
      'mruMenu
      '
      Me.mruMenu.MenuItems.AddRange(New MenuItem() {mruItem1, mruItem2, mruItem3, mruItem4, mruItem5})
      Me.mruMenu.Enabled = False
      '
      'mruItem1
      '
      Me.mruItem1.Index = 0
      Me.mruItem1.Text = "&1. "
      Me.mruItem1.Visible = False
      Me.mruItem1.Enabled = True
      '
      'mruItem2
      '
      Me.mruItem2.Index = 1
      Me.mruItem2.Text = "&2. "
      Me.mruItem2.Visible = False
      Me.mruItem2.Enabled = True
      '
      'mruItem3
      '
      Me.mruItem3.Index = 2
      Me.mruItem3.Text = "&3. "
      Me.mruItem3.Visible = False
      Me.mruItem3.Enabled = True
      '
      'mruItem4
      '
      Me.mruItem4.Index = 3
      Me.mruItem4.Text = "&4. "
      Me.mruItem4.Visible = False
      Me.mruItem4.Enabled = True
      '
      'mruItem5
      '
      Me.mruItem5.Index = 4
      Me.mruItem5.Text = "&5. "
      Me.mruItem5.Visible = False
      Me.mruItem5.Enabled = True

    End Sub

#End Region

#Region "Public Functions"

    Public Sub AddNewFile(ByVal newFile As String)
      'This adds a new file path to the Array list
      mruList.Add(newFile)
      'This adds the mru to the 'Recent' Menu
      performMru()
    End Sub

#End Region

#Region "Private Functions"

    Private Sub performMru()
      'Check to make sure we have at least one mru
      If mruList.Count > 0 Then
        'We have at least one mru so let's enable the 'Recent' menu
        mruMenu.Enabled = True
        Dim mruItemNum As Integer = mruList.Count - 1
        Dim x As Integer = 0
        'now lets pull the last 5 entries or mru count, which
        'ever is lesser
        Do Until x > 4 Or x > (mruList.Count - 1)
          Select Case x
            Case 0             'this is the last entry in the arraylist
              'Set the menu text with a numbered prefix
              mruItem1.Text = "&1. " & shortUrl(mruList(mruItemNum))
              'Set the Path1 property
              mruPath_1 = mruList(mruItemNum)
              'Make sure we can see the menu
              mruItem1.Visible = True
            Case 1             'this is the second last entry in the array list
              'Set the menu text with a numbered prefix
              mruItem2.Text = "&2. " & shortUrl(mruList(mruItemNum))
              'Set the Path1 property
              mruPath_2 = mruList(mruItemNum)
              'Make sure we can see the menu
              mruItem2.Visible = True
            Case 2            'this is the thrid last entry in the array list
              'Set the menu text with a numbered prefix
              mruItem3.Text = "&3. " & shortUrl(mruList(mruItemNum))
              'Set the Path1 property
              mruPath_3 = mruList(mruItemNum)
              'Make sure we can see the menu
              mruItem3.Visible = True
            Case 3            'this is the fourth last entry in the array list
              'Set the menu text with a numbered prefix
              mruItem4.Text = "&4. " & shortUrl(mruList(mruItemNum))
              'Set the Path1 property
              mruPath_4 = mruList(mruItemNum)
              'Make sure we can see the menu
              mruItem4.Visible = True
            Case 4            'this is the fifth last entry in the array list
              'Set the menu text with a numbered prefix
              mruItem5.Text = "&5. " & shortUrl(mruList(mruItemNum))
              'Set the Path1 property
              mruPath_5 = mruList(mruItemNum)
              'Make sure we can see the menu
              mruItem5.Visible = True
          End Select
          mruItemNum -= 1
          x += 1
        Loop
      End If
    End Sub

    Private Function shortUrl(ByVal mruValue As String) As String
      'This is the characters that will be shown between the short url
      Const elipse As String = " .. "
      Dim frontLen, endLen As Integer
      Dim amountShortLong As Integer
      Dim frontUrl, endUrl, shorterUrl As String
      'Get the length of the front part of the string
      frontLen = Math.Round((mruMaxLen * 0.25), 0)
      'Get the lenght of the last part of the string
      endLen = Math.Round((mruMaxLen * 0.75), 0)
      'Determin if the path string is more or less than the max length of
      'the menu item
      amountShortLong = mruValue.Length - endLen
      If amountShortLong > 0 Then
        'string is longer than the max so we have to condense it
        'Get last part of string
        endUrl = mruValue.Substring(mruValue.Length - endLen)
        'Get front part of string
        frontUrl = mruValue.Substring(0, frontLen)
        'Contruct the shorturl
        shorterUrl = frontUrl & elipse & endUrl
        Return shorterUrl
      Else
        Return mruValue
      End If

    End Function

#End Region

#Region "Event Handlers"
    'We need a way for the click event to be accessible
    'so for each click events of the menu Items we
    'Raise a custome mru_click event that can be handled
    'in your program
    Public Event mru_click(ByVal mruPath As String)

    Private Sub mruItem1_click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mruItem1.Click
      RaiseEvent mru_click(MruPath1)
    End Sub

    Private Sub mruItem2_click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mruItem2.Click
      RaiseEvent mru_click(MruPath2)
    End Sub

    Private Sub mruitem3_click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mruItem3.Click
      RaiseEvent mru_click(MruPath3)
    End Sub

    Private Sub mruItem4_click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mruItem4.Click
      RaiseEvent mru_click(MruPath4)
    End Sub

    Private Sub mruItem5_click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mruItem5.Click
      RaiseEvent mru_click(MruPath5)
    End Sub


#End Region

  End Class
End Namespace

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Drawing.dll'

# Add-Type : C:\Users\sergueik\AppData\Local\Temp\og5psvgm.0.vb(10) : Type 'ArrayList' is not defined.

<#
 manually update project and solution to VS10 schema:

#>

@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

$f = New-Object System.Windows.Forms.Form
$f.MaximizeBox = $false
$f.MinimizeBox = $false

$m1 = New-Object System.Windows.Forms.MainMenu
$fi = New-Object System.Windows.Forms.MenuItem
$fo = New-Object System.Windows.Forms.MenuItem
$m3 = New-Object System.Windows.Forms.MenuItem
$re = New-Object System.Windows.Forms.MenuItem
$m5 = New-Object System.Windows.Forms.MenuItem
$m6 = New-Object System.Windows.Forms.MenuItem
$t = New-Object System.Windows.Forms.TextBox
$b = New-Object System.Windows.Forms.Button
$f.SuspendLayout()

# MainMenu1

$m1.MenuItems.Add($fi)

# mnuFile

$fi.Index = 0
$fi.MenuItems.AddRange(@( $fo,$m3,$re,$m5,$m6))
$fi.Text = "&File"

# mnuFileOpen

$fo.Index = 0
$fo.Text = "&Open"

# MenuItem3

$m3.Index = 1
$m3.Text = "-"

# mnuFileRecent

$re.Index = 2
$re.Text = "&Recent"

# MenuItem5

$m5.Index = 3
$m5.Text = "-"

# MenuItem6

$m6.Index = 4
$m6.Text = "E&xit"

# txtNew

$t.Location = New-Object System.Drawing.Point (6,8)
$t.Name = "txtNew"
$t.Size = New-Object System.Drawing.Size (402,20)
$t.TabIndex = 0
$t.Text = "C:\Documents and Settings\Chad\My Documents\"

# btnAdd

$b.Location = New-Object System.Drawing.Point (422,8)
$b.Name = "btnAdd"
$b.Size = New-Object System.Drawing.Size (36,23)
$b.TabIndex = 1
$b.Text = "Add"

# frmMruMenu

$f.AutoScaleBaseSize = New-Object System.Drawing.Size (5,13)
$f.BackColor = [System.Drawing.Color]::FromArgb([byte](224),[byte](224),[byte](224))
$f.ClientSize = New-Object System.Drawing.Size (468,39)
$f.Controls.AddRange(@( $b,$t))
$f.Menu = $m1
$f.Name = "frmMruMenu"
$f.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$f.Text = "MRU Menu Demo"
$f.ResumeLayout($false)

$mru_list = New-Object -TypeName 'CjsDen.MruList' -ArgumentList ($re)
$m6.Add_Click({
    param(
      [System.Object]$sender,[System.EventArgs]$e
    )

  })
$b.Add_Click({
    param(
      [System.Object]$sender,[System.EventArgs]$e
    )
    $mru_list.AddNewFile($t.Text)
  })
$f.Add_Shown({ $f.Activate() })
$f.KeyPreview = $True
$caller = New-Object -TypeName 'MyWin32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
[void]$f.ShowDialog([mywin32window]($caller))

$f.Dispose()



