using System.Web.Mvc;

namespace mvc_log4net.Utilities
{
    public class ErrorLoggerAttribute : HandleErrorAttribute
    {
        public override void OnException(ExceptionContext filterContext)
        {
            LogError(filterContext);
            base.OnException(filterContext);
        }

        private void LogError(ExceptionContext filterContext)
        {
            Log.Error(filterContext.ToString(), filterContext.Exception);
        }
    }
}