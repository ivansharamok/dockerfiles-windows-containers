using System.Web;
using System.Web.Mvc;

namespace mvc_log4net
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            //filters.Add(new HandleErrorAttribute());
            filters.Add(new Utilities.ErrorLoggerAttribute());
        }
    }
}
