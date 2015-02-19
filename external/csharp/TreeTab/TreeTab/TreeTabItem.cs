using System;
using System.Windows.Controls;

namespace TreeTab
{
    public class TreeTabItem : TabItem, IDisposable
    {
        #region Attributes

        protected TreeItem.TREEITEM_TYPE type;
        protected readonly string id;
        private DisposingMethod disposingMethod;

        #endregion

        #region Properties

        /// <summary>
        /// Gets the type of the object.
        /// </summary>
        public TreeItem.TREEITEM_TYPE TabType
        {
            get
            {
                return this.type;
            }
        }

        /// <summary>
        /// Gets a boolean indicating whether the tab can be closed.
        /// </summary>
        public bool CanClose
        {
            get
            {                
                return this.Header.ShowCloseButton;
            }
        }

        /// <summary>
        /// Gets or sets the header of the tab.
        /// </summary>
        public new TabHeader Header
        {
            get
            {
                return (TabHeader)base.Header;
            }
            set
            {
                base.Header = value;
            }
        }

        /// <summary>
        /// Gets the Id of the object.
        /// </summary>
        public string Id
        {
            get
            {
                return this.id;
            }
        }

        /// <summary>
        /// Gets or sets the DisposingMethod.
        /// Method that will execute when the object finalizes.
        /// </summary>
        public DisposingMethod DisposingMethod
        {
            get
            {
                return this.disposingMethod;
            }
            set
            {
                this.disposingMethod = value;
            }
        }

        /// <summary>
        /// Gets or sets the content of the tab.
        /// The content must implent the IDisposable interface.
        /// </summary>
        public new IDisposable Content
        {
            get
            {
                return (IDisposable)base.Content;
            }
            set
            {
                base.Content = (IDisposable)value;
            }
        }

        #endregion

        #region Constructors and Destructors

        /// <summary>
        /// Constructor of the object.
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_headerText">string</param>
        /// <param name="_showCloseButton">bool</param>
        public TreeTabItem(string _id, string _headerText, bool _showCloseButton)
        {
            this.type = TreeItem.TREEITEM_TYPE.MAIN;
            this.id = _id;
            TabHeader header = new TabHeader(_headerText, _showCloseButton);
            this.Header = header;
        }

        /// <summary>
        /// Destructor.
        /// Executes the method on disposing if it exists.
        /// </summary>
        ~TreeTabItem()
        {
            if (this.DisposingMethod != null)
                this.DisposingMethod.Execute();
        }

        #endregion

        #region Methods

        /// <summary>
        /// Remeoves itself from the parent's collection and call the disposing method.
        /// </summary>
        public void Close()
        {
            if (this.IsLoaded)
            {
                ((TabControl)this.Parent).Items.Remove(this);
                this.Dispose();
            }
        }

        #endregion 
    
        #region IDisposable Members

        /// <summary>
        /// Call the content's disposing method and register itself to be collected.
        /// </summary>
        public void Dispose()
        {
            if (this.Content != null)
                this.Content.Dispose();
            GC.ReRegisterForFinalize(this);            
        }

        #endregion
    }
}
