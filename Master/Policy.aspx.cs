using System;
using System.Collections.Generic;
using System.Data.Objects.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class Master_Policy : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected int MenuID;
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
            DDMSEntities ctx = new DDMSEntities();
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
                MenuID = Auth.MenuID;
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
                        var unit = xml.Descendants("material_master");
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

    public void ClearAllInputs()
    {
        if (chkMode.Checked)
        {
            txtPolicyNo.Text = "Auto generated";
            txtPolicyNo.Enabled = ACEtxtName.Enabled = false;
            btnSubmit.Text = "Submit";
            txtPolicyNo.Style.Remove("background-color");
            txtPName.Focus();
        }
        else
        {
            txtPolicyNo.Text = "";
            txtPolicyNo.Enabled = ACEtxtName.Enabled = true;
            btnSubmit.Text = "Submit";
            txtPolicyNo.Style.Add("background-color", "rgb(250, 255, 189);");
            txtPolicyNo.Focus();
        }
        ViewState["LeavePolicyID"] = null;
        txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
        lnkDownloadFile.InnerText = txtPlant.Text = txtRegion.Text = txtPName.Text = "";
        lnkDownloadFile.HRef = "";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(btnSubmit);
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

                OLVPY objOLVPY;
                int PolicyID;
                if (string.IsNullOrEmpty(txtPName.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Enter Policy Name',3);", true);
                    return;
                }
                int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).First().Trim(), out RegionID) ? RegionID : 0;
                if (RegionID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper Region',3);", true);
                    return;
                }
                if (ViewState["LeavePolicyID"] != null && Int32.TryParse(ViewState["LeavePolicyID"].ToString(), out PolicyID))
                {
                    objOLVPY = ctx.OLVPies.FirstOrDefault(x => x.LeavePolicyID == PolicyID);
                }
                else
                {
                    objOLVPY = new OLVPY();
                    objOLVPY.LeavePolicyID = ctx.GetKey("OLVPY", "LeavePolicyID", "", 0, 0).FirstOrDefault().Value;
                    objOLVPY.CreatedDate = DateTime.Now;
                    objOLVPY.CreatedBy = UserID;
                    ctx.OLVPies.Add(objOLVPY);
                }
                int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) ? PlantID : 0;
                objOLVPY.PolicyName = txtPName.Text;
                objOLVPY.FromDate = Convert.ToDateTime(txtFromDate.Text);
                objOLVPY.ToDate = Convert.ToDateTime(txtToDate.Text);
                if (RegionID > 0)
                {
                    objOLVPY.StateID = RegionID;
                }
                else
                {
                    objOLVPY.StateID = null;
                }
                if (PlantID > 0)
                {
                    objOLVPY.PlantID = PlantID;
                }
                else
                {
                    objOLVPY.PlantID = null;
                }

                if (string.IsNullOrEmpty(objOLVPY.FilePath) && !flCUpload.HasFile)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper PDF Document.',3);", true);
                    return;
                }
                else
                {
                    if (flCUpload.HasFile)
                    {
                        string ext = Path.GetExtension(flCUpload.PostedFile.FileName);
                        if (ext.ToLower() == ".pdf")
                        {
                            string fileName = Path.Combine(Guid.NewGuid().ToString("N") + Path.GetExtension(flCUpload.PostedFile.FileName));

                            if (!System.IO.Directory.Exists(Server.MapPath("~/Document/Policies/")))
                                System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/Policies/"));

                            flCUpload.PostedFile.SaveAs(Server.MapPath("~/Document/Policies/") + fileName);
                            if (!string.IsNullOrEmpty(objOLVPY.FilePath) && File.Exists(Server.MapPath("~/Document/Policies/") + objOLVPY.FilePath))
                            {
                                File.Delete(Server.MapPath("~/Document/Policies/") + objOLVPY.FilePath);
                            }
                            objOLVPY.FilePath = fileName;
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper PDF Document.',3);", true);
                            return;
                        }
                    }
                }
                objOLVPY.UpdatedDate = DateTime.Now;
                objOLVPY.UpdatedBy = UserID;
                objOLVPY.Active = chkAcitve.Checked;

                ctx.SaveChanges();
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully: " + objOLVPY.LeavePolicyID + "',1);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }
    #endregion

    #region Change Event

    protected void txtPolicyNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (!chkMode.Checked && !string.IsNullOrEmpty(txtPolicyNo.Text))
                {
                    int PolicyID = Int32.TryParse(txtPolicyNo.Text.Split("-".ToArray()).First().Trim(), out PolicyID) ? PolicyID : 0;
                    if (PolicyID > 0)
                    {
                        OLVPY objOLVPY = ctx.OLVPies.FirstOrDefault(x => x.LeavePolicyID == PolicyID);
                        if (objOLVPY != null)
                        {
                            txtPolicyNo.Text = objOLVPY.LeavePolicyID.ToString();
                            txtPName.Text = objOLVPY.PolicyName;
                            txtRegion.Text = objOLVPY.StateID.GetValueOrDefault(0) + " - " + ctx.OCSTs.FirstOrDefault(x => x.StateID == objOLVPY.StateID.Value).StateName;
                            if (objOLVPY.PlantID != null)
                                txtPlant.Text = objOLVPY.PlantID.GetValueOrDefault(0) + " - " + ctx.OPLTs.FirstOrDefault(x => x.PlantID == objOLVPY.PlantID.Value).PlantName;
                            if (objOLVPY.FromDate.HasValue)
                                txtFromDate.Text = Common.DateTimeConvert(objOLVPY.FromDate.Value);
                            if (objOLVPY.ToDate.HasValue)
                                txtToDate.Text = Common.DateTimeConvert(objOLVPY.ToDate.Value);

                            chkAcitve.Checked = objOLVPY.Active;

                            lnkDownloadFile.InnerText = objOLVPY.PolicyName;
                            lnkDownloadFile.HRef = ctx.Database.Connection.Database.Contains("DMS_LIVE") ? "http://dms.vadilalgroup.com/Document/Policies/" + objOLVPY.FilePath :
                                                ctx.Database.Connection.Database.Contains("DMS_QA") ? "http://dmsqa.vadilalgroup.com/Document/Policies/" + objOLVPY.FilePath :
                                                ctx.Database.Connection.Database.Contains("VDMS") ? "http://10.1.1.240/vadilal/Document/Policies/" + objOLVPY.FilePath : "";

                            ViewState["LeavePolicyID"] = objOLVPY.LeavePolicyID;
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper Policy Number',3);", true);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
    # endregion

    # region Text_Changed
    protected void chkMode_Checked(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
    # endregion
}