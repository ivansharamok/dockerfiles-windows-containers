using mvc_log4net.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace mvc_log4net.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            Log.Info(string.Format("Home page Index action is called at '{0}'", DateTime.Now));
            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}