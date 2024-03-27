using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_ClaimRejectUtility : System.Web.UI.Page
{

    #region Property

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    public int SaleID;

    #endregion

    #region PageLoad

    public void ClearAllInputs()
    {
        txtCustCode.Text = "";
        txtSSCode.Text = "";
        gvGrid.DataSource = null;
        gvGrid.DataBind();
        btnSubmit.Visible = false;
        txtCustCode.Enabled = true;
        txtSSCode.Enabled = true;
        if (ddlSaleBy.SelectedValue == "4")
        {
            divDistributor.Attributes.Add("style", "display:none;");
            divSS.Attributes.Add("style", "");
        }
        else
        {
            divDistributor.Attributes.Add("style", "");
            divSS.Attributes.Add("style", "display:none;");
        }
    }

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                int CustType = Convert.ToInt32(Session["Type"]);
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
                            var unit = xml.Descendants("Inward");
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

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            if (CustType == 4) // SS
            {
                ddlSaleBy.SelectedValue = "4";
                txtSSCode.Enabled = ddlSaleBy.Enabled = false;
                divDistributor.Attributes.Add("style", "display:none;");
                divSS.Attributes.Add("style", "");
            }
            else if (CustType == 2) // Distributor
            {
                divSS.Attributes.Add("style", "display:none;");
                divDistributor.Attributes.Add("style", "");
                ddlSaleBy.SelectedValue = "2";
            }
        }
    }
    #endregion

    #region Button

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            Decimal DistributorID = 0;
            Decimal SSID = 0;

            if (!string.IsNullOrEmpty(txtCustCode.Text) && Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) && DistributorID > 0
                || !string.IsNullOrEmpty(txtSSCode.Text) && Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) && SSID > 0)
            {
                Decimal CustomerID = DistributorID > 0 ? DistributorID : SSID;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var ClaimData = (from a in ctx.OCLMRQs
                                     join b in ctx.ORSNs on a.ReasonCode equals b.SAPReasonItemCode
                                     join c in ctx.OEMPs on new { a.ParentID, EmpID = a.CreatedBy } equals new { c.ParentID, c.EmpID }
                                     where (a.CustomerID == CustomerID) && a.ParentID == ParentID && new int[] { 1, 4 }.Contains(a.Status)
                                     select new
                                     {
                                         a.ClaimRequestID,
                                         a.DocNo,
                                         a.FromDate,
                                         a.ToDate,
                                         a.SchemeAmount,
                                         a.ApprovedAmount,
                                         b.ReasonDesc,
                                         b.ReasonName,
                                         a.ClaimDate,
                                         c.EmpCode,
                                         c.Name,
                                         a.IsAuto
                                     }).ToList().Select(x => new
                                     {
                                         x.ClaimRequestID,
                                         x.DocNo,
                                         FromDate = Common.DateTimeConvert(x.FromDate),
                                         ToDate = Common.DateTimeConvert(x.ToDate),
                                         x.SchemeAmount,
                                         x.ApprovedAmount,
                                         ClaimDate = Common.DateTimeConvert(x.ClaimDate),
                                         Reason = x.ReasonName,
                                         Emp = x.EmpCode + " - " + x.Name,
                                         Auto = x.IsAuto
                                     }).ToList();

                    if (ClaimData.Count > 0)
                    {
                        gvGrid.DataSource = null;
                        gvGrid.DataBind();

                        gvGrid.DataSource = ClaimData;
                        gvGrid.DataBind();
                        txtCustCode.Enabled = false;
                        txtSSCode.Enabled = false;
                        btnSubmit.Visible = true;
                    }
                    else
                    {
                        gvGrid.DataSource = null;
                        gvGrid.DataBind();
                        txtCustCode.Enabled = true;
                        txtSSCode.Enabled = true;
                        btnSubmit.Visible = false;
                    }
                    if (ddlSaleBy.SelectedValue == "4")
                    {
                        divDistributor.Attributes.Add("style", "display:none;");
                        divSS.Attributes.Add("style", "");
                    }
                    else
                    {
                        divDistributor.Attributes.Add("style", "");
                        divSS.Attributes.Add("style", "display:none;");
                    }
                }
            }
            else
            {
                gvGrid.DataSource = null;
                gvGrid.DataBind();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper distributor..!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            bool errFound = true;

            if (Page.IsValid)
            {
                for (int i = 0; i < gvGrid.Rows.Count; i++)
                {
                    HtmlInputCheckBox chk = (HtmlInputCheckBox)gvGrid.Rows[i].FindControl("chkCheck");
                    if (chk.Checked == true)
                    {
                        errFound = false;
                    }
                }
                if (errFound == true)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one row!',3);", true);
                    return;
                }
                Decimal DistributorID = 0;
                Decimal SSID = 0;
                Int32 ID = 0;
                string IPAdd = hdnIPAdd.Value;
                if (IPAdd == "undefined")
                    IPAdd = "";
                if (IPAdd.Length > 15)
                    IPAdd = IPAdd = IPAdd.Substring(0, 15);
                if (!string.IsNullOrEmpty(txtCustCode.Text) && Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) && DistributorID > 0 ||
                    !string.IsNullOrEmpty(txtSSCode.Text) && Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) && SSID > 0)
                {
                    Decimal CustomerID = DistributorID > 0 ? DistributorID : SSID;
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        foreach (GridViewRow request in gvGrid.Rows)
                        {
                            TextBox txtRemarks = (TextBox)request.FindControl("txtRemarks");
                            HtmlInputCheckBox chk = (HtmlInputCheckBox)request.FindControl("chkCheck");
                            Label lblRequestID = (Label)request.FindControl("lblRequestID");
                            if (chk.Checked && Int32.TryParse(lblRequestID.Text, out ID) && ID > 0)
                            {
                                OCLMRQ objOCLMRQ = ctx.OCLMRQs.FirstOrDefault(x => x.ClaimRequestID == ID && (x.CustomerID == CustomerID));
                                if (objOCLMRQ.OCLMRAs.Any(x => x.ClaimRequestID == ID && x.ParentID == ParentID))
                                {
                                    objOCLMRQ.OCLMRAs.Where(x => x.ClaimRequestID == ID && x.ParentID == ParentID).ToList().ForEach(x => x.Status = 6);
                                }
                                objOCLMRQ.Status = 6;
                                objOCLMRQ.NextManagerID = null;
                                objOCLMRQ.UpdatedBy = UserID;
                                objOCLMRQ.UpdatedDate = DateTime.Now;
                                ctx.OCLMs.Where(x => objOCLMRQ.ParentClaimID == x.ParentClaimID && x.ParentID == objOCLMRQ.CustomerID).ToList().ForEach(x => x.Status = 6);
                                OCLMP objOCLMP = ctx.OCLMPs.FirstOrDefault(x => objOCLMRQ.ParentClaimID == x.ParentClaimID && objOCLMRQ.CustomerID == x.ParentID);
                                objOCLMP.Notes = IPAdd + " # " + txtRemarks.Text.ToString();
                                objOCLMP.HierarchyManagerId = null;
                            }
                            ctx.SaveChanges();
                            txtCustCode.Enabled = true;
                            ClearAllInputs();
                        }
                    }
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record deleted successfully.',1);", true);
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper distributor..!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        ClearAllInputs();


    }

    #endregion
}