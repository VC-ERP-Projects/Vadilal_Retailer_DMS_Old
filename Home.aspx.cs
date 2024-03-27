using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Threading;
using System.Data.SqlClient;
using System.Data;
using System.Web.Services;
using Newtonsoft.Json;


public partial class Home : System.Web.UI.Page
{
    static int UserIDNew = 0;
    static decimal ParentIDNew = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["LoginFlag"] != null && Session["LoginFlag"].ToString() == "2")
        {
            Response.Redirect("~/MyAccount/ChangePassword.aspx?flag=true");
        }
        else if (Session["LoginFlag"] != null && Session["LoginFlag"].ToString() == "3")
        {
            Response.Redirect("~/Sales/DayClose.aspx");
        }
        if (Session["UserID"] != null && Session["ParentID"] != null &&
            Int32.TryParse(Session["UserID"].ToString(), out UserIDNew) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentIDNew))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                lblloginname.Text = Session["FirstName"].ToString();
                var UserType = Session["UserType"].ToString();

                lbltype.Text = Session["Type"].ToString() == "1" ? "Company" : Session["Type"].ToString() == "2" ? "Distributor" : Session["Type"].ToString() == "4" ? "Super Stockiest" : "";
                var GRP1s = ctx.OEMPs.Include("OGRP").Include("OGRP.GRP1").Include("OGRP.GRP1.OMNU").FirstOrDefault(x => x.EmpID == UserIDNew && x.ParentID == ParentIDNew && x.Active).OGRP.GRP1.ToList();
                if (GRP1s != null && GRP1s.Count > 0)
                {
                    int CustType = Convert.ToInt32(Session["Type"]);
                    if (CustType != 1)
                    {
                        var id = (from a in ctx.GCM1
                                  where a.ParentID == ParentIDNew && a.IsDeleted == false && a.UnRead == true
                                  select a).Count();
                        if (id > 0)
                        {
                            lblCounter.Text = id.ToString();
                            imgReminder_notification.Visible = true;
                        }
                        else
                        {
                            imgReminder.Visible = true;
                        }
                        lblCounter.Visible = true;
                    }
                    else
                    {
                        var id = (from a in ctx.GCM1
                                  where a.CreatedBy == UserIDNew && a.IsDeleted == false && a.UnRead == true
                                    && a.Title.Contains("Claim") &&  a.ParentID == ParentIDNew
                                  select a).Count();
                        if (id > 0)
                        {
                            lblCounterEmp.Text = id.ToString();
                            imgReminder_notificationEmp.Visible = true;
                        }
                        else
                        {
                            imgReminderEmp.Visible = true;
                        }
                        lblCounterEmp.Visible = true;
                    }

                    var FilterMenus = GRP1s.Where(x => x.Active && x.AuthorizationType != "N" && !x.OMNU.ParentMenuID.HasValue && (x.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == x.OMNU.MenuType.ToUpper())).ToList();
                    foreach (var item in FilterMenus)
                    {
                        switch (item.OMNU.MenuID)
                        {
                            case 1:
                                imgAdmin.Visible = true;
                                imgAdmin.PostBackUrl = item.OMNU.MenuPath;
                                break;
                            case 2:
                                imgMaster.Visible = true;
                                imgMaster.PostBackUrl = item.OMNU.MenuPath;
                                break;
                            case 3:
                                imgBusinessPartner.Visible = true;
                                imgBusinessPartner.PostBackUrl = item.OMNU.MenuPath;
                                break;
                            case 4:
                                imgHRMS.Visible = true;
                                imgHRMS.PostBackUrl = item.OMNU.MenuPath;
                                break;
                            case 5:
                                imgInventory.Visible = true;
                                imgInventory.PostBackUrl = item.OMNU.MenuPath;
                                break;
                            case 6:
                                imgPurchase.Visible = true;
                                imgPurchase.PostBackUrl = item.OMNU.MenuPath;
                                break;
                            case 7:
                                imgSales.Visible = true;
                                imgSales.PostBackUrl = item.OMNU.MenuPath;
                                break;
                            case 8:
                                imgCRM.Visible = true;
                                imgCRM.PostBackUrl = item.OMNU.MenuPath;
                                break;
                            case 9:
                                imgUtility.Visible = true;
                                imgUtility.PostBackUrl = item.OMNU.MenuPath;
                                break;
                            case 10:
                                imgReport.Visible = false;
                                imgReport.PostBackUrl = item.OMNU.MenuPath;
                                break;
                            case 11:
                                imgAccount.Visible = false;
                                imgAccount.PostBackUrl = item.OMNU.MenuPath;
                                break;
                            case 278:
                                imgTask.Visible = true;
                                imgTask.PostBackUrl = item.OMNU.MenuPath;
                                break;
                        }
                    }
                }
            }
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }


    }

    [WebMethod]
    public static string GetMessageBroadcastList()
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand cmd = new SqlCommand();

            string ApplicableFor = ParentIDNew == 1000010000000000 ? "E" : "C";
            if (ParentIDNew == 1000010000000000 && UserIDNew == 1)
                ApplicableFor = "P";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = "GetBroadcastMsg";
            cmd.Parameters.AddWithValue("@ParentID", 1000010000000000);
            cmd.Parameters.AddWithValue("@UserID", ParentIDNew == 1000010000000000 ? UserIDNew : ParentIDNew);
            cmd.Parameters.AddWithValue("@ApplicableFor", ApplicableFor);
            cmd.Parameters.AddWithValue("@Path", "");

            DataSet Ds = new DataSet();
            Ds = objClass.CommonFunctionForSelect(cmd);
            DataTable Dt = Ds.Tables[0];
            result.Add(Dt);

            string strmsg = JsonConvert.SerializeObject(result,
                           new JsonSerializerSettings
                           {
                               ReferenceLoopHandling = ReferenceLoopHandling.Ignore
                           });
            return strmsg;
        }
        catch (Exception ex)
        {
            return "";
        }
    }

    protected void lnkLogout_Click(object sender, EventArgs e)
    {
        Session["UserType"] = Session["Type"] = Session["UserID"] = Session["ParentID"] = Session["GroupID"] = Session["FirstName"] = Session["Lang"] = Session["LoginFlag"] = null;
        Session.Clear();
        Session.Abandon();

        HttpCookie myCookie = new HttpCookie("DDMS");
        myCookie.Expires = DateTime.Now.AddDays(-1d);
        Response.Cookies.Add(myCookie);

        Response.Redirect("~/Login.aspx");
    }



    //protected void timer1_Tick(object sender, EventArgs e)
    //{
    //    var orders = ctx.OPOS.Include("OCRD").Include("OCRD.CRD1").Where(x => x.OrderType == 11 && x.ParentID == ParentID && x.IsMobile == true).Select(c => new
    //    {
    //        BillRefNo = c.BillRefNo,
    //        SalesID = c.SaleID
    //    }).Take(10).ToList();


    //    System.Text.StringBuilder str = new System.Text.StringBuilder();
    //    str.Append("<table style='width:100px;'>");
    //    lnkVersion.Text = "";
    //    int i = 1;
    //    foreach (var items in orders)
    //    {
    //        lnkVersion.Text = ".";
    //        str.Append("<tr><td style='text-align:left'>" + i + ".</td><td style='text-align:left'>&nbsp; <a href='Sales/SaleDeliveryMCom.aspx?SaleID=" + items.SalesID +"'> " + items.BillRefNo + "</a>");
    //        str.Append("</td></tr>");
    //        i++;
    //    }
    //    str.Append("</table>");
    //    lnkVersion.Attributes.Add("data-content", str.ToString());

    //}

}