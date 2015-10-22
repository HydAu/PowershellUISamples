using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Threading;

namespace PowershellRunner
{
    public class PipelineExecutor
    {
        #region public types, members
        public Pipeline Pipeline
        {
            get
            {
                return pipeline;
            }
        }

        public delegate void DataReadyDelegate(PipelineExecutor sender, ICollection<PSObject> data);
        public delegate void DataEndDelegate(PipelineExecutor sender);
        public delegate void ErrorReadyDelegate(PipelineExecutor sender, ICollection<object> data);
        public event DataReadyDelegate OnDataReady;

        public event DataEndDelegate OnDataEnd;

        public event ErrorReadyDelegate OnErrorReady;

        #endregion

        #region private types, members

        private ISynchronizeInvoke invoker;

        private Pipeline pipeline;

        private DataReadyDelegate synchDataReady;

        private DataEndDelegate synchDataEnd;

        private ErrorReadyDelegate synchErrorReady;

        private ManualResetEvent stopEvent;

        private WaitHandle[] waitHandles;
        #endregion

        #region public methods
        public PipelineExecutor(Runspace runSpace,ISynchronizeInvoke invoker,string command)
        {
            this.invoker = invoker;

            // initialize delegates
            synchDataReady = new DataReadyDelegate(SynchDataReady);
            synchDataEnd = new DataEndDelegate(SynchDataEnd);
            synchErrorReady = new ErrorReadyDelegate(SynchErrorReady);

            // initialize event members
            stopEvent = new ManualResetEvent(false);
            waitHandles = new WaitHandle[] { null, stopEvent };
            // create a pipeline and feed it the script text
            pipeline = runSpace.CreatePipeline(command);

            // we'll listen for script output data by way of the DataReady event
            pipeline.Output.DataReady += new EventHandler(Output_DataReady);
            pipeline.Error.DataReady += new EventHandler(Error_DataReady);
        }

        void Error_DataReady(object sender, EventArgs e)
        {
            // fetch all available objects
            Collection<object> data = pipeline.Error.NonBlockingRead();

            // if there were any, invoke the ErrorReady event
            if (data.Count > 0)
            {
                StoppableInvoke(synchErrorReady, new object[] { this, data });
            }
        }

        public void Start()
        {
            if (pipeline.PipelineStateInfo.State == PipelineState.NotStarted)
            {
                // close the pipeline input. If you forget to do 
                // this it won't start processing the script.
                pipeline.Input.Close();
                // invoke the pipeline. This will cause it to process the script in the background.
                pipeline.InvokeAsync();
            }
        }
        public void Stop()
        {
            // first make sure StoppableInvoke() stops blocking
            stopEvent.Set();
            // then tell the pipeline to stop the script
            pipeline.Stop();
        }
        #endregion

        #region private methods

        private object StoppableInvoke(Delegate method, object[] args)
        {
            IAsyncResult asyncResult = invoker.BeginInvoke(method, args);
            waitHandles[0] = asyncResult.AsyncWaitHandle;
            return (WaitHandle.WaitAny(waitHandles)==0) ? invoker.EndInvoke(asyncResult) : null;
        }

        private void Output_DataReady(object sender, EventArgs e)
        {
            // fetch all available objects
            Collection<PSObject> data = pipeline.Output.NonBlockingRead();

            // if there were any, invoke the DataReady event
            if (data.Count > 0)
            {
                StoppableInvoke(synchDataReady, new object[] { this, data });
            }

            if (pipeline.Output.EndOfPipeline)
            {
                // we're done! invoke the DataEnd event
                StoppableInvoke(synchDataEnd, new object[] { this });
            }
        }

        private void SynchDataReady(PipelineExecutor sender, ICollection<PSObject> data)
        {
            DataReadyDelegate delegateDataReadyCopy = OnDataReady;
            if (delegateDataReadyCopy != null)
            {
                delegateDataReadyCopy(sender, data);
            }
        }

        private void SynchDataEnd(PipelineExecutor sender)
        {
            DataEndDelegate delegateDataEndCopy = OnDataEnd;
            if (delegateDataEndCopy != null)
            {
                delegateDataEndCopy(sender);
            }
        }

        private void SynchErrorReady(PipelineExecutor sender, ICollection<object> data)
        {
            ErrorReadyDelegate delegateErrorReadyCopy = OnErrorReady;
            if (delegateErrorReadyCopy != null)
            {
                delegateErrorReadyCopy(sender, data);
            }
        }

        #endregion
    }
}
