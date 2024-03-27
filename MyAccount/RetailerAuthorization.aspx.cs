using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using AjaxControlToolkit;
using System.Globalization;
using System.Web.UI.HtmlControls;
using System.Xml.Linq;
using System.Data.SqlClient;


public partial class MyAccount_RetailerAuthorization : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ClearAllInputs()
    {
        chkIsActive.Checked = true;
        txtUpdateBy.Text = string.Empty;
        txtUpdatedDate.Text = string.Empty;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var EmpG = ctx.OGRPs.Where(x => x.Active && x.ParentID == ParentID).Select(x => new { EmpGroupName = x.EmpGroupName + " # " + x.EmpGroupDesc, x.EmpGroupID }).ToList();
            ddlEGroup.DataSource = EmpG;
            ddlEGroup.DataBind();
            ddlEGroup.Items.Insert(0, new ListItem("---Select---", "0"));
            ddlEGroup.SelectedValue = "0";

        }
        gvAuthorization.DataSource = null;
        gvAuthorization.DataBind();
        txtRegion.Text = "";
        txtDistributor.Text = "";
        txtCustGroup.Text = "";
        txtDealer.Text = "";
        txtEmployee.Text = "";
        BindGrid();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ClearAll();", true);
    }
    public void ResetControls()
    {
        //gvAuthorization.Columns[1].Visible = true;
        //btnPriority.Visible = true;
        //gvAuthorization.Columns[1].Visible = false;
        //btnPriority.Visible = false;
    }
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
                            var unit = xml.Descendants("authorization");
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
    public void BindGrid()
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                List<OMNU> Data = new List<OMNU>();

                List<OMNU> parentMenu = ctx.OMNUs.Where(x => !x.ParentMenuID.HasValue && x.Active && x.DealerApp == true).OrderBy(y => y.SortOrder).ToList();
                foreach (OMNU item in parentMenu)
                {
                    Data.Add(item);
                    Data.AddRange(ctx.OMNUs.Where(x => x.ParentMenuID == item.MenuID && x.Active && x.DealerApp == true).OrderBy(y => y.SortOrder).ToList());
                }
                gvAuthorization.DataSource = Data;
                gvAuthorization.DataBind();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
    public void FillGrid(Decimal CustID)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            RMNU GRPs = new RMNU();
            Int32 RegionID = 0;
            if(txtDealer.Text != "" || txtDistributor.Text != "")
            {
                txtDistributor.Text = "";
                txtDealer.Text = "";
            }
            if (txtRegion.Text.Trim() == "")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper parameter.',3);", true);
                return;
            }

            if (txtRegion.Text.Trim() != "")
            {
                RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
                OCST obj = ctx.OCSTs.Where(x => x.StateID == RegionID).FirstOrDefault();
                if (obj == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper region.',3);", true);
                    return;
                }
            }
           
            GRPs = ctx.RMNUs.Where(x => x.RegionId == RegionID).FirstOrDefault();
            if (GRPs != null)
            {
                foreach (GridViewRow item in gvAuthorization.Rows)
                {
                    RadioButton chkWrite = (RadioButton)item.FindControl("chkWrite");
                    RadioButton chkNone = (RadioButton)item.FindControl("chkNone");
                    Label lblMenuID = (Label)item.FindControl("lblMenuID");
                    TextBox txtPriority = (TextBox)item.FindControl("txtPriority");
                    int MenuID;
                    if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                    {
                        //var ObjRMNU1 = ctx.r

                        var objOMNU = ctx.OMNUs.Where(x => x.MenuID == MenuID && x.Active).FirstOrDefault();
                        if (objOMNU != null)
                        {
                            //txtPriority.Text = objOMNU.SortOrder.ToString();
                        }

                        var Auth = ctx.RMNU1.Where(x => x.MenuId == MenuID && x.MenuGroupID == GRPs.MenuGroupID).OrderBy(y => y.Priority).FirstOrDefault();
                        chkNone.Checked = chkWrite.Checked = false;
                        if (Auth != null)
                        {
                            if (Auth.IsWrite == 1)
                                chkWrite.Checked = true;
                            else if (Auth.IsWrite == 0)
                                chkNone.Checked = true;
                            txtPriority.Text = Auth.Priority.ToString();
                        }
                    }
                }
                var updatedBy = GRPs;

                txtUpdateBy.Text = updatedBy != null ? ctx.OEMPs.Where(x => x.EmpID == updatedBy.UpdatedBy).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() : string.Empty;
                txtUpdatedDate.Text = updatedBy != null ? updatedBy.UpdatedDateTime.ToString("dd/MM/yyyy HH:mm") : string.Empty;

                ResetControls();
            }
            else
            {
                txtUpdateBy.Text = string.Empty;
                txtUpdatedDate.Text = string.Empty;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ClearAll();", true);
                ResetControls();
            }
            //}
        }
    }
    public void FillGridDistributer(Decimal CustID)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            RMNU GRPs = new RMNU();
            decimal DistID = 0;
            if (txtDistributor.Text.Trim() == "")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper parameter.',3);", true);
                return;
            }
            if (txtDistributor.Text.Trim() != "")
            {
                DistID = Decimal.TryParse(txtDistributor.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
                //OCRD OjOCRD = ctx.OCRDs.Where(x => x.CustomerID == DistID && x.Type == 2 && x.Active).FirstOrDefault();
                OCRD OjOCRD = ctx.OCRDs.Where(x => x.CustomerID == DistID && x.Active).FirstOrDefault();
                if (OjOCRD == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                    return;
                }
            }
            GRPs = ctx.RMNUs.Where(x => x.DistributerId == DistID).FirstOrDefault();
            if (GRPs != null)
            {
                foreach (GridViewRow item in gvAuthorization.Rows)
                {
                    RadioButton chkWrite = (RadioButton)item.FindControl("chkWrite");
                    RadioButton chkNone = (RadioButton)item.FindControl("chkNone");
                    Label lblMenuID = (Label)item.FindControl("lblMenuID");
                    TextBox txtPriority = (TextBox)item.FindControl("txtPriority");
                    int MenuID;
                    if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                    {
                        //var ObjRMNU1 = ctx.r

                        var objOMNU = ctx.OMNUs.Where(x => x.MenuID == MenuID && x.Active).FirstOrDefault();
                        if (objOMNU != null)
                        {
                            //txtPriority.Text = objOMNU.SortOrder.ToString();
                        }

                        var Auth = ctx.RMNU1.Where(x => x.MenuId == MenuID && x.MenuGroupID == GRPs.MenuGroupID).OrderBy(y => y.Priority).FirstOrDefault();
                        chkNone.Checked = chkWrite.Checked = false;
                        if (Auth != null)
                        {
                            if (Auth.IsWrite == 1)
                                chkWrite.Checked = true;
                            else if (Auth.IsWrite == 0)
                                chkNone.Checked = true;
                            txtPriority.Text = Auth.Priority.ToString();
                        }
                    }
                }
                var updatedBy = GRPs;

                txtUpdateBy.Text = updatedBy != null ? ctx.OEMPs.Where(x => x.EmpID == updatedBy.UpdatedBy).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() : string.Empty;
                txtUpdatedDate.Text = updatedBy != null ? updatedBy.UpdatedDateTime.ToString() : string.Empty;

                ResetControls();
            }
            else
            {
                txtUpdateBy.Text = string.Empty;
                txtUpdatedDate.Text = string.Empty;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ClearAll();", true);
                ResetControls();
            }
            //}
        }
    }
    public void FillGridCustGroup(Decimal CustID)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            RMNU GRPs = new RMNU();
            Int32 CustGroupID = 0;
            string CustGroup = "";
            if (txtCustGroup.Text.Trim() == "")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper parameter.',3);", true);
                return;
            }
            if (txtCustGroup.Text.Trim() != "")
            {
                CustGroup = (txtCustGroup.Text.Split("#".ToArray()).First().Trim());
                CGRP OjCGRP = ctx.CGRPs.Where(x => x.CustGroupName == CustGroup && x.Active).FirstOrDefault();
                CustGroupID = OjCGRP.CustGroupID;
                if (OjCGRP == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper CustGroup.',3);", true);
                    return;
                }
            }
            GRPs = ctx.RMNUs.Where(x => x.CustGroupId == CustGroupID).FirstOrDefault();
            if (GRPs != null)
            {
                foreach (GridViewRow item in gvAuthorization.Rows)
                {
                    RadioButton chkWrite = (RadioButton)item.FindControl("chkWrite");
                    RadioButton chkNone = (RadioButton)item.FindControl("chkNone");
                    Label lblMenuID = (Label)item.FindControl("lblMenuID");
                    TextBox txtPriority = (TextBox)item.FindControl("txtPriority");
                    int MenuID;
                    if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                    {
                        //var ObjRMNU1 = ctx.r

                        var objOMNU = ctx.OMNUs.Where(x => x.MenuID == MenuID && x.Active).FirstOrDefault();
                        if (objOMNU != null)
                        {
                            //txtPriority.Text = objOMNU.SortOrder.ToString();
                        }

                        var Auth = ctx.RMNU1.Where(x => x.MenuId == MenuID && x.MenuGroupID == GRPs.MenuGroupID).OrderBy(y => y.Priority).FirstOrDefault();

                        chkNone.Checked = chkWrite.Checked = false;
                        if (Auth != null)
                        {
                            if (Auth.IsWrite == 1)
                                chkWrite.Checked = true;
                            else if (Auth.IsWrite == 0)
                                chkNone.Checked = true;
                            txtPriority.Text = Auth.Priority.ToString();
                        }
                    }
                }
                var updatedBy = GRPs;

                txtUpdateBy.Text = updatedBy != null ? ctx.OEMPs.Where(x => x.EmpID == updatedBy.UpdatedBy).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() : string.Empty;
                txtUpdatedDate.Text = updatedBy != null ? updatedBy.UpdatedDateTime.ToString() : string.Empty;

                ResetControls();
            }
            else
            {
                txtUpdateBy.Text = string.Empty;
                txtUpdatedDate.Text = string.Empty;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ClearAll();", true);
                ResetControls();
            }
            //}
        }
    }
    public void FillGridDealer(Decimal CustID)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            RMNU GRPs = new RMNU();
            Decimal DealerID = 0;
            if (txtDealer.Text.Trim() == "")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper parameter.',3);", true);
                return;
            }
            if (txtDealer.Text.Trim() != "")
            {
                DealerID = Decimal.TryParse(txtDealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
                OCRD OjOCRDD = ctx.OCRDs.Where(x => x.CustomerID == DealerID && x.Type == 3 && x.Active).FirstOrDefault();
                if (OjOCRDD == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Dealer.',3);", true);
                    return;
                }
            }
            GRPs = ctx.RMNUs.Where(x => x.DealerId == DealerID).FirstOrDefault();
            if (GRPs != null)
            {
                foreach (GridViewRow item in gvAuthorization.Rows)
                {
                    RadioButton chkWrite = (RadioButton)item.FindControl("chkWrite");
                    RadioButton chkNone = (RadioButton)item.FindControl("chkNone");
                    Label lblMenuID = (Label)item.FindControl("lblMenuID");
                    TextBox txtPriority = (TextBox)item.FindControl("txtPriority");
                    int MenuID;
                    if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                    {
                        //var ObjRMNU1 = ctx.r
                        var objOMNU = ctx.OMNUs.Where(x => x.MenuID == MenuID && x.Active).FirstOrDefault();
                        if (objOMNU != null)
                        {
                            //txtPriority.Text = objOMNU.SortOrder.ToString();
                        }

                        var Auth = ctx.RMNU1.Where(x => x.MenuId == MenuID && x.MenuGroupID == GRPs.MenuGroupID).OrderBy(x => x.Priority).FirstOrDefault();
                        chkNone.Checked = chkWrite.Checked = false;
                        if (Auth != null)
                        {
                            if (Auth.IsWrite == 1)
                                chkWrite.Checked = true;
                            else if (Auth.IsWrite == 0)
                                chkNone.Checked = true;
                            txtPriority.Text = Auth.Priority.ToString();
                        }
                    }
                }
                var updatedBy = GRPs;

                txtUpdateBy.Text = updatedBy != null ? ctx.OEMPs.Where(x => x.EmpID == updatedBy.UpdatedBy).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() : string.Empty;
                txtUpdatedDate.Text = updatedBy != null ? updatedBy.UpdatedDateTime.ToString() : string.Empty;

                ResetControls();
            }
            else
            {
                txtUpdateBy.Text = string.Empty;
                txtUpdatedDate.Text = string.Empty;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ClearAll();", true);
                ResetControls();
            }
            //}
        }
    }
    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        ResetControls();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Button Click
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Int32 EGID = 0;
                RMNU GRPs = new RMNU();
                Int32 RegionID = 0, CustGroupID = 0;
                decimal DistID = 0;
                decimal DealerID = 0;
                string CustGroup = "";
                if (txtRegion.Text.Trim() == "" && txtDistributor.Text.Trim() == "" && txtCustGroup.Text.Trim() == "" && txtDealer.Text.Trim() == "")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper parameter.',3);", true);
                    return;
                }

                //if (txtCustGroup.Text.Trim() == "" || txtRegion.Text.Trim() == "")
                //{
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select First Region.',3);", true);
                //    return;
                //}

                if (txtRegion.Text.Trim() != "")
                {
                    RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
                    OCST obj = ctx.OCSTs.Where(x => x.StateID == RegionID).FirstOrDefault();
                    if (obj == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper region.',3);", true);
                        return;
                    }
                }
                if (txtDistributor.Text.Trim() != "")
                {
                    DistID = Decimal.TryParse(txtDistributor.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
                    //OCRD OjOCRD = ctx.OCRDs.Where(x => x.CustomerID == DistID && x.Type == 2 && x.Active).FirstOrDefault();
                    OCRD OjOCRD = ctx.OCRDs.Where(x => x.CustomerID == DistID && x.Active).FirstOrDefault();
                    if (OjOCRD == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                        return;
                    }
                }

                if (txtCustGroup.Text.Trim() != "")
                {
                    CustGroup = (txtCustGroup.Text.Split("#".ToArray()).First().Trim());
                    CGRP OjCGRP = ctx.CGRPs.Where(x => x.CustGroupName == CustGroup && x.Active).FirstOrDefault();
                    CustGroupID = OjCGRP.CustGroupID;
                    if (OjCGRP == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper CustGroup.',3);", true);
                        return;
                    }
                }

                if (txtDealer.Text.Trim() != "")
                {
                    DealerID = decimal.TryParse(txtDealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
                    OCRD OjOCRDD = ctx.OCRDs.Where(x => x.CustomerID == DealerID && x.Type == 3 && x.Active).FirstOrDefault();
                    if (OjOCRDD == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Dealer.',3);", true);
                        return;
                    }
                }

                EGID = Int32.TryParse(ddlEGroup.SelectedValue, out EGID) ? EGID : 0;

                if (gvAuthorization.Rows.Count >= 1)
                {
                    Int32 MenuGroupId = 0;
                    GRPs = ctx.RMNUs.Where(x => x.RegionId == RegionID && x.DistributerId == DistID && x.CustGroupId == CustGroupID && x.DealerId == DealerID).FirstOrDefault();
                    if (GRPs != null)
                    {
                        MenuGroupId = GRPs.MenuGroupID;
                    }
                    else
                    {
                        int RMNUCount = ctx.GetKey("RMNU", "MenuGroupID", "", MenuGroupId, 0).FirstOrDefault().Value;
                        GRPs = new RMNU();
                        GRPs.MenuGroupID = RMNUCount;
                        MenuGroupId = RMNUCount;
                        GRPs.EmpGroupId = EGID;
                        GRPs.EmployeeId = 0;
                        GRPs.RegionId = RegionID;
                        GRPs.DistributerId = DistID;
                        GRPs.CustGroupId = CustGroupID;
                        GRPs.DealerId = DealerID;
                        GRPs.IsActive = true;
                        GRPs.CreatedBy = UserID;
                        GRPs.CreatedDateTime = DateTime.Now;
                        GRPs.UpdatedBy = UserID;
                        GRPs.UpdatedDateTime = DateTime.Now;
                        GRPs.ParentID = ParentID;
                        ctx.RMNUs.Add(GRPs);
                    }
                    GRPs.UpdatedBy = UserID;
                    GRPs.UpdatedDateTime = DateTime.Now;
                    int Grp1Count = ctx.GetKey("RMNU1", "RMNU1ID", "", ParentID, 0).FirstOrDefault().Value;
                    foreach (GridViewRow item in gvAuthorization.Rows)
                    {
                        bool chkWrite = ((RadioButton)item.FindControl("chkWrite")).Checked;
                        bool chkNone = ((RadioButton)item.FindControl("chkNone")).Checked;
                        Label lblMenuID = (Label)item.FindControl("lblMenuID");
                        TextBox txtPriority = (TextBox)item.FindControl("txtPriority");
                        int MenuID;

                        if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                        {

                            var objGRP1 = ctx.RMNU1.FirstOrDefault(x => x.MenuGroupID == MenuGroupId && x.MenuId == MenuID);
                            if (objGRP1 == null)
                            {
                                objGRP1 = new RMNU1();
                                objGRP1.RMNU1ID = Grp1Count++;
                                objGRP1.MenuGroupID = MenuGroupId;
                                objGRP1.MenuId = Convert.ToInt32(lblMenuID.Text);
                                objGRP1.ParentID = ParentID;
                                ctx.RMNU1.Add(objGRP1);
                            }
                            objGRP1.Priority = Convert.ToInt32(txtPriority.Text);
                            objGRP1.IsWrite = Convert.ToInt32(chkWrite == true ? 1 : 0);
                            objGRP1.Active = true;
                        }
                    }

                    ctx.SaveChanges();
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Distributor found.',3);", true);
                    ResetControls();
                    return;
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully!',1);", true);
                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("MyAccount.aspx");
    }
    protected void btnSubmitPriority_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {


                Int32 EGID = 0;
                RMNU GRPs = new RMNU();
                Int32 RegionID = 0, EmpIID = 0;
                if (txtRegion.Text.Trim() == "" && txtEmployee.Text.Trim() == "" && ddlEGroup.SelectedValue == "0")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper parameter.',3);", true);
                    return;
                }
                if (txtRegion.Text.Trim() != "")
                {
                    RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
                    OCST obj = ctx.OCSTs.Where(x => x.StateID == RegionID).FirstOrDefault();
                    if (obj == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper region.',3);", true);
                        return;
                    }
                }
                if (txtEmployee.Text.Trim() != "")
                {
                    EmpIID = Int32.TryParse(txtEmployee.Text.Split("-".ToArray()).Last().Trim(), out EmpIID) ? EmpIID : 0;
                    OEMP OjEmp = ctx.OEMPs.Where(x => x.EmpID == EmpIID && x.ParentID == 1000010000000000).FirstOrDefault();
                    if (OjEmp == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper employee.',3);", true);
                        return;
                    }
                }
                EGID = Int32.TryParse(ddlEGroup.SelectedValue, out EmpIID) ? EmpIID : 0;

                Int32 MenuGroupId = 0;
                GRPs = ctx.RMNUs.Where(x => x.EmpGroupId == EGID && x.RegionId == RegionID && x.EmployeeId == EmpIID && x.IsActive == true).FirstOrDefault();
                if (GRPs != null)
                {
                    MenuGroupId = GRPs.MenuGroupID;
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper parameter.',3);", true);
                    return;
                }
                if (gvAuthorization.Rows.Count > 1)
                {
                    int Grp1Count = ctx.GetKey("RMNU1", "RMNU1ID", "", ParentID, 0).FirstOrDefault().Value;
                    foreach (GridViewRow item in gvAuthorization.Rows)
                    {
                        bool chkWrite = ((RadioButton)item.FindControl("chkWrite")).Checked;
                        bool chkNone = ((RadioButton)item.FindControl("chkNone")).Checked;
                        Label lblMenuID = (Label)item.FindControl("lblMenuID");
                        TextBox txtPriority = (TextBox)item.FindControl("txtPriority");
                        int MenuID;

                        if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                        {
                            var objGRP1 = ctx.RMNU1.FirstOrDefault(x => x.MenuGroupID == MenuGroupId && x.MenuId == MenuID);
                            objGRP1.Priority = Convert.ToInt32(txtPriority.Text);
                        }
                    }
                    ctx.SaveChanges();
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Distributor found.',3);", true);
                    ResetControls();
                    return;
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully!',1);", true);
                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
    #endregion

    #region GridView Command

    protected void gvAuthorization_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            TextBox txtPriority = (TextBox)e.Row.FindControl("txtPriority");
            txtPriority.Visible = true;
        }
    }

    #endregion

    #region Change Event

    protected void ddlEGroup_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlEGroup.SelectedValue != "0")
        {
            FillGrid(0);
        }
    }

    #endregion

    protected void chkForDistri_CheckedChanged(object sender, EventArgs e)
    {
        ClearAllInputs();
        ResetControls();
    }
   
    protected void gvAuthorization_PreRender(object sender, EventArgs e)
    {
        if (gvAuthorization.Rows.Count > 0)
        {
            gvAuthorization.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvAuthorization.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    protected void txtEmployee_TextChanged(object sender, EventArgs e)
    {
        if (txtEmployee.Text != "")
        {
            FillGrid(0);
        }
    }
    protected void txtRegion_TextChanged(object sender, EventArgs e)
    {
        if (txtRegion.Text != "")
        {
            FillGrid(0);
        }
    }
    protected void txtDistributor_TextChanged(object sender, EventArgs e)
    {
        if (txtDistributor.Text != "")
        {
            FillGridDistributer(0);
        }
    }
    protected void txtCustGroup_TextChanged(object sender, EventArgs e)
    {
        if (txtRegion.Text == "")
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Region.',3);", true);
            return;
        }

        if (txtRegion.Text != "" && txtCustGroup.Text != "")
        {
            FillGridCustGroup(0);
        }
    }
    protected void txtDealer_TextChanged(object sender, EventArgs e)
    {
        if (txtDealer.Text != "")
        {
            FillGridDealer(0);
        }
    }
}