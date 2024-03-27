using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_RouteDisplay : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                CustType = Convert.ToInt32(Session["Type"]);
                Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);
                LogoURL = Common.GetLogo(ParentID);
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.OMNU.PageName == pagename && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
                    AuthType = Auth.AuthorizationType;

                    var UserType = Session["UserType"].ToString();
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");

                    if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                    {
                        try
                        {
                            var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                            var unit = xml.Descendants("reports");
                            if (unit != null)
                            {
                                var ctrls = Common.GetAll(this, typeof(Label));
                                foreach (Label item in ctrls)
                                {
                                    if (unit.Elements().Any(x => x.Name == item.ID))
                                        item.Text = unit.Elements().FirstOrDefault(x => x.Name == item.ID).Value;
                                }
                            }
                        }
                        catch (Exception)
                        { }
                    }
                }
            }
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    public void ClearAllInputs()
    {
        txtDistCode.Text = "";
        if (CustType == 1)
        {
            //lblDealerWise.Text = "Dealer / Distributor Wise";
        }
        if (CustType == 2)// Distributor 
        {
            ddlRouteBy.SelectedValue = "2";
            divRouteBy.Visible = false;
            divSS.Visible = false;
            txtDistCode.Enabled = false;
            //lblDealerWise.Text = "Dealer Wise";


            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }
        else if (CustType == 4)// SS
        {
            ddlRouteBy.SelectedValue = "4";
            divRouteBy.Visible = false;
            divDistributor.Visible = false;
            txtSSDistCode.Enabled = false;
            //lblDealerWise.Text = "Distributor Wise";

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }

        var Day = System.DateTime.Now.DayOfWeek.ToString();

        if (Day == "Monday")
            inMonday.Checked = true;
        if (Day == "Tuesday")
            inTuesday.Checked = true;
        if (Day == "Wednesday")
            inWednesday.Checked = true;
        if (Day == "Thursday")
            inThursday.Checked = true;
        if (Day == "Friday")
            inFriday.Checked = true;
        if (Day == "Saturday")
            inSaturday.Checked = true;
        if (Day == "Sunday")
            inSunday.Checked = true;
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }

    }

    #endregion

    #region Griedview Events

    protected void gvRouteDisplay_PreRender(object sender, EventArgs e)
    {
        if (gvRouteDisplay.Rows.Count > 0)
        {
            gvRouteDisplay.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvRouteDisplay.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region Button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            Decimal CompanyParentID = 1000010000000000;

            if (string.IsNullOrEmpty(txtDistCode.Text) && ddlRouteBy.SelectedValue == "2")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                return;
            }
            else if (string.IsNullOrEmpty(txtSSDistCode.Text) && ddlRouteBy.SelectedValue == "4")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper SS.',3);", true);
                return;
            }

            Decimal CustomerID = 0;
            if (ddlRouteBy.SelectedValue == "2")
            {
                CustomerID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
            }
            else
            {
                CustomerID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
            }

            var DayName = (inMonday.Checked ? inMonday.Value : inTuesday.Checked ? inTuesday.Value : inWednesday.Checked ? inWednesday.Value : inThursday.Checked ? inThursday.Value : inFriday.Checked ? inFriday.Value : inSaturday.Checked ? inSaturday.Value : inSunday.Checked ? inSunday.Value : "");

            if (string.IsNullOrEmpty(DayName))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Day.',3);", true);
                return;
            }

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetRouteDisplayList";
            Cm.Parameters.AddWithValue("@RouteDay", DayName);
            Cm.Parameters.AddWithValue("@ParentID", CompanyParentID);
            Cm.Parameters.AddWithValue("@CustomerID ", CustomerID);
            Cm.Parameters.AddWithValue("@DealerWise", (chkDealerWise.Checked ? "1" : "0"));
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            gvRouteDisplay.DataSource = ds.Tables[0];
            gvRouteDisplay.DataBind();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}