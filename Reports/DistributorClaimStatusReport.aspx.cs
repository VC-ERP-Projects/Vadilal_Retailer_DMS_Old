using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class Reports_DistributorClaimStatusReport : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;

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

                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.OMNU.PageName == pagename && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    AuthType = Auth.AuthorizationType;

                    var UserType = Session["UserType"].ToString();
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");

                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
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

        txtDate.Text = "";
        txtToDate.Text = "";
        ddlClaimStatus.SelectedValue = "0";
        //gvclaimstatus.DataSource = null;
        //gvclaimstatus.DataBind();
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                ddlMode.DataTextField = "ReasonName";
                ddlMode.DataValueField = "ReasonID";
                ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID }).OrderBy(x => x.ReasonName).ToList();
                ddlMode.DataBind();
                ddlMode.Items.Insert(0, new ListItem("---Select---", "0"));

                // txtFromDate.Text = "01/06/2022";
                //txtToDate.Text = "30/06/2022";
                // txtDistCode.Text = "DOAK9320 - KATARIA AGENCY JUNAGADH - 2001200000100000";
            }
        }
    }

    #endregion

    #region Griedview Events

    //protected void gvclaimstatus_Prerender(object sender, EventArgs e)
    //{
    //    if (gvclaimstatus.Rows.Count > 0)
    //    {
    //        gvclaimstatus.HeaderRow.TableSection = TableRowSection.TableHeader;
    //        gvclaimstatus.FooterRow.TableSection = TableRowSection.TableFooter;
    //    }
    //}

    #endregion

    #region Button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {

        try
        {
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
            int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }
            if (ddlReportBy.SelectedValue == "4")
            {
                if (SUserID == 0 && RegionID == 0 && PlantID == 0 && SSID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                    return;
                }
            }
            if (ddlReportBy.SelectedValue == "2")
            {
                if (SUserID == 0 && RegionID == 0 && PlantID == 0 && DistributorID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                    return;
                }
            }
            DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
            DateTime Todate = Convert.ToDateTime(txtToDate.Text);
            Todate = new DateTime(Todate.Year, Todate.Month, DateTime.DaysInMonth(Todate.Year, Todate.Month));

            if (Fromdate > Todate)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim To month  is not less than From month.',3);", true);
                return;
            }
            int lastDay = DateTime.DaysInMonth(DateTime.Now.Year, DateTime.Now.Month);
            var endDate = lastDay.ToString() + "/" + DateTime.Now.Month.ToString() + "/" + DateTime.Now.Year.ToString();
            DateTime origDT = Convert.ToDateTime(endDate);
            DateTime lastDate = new DateTime(origDT.Year, origDT.Month, 1).AddMonths(1).AddDays(-1);
            if (Todate > lastDate)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you can not select future month.',3);", true);
                return;

            }
            if (ddlMode.SelectedValue.ToString() == "57")
            {

                 ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select this claim type because it is direct sync to SAP Z-Table.',3);", true);
                //ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('તમે આ ક્લેમ ટાઈપ સિલેક્ટ નાં કરી શકો કારણ કે તે ડાયરેક્ટ SAP ના Z - Table માં Sync થાય છે.',3);", true);
                return;
            }
            ifmMaterialPurchase.Attributes.Add("src", "../Reports/ViewReport.aspx?DistClaimFromDate=" + Fromdate.ToShortDateString() + "&DistClaimToDate=" + Todate.ToShortDateString() +
         "&ClaimRptSSID=" + SSID + "&ClaimRptDistributorID=" + DistributorID + "&ClaimRptRegionID=" + RegionID + "&ClaimRpttRptForID=" + ddlReportBy.SelectedValue + "&PlantID=" + PlantID +
         "&ClaimRqstClaimTypeID=" + ddlMode.SelectedValue + "&ClaimRptStatusID=" + ddlClaimStatus.SelectedValue + "&ClaimRqstReportBy=" + ddlReportBy.SelectedValue + "&ClaimRqstSUserID=" + SUserID + "&ClaimType=" + ddlMode.SelectedValue + "&IsAuto=" + ddlIsAuto.SelectedValue);

            //Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            //SqlCommand Cm = new SqlCommand();
            //Cm.Parameters.Clear();
            //Cm.CommandType = CommandType.StoredProcedure;
            //Cm.CommandText = "DistributorClaimStatus";
            //Cm.Parameters.AddWithValue("@FromDate", Common.DateTimeConvert(txtFromDate.Text));
            //Cm.Parameters.AddWithValue("@ToDate", Common.DateTimeConvert(txtToDate.Text));
            //Cm.Parameters.AddWithValue("@ClaimStatus", ddlClaimStatus.SelectedValue);
            //Cm.Parameters.AddWithValue("@MonthWise", ddlDate.SelectedValue);
            //Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            //Cm.Parameters.AddWithValue("@SSID", SSID);
            //Cm.Parameters.AddWithValue("@PlantID", PlantID);
            //Cm.Parameters.AddWithValue("@RegionID", RegionID);
            //Cm.Parameters.AddWithValue("@ReportFor", ddlReportBy.SelectedValue);
            //Cm.Parameters.AddWithValue("@ParentID", ParentID);
            //Cm.Parameters.AddWithValue("@EmpID", UserID);
            //Cm.Parameters.AddWithValue("@SUserID", SUserID);
            //Cm.Parameters.AddWithValue("@ClaimType", ddlMode.SelectedValue);
            //Cm.Parameters.AddWithValue("@IsAuto", ddlIsAuto.SelectedValue);
            //DataSet ds = objClass.CommonFunctionForSelect(Cm);
            //gvclaimstatus.DataSource = ds.Tables[0];
            //gvclaimstatus.DataBind();

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }

    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
            int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }
            if (ddlReportBy.SelectedValue == "4")
            {
                if (SUserID == 0 && RegionID == 0 && PlantID == 0 && SSID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                    return;
                }
            }
            if (ddlReportBy.SelectedValue == "2")
            {
                if (SUserID == 0 && RegionID == 0 && PlantID == 0 && DistributorID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                    return;
                }
            }
            DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
            DateTime Todate = Convert.ToDateTime(txtToDate.Text);
            Todate = new DateTime(Todate.Year, Todate.Month, DateTime.DaysInMonth(Todate.Year, Todate.Month));
            if (Fromdate > Todate)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim To month  is not less than From month.',3);", true);
                return;
            }
            if (ddlMode.SelectedValue.ToString() == "57")
            {

                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select this claim type because it is direct sync to SAP Z-Table.',3);", true);
                //ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('તમે આ ક્લેમ ટાઈપ સિલેક્ટ નાં કરી શકો કારણ કે તે ડાયરેક્ટ SAP ના Z - Table માં Sync થાય છે.',3);", true);
                return;
            }
            ifmMaterialPurchase.Attributes.Add("src", "../Reports/ViewReport.aspx?DistClaimFromDate=" + Fromdate.ToShortDateString() + "&DistClaimToDate=" + Todate.ToShortDateString() +
         "&ClaimRptSSID=" + SSID + "&ClaimRptDistributorID=" + DistributorID + "&ClaimRptRegionID=" + RegionID + "&ClaimRpttRptForID=" + ddlReportBy.SelectedValue + "&PlantID=" + PlantID +
         "&ClaimRqstClaimTypeID=" + ddlMode.SelectedValue + "&ClaimRptStatusID=" + ddlClaimStatus.SelectedValue + "&ClaimRqstReportBy=" + ddlReportBy.SelectedValue + "&ClaimRqstSUserID=" + SUserID + "&ClaimType=" + ddlMode.SelectedValue + "&IsAuto=" + ddlIsAuto.SelectedValue + "&Export=1");
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }

    }
    #endregion

    protected void ifmMaterialPurchase_Load(object sender, EventArgs e)
    {

    }
}