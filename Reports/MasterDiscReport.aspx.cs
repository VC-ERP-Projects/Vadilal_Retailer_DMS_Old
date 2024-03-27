using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_MasterDiscReport : System.Web.UI.Page
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

    public void ClearAllInputs()
    {
        txtDealerCode.Text = txtRegion.Text = txtDistCode.Text = txtRequestBy.Text = txtManager.Text = "";
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
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
                var Division = ctx.ODIVs.Where(x => x.Active).ToList();
                ddlDivision.DataSource = Division;
                ddlDivision.DataBind();
            }
        }
    }

    #endregion

    #region ButtonClick

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        Int32 RequestBy = Int32.TryParse(txtRequestBy.Text.Split("-".ToArray()).Last().Trim(), out RequestBy) ? RequestBy : 0;
        Int32 ManagerID = Int32.TryParse(txtManager.Text.Split("-".ToArray()).Last().Trim(), out ManagerID) ? ManagerID : 0;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        Int32 EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : UserID;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        ifmMasterDisc.Attributes.Add("src", "../Reports/ViewReport.aspx?MasterDiscApprovlFromDate=" + txtFromDate.Text + "&MasterDiscApprovlToDate=" + txtToDate.Text +
                    "&MasterDiscDivisionID=" + ddlDivision.SelectedValue + "&MasterDiscRegion=" + RegionID + "&MasterDiscDist=" + DistributorID + "&MasterDiscDealer=" + DealerID +
                    "&MasterDiscRequestBy=" + RequestBy + "&MasterDiscPendingFrom=" + ManagerID + "&MasterDiscRequestType=" + ddlRequestType.SelectedValue + "&IsDetail=" + IsDetail +
                    "&MasterDiscSUserID=" + SUserID + "&MasterDiscEMP=" + EmpID);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        Int32 RequestBy = Int32.TryParse(txtRequestBy.Text.Split("-".ToArray()).Last().Trim(), out RequestBy) ? RequestBy : 0;
        Int32 ManagerID = Int32.TryParse(txtManager.Text.Split("-".ToArray()).Last().Trim(), out ManagerID) ? ManagerID : 0;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        Int32 EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : UserID;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        ifmMasterDisc.Attributes.Add("src", "../Reports/ViewReport.aspx?MasterDiscApprovlFromDate=" + txtFromDate.Text + "&MasterDiscApprovlToDate=" + txtToDate.Text +
            "&MasterDiscDivisionID=" + ddlDivision.SelectedValue + "&MasterDiscRegion=" + RegionID + "&MasterDiscDist=" + DistributorID + "&MasterDiscDealer=" + DealerID +
            "&MasterDiscRequestBy=" + RequestBy + "&MasterDiscPendingFrom=" + ManagerID + "&MasterDiscRequestType=" + ddlRequestType.SelectedValue + "&IsDetail=" + IsDetail +
            "&MasterDiscSUserID=" + SUserID + "&MasterDiscEMP=" + EmpID + "&Export=1");
    }

    #endregion

    protected void ifmMasterDisc_Load(object sender, EventArgs e)
    {

    }
}