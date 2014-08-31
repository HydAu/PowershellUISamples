Imports System.Text

Module Module1

    Sub Main()
        Dim notepadHandle As IntPtr

        notepadHandle = Win32.FindWindow(Nothing, "Untitled - Notepad")

        If notepadHandle <> IntPtr.Zero Then
            Win32.EnumChildWindows(notepadHandle, AddressOf EnumCallback, 0)
        Else
            Console.WriteLine("No notepad instances found.")
        End If
    End Sub

    Function EnumCallback(ByVal hWnd As IntPtr, ByVal lParam As Integer) As Boolean
        Console.WriteLine("Got: |{0}|", Win32.GetEditText(hWnd))
        Win32.SetEditText(hWnd, "This text was set programmatically.")

        ' By returning false I tell the program to stop enumerating.  This means I'm only working
        ' with the first child window of the notepad window, which I'm hoping will be the edit
        ' control.
        Return False
    End Function

    Private Class Win32

        Private Const WM_GETTEXTLENGTH As Integer = &HE
        Private Const WM_GETTEXT As Integer = &HD
        Private Const WM_SETTEXT As Integer = &HC

        Friend Declare Auto Function FindWindow Lib "user32.dll" (ByVal className As String, _
                                                             ByVal title As String) As IntPtr

        ' The three overloads of SendMessage exist for the following reasons:
        ' 1) WM_GETTEXT needs a StringBuilder for its lParam
        ' 2) WM_SETTEXT needs a normal string for its lParam
        ' 3) WM_GETTEXTLENGTH uses 0 for both lParam and wParam
        Friend Declare Auto Function SendMessage Lib "user32.dll" (ByVal hWnd As IntPtr, _
                                                              ByVal msgId As Integer, _
                                                              ByVal wParam As Integer, _
                                                              ByVal text As StringBuilder) _
                                                                As Integer

        Friend Declare Auto Function SendMessage Lib "user32.dll" (ByVal hWnd As IntPtr, _
                                                      ByVal msgId As Integer, _
                                                      ByVal wParam As Integer, _
                                                      ByVal text As String) _
                                                        As Boolean

        Friend Declare Auto Function SendMessage Lib "user32.dll" (ByVal hWnd As IntPtr, _
                                                      ByVal msgId As Integer, _
                                                      ByVal wParam As Integer, _
                                                      ByVal lParam As Integer) _
                                                        As Integer

        Friend Declare Auto Function EnumChildWindows Lib "user32.dll" (ByVal hWndParent As IntPtr, _
                                                                   ByVal callback As EnumChildProc, _
                                                                   ByVal lParam As Integer) As Boolean

        Friend Delegate Function EnumChildProc(ByVal hWnd As IntPtr, _
                                               ByVal lParam As Integer) As Boolean

        Friend Shared Function GetEditText(ByVal hWnd As IntPtr) As String
            ' We have to know the length before getting the text; the length is one less than
            ' the number of characters we should ask for due to C's terminating null
            Dim textLength As Integer = SendMessage(hWnd, WM_GETTEXTLENGTH, 0, 0)
            Dim controlText As New StringBuilder

            If textLength > 0 Then
                Dim charsCopied As Integer
                charsCopied = SendMessage(hWnd, WM_GETTEXT, textLength + 1, controlText)
            End If

            Return controlText.ToString()
        End Function

        Friend Shared Function SetEditText(ByVal hWnd As IntPtr, ByVal text As String) As Boolean
            Return SendMessage(hWnd, WM_SETTEXT, 0, text)
        End Function
    End Class

End Module