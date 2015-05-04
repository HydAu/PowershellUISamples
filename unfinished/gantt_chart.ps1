
#Copyright (c) 2015 Serguei Kouzmine
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

#  https://www.google.com/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=how+to+suppress+Warning+as+Error:+The+field+is+assigned+but+its+value+is+never+used
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

#--  added a c# version of the same. Source output of dot JetBrains decompiler used

Add-Type @"
// Decompiled with JetBrains decompiler

using System;
using System.Windows.Forms;
using System.Drawing;

namespace JetBrainsDecompiledApplication
{
  public class BarInformation
  {
    private string _rowText;
    private DateTime _fromTime;
    private DateTime _toTime;
    private Color _color;
    private Color _hoverColor;
    private int _index;

    public string RowText
    {
      get
      {
        return this._rowText;
      }
      set
      {
        this._rowText = value;
      }
    }

    public DateTime FromTime
    {
      get
      {
        return this._fromTime;
      }
      set
      {
        this._fromTime = value;
      }
    }

    public DateTime ToTime
    {
      get
      {
        return this._toTime;
      }
      set
      {
        this._toTime = value;
      }
    }

    public Color Color
    {
      get
      {
        return this._color;
      }
      set
      {
        this._color = value;
      }
    }

    public Color HoverColor
    {
      get
      {
        return this._hoverColor;
      }
      set
      {
        this._hoverColor = value;
      }
    }

    public int Index
    {
      get
      {
        return this._index;
      }
      set
      {
        this._index = value;
      }
    }

    public BarInformation(string rowText, DateTime fromTime, DateTime totime, Color color, Color hoverColor, int index)
    {
      this.RowText = rowText;
      this.FromTime = fromTime;
      this.ToTime = totime;
      this.Color = color;
      this.HoverColor = hoverColor;
      this.Index = index;
    }
  }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll', 'System.Drawing.dll'

Add-Type @"
// Decompiled with JetBrains decompiler

// using Microsoft.VisualBasic.CompilerServices;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
// using System.Runtime.CompilerServices;
using System.Windows.Forms;

namespace JetBrainsDecompiledApplication
{
  public class GanttChart : Control
  {
    // private GanttChart.MouseOverPart mouseHoverPart;
    // private int mouseHoverBarIndex;
    private List<GanttChart.ChartBarDate> bars;
    private DateTime headerFromDate;
    private DateTime headerToDate;
    // private int barIsChanging;
    private int barStartRight;
    private int barStartLeft;
    private int headerTimeStartTop;
    private List<GanttChart.Header> shownHeaderList;
    private int barStartTop;
    private int barHeight;
    private int barSpace;
    private int widthPerItem;
    private DateTime _mouseOverColumnValue;
    private string _mouseOverRowText;
    private object _mouseOverRowValue;
    private Pen lineColor;
    private Font dateTextFont;
    private Font timeTextFont;
    private Font rowTextFont;
    private ToolTip _ToolTip;
    private bool _allowEditBarWithMouse;
    private Bitmap objBmp;
    private Graphics objGraphics;
    private int lastLineStop;
    private List<string> _toolTipText;
    private string _toolTipTextTitle;
    private Point MyPoint;
    private int barsViewable;
    private int scrollPosition;
    //private Rectangle topPart;
    //private Rectangle BottomPart;
    private Rectangle scroll;
    // private Rectangle scrollBarArea;
    // private bool mouseOverTopPart;
    // private bool mouseOverBottomPart;
    // private bool mouseOverScrollBar;
    // private bool mouseOverScrollBarArea;

    internal virtual ToolTip ToolTip
    {
    get
      {
        return this._ToolTip;
      }
 set
      {
        PopupEventHandler popupEventHandler = new PopupEventHandler(this.ToolTipText_Popup);
        DrawToolTipEventHandler toolTipEventHandler = new DrawToolTipEventHandler(this.ToolTipText_Draw);
        if (this._ToolTip != null)
        {
          this._ToolTip.Popup -= popupEventHandler;
          this._ToolTip.Draw -= toolTipEventHandler;
        }
        this._ToolTip = value;
        if (this._ToolTip == null)
          return;
        this._ToolTip.Popup += popupEventHandler;
        this._ToolTip.Draw += toolTipEventHandler;
      }
    }

    public bool AllowManualEditBar
    {
      get
      {
        return this._allowEditBarWithMouse;
      }
      set
      {
        this._allowEditBarWithMouse = value;
      }
    }

    public DateTime FromDate
    {
      get
      {
        return this.headerFromDate;
      }
      set
      {
        this.headerFromDate = value;
      }
    }

    public DateTime ToDate
    {
      get
      {
        return this.headerToDate;
      }
      set
      {
        this.headerToDate = value;
      }
    }
    public string MouseOverRowText
    {
      get
      {
        return this._mouseOverRowText;
      }
    }

    public object MouseOverRowValue
    {
      get
      {
        return this._mouseOverRowValue;
      }
    }

    public DateTime MouseOverColumnDate
    {
      get
      {
        return this._mouseOverColumnValue;
      }
    }

    public Pen GridColor
    {
      get
      {
        return this.lineColor;
      }
      set
      {
        this.lineColor = value;
      }
    }

    public Font RowFont
    {
      get
      {
        return this.rowTextFont;
      }
      set
      {
        this.rowTextFont = value;
      }
    }

    public Font DateFont
    {
      get
      {
        return this.dateTextFont;
      }
      set
      {
        this.dateTextFont = value;
      }
    }

    public Font TimeFont
    {
      get
      {
        return this.timeTextFont;
      }
      set
      {
        this.timeTextFont = value;
      }
    }

    public string ToolTipTextTitle
    {
      get
      {
        return this._toolTipTextTitle;
      }
      set
      {
        this._toolTipTextTitle = value;
      }
    }

    public List<string> ToolTipText
    {
      get
      {
        if (this._toolTipText == null)
          this._toolTipText = new List<string>();
        return this._toolTipText;
      }
      set
      {
        this._toolTipText = value;
        Point point = this.PointToClient(Cursor.Position);
        if (point == this.MyPoint)
          return;
        this.MyPoint = point;
        this.ToolTip.SetToolTip((Control) this, ".");
      }
    }

    private int ScrollPositionY
    {
      get
      {

        if (this.scroll == null)
          return -1;
        return checked ((int) Math.Round(unchecked ((double) this.scroll.Height / 2.0 + (double) this.scroll.Location.Y + 19.0)));
      }
      set
      {
        int indexChartBar = this.GetIndexChartBar("QQQWWW");
        int num1 = checked (this.Height - 30);
        Decimal num2 = new Decimal((double) num1 / (double) indexChartBar * (double) this.barsViewable);
        Decimal d2 = Decimal.Divide(Decimal.Subtract(new Decimal(num1), num2), new Decimal(checked (indexChartBar - this.barsViewable)));
        int num3 = 0;
        int obj =  9999;
        while (num3 < indexChartBar)
        {
          int Left = (int) Math.Round(Convert.ToDouble(Decimal.Add(Decimal.Multiply(new Decimal(num3), d2), Decimal.Divide(num2, new Decimal(2L)))) + 15.0) - value;
          if (obj  < 0)
          {
            if( Left <  obj )
            {
              this.scrollPosition = checked (num3 - 1);
              this.PaintChart();
              break;
            }
          }
          else if ( Left < obj)
          {
            this.scrollPosition = checked (num3 - 1);
            if (checked (this.scrollPosition + this.barsViewable) > this.GetIndexChartBar("QQQWWW"))
              this.scrollPosition = checked (this.GetIndexChartBar("QQQWWW") - this.barsViewable);
            this.PaintChart();
            break;
          }
          // obj = RuntimeHelpers.GetObjectValue(Left);
          obj = Left;
          checked { ++num3; }
        }
      }
    }

    // public event GanttChart.MouseDraggedEventHandler MouseDragged;
    // will need the next one.
    // public event GanttChart.BarChangedEventHandler BarChanged;

    public GanttChart()
    {
      // this.MouseLeave += new EventHandler(this.GanttChart_MouseLeave);
      // this.MouseDragged += new GanttChart.MouseDraggedEventHandler(this.GanttChart_MouseDragged);
      // this.MouseClick += new MouseEventHandler(this.GanttChart_Click);
      // this.MouseWheel += new MouseEventHandler(this.GanttChart_MouseWheel);
      // this.MouseMove += new MouseEventHandler(this.GanttChart_MouseMove);
      // this.mouseHoverPart = GanttChart.MouseOverPart.Empty;
      // this.mouseHoverBarIndex = -1;
      this.bars = new List<GanttChart.ChartBarDate>();
      this.headerFromDate = new DateTime();
      this.headerToDate = new DateTime();
      // this.barIsChanging = -1;
      this.barStartRight = 20;
      this.barStartLeft = 100;
      this.headerTimeStartTop = 30;
      this.barStartTop = 50;
      this.barHeight = 9;
      this.barSpace = 5;
      this._mouseOverColumnValue = new DateTime();
      this._mouseOverRowText = "";
      this._mouseOverRowValue = (object) null;
      this.lineColor = Pens.Bisque;
      this.dateTextFont = new Font("VERDANA", 8f, FontStyle.Regular, GraphicsUnit.Point);
      this.timeTextFont = new Font("VERDANA", 8f, FontStyle.Regular, GraphicsUnit.Point);
      this.rowTextFont = new Font("VERDANA", 8f, FontStyle.Regular, GraphicsUnit.Point);
      this.ToolTip = new ToolTip();
      this._allowEditBarWithMouse = false;
      this.lastLineStop = 0;
      this._toolTipText = new List<string>();
      this._toolTipTextTitle = "";
      this.MyPoint = new Point(0, 0);
      this.barsViewable = -1;
      this.scrollPosition = 0;
      //this.topPart = new Rectangle();
      //this.BottomPart = new Rectangle();
      this.scroll = new Rectangle();
      //this.scrollBarArea = new Rectangle();
      // this.mouseOverTopPart = false;
      // this.mouseOverBottomPart = false;
      // this.mouseOverScrollBar = false;
      // this.mouseOverScrollBarArea = false;
      this.ToolTip.AutoPopDelay = 15000;
      this.ToolTip.InitialDelay = 250;
      this.ToolTip.OwnerDraw = true;
      this.objBmp = new Bitmap(1280, 1024, PixelFormat.Format24bppRgb);
      this.objGraphics = Graphics.FromImage((Image) this.objBmp);
      this.SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.DoubleBuffer, true);
    }

    private void SetBarStartLeft(string rowText)
    {
      int num = checked ((int) Math.Round((double) this.CreateGraphics().MeasureString(rowText, this.rowTextFont, 500).Width));
      if (num <= this.barStartLeft)
        return;
      this.barStartLeft = num;
    }

    public void AddChartBar(string rowText, object barValue, DateTime fromTime, DateTime toTime, Color color, Color hoverColor, int rowIndex)
    {
      this.bars.Add(new GanttChart.ChartBarDate()
      {
        Text = rowText,
        Value  = barValue,
        StartValue = fromTime,
        EndValue = toTime,
        Color = color,
        HoverColor = hoverColor,
        RowIndex = rowIndex
      });
      this.SetBarStartLeft(rowText);
    }

    public void AddChartBar(string rowText, object barValue, DateTime fromTime, DateTime toTime, Color color, Color hoverColor, int rowIndex, bool hideFromMouseMove)
    {
      this.bars.Add(new GanttChart.ChartBarDate()
      {
        Text = rowText,
        /*  Value = RuntimeHelpers.GetObjectValue(barValue), */
        Value  = barValue,
        StartValue = fromTime,
        EndValue = toTime,
        Color = color,
        HoverColor = hoverColor,
        RowIndex = rowIndex,
        HideFromMouseMove = hideFromMouseMove
      });
      this.SetBarStartLeft(rowText);
    }

    public int GetIndexChartBar(string rowText)
    {
      int num = -1;
      List<GanttChart.ChartBarDate>.Enumerator enumerator;
      try
      {
        enumerator = this.bars.GetEnumerator();
        while (enumerator.MoveNext())
        {
          GanttChart.ChartBarDate current = enumerator.Current;
          if (current.Text.Equals(rowText))
            return current.RowIndex;
          if (current.RowIndex > num)
            num = current.RowIndex;
        }
      }
      finally
      {
       /*  enumerator.Dispose(); */
      }
      return checked (num + 1);
    }

    public void RemoveBars()
    {
      this.bars = new List<GanttChart.ChartBarDate>();
      this.barStartLeft = 100;
    }

    public void PaintChart()
    {
      this.Invalidate();
    }

    private void PaintChart(Graphics gfx)
    {
      gfx.Clear(this.BackColor);
      if (DateTime.Compare(this.headerFromDate, DateTime.MinValue) == 0 | DateTime.Compare(this.headerToDate, DateTime.MinValue) == 0)
        return;
      this.DrawScrollBar(gfx);
      this.DrawHeader(gfx, (List<GanttChart.Header>) null);
      this.DrawNetHorizontal(gfx);
      this.DrawNetVertical(gfx);
      this.DrawBars(gfx, false);
      // this.objBmp = new Bitmap(checked (this.Width - this.barStartRight), this.lastLineStop, PixelFormat.Format24bppRgb);
      // this.objGraphics = Graphics.FromImage((Image) this.objBmp);
    }

    protected override void OnPaint(PaintEventArgs pe)
    {
      base.OnPaint(pe);
      this.PaintChart(pe.Graphics);
    }

    private void DrawHeader(Graphics gfx, List<GanttChart.Header> headerList)
    {
      if (headerList == null)
        headerList = this.GetFullHeaderList();
      if (headerList.Count == 0)
        return;
      this.widthPerItem = (this.Width - 10 - this.barStartLeft - this.barStartRight) /  headerList.Count;
      if (this.widthPerItem < 40)
      {
        List<GanttChart.Header> headerList1 = new List<GanttChart.Header>();
        bool flag = true;
        List<GanttChart.Header>.Enumerator enumerator;
        try
        {
          enumerator = headerList.GetEnumerator();
          while (enumerator.MoveNext())
          {
            GanttChart.Header current = enumerator.Current;
            if (flag)
            {
              headerList1.Add(current);
              flag = false;
            }
            else
              flag = true;
          }
        }
        finally
        {
         // enumerator.Dispose();
        }
        this.DrawHeader(gfx, headerList1);
      }
      else
      {
        int num1 = 0;
        GanttChart.Header header = (GanttChart.Header) null;
        List<GanttChart.Header>.Enumerator enumerator;
        try
        {
          enumerator = headerList.GetEnumerator();
          while (enumerator.MoveNext())
          {
            GanttChart.Header current = enumerator.Current;
            int num2 = checked (this.barStartLeft + num1 * this.widthPerItem);
            bool flag = false;
            current.StartLocation = num2;
            if (header == null)
              flag = true;
            else if (current.Time.Hour < header.Time.Hour)
              flag = true;
            else if (current.Time.Minute == header.Time.Minute)
              flag = true;
            if (flag)
            {
              string s = current.HeaderTextInsteadOfTime.Length <= 0 ? current.Time.ToString("d-MMM") : current.HeaderTextInsteadOfTime;
              gfx.DrawString(s, this.dateTextFont, Brushes.Black, (float) num2, 0.0f);
            }
            gfx.DrawString(current.HeaderText, this.timeTextFont, Brushes.Black, (float) num2, (float) this.headerTimeStartTop);
            checked { ++num1; }
            header = current;
          }
        }
        finally
        {
         // enumerator.Dispose();
        }
        this.shownHeaderList = headerList;
        this.widthPerItem = checked ((int) Math.Round(unchecked ((double) checked (this.Width - 10 - this.barStartLeft - this.barStartRight) / (double) this.shownHeaderList.Count)));
      }
    }

    private void DrawBars(Graphics grfx, bool ignoreScrollAndMousePosition = false)
    {
/*
      if (this.shownHeaderList == null || this.shownHeaderList.Count == 0)
        return;
      Decimal d1 = (this.shownHeaderList[1].StartLocation - this.shownHeaderList[0].StartLocation)/ 
                    (int)(Math.Round((this.shownHeaderList[1].Time - this.shownHeaderList[0].Time).TotalMinutes));
      List<GanttChart.ChartBarDate>.Enumerator enumerator;
      try
      {
        enumerator = this.bars.GetEnumerator();
        while (enumerator.MoveNext())
        {
          GanttChart.ChartBarDate current = enumerator.Current;
          int rowIndex = current.RowIndex;
          int num1 = 0;
          if (!ignoreScrollAndMousePosition)
            num1 = this.scrollPosition;
          TimeSpan timeSpan1 = current.StartValue - this.FromDate;
          int num2 = timeSpan1.Days * 1440 + timeSpan1.Hours * 60 + timeSpan1.Minutes;
          int num3 = Convert.ToInt32(Decimal.Multiply(d1, new Decimal(num2)));
          DateTime t1 = current.EndValue;
          if (DateTime.Compare(t1, DateTime.MinValue) == 0)
            t1 = DateTime.Now;
          TimeSpan timeSpan2 = t1 - current.StartValue;
          int num4 = checked (timeSpan2.Days * 1440 + timeSpan2.Hours * 60 + timeSpan2.Minutes);
          int num5 = Convert.ToInt32(Decimal.Multiply(d1, new Decimal(num4)));
          int x = this.barStartLeft + num3;
          int y = this.barStartTop + this.barHeight * (rowIndex - num1) + this.barSpace * (rowIndex - num1) + 2;
          int width = num5;
          int height = this.barHeight;
          if (width == 0)
            width = 1;
          if (checked (x - this.barStartLeft) < 0)
            x = this.barStartLeft;
          Color color1 = !(Operators.CompareString(this.MouseOverRowText, current.Text, false) == 0 & DateTime.Compare(current.StartValue, this._mouseOverColumnValue) <= 0 & DateTime.Compare(current.EndValue, this._mouseOverColumnValue) >= 0) ? current.Color : current.HoverColor;
          GanttChart.ChartBarDate.Location topLocation1 = current.TopLocation;
          Point point1 = new Point(x, y);
          Point point2 = point1;
          topLocation1.Left = point2;
          GanttChart.ChartBarDate.Location topLocation2 = current.TopLocation;
          point1 = new Point(checked (x + width), y);
          Point point3 = point1;
          topLocation2.Right = point3;
          GanttChart.ChartBarDate.Location bottomLocation1 = current.BottomLocation;
          point1 = new Point(x, checked (y + height));
          Point point4 = point1;
          bottomLocation1.Left = point4;
          GanttChart.ChartBarDate.Location bottomLocation2 = current.BottomLocation;
          point1 = new Point(x, checked (y + height));
          Point point5 = point1;
          bottomLocation2.Right = point5;
          Rectangle rect = new Rectangle(x, y, width, height);
          if (DateTime.Compare(current.StartValue, DateTime.MinValue) != 0 & DateTime.Compare(t1, DateTime.MinValue) != 0 && rowIndex >= num1 & rowIndex < checked (this.barsViewable + num1) | ignoreScrollAndMousePosition)
          {
            LinearGradientBrush linearGradientBrush1 = new LinearGradientBrush(rect, color1, Color.Gray, LinearGradientMode.Vertical);
            grfx.DrawRectangle(Pens.Black, rect);
            grfx.FillRectangle((Brush) linearGradientBrush1, rect);
            grfx.DrawString(current.Text, this.rowTextFont, Brushes.Black, 0.0f, (float) checked (this.barStartTop + this.barHeight * (rowIndex - num1) + this.barSpace * (rowIndex - num1)));
            LinearGradientBrush linearGradientBrush2 = (LinearGradientBrush) null;
            rect = new Rectangle();
            linearGradientBrush2 = (LinearGradientBrush) null;
          }
          Color color = new Color();
        }
      }
      finally
      {
     //   enumerator.Dispose();
      }
*/
    }

    public void DrawNetVertical(Graphics grfx)
    {
      if (this.shownHeaderList == null || this.shownHeaderList.Count == 0)
        return;
      int num1 = 0;
      int num2 = checked (this.Width - 10 - this.barStartLeft - this.barStartRight);
      GanttChart.Header header = (GanttChart.Header) null;
      List<GanttChart.Header>.Enumerator enumerator;
      try
      {
        enumerator = this.shownHeaderList.GetEnumerator();
        while (enumerator.MoveNext())
        {
          GanttChart.Header current = enumerator.Current;
          int y1 = header != null ? (current.Time.Hour >= header.Time.Hour ? this.headerTimeStartTop : 0) : 0;
          grfx.DrawLine(Pens.Bisque, checked (this.barStartLeft + num1 * this.widthPerItem), y1, checked (this.barStartLeft + num1 * this.widthPerItem), this.lastLineStop);
          checked { ++num1; }
          header = current;
        }
      }
      finally
      {
       // enumerator.Dispose();
      }
      grfx.DrawLine(this.lineColor, checked (this.barStartLeft + num1 * this.widthPerItem), this.headerTimeStartTop, checked (this.barStartLeft + num1 * this.widthPerItem), this.lastLineStop);
    }

    public void DrawNetHorizontal(Graphics grfx)
    {
      if (this.shownHeaderList == null || this.shownHeaderList.Count == 0)
        return;
      int x2 = checked (this.widthPerItem * this.shownHeaderList.Count + this.barStartLeft);
      int num1 = 0;
      int indexChartBar = this.GetIndexChartBar("QQQQQQ");
      int num2 = num1;
      while (num2 <= indexChartBar)
      {
        List<GanttChart.ChartBarDate>.Enumerator enumerator;
        try
        {
          enumerator = this.bars.GetEnumerator();
          while (enumerator.MoveNext())
          {
            GanttChart.ChartBarDate current = enumerator.Current;
            grfx.DrawLine(this.lineColor, 0, checked (this.barStartTop + this.barHeight * num2 + this.barSpace * num2), x2, checked (this.barStartTop + this.barHeight * num2 + this.barSpace * num2));
          }
        }
        finally
        {
         // enumerator.Dispose();
        }
        checked { ++num2; }
      }
      this.lastLineStop = checked (this.barStartTop + this.barHeight * (num2 - 1) + this.barSpace * (num2 - 1));
    }

    private List<GanttChart.Header> GetFullHeaderList()
    {

      List<GanttChart.Header> list = new List<GanttChart.Header>();
/*
      DateTime t1_1;
      // ISSUE: explicit reference operation
      // ISSUE: variable of a reference type
      DateTime& local1 = @t1_1;
      int year = this.FromDate.Year;
      int month = this.FromDate.Month;
      DateTime dateTime1 = this.FromDate;
      int day = dateTime1.Day;
      // ISSUE: explicit reference operation
      ^local1 = new DateTime(year, month, day);
      TimeSpan timeSpan = this.ToDate - this.FromDate;
      if (timeSpan.TotalDays < 1.0)
      {
        // ISSUE: explicit reference operation
        // ISSUE: variable of a reference type
        DateTime& local2 = @t1_1;
        DateTime dateTime2 = this.FromDate;
        double num = (double) dateTime2.Hour;
        // ISSUE: explicit reference operation
        DateTime t1_2 = (^local2).AddHours(num);
        for (t1_2 = !(this.headerFromDate.Minute < 59 & this.headerFromDate.Minute > 29) ? t1_2.AddMinutes(0.0) : t1_2.AddMinutes(30.0); DateTime.Compare(t1_2, this.ToDate) <= 0; t1_2 = t1_2.AddMinutes(5.0))
        {
          string str1 = Conversions.ToString(t1_2.Hour) + ":";
          string str2 = t1_2.Minute >= 10 ? str1 + "" + Conversions.ToString(t1_2.Minute) : str1 + "0" + Conversions.ToString(t1_2.Minute);
          GanttChart.Header header1 = new GanttChart.Header();
          header1.HeaderText = str2;
          header1.HeaderTextInsteadOfTime = "";
          GanttChart.Header header2 = header1;
          dateTime2 = new DateTime(t1_2.Year, t1_2.Month, t1_2.Day, t1_2.Hour, t1_2.Minute, 0);
          DateTime dateTime3 = dateTime2;
          header2.Time = dateTime3;
          list.Add(header1);
        }
      }
      else if (timeSpan.TotalDays < 60.0)
      {
        for (; DateTime.Compare(t1_1, this.ToDate) <= 0; t1_1 = t1_1.AddDays(1.0))
        {
          GanttChart.Header header1 = new GanttChart.Header();
          header1.HeaderText = "";
          header1.HeaderTextInsteadOfTime = "";
          GanttChart.Header header2 = header1;
          dateTime1 = new DateTime(t1_1.Year, t1_1.Month, t1_1.Day, 0, 0, 0);
          DateTime dateTime2 = dateTime1;
          header2.Time = dateTime2;
          list.Add(header1);
        }
      }
      else
      {
        for (; DateTime.Compare(t1_1, this.ToDate) <= 0; t1_1 = t1_1.AddMonths(1))
        {
          GanttChart.Header header1 = new GanttChart.Header();
          header1.HeaderText = "";
          GanttChart.Header header2 = header1;
          dateTime1 = new DateTime(t1_1.Year, t1_1.Month, t1_1.Day, 0, 0, 0);
          DateTime dateTime2 = dateTime1;
          header2.Time = dateTime2;
          header1.HeaderTextInsteadOfTime = t1_1.ToString("MMM");
          list.Add(header1);
        }
      }
      */
      return list;
    }

    private void GanttChart_MouseMove(object sender, MouseEventArgs e)
    {
/*
      if (this.shownHeaderList == null || this.shownHeaderList.Count == 0)
        return;
      if (e.Button != MouseButtons.Left)
      {
        this.mouseHoverPart = GanttChart.MouseOverPart.Empty;
        if (this.AllowManualEditBar && this.barIsChanging >= 0)
        {
          GanttChart.BarChangedEventHandler changedEventHandler1 = this.BarChangedEvent;
          if (changedEventHandler1 != null)
          {
            GanttChart.BarChangedEventHandler changedEventHandler2 = changedEventHandler1;
            GanttChart.ChartBarDate chartBarDate = this.bars[this.barIsChanging];
            object objectValue = RuntimeHelpers.GetObjectValue(chartBarDate.Value);

            object objectValue = chartBarDate.Value;
            // ISSUE: explicit reference operation
            // ISSUE: variable of a reference type
            object& barValue = @objectValue;
            changedEventHandler2((object) this, barValue);
            chartBarDate.Value = RuntimeHelpers.GetObjectValue(objectValue);
          }
          this.barIsChanging = -1;
        }
      }
      this.mouseHoverBarIndex = -1;
      Point point = this.PointToClient(Cursor.Position);
      TimeSpan timeSpan = this.shownHeaderList[1].Time - this.shownHeaderList[0].Time;
      Decimal d2 = Conversions.ToDecimal(Operators.DivideObject((object) checked (this.shownHeaderList[1].StartLocation - this.shownHeaderList[0].StartLocation), (object) checked (timeSpan.Days * 1440 + timeSpan.Hours * 60 + timeSpan.Minutes)));
      this._mouseOverColumnValue = point.X <= this.barStartLeft ? new DateTime() : this.FromDate.AddMinutes((double) Convert.ToInt32(Decimal.Divide(new Decimal(checked (point.X - this.barStartLeft)), d2)));
      string str = "";
      object obj = (object) null;
      bool flag = false;
      if (point.X > this.BottomPart.Left & point.Y < this.BottomPart.Right & point.Y < this.BottomPart.Bottom & point.Y > this.BottomPart.Top)
      {
        if (!this.mouseOverBottomPart)
          flag = true;
        this.mouseOverBottomPart = true;
      }
      else
      {
        if (!this.mouseOverBottomPart)
          flag = true;
        this.mouseOverBottomPart = false;
      }
      if (point.X > this.topPart.Left & point.Y < this.topPart.Right & point.Y < this.topPart.Bottom & point.Y > this.topPart.Top)
      {
        if (!this.mouseOverTopPart)
          flag = true;
        this.mouseOverTopPart = true;
      }
      else
      {
        if (!this.mouseOverTopPart)
          flag = true;
        this.mouseOverTopPart = false;
      }
      if (point.X > this.scroll.Left & point.Y < this.scroll.Right & point.Y < this.scroll.Bottom & point.Y > this.scroll.Top)
      {
        if (!this.mouseOverScrollBar)
          flag = true;
        this.mouseOverScrollBar = true;
        this.mouseOverScrollBarArea = true;
      }
      else
      {
        if (!this.mouseOverScrollBar)
          flag = true;
        this.mouseOverScrollBar = false;
        this.mouseOverScrollBarArea = false;
      }
      if (!this.mouseOverScrollBarArea && point.X > this.scrollBarArea.Left & point.Y < this.scrollBarArea.Right & point.Y < this.scrollBarArea.Bottom & point.Y > this.scrollBarArea.Top)
        this.mouseOverScrollBarArea = true;
      int num1 = 0;
      List<GanttChart.ChartBarDate>.Enumerator enumerator;
      try
      {
        enumerator = this.bars.GetEnumerator();
        while (enumerator.MoveNext())
        {
          GanttChart.ChartBarDate current = enumerator.Current;
          if (!current.HideFromMouseMove)
          {
            if (DateTime.Compare(current.EndValue, DateTime.MinValue) == 0)
              current.EndValue = DateTime.Now;
            if (point.Y > current.TopLocation.Left.Y & point.Y < current.BottomLocation.Left.Y)
            {
              if (point.X > current.TopLocation.Left.X & point.X < current.TopLocation.Right.X)
              {
                str = current.Text;
                obj = RuntimeHelpers.GetObjectValue(current.Value);
                obj = current.Value;

                this.mouseHoverBarIndex = num1;
                if (this.mouseHoverPart != GanttChart.MouseOverPart.BarLeftSide & this.mouseHoverPart != GanttChart.MouseOverPart.BarRightSide)
                  this.mouseHoverPart = GanttChart.MouseOverPart.Bar;
              }
              if (this.AllowManualEditBar)
              {
                int num2 = 5;
                if (e.Button == MouseButtons.Left)
                  num2 = 50;
                if (point.X > checked (current.TopLocation.Left.X - num2) & point.X < checked (current.TopLocation.Left.X + num2) & this.mouseHoverPart != GanttChart.MouseOverPart.BarRightSide)
                {
                  this.Cursor = Cursors.VSplit;
                  this.mouseHoverPart = GanttChart.MouseOverPart.BarLeftSide;
                  this.mouseHoverBarIndex = num1;
                }
                else if (point.X > checked (current.TopLocation.Right.X - num2) & point.X < checked (current.TopLocation.Right.X + num2) & this.mouseHoverPart != GanttChart.MouseOverPart.BarLeftSide)
                {
                  this.Cursor = Cursors.VSplit;
                  this.mouseHoverPart = GanttChart.MouseOverPart.BarRightSide;
                  this.mouseHoverBarIndex = num1;
                }
                else
                  this.Cursor = Cursors.Default;
              }
            }
          }
          checked { ++num1; }
        }
      }
      finally
      {
       // enumerator.Dispose();
      }
      this._mouseOverRowText = str;
      this._mouseOverRowValue = RuntimeHelpers.GetObjectValue(obj);
      this._mouseOverRowValue = obj ;

      if (e.Button == MouseButtons.Left)
      {
        GanttChart.MouseDraggedEventHandler draggedEventHandler = this.MouseDraggedEvent;
        if (draggedEventHandler != null)
          draggedEventHandler(RuntimeHelpers.GetObjectValue(sender), e);
          draggedEventHandler(sender, e);

      }
      else if (this._mouseOverRowValue == null & obj != null | this._mouseOverRowValue != null & obj == null | flag)
        this.PaintChart();
   */ 
    }

    private void GanttChart_MouseLeave(object sender, EventArgs e)
    {
/*
      this._mouseOverRowText = (string) null;
      this._mouseOverRowValue = (object) null;
      this.mouseHoverPart = GanttChart.MouseOverPart.Empty;
      this.PaintChart();
*/
    }

    public void GanttChart_MouseDragged(object sender, MouseEventArgs e)
    {
     /* 
      if (this.mouseOverScrollBarArea)
        this.ScrollPositionY = e.Location.Y;
      if (!this.AllowManualEditBar || this.mouseHoverBarIndex <= -1)
        return;
      if (this.mouseHoverPart == GanttChart.MouseOverPart.BarLeftSide)
      {
        this.barIsChanging = this.mouseHoverBarIndex;
        this.bars[this.mouseHoverBarIndex].StartValue = this._mouseOverColumnValue;
        this.PaintChart();
      }
      else if (this.mouseHoverPart == GanttChart.MouseOverPart.BarRightSide)
      {
        this.barIsChanging = this.mouseHoverBarIndex;
        this.bars[this.mouseHoverBarIndex].EndValue = this._mouseOverColumnValue;
        this.PaintChart();
      }
      */
    }

    private void ToolTipText_Draw(object sender, DrawToolTipEventArgs e)
    {
     /*       if (this.ToolTipText == null)
      {
        this.ToolTipText = new List<string>();
      }
      else
      {
        if (this.ToolTipText.Count == 0 || this.ToolTipText[0].Length == 0)
          return;
        e.Graphics.FillRectangle(Brushes.AntiqueWhite, e.Bounds);
        e.DrawBorder();
        int num1 = 14;
        int num2 = 12;
        e.Graphics.DrawLine(Pens.Black, 0, num1, e.Bounds.Width, num1);
        int num3 = 1;
        string toolTipTextTitle = this.ToolTipTextTitle;
        using (Font font = new Font(e.Font, FontStyle.Bold))
        {
          int num4 = checked ((int) unchecked (checked ((long) Math.Round(unchecked ((double) e.Bounds.Width - (double) e.Graphics.MeasureString(toolTipTextTitle, font).Width))) / 2L));
          int num5 = checked ((int) unchecked (checked ((long) Math.Round(unchecked ((double) num1 - (double) e.Graphics.MeasureString(toolTipTextTitle, font).Height))) / 2L));
          e.Graphics.DrawString(toolTipTextTitle, font, Brushes.Black, (float) num4, (float) num5);
        }
        List<string>.Enumerator enumerator;
        try
        {
          enumerator = this.ToolTipText.GetEnumerator();
          while (enumerator.MoveNext())
          {
            string str = enumerator.Current;
            Font font = new Font(e.Font, FontStyle.Regular);
            if (str.Contains("[b]"))
            {
              font = new Font(font.FontFamily, font.Size, FontStyle.Bold, font.Unit);
              str = str.Replace("[b]", "");
            }
            using (font)
            {
              int num4 = 5;
              int num5 = checked ((int) (unchecked (checked ((long) Math.Round(unchecked ((double) checked (num1 - num2) - (double) e.Graphics.MeasureString(str, font).Height))) / 2L) + 10L + (long) (num3 * 14)));
              e.Graphics.DrawString(str, font, Brushes.Black, (float) num4, (float) num5);
            }
            checked { ++num3; }
          }
        }
        finally
        {
  //        enumerator.Dispose();
        }
      }
      */
    }

    private void ToolTipText_Popup(object sender, PopupEventArgs e)
    {
	/*
      if (this.ToolTipText == null)
        this.ToolTipText = new List<string>();
      if (this.ToolTipText.Count == 0)
        e.ToolTipSize = new Size(0, 0);
      else if (this.ToolTipText[0].Length == 0)
      {
        e.ToolTipSize = new Size(0, 0);
      }
      else
      {
        int height = checked (18 + this.ToolTipText.Count * 15);
        e.ToolTipSize = new Size(200, height);
      }
     */
    }

    protected override void OnResize(EventArgs e)
    {
    /*
      base.OnResize(e);
      this.scrollPosition = 0;
      if (this.lastLineStop > 0)
      {
        this.objBmp = new Bitmap(checked (this.Width - this.barStartRight), this.lastLineStop, PixelFormat.Format24bppRgb);
        this.objGraphics = Graphics.FromImage((Image) this.objBmp);
      }
      this.PaintChart();
     */
    }

    private void DrawScrollBar(Graphics grfx)
    {
      /* 
      this.barsViewable = checked ((int) Math.Round(unchecked ((double) checked (this.Height - this.barStartTop) / (double) checked (this.barHeight + this.barSpace))));
      int indexChartBar = this.GetIndexChartBar("QQQWWW");
      if (indexChartBar == 0)
        return;
      int height = checked (this.Height - 30);
      Decimal num = new Decimal((double) height / (double) indexChartBar * (double) this.barsViewable);
      if (Decimal.Compare(num, new Decimal(height)) >= 0)
        return;
      Decimal d2 = Decimal.Divide(Decimal.Subtract(new Decimal(height), num), new Decimal(checked (indexChartBar - this.barsViewable)));
      this.scrollBarArea = new Rectangle(checked (this.Width - 20), 19, 12, height);
      this.scroll = new Rectangle(checked (this.Width - 20), Convert.ToInt32(Decimal.Add(new Decimal(19L), Decimal.Multiply(new Decimal(this.scrollPosition), d2))), 12, Convert.ToInt32(num));
      this.topPart = new Rectangle(checked (this.Width - 20), 10, 12, 8);
      this.BottomPart = new Rectangle(checked (this.Width - 20), checked (this.Height - 10), 12, 8);
      Brush brush1 = !this.mouseOverTopPart ? Brushes.Gray : Brushes.Black;
      Brush brush2 = !this.mouseOverBottomPart ? Brushes.Gray : Brushes.Black;
      Brush brush3 = !this.mouseOverScrollBar ? (Brush) new LinearGradientBrush(this.scroll, Color.White, Color.Gray, LinearGradientMode.Horizontal) : (Brush) new LinearGradientBrush(this.scroll, Color.Bisque, Color.Gray, LinearGradientMode.Horizontal);
      grfx.DrawRectangle(Pens.Black, this.topPart);
      grfx.FillRectangle(Brushes.LightGray, this.topPart);
      grfx.DrawRectangle(Pens.Black, this.BottomPart);
      grfx.FillRectangle(Brushes.LightGray, this.BottomPart);
      PointF[] points = new PointF[3]
      {
        new PointF((float) this.topPart.Left, (float) checked (this.topPart.Bottom - 1)),
        new PointF((float) this.topPart.Right, (float) checked (this.topPart.Bottom - 1)),
        new PointF((float) checked (this.topPart.Left + this.topPart.Right) / 2f, (float) checked (this.topPart.Top + 1))
      };
      grfx.FillPolygon(brush1, points);
      points[0] = new PointF((float) this.BottomPart.Left, (float) checked (this.BottomPart.Top + 1));
      points[1] = new PointF((float) this.BottomPart.Right, (float) checked (this.BottomPart.Top + 1));
      points[2] = new PointF((float) checked (this.BottomPart.Left + this.BottomPart.Right) / 2f, (float) checked (this.BottomPart.Bottom - 1));
      grfx.FillPolygon(brush2, points);
      grfx.DrawRectangle(Pens.Black, this.scrollBarArea);
      grfx.FillRectangle(Brushes.DarkGray, this.scrollBarArea);
      grfx.DrawRectangle(Pens.Black, this.scroll);
      grfx.FillRectangle(brush3, this.scroll);
      */
    }

    public void ScrollOneup()
    {
       /* 
      if (this.scrollPosition == 0)
        return;
      this.scrollPosition = checked (this.scrollPosition - 1);
      this.PaintChart();
      */
    }

    public void ScrollOneDown()
    {
       /* 
      if (checked (this.scrollPosition + this.barsViewable) >= this.GetIndexChartBar("QQQWWW"))
        return;
      this.scrollPosition = checked (this.scrollPosition + 1);
      this.PaintChart();
      */
    }

    private void GanttChart_Click(object sender, MouseEventArgs e)
    {
       /* 
      if (e.Button != MouseButtons.Left)
        return;
      if (this.mouseOverBottomPart)
        this.ScrollOneDown();
      else if (this.mouseOverTopPart)
        this.ScrollOneup();
      */
    }

    private void GanttChart_MouseWheel(object sender, MouseEventArgs e)
    {
       /* 
      if (e.Delta > 0)
        this.ScrollOneup();
      else
        this.ScrollOneDown();
      */
    }

    public void SaveImage(string filePath)
    {
       /* 
      this.objGraphics.SmoothingMode = SmoothingMode.HighSpeed;
      this.objGraphics.Clear(this.BackColor);
      if (DateTime.Compare(this.headerFromDate, DateTime.MinValue) == 0 | DateTime.Compare(this.headerToDate, DateTime.MinValue) == 0)
        return;
      this.DrawHeader(this.objGraphics, (List<GanttChart.Header>) null);
      this.DrawNetHorizontal(this.objGraphics);
      this.DrawNetVertical(this.objGraphics);
      this.DrawBars(this.objGraphics, true);
      this.objBmp.Save(filePath);
      */
    }

    public delegate void MouseDraggedEventHandler(object sender, MouseEventArgs e);

    public delegate void BarChangedEventHandler(object sender, ref object barValue);

    private class ChartBarDate
    {
      private DateTime _startValue;
      private DateTime _endValue;
      private Color _color;
      private Color _hoverColor;
      private string _text;
      private object _value;
      private int _rowIndex;
      private GanttChart.ChartBarDate.Location _topLocation;
      private GanttChart.ChartBarDate.Location _bottomLocation;
      private bool _hideFromMouseMove;

      public DateTime StartValue
      {
        get
        {
          return this._startValue;
        }
        set
        {
          this._startValue = value;
        }
      }

      public DateTime EndValue
      {
        get
        {
          return this._endValue;
        }
        set
        {
          this._endValue = value;
        }
      }

      public Color Color
      {
        get
        {
          return this._color;
        }
        set
        {
          this._color = value;
        }
      }

      public Color HoverColor
      {
        get
        {
          return this._hoverColor;
        }
        set
        {
          this._hoverColor = value;
        }
      }

      public string Text
      {
        get
        {
          return this._text;
        }
        set
        {
          this._text = value;
        }
      }

      public object Value
      {
        get
        {
          return this._value;
        }
        set
        {
          // this._value = RuntimeHelpers.GetObjectValue(value);
          this._value = value;
        }
      }

      public int RowIndex
      {
        get
        {
          return this._rowIndex;
        }
        set
        {
          this._rowIndex = value;
        }
      }

      public bool HideFromMouseMove
      {
        get
        {
          return this._hideFromMouseMove;
        }
        set
        {
          this._hideFromMouseMove = value;
        }
      }

      internal GanttChart.ChartBarDate.Location TopLocation
      {
        get
        {
          return this._topLocation;
        }
        set
        {
          this._topLocation = value;
        }
      }

      internal GanttChart.ChartBarDate.Location BottomLocation
      {
        get
        {
          return this._bottomLocation;
        }
        set
        {
          this._bottomLocation = value;
        }
      }

      public ChartBarDate()
      {
        this._topLocation = new GanttChart.ChartBarDate.Location();
        this._bottomLocation = new GanttChart.ChartBarDate.Location();
        this._hideFromMouseMove = false;
      }

      internal class Location
      {
        private Point _right;
        private Point _left;

        public Point Right
        {
          get
          {
            return this._right;
          }
          set
          {
            this._right = value;
          }
        }

        public Point Left
        {
          get
          {
            return this._left;
          }
          set
          {
            this._left = value;
          }
        }

        public Location()
        {
          this._right = new Point(0, 0);
          this._left = new Point(0, 0);
        }
      }
    }

    private class Header
    {
      private string _headerText;
      private int _startLocation;
      private string _headerTextInsteadOfTime;
      private DateTime _time;

      public string HeaderText
      {
        get
        {
          return this._headerText;
        }
        set
        {
          this._headerText = value;
        }
      }

      public int StartLocation
      {
        get
        {
          return this._startLocation;
        }
        set
        {
          this._startLocation = value;
        }
      }

      public string HeaderTextInsteadOfTime
      {
        get
        {
          return this._headerTextInsteadOfTime;
        }
        set
        {
          this._headerTextInsteadOfTime = value;
        }
      }

      public DateTime Time
      {
        get
        {
          return this._time;
        }
        set
        {
          this._time = value;
        }
      }

      public Header()
      {
        this._headerTextInsteadOfTime = "";
        this._time = new DateTime();
      }
    }

    private enum MouseOverPart
    {
      Empty,
      Bar,
      BarLeftSide,
      BarRightSide,
    }
  }
}

"@  -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll'
#--
@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

$f = New-Object System.Windows.Forms.Form
$f.MaximizeBox = $false
$f.MinimizeBox = $false

$c = New-Object -TypeName 'JetBrainsDecompiledApplication.GanttChart'

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

$b1 = New-Object -TypeName 'JetBrainsDecompiledApplication.BarInformation' -ArgumentList ('Step 1',(New-Object System.DateTime(2015,4,27,8,6,0)),(New-Object System.DateTime (2015,4,27,8,7,0)), [System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,0)
$b2 = New-Object -TypeName 'JetBrainsDecompiledApplication.BarInformation' -ArgumentList ('Step 2',(New-Object System.DateTime (2015,4,27,8,7,0)),(New-Object System.DateTime (2015,4,27,8,9,0)), [System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,1)
$b3 = New-Object -TypeName 'JetBrainsDecompiledApplication.BarInformation' -ArgumentList ('Step 3',(New-Object System.DateTime (2015,4,27,8,9,0)),(New-Object System.DateTime (2015,4,27,8,11,0)), [System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,2)
$b4 = New-Object -TypeName 'JetBrainsDecompiledApplication.BarInformation' -ArgumentList ('Step 4',(New-Object System.DateTime (2015,4,27,8,14,0)),(New-Object System.DateTime (2015,4,27,8,15,0)), [System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,3)
$b5 = New-Object -TypeName 'JetBrainsDecompiledApplication.BarInformation' -ArgumentList ('Step 5',(New-Object System.DateTime (2015,4,27,8,16,0)),(New-Object System.DateTime (2015,4,27,8,19,0)), [System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,4)
$b6 = New-Object -TypeName 'JetBrainsDecompiledApplication.BarInformation' -ArgumentList ('Step 6',(New-Object System.DateTime (2015,4,27,8,20,0)),(New-Object System.DateTime (2015,4,27,8,23,0)), [System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,5)
$b7 = New-Object -TypeName 'JetBrainsDecompiledApplication.BarInformation' -ArgumentList ('Step 7',(New-Object System.DateTime (2015,4,27,8,28,0)),(New-Object System.DateTime (2015,4,27,8,40,0)), [System.Drawing.Color]::Maroon,[System.Drawing.Color]::Khaki,6)
$b8 = New-Object -TypeName 'JetBrainsDecompiledApplication.BarInformation' -ArgumentList ('Step 7',(New-Object System.DateTime (2015,4,27,8,40,0)),(New-Object System.DateTime (2015,4,27,8,43,0)), [System.Drawing.Color]::DarkGray,[System.Drawing.Color]::LightGray,7)
$b9 = New-Object -TypeName 'JetBrainsDecompiledApplication.BarInformation' -ArgumentList ('Step 7',(New-Object System.DateTime (2015,4,27,8,43,0)),(New-Object System.DateTime (2015,4,27,8,55,0)), [System.Drawing.Color]::Maroon,[System.Drawing.Color]::Khaki,8)

$c.AddChartBar($b1)
$c.AddChartBar($b2)
$c.AddChartBar($b3)
$c.AddChartBar($b4)
$c.AddChartBar($b5)
$c.AddChartBar($b6)
$c.AddChartBar($b7)
$c.AddChartBar($b8)
$c.AddChartBar($b9)


$c.FromDate = New-Object System.DateTime (2015,4,27,8,5,0)
$c.ToDate   = New-Object System.DateTime (2015,4,27,8,40,0)

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
<#
$c.Add_MouseMove({
    param(
      [System.Object]$sender,
      [System.Windows.Forms.MouseEventArgs]$e
    )
    [GanttChart]$b = [GanttChart]($sender)
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
#>
$f.Add_Shown({ $f.Activate() })
$f.KeyPreview = $True
$caller = New-Object -TypeName 'MyWin32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

[void]$f.ShowDialog([mywin32window]($caller))

$f.Dispose()
