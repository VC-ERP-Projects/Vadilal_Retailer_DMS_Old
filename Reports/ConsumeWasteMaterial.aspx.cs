using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_ConsumeWasteMaterial : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
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
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            if (CustType == 1)
            {
                divCustomer.Visible = true;
            }
            else if (CustType == 2)
            {
                ddlReportBy.SelectedValue = "2";
                divEmpCode.Attributes.Add("style", "display:none;");
                divSS.Attributes.Add("style", "display:none;");
                txtCustCode.Enabled = ddlReportBy.Enabled = false;
                divRegion.Attributes.Add("style", "display:none;");
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtCustCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }

            else if (CustType == 4)
            {
                divCustomer.Visible = false;
                divEmpCode.Attributes.Add("style", "display:none;");
                ddlReportBy.SelectedValue = "4";
                txtSSDistCode.Enabled = ddlReportBy.Enabled = false;
                divRegion.Attributes.Add("style", "display:none;");

                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtSSDistCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;
                }
            }

            acetxtName.ContextKey = (CustType + 1).ToString();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                ddlItemGroup.DataSource = ctx.OITBs.OrderBy(x => x.SortOrder).ToList();
                ddlItemGroup.DataBind();
                ddlItemGroup.Items.Insert(0, new ListItem("---Select---", "0"));
            }
            using (DDMSEntities ctx = new DDMSEntities())
            {
                ddlReason.DataSource = ctx.ORSNs.Where(x => x.Type == "W").Select(x => new { x.ReasonID, x.ReasonName }).ToList();
                ddlReason.DataBind();
                ddlReason.Items.Insert(0, new ListItem("---- Select ----", "0"));
            }
            ////txtFromDate.Focus();
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        }
    }

    protected void ifmConsumeWasteMaterial_Load(object sender, EventArgs e)
    {

    }
    #endregion

    #region Button Click

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Decimal CustomerID = 0;

        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 SelectedValue = Int32.TryParse(ddlReportBy.SelectedValue, out SelectedValue) ? SelectedValue : 0;

        if (!string.IsNullOrEmpty(ddlReportBy.SelectedValue))
        {
            if (SelectedValue == 2)
            {
                CustomerID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
            }
            else if (SelectedValue == 4)
            {
                CustomerID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
            }
            //else
            //{
            //    CustomerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
            //}
        }

        if (SelectedValue == 2 && CustomerID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
            txtCustCode.Text = "";
            txtCustCode.Focus();
            return;
        }

        if (SelectedValue == 4 && CustomerID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Super Stockist.',3);", true);
            txtCustCode.Text = "";
            txtCustCode.Focus();
            return;
        }

        //if (SelectedValue == 3 && CustomerID == 0)
        //{
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Dealer.',3);", true);
        //    txtCustCode.Text = "";
        //    txtCustCode.Focus();
        //    return;
        //}

        ifmConsumeWasteMaterial.Attributes.Add("src", "../Reports/ViewReport.aspx?CWMFromDate=" + txtFromDate.Text + "&CWMToDate=" + txtToDate.Text + "&CWMType=" + ddltype.SelectedValue + "&CWMIGID=" + ddlItemGroup.SelectedValue + "&CWMReasonID=" + ddlReason.SelectedValue + "&CWMReasonCustomerID=" + CustomerID + "&CWMReasonRegionID=" + RegionID + "&CWMReasonSUserID=" + SUserID);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Decimal CustomerID = 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 SelectedValue = Int32.TryParse(ddlReportBy.SelectedValue, out SelectedValue) ? SelectedValue : 0;

        if (!string.IsNullOrEmpty(ddlReportBy.SelectedValue))
        {
            if (SelectedValue == 2)
            {
                CustomerID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
            }
            else if (SelectedValue == 4)
            {
                CustomerID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
            }
            //else
            //{
            //    CustomerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
            //}
        }

        if (SelectedValue == 2 && CustomerID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
            txtCustCode.Text = "";
            txtCustCode.Focus();
            return;
        }

        if (SelectedValue == 4 && CustomerID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Super Stockist.',3);", true);
            txtCustCode.Text = "";
            txtCustCode.Focus();
            return;
        }

        //if (SelectedValue == 3 && CustomerID == 0)
        //{
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Dealer.',3);", true);
        //    txtCustCode.Text = "";
        //    txtCustCode.Focus();
        //    return;
        //}

        ifmConsumeWasteMaterial.Attributes.Add("src", "../Reports/ViewReport.aspx?CWMFromDate=" + txtFromDate.Text + "&CWMToDate=" + txtToDate.Text + "&CWMType=" + ddltype.SelectedValue + "&CWMIGID=" + ddlItemGroup.SelectedValue + "&CWMReasonID=" + ddlReason.SelectedValue + "&CWMReasonCustomerID=" + CustomerID + "&CWMReasonRegionID=" + RegionID + "&CWMReasonSUserID=" + SUserID + "&Export=1");
    }

    #endregion
}