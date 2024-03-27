using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Configuration;
using Newtonsoft.Json;

public partial class Reports_NotificationEmp : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected static int UserEmpID;
    protected static decimal ParentIDEmpID;
    protected decimal ParentID;


    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
         Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            UserEmpID = UserID;
            ParentIDEmpID = ParentID;
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
    }

    [WebMethod(EnableSession = true)]
    public static string GetTableData()
    {
        string text = "";
        try
        {

            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var result = (from a in ctx.GCM1
                              join b in ctx.OEMPs on new { EmpID = a.CreatedBy } equals new { b.EmpID } into grp
                              from pl in grp.DefaultIfEmpty()
                              where a.CreatedBy == UserEmpID && a.ParentID == ParentIDEmpID && a.IsDeleted == false
                              && a.Title.Contains("Claim")
                              select new
                              {
                                  a.GCM1ID,
                                  pl.EmpCode,
                                  pl.Name,
                                  a.Body,
                                  a.Title,
                                  a.CreatedDate,
                                  a.UnRead
                              }).OrderByDescending(x => x.CreatedDate).Take(50).ToList().
                              Select(a => new
                              {
                                  Employee = a.EmpCode + " # " + a.Name,
                                  Body = a.Body,
                                  Title = a.Title,
                                  Date = Common.DateTimeConvert(a.CreatedDate) + " " + a.CreatedDate.ToShortTimeString(),
                                  Status = (a.UnRead ? "UnRead" : "Read") + "-" + a.GCM1ID
                              }).ToList();

                text = JsonConvert.SerializeObject(result, Formatting.Indented);

            }

        }
        catch (Exception)
        {
            text = "";
        }
        return text;
    }

    [WebMethod]
    public static bool DeleteReminder(int GCM1ID)
    {
        decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

        using (DDMSEntities ctx = new DDMSEntities())
        {
            GCM1 objGCM1 = (from a in ctx.GCM1
                            where a.GCM1ID == GCM1ID && a.ParentID == ParentID
                            select a).FirstOrDefault();
            objGCM1.IsDeleted = true;

            ctx.SaveChanges();

            return true;
        }
    }

    [WebMethod]
    public static bool ReadReminder(int GCM1ID)
    {
        decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

        using (DDMSEntities ctx = new DDMSEntities())
        {
            GCM1 objGCM1 = (from a in ctx.GCM1
                            where a.GCM1ID == GCM1ID && a.ParentID == ParentIDEmpID
                            select a).FirstOrDefault();

            objGCM1.UnRead = false;

            ctx.SaveChanges();

            return true;
        }
    }

    [WebMethod]
    public static bool ReadAllReminder()
    {
        decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

        using (DDMSEntities ctx = new DDMSEntities())
        {
            ctx.GCM1.Where(a => a.IsDeleted == false && a.ParentID == ParentIDEmpID).ToList().ForEach(x => x.UnRead = false);
            ctx.SaveChanges();

            return true;
        }
    }

    [WebMethod]
    public static bool DeleteAllReminder()
    {
        decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

        using (DDMSEntities ctx = new DDMSEntities())
        {
            ctx.GCM1.Where(a => a.ParentID == ParentIDEmpID && a.IsDeleted == false).ToList().ForEach(x => x.IsDeleted = true);
            ctx.SaveChanges();

            return true;
        }
    }
}