using System;
using System.Reflection;
using System.Collections;

namespace TreeTab
{
    public class DisposingMethod
    {
        #region Attributes

        private readonly ArrayList parameters;
        private readonly Delegate myDelegate;

        #endregion

        #region Properties

        /// <summary>
        /// Delegate for the method.
        /// </summary>
        public Delegate MyDelegate
        {
            get
            {
                return this.myDelegate;
            }
        }

        /// <summary>
        /// ArrayList containing the parameters for the method.
        /// </summary>
        public ArrayList Params
        {
            get
            {
                return this.parameters;
            }
        }

        /// <summary>
        /// Converts the collection of parameters to an array of objects.
        /// </summary>
        public object[] ParamsToArray
        {
            get
            {
                return this.parameters.ToArray();
            }
        }

        #endregion

        #region Constructors

        /// <summary>
        /// Overloads the contructor and sets the collection of parameters.
        /// </summary>
        /// <param name="_methodName">string</param>
        /// <param name="_target">object</param>
        /// <param name="_delegateType">Type</param>
        /// <param name="_parameters">ArrayList</param>
        public DisposingMethod(string _methodName, object _target, Type _delegateType, ArrayList _parameters)
            : this(_methodName, _target, _delegateType)
        {
            this.parameters = _parameters;
        }

        /// <summary>
        /// Tries to create the delegate for hte method.
        /// </summary>
        /// <param name="_methodName">string</param>
        /// <param name="_target">object</param>
        /// <param name="_delegateType">Type</param>
        public DisposingMethod(string _methodName, object _target, Type _delegateType)
        {
            try
            {
                this.myDelegate = Delegate.CreateDelegate(_delegateType, _target, _methodName);
            }
            catch (Exception ex)
            {
                throw new Exception("Error building the delegate:" + Environment.NewLine +
                    _methodName, ex);
            }
            this.parameters = new ArrayList();
        }

        #endregion

        #region Methods

        /// <summary>
        /// Executes the method.
        /// </summary>
        public void Execute()
        {
            try
            {
                this.MyDelegate.Method.Invoke(this.MyDelegate.Target, this.ParamsToArray);
            }
            catch(Exception ex)
            {
                throw new Exception("Error executing Disposing Method:" + Environment.NewLine +
                    this.MyDelegate.Method.Name, ex);
            }
        }

        #endregion
    }
}
