using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MasterPage : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Logo As per region
       //// var FileName = Server.MapPath("~/Document/IpRegion.txt");
       //// string ipAddress = HttpContext.Current.Request.UserHostAddress.ToString();
       //// string RegionName = GetLocation();
       ////// Response.Write(RegionName);
       //// Common.TraceService(FileName, RegionName);
       //// Common.TraceService(FileName, ipAddress);
        //DDMSEntities ctx4 = new DDMSEntities();
        //int RegionId = ctx4.OCSTs.Where(x => x.StateName.ToLower() == RegionName.ToLower()).FirstOrDefault().StateID;
        //ODCM ObjODCM = ctx4.ODCMs.FirstOrDefault(x => x.RegionId == RegionId && x.OptionId == 1);
        //string LogoURL = "";
        //if (ObjODCM != null)
        //{
        //    LogoURL = ObjODCM.Logo;
        //}
        //if (LogoURL != "")
        //{
        //    LogoImg.ImageUrl = "https://dmsqa.vadilalgroup.com/Images/CompanyLogo/" + LogoURL;
        //}
        //else
        //{
        //    LogoImg.ImageUrl = "";
        //}
        //
    }
    // Get Location
    public string GetLocation()
    {

        string ipAddress = HttpContext.Current.Request.UserHostAddress.ToString();
      //  Response.Write(ipAddress);
        string APIKey = "A15FBD605A84806EE36D00D0642AA735";
        string url = string.Format("http://api.ip2location.io/?ip={1}&key={0}&format=json", APIKey, ipAddress);
        using (WebClient client = new WebClient())
        {
            string json = client.DownloadString(url);
            Location location = new JavaScriptSerializer().Deserialize<Location>(json);
            List<Location> locations = new List<Location>();
            locations.Add(location);
            return location.region_name;
        }
        //return "reg";
    }
    //
}

public class Location
{
    public string ip { get; set; }
    public string country_name { get; set; }
    public string country_code { get; set; }
    public string city_name { get; set; }
    public string region_name { get; set; }
    public string zip_code { get; set; }
    public string Latitude { get; set; }
    public string Longitude { get; set; }
    public string time_zone { get; set; }
}