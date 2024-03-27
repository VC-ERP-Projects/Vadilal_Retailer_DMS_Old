using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_ClaimRequest : System.Web.UI.Page
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
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        if (CustType == 4) // SS
        {
            divRegion.Attributes.Add("style", "display:none;");
            divEmpCode.Attributes.Add("style", "display:none;");
            divDistributor.Attributes.Add("style", "display:none;");
            divReportFor.Attributes.Add("style", "display:none;");
            divPendingFrom.Attributes.Add("style", "display:none;");
            ddlReportBy.SelectedValue = "4";
            ddlOption.SelectedValue = "2";
            txtSSDistCode.Enabled = ddlReportBy.Enabled = ddlOption.Enabled = false;
            divclaimStatus.Visible = divdetail.Visible = divclaimtype.Visible = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSDistCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;
            }
        }
        else if (CustType == 2)// Distributor
        {
            divRegion.Attributes.Add("style", "display:none;");
            divEmpCode.Attributes.Add("style", "display:none;");
            divSS.Attributes.Add("style", "display:none;");
            divReportFor.Attributes.Add("style", "display:none;");
            divPendingFrom.Attributes.Add("style", "display:none;");
            txtDistCode.Enabled = ddlReportBy.Enabled = ddlOption.Enabled = false;
            ddlReportBy.SelectedValue = "2";
            ddlOption.SelectedValue = "2";
             
            divclaimStatus.Visible = divdetail.Visible = divclaimtype.Visible= false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }
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
                ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID,x.IsAuto }).OrderByDescending(x => x.IsAuto).ToList();
                ddlMode.DataBind();
                ddlMode.Items.Insert(0, new ListItem("---Select---", "0"));
                gvCustomers.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID, x.IsAuto }).OrderByDescending(x => x.IsAuto).ToList();
                gvCustomers.DataBind();
            }
        }
    }
    protected void OnSelectedIndexChanged(object sender, EventArgs e)
    {
        if (gvCustomers.SelectedRow != null)
        {
            hfCustomerId.Value = Server.HtmlDecode(gvCustomers.SelectedRow.Cells[0].Text);
            txtCustomer.Text = Server.HtmlDecode(gvCustomers.SelectedRow.Cells[1].Text);
        }
        else
        {
            txtCustomer.Text = "";
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
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        //if (RptForID == 0 && ManagerID == 0 && SSID == 0 && DistributorID == 0 && RegionID == 0)
        //{
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
        //    return;
        //}
        ifmClaimReq.Attributes.Add("src", "../Reports/ViewReport.aspx?ClaimRequestFromDate=" + txtFromDate.Text + "&ClaimRequestToDate=" + txtToDate.Text +
            "&ClaimRqstSSID=" + SSID + "&ClaimRqstDistributorID=" + DistributorID + "&ClaimRqstRegionID=" + RegionID + "&ClaimRqstRptForID=" + RptForID + "&ClaimRqstManagerID=" + ManagerID +
            "&ClaimRqstOption=" + ddlOption.SelectedValue + "&ClaimRqstClaimTypeID=" + ddlMode.SelectedValue + "&ClaimRqstStatusID=" + ddlStatus.SelectedValue + "&ClaimRqstReportBy=" + ddlReportBy.SelectedValue + "&ClaimRqstSUserID=" + SUserID + "&IsDetail=" + IsDetail + "&Export=1");
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
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        //if (RptForID == 0 && ManagerID == 0 && SSID == 0 && DistributorID == 0 && RegionID == 0)
        //{
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
        //    return;
        //}
        ifmClaimReq.Attributes.Add("src", "../Reports/ViewReport.aspx?ClaimRequestFromDate=" + txtFromDate.Text + "&ClaimRequestToDate=" + txtToDate.Text +
            "&ClaimRqstSSID=" + SSID + "&ClaimRqstDistributorID=" + DistributorID + "&ClaimRqstRegionID=" + RegionID + "&ClaimRqstRptForID=" + RptForID + "&ClaimRqstManagerID=" + ManagerID +
            "&ClaimRqstOption=" + ddlOption.SelectedValue + "&ClaimRqstClaimTypeID=" + ddlMode.SelectedValue + "&ClaimRqstStatusID=" + ddlStatus.SelectedValue + "&ClaimRqstReportBy=" + ddlReportBy.SelectedValue + "&ClaimRqstSUserID=" + SUserID + "&IsDetail=" + IsDetail);
    }

    protected void ifmClaimReq_Load(object sender, EventArgs e)
    {

    }

    #endregion

}