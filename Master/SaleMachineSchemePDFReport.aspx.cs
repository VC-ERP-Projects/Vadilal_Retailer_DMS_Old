using System;
using System.Collections.Generic;
using System.Data.Objects.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_SaleMachineSchemePDFReport : System.Web.UI.Page
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
        lnkDownloadFile.InnerText  = txtDealRegion.Text = txtDistRegion.Text = txtCode.Text = txtPName.Text = "";
        lnkDownloadFile.HRef = "";
    }

    #endregion
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
    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {

                SMVSPN objSMVSPN;
                int PolicyID;
                if (string.IsNullOrEmpty(txtPName.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Enter Policy Name',3);", true);
                    return;
                }
                int DealerRegionID = Int32.TryParse(txtDealRegion.Text.Split("-".ToArray()).Last().Trim(), out DealerRegionID) ? DealerRegionID : 0;
                int DistRegionID = Int32.TryParse(txtDistRegion.Text.Split("-".ToArray()).First().Trim(), out DistRegionID) ? DistRegionID : 0;
                int EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).First().Trim(), out EmpID) ? EmpID : 0;
                if (DealerRegionID == 0 && DistRegionID == 0 && EmpID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select Proper Parameter.',3);", true);
                    return;
                }
                
                
                if (ViewState["LeavePolicyID"] != null && Int32.TryParse(ViewState["LeavePolicyID"].ToString(), out PolicyID))
                {
                    objSMVSPN = ctx.SMVSPNs.FirstOrDefault(x => x.LeavePolicyID == PolicyID);
                }
                else
                {
                    objSMVSPN = new SMVSPN();
                    objSMVSPN.LeavePolicyID = ctx.GetKey("SMVSPN", "LeavePolicyID", "", 0, 0).FirstOrDefault().Value;
                    objSMVSPN.CreatedDate = DateTime.Now;
                    objSMVSPN.CreatedBy = UserID;
                    ctx.SMVSPNs.Add(objSMVSPN);
                }
                //int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) ? PlantID : 0;
                objSMVSPN.SaleMachineSchemeName = txtPName.Text;
                objSMVSPN.FromDate = Convert.ToDateTime(txtFromDate.Text);
                objSMVSPN.ToDate = Convert.ToDateTime(txtToDate.Text);
                if (DealerRegionID > 0)
                {
                    objSMVSPN.DealerRegionID = DealerRegionID;
                }
                else
                {
                    objSMVSPN.DealerRegionID = null;
                }
                if (DistRegionID > 0)
                {
                    objSMVSPN.DistRegionID = DistRegionID;
                }
                else
                {
                    objSMVSPN.DistRegionID = null;
                }
                if (EmpID > 0)
                {
                    objSMVSPN.EmpID = EmpID;
                }
                else
                {
                    objSMVSPN.EmpID = null;
                }
                //if (PlantID > 0)
                //{
                //    objOLVPY.PlantID = PlantID;
                //}
                //else
                //{
                //    objOLVPY.PlantID = null;
                //}

                if (string.IsNullOrEmpty(objSMVSPN.FilePath) && !flCUpload.HasFile)
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

                            if (!System.IO.Directory.Exists(Server.MapPath("~/Document/SaleMachineScheme/")))
                                System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/SaleMachineScheme/"));

                            flCUpload.PostedFile.SaveAs(Server.MapPath("~/Document/SaleMachineScheme/") + fileName);
                            if (!string.IsNullOrEmpty(objSMVSPN.FilePath) && File.Exists(Server.MapPath("~/Document/SaleMachineScheme/") + objSMVSPN.FilePath))
                            {
                                File.Delete(Server.MapPath("~/Document/Policies/") + objSMVSPN.FilePath);
                            }
                            objSMVSPN.FilePath = fileName;
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper PDF Document.',3);", true);
                            return;
                        }
                    }
                }
                objSMVSPN.UpdatedDate = DateTime.Now;
                objSMVSPN.UpdatedBy = UserID;
                objSMVSPN.Active = chkAcitve.Checked;

                ctx.SaveChanges();
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully: " + objSMVSPN.LeavePolicyID + "',1);", true);
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
                        SMVSPN objSMVSPN = ctx.SMVSPNs.FirstOrDefault(x => x.LeavePolicyID == PolicyID);
                        if (objSMVSPN != null)
                        {
                            txtPolicyNo.Text = objSMVSPN.LeavePolicyID.ToString();
                            txtPName.Text = objSMVSPN.SaleMachineSchemeName;
                            if(objSMVSPN.DealerRegionID != null && objSMVSPN.DealerRegionID != 0)
                            {
                                txtDealRegion.Text = objSMVSPN.DealerRegionID.GetValueOrDefault(0) + " - " + ctx.OCSTs.FirstOrDefault(x => x.StateID == objSMVSPN.DealerRegionID.Value).StateName;
                            }
                            if (objSMVSPN.DistRegionID != null && objSMVSPN.DistRegionID != 0)
                            {
                                txtDistRegion.Text = objSMVSPN.DistRegionID.GetValueOrDefault(0) + " - " + ctx.OCSTs.FirstOrDefault(x => x.StateID == objSMVSPN.DistRegionID.Value).StateName;
                            }
                            if(objSMVSPN.EmpID != null && objSMVSPN.EmpID != 0)
                            {
                                txtCode.Text = objSMVSPN.EmpID.GetValueOrDefault(0) + " - " + ctx.OEMPs.FirstOrDefault(x => x.EmpID == objSMVSPN.EmpID.Value).Name + " - " + objSMVSPN.EmpID.GetValueOrDefault(0);
                            }
                            
                            //if (objOLVPY.PlantID != null)
                            //    txtPlant.Text = objOLVPY.PlantID.GetValueOrDefault(0) + " - " + ctx.OPLTs.FirstOrDefault(x => x.PlantID == objOLVPY.PlantID.Value).PlantName;
                            if (objSMVSPN.FromDate.HasValue)
                                txtFromDate.Text = Common.DateTimeConvert(objSMVSPN.FromDate.Value);
                            if (objSMVSPN.ToDate.HasValue)
                                txtToDate.Text = Common.DateTimeConvert(objSMVSPN.ToDate.Value);

                            chkAcitve.Checked = objSMVSPN.Active;
                            lnkDownloadFile.InnerText = objSMVSPN.SaleMachineSchemeName;
                            lnkDownloadFile.HRef = ctx.Database.Connection.Database.Contains("DMS_LIVE") ? "http://dms.vadilalgroup.com/Document/SaleMachineScheme/" + objSMVSPN.FilePath :
                                                ctx.Database.Connection.Database.Contains("DMS_QA") ? "http://120.72.91.204:868/Document/SaleMachineScheme/" + objSMVSPN.FilePath :
                                                ctx.Database.Connection.Database.Contains("VDMS") ? "http://10.1.1.240/vadilal/Document/SaleMachineScheme/" + objSMVSPN.FilePath : "";

                            ViewState["LeavePolicyID"] = objSMVSPN.LeavePolicyID;
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