using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
public partial class Reports_ClaimOnHandReport : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
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

    private void ClearAllInputs()
    {
        txtDistCode.Text = "";
        chkIsDetail.Checked = true;
        txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        var today = DateTime.Today;
        var month = new DateTime(today.Year, today.Month, 1);
        var first = month.AddMonths(-1);
        var last = month.AddDays(-1);
        txtToDate.Text = Common.DateTimeConvert(last);
        txtProceFrom.Text = txtProcessdTo.Text = Common.DateTimeConvert(DateTime.Now);
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var objOEMP = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
            if (objOEMP != null)
            {
                txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
            }
        }
        //if (CustType == 4) // SS
        //{
        //    divRegion.Attributes.Add("style", "display:none;");
        //    divEmpCode.Attributes.Add("style", "display:none;");
        //    divDistributor.Attributes.Add("style", "display:none;");
        //    divReportFor.Attributes.Add("style", "display:none;");
        //    divPendingFrom.Attributes.Add("style", "display:none;");
        //    ddlReportBy.SelectedValue = "4";
        //    txtSSDistCode.Enabled = ddlReportBy.Enabled = false;

        //    using (DDMSEntities ctx = new DDMSEntities())
        //    {
        //        var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
        //        txtSSDistCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;
        //    }
        //}
        //else if (CustType == 2)// Distributor
        //{
        //    divRegion.Attributes.Add("style", "display:none;");
        //    divEmpCode.Attributes.Add("style", "display:none;");
        //    divSS.Attributes.Add("style", "display:none;");
        //    divReportFor.Attributes.Add("style", "display:none;");
        //    divPendingFrom.Attributes.Add("style", "display:none;");
        //    txtDistCode.Enabled = ddlReportBy.Enabled = false;
        //    ddlReportBy.SelectedValue = "2";
        //    using (DDMSEntities ctx = new DDMSEntities())
        //    {
        //        var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
        //        txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
        //    }
        //}
    }



    #endregion

    #region Page Load

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

                //ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID }).OrderBy(x => x.ReasonName).ToList();
                ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID, x.IsAuto }).OrderByDescending(x => x.IsAuto).ToList();
                ddlMode.DataBind();
                ddlMode.Items.Insert(0, new ListItem("---Select---", "0"));
                gvCustomers.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName, x.ReasonID, x.IsAuto }).OrderByDescending(x => x.IsAuto).ToList();
                gvCustomers.DataBind();
            }
        }
    }
    protected void OnSelectedIndexChanged(object sender, EventArgs e)
    {
        if (gvCustomers.SelectedRow != null)
        {
            Label lblreasonId = gvCustomers.SelectedRow.FindControl("lblReasonId") as Label;
            hfCustomerId.Value = lblreasonId.Text;
            if (hfCustomerId.Value == "57")
            {
                hfCustomerId.Value = "0";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select this claim type because it is direct sync to SAP Z-Table.',3);", true);
                //ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('તમે આ ક્લેમ ટાઈપ સિલેક્ટ નાં કરી શકો કારણ કે તે ડાયરેક્ટ SAP ના Z - Table માં Sync થાય છે.',3);", true);
                return;
            }
            
            txtCustomer.Text = Server.HtmlDecode(gvCustomers.SelectedRow.Cells[0].Text);
        }
        else
        {
            txtCustomer.Text = "";
        }
    }

    protected void OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[1].Text == "True")
            {
                e.Row.Cells[1].Text = "Auto";
            }
            else
            {
                e.Row.Cells[1].Text = "Manual";
            }

            //   e.Row.Attributes["onmouseover"] = "this.style.cursor='hand';this.originalBackgroundColor=this.style.backgroundColor;this.style.backgroundColor='#bbbbbb';";
            //  e.Row.Attributes["onmouseout"] = "this.style.backgroundColor=this.originalBackgroundColor;";
            e.Row.Attributes["onclick"] = ClientScript.GetPostBackClientHyperlink(this.gvCustomers, "Select$" + e.Row.RowIndex);
        }
    }
    #endregion

    #region ButtonEvent

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Int32 RptForID = Int32.TryParse(txtRptForID.Text.Split("-".ToArray()).Last().Trim(), out RptForID) ? RptForID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 ManagerID = Int32.TryParse(txtManager.Text.Split("-".ToArray()).Last().Trim(), out ManagerID) ? ManagerID : 0;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (string.IsNullOrEmpty(txtCustomer.Text))
        {
            hfCustomerId.Value = "0";
        }
        Int32 ClaimTypId = Int32.TryParse(hfCustomerId.Value, out ClaimTypId) ? ClaimTypId : 0;
        if (ClaimTypId == 57)
        {
            hfCustomerId.Value = "0";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select this claim type because it is direct sync to SAP Z-Table.',3);", true);
            return;
        }
        Int32 EmpIID = Int32.TryParse(txtEmployee.Text.Split("-".ToArray()).Last().Trim(), out EmpIID) ? EmpIID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        Int32 IsHierarchy = Int32.TryParse(ddlIsHierarchy.SelectedValue, out IsHierarchy) ? IsHierarchy : 0;
        Int32 IsAuto = Int32.TryParse(ddlClaimType.SelectedValue, out IsAuto) ? IsAuto : 0;
        //ifmClaimReq.Attributes.Add("src", "../Reports/ViewReport.aspx?ClaimRequestFromDate=" + txtFromDate.Text + "&ClaimRequestToDate=" + txtToDate.Text +
        //    "&ClaimRqstSSID=" + SSID + "&ClaimRqstDistributorID=" + DistributorID + "&ClaimRqstRegionID=" + RegionID + "&ClaimRqstRptForID=" + RptForID + "&ClaimRqstManagerID=" + ManagerID +
        //    "&ClaimRqstOption=" + ddlOption.SelectedValue + "&ClaimRqstClaimTypeID=" + ddlMode.SelectedValue + "&ClaimRqstStatusID=" + ddlStatus.SelectedValue + "&ClaimRqstReportBy=" + ddlReportBy.SelectedValue + "&ClaimRqstSUserID=" + SUserID + "&IsDetail=" + IsDetail + "&Export=1");

        ifmClaimReq.Attributes.Add("src", "../Reports/ViewReport.aspx?ClaimonHandFromDate=" + txtFromDate.Text + "&ClaimonHandToDate=" + txtToDate.Text +
        "&ClaimRqstSSID=" + SSID + "&ClaimRqstDistributorID=" + DistributorID + "&ClaimRqstRegionID=" + RegionID + "&ClaimRqstRptForID=" + RptForID + "&ClaimRqstManagerID=" + ManagerID +
        "&ClaimRqstOption=" + ddlOption.SelectedValue + "&ClaimRqstClaimTypeID=" + ClaimTypId + "&ClaimRqstStatusID=" + ddlStatus.SelectedValue + "&ClaimRqstReportBy=" + ddlReportBy.SelectedValue + "&ClaimRqstSUserID=" + EmpIID + "&IsDetail=" + IsDetail + "&LastProceedFromDate=" + txtProceFrom.Text + "&LastProceedToDate=" + txtProcessdTo.Text + "&Export=1&LastProcedBy=" + SUserID + "&IsHierarchy=" + IsHierarchy + "&IsAuto=" + IsAuto);

    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Int32 RptForID = Int32.TryParse(txtRptForID.Text.Split("-".ToArray()).Last().Trim(), out RptForID) ? RptForID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 ManagerID = Int32.TryParse(txtManager.Text.Split("-".ToArray()).Last().Trim(), out ManagerID) ? ManagerID : 0;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        Int32 EmpIID = Int32.TryParse(txtEmployee.Text.Split("-".ToArray()).Last().Trim(), out EmpIID) ? EmpIID : 0;

        Int32 IsHierarchy = Int32.TryParse(ddlIsHierarchy.SelectedValue, out IsHierarchy) ? IsHierarchy : 0;
        Int32 IsAuto = Int32.TryParse(ddlClaimType.SelectedValue, out IsAuto) ? IsAuto : 0;

        if (string.IsNullOrEmpty(txtCustomer.Text))
        {
            hfCustomerId.Value = "0";
        }
        Int32 ClaimTypId = Int32.TryParse(hfCustomerId.Value, out ClaimTypId) ? ClaimTypId : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        if (ClaimTypId == 57)
        {
            hfCustomerId.Value = "0";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select this claim type because it is direct sync to SAP Z-Table.',3);", true);
            return;
        }
        //if (RptForID == 0 && ManagerID == 0 && SSID == 0 && DistributorID == 0 && RegionID == 0)
        //{
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
        //    return;
        //}
        ifmClaimReq.Attributes.Add("src", "../Reports/ViewReport.aspx?ClaimonHandFromDate=" + txtFromDate.Text + "&ClaimonHandToDate=" + txtToDate.Text +
            "&ClaimRqstSSID=" + SSID + "&ClaimRqstDistributorID=" + DistributorID + "&ClaimRqstRegionID=" + RegionID + "&ClaimRqstRptForID=" + RptForID + "&ClaimRqstManagerID=" + ManagerID +
            "&ClaimRqstOption=" + ddlOption.SelectedValue + "&ClaimRqstClaimTypeID=" + ClaimTypId + "&ClaimRqstStatusID=" + ddlStatus.SelectedValue + "&ClaimRqstReportBy=" + ddlReportBy.SelectedValue + "&ClaimRqstSUserID=" + EmpIID + "&IsDetail=" + IsDetail + "&LastProceedFromDate=" + txtProceFrom.Text + "&LastProceedToDate=" + txtProcessdTo.Text + "&LastProcedBy=" + SUserID + "&IsHierarchy=" + IsHierarchy + "&IsAuto=" + IsAuto);


    }

    protected void ifmClaimReq_Load(object sender, EventArgs e)
    {

    }

    #endregion
}