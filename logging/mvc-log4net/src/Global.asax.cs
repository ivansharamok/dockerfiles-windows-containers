using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace mvc_log4net
{
    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            log4net.Config.XmlConfigurator.Configure();
            //log4net.Config.XmlConfigurator.Configure(new System.IO.FileInfo("~/web.config"));
            // add this line at the bottom of AssemblyInfo file if you want to load log4net configuration in this way
            // [assembly: log4net.Config.XmlConfigurator(ConfigFile = "log4net.config")]
            //log4net.Config.XmlConfigurator.Configure(System.IO.File.Open("bin/log4net.xml", System.IO.FileMode.Open, System.IO.FileAccess.Read));
        }
    }
}
