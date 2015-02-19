using System;
using System.Windows.Controls;

namespace TreeTab
{
    public class TreeTabIGroupGrid : Grid, IDisposable
    {
        #region Constructor

        /// <summary>
        /// Sets the margins by default.
        /// </summary>
        public TreeTabIGroupGrid()
        {
            this.Margin = new System.Windows.Thickness(0, 0, 0, 0);
        }

        #endregion

        #region Methods

        #region IDisposable Members

        /// <summary>
        /// Registers the object to be collected.
        /// </summary>
        public void Dispose()
        {
            GC.ReRegisterForFinalize(this);
        }

        #endregion

        #endregion
    }
}
