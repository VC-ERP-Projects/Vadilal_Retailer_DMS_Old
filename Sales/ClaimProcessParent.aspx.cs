using ClaimDMS;
using Scheme;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Objects;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Sales_ClaimProcessParent : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
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

    public void ClearAllInputs(Boolean allclear)
    {
        gvCommon.DataSource = null;
        gvCommon.DataBind();
        if (allclear)
        {
            txtCustCode.Text = txtDate.Text = "";
            txtCustCode.Enabled = txtDate.Enabled = ddlMode.Enabled = true;
        }
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputs(true);
            using (DDMSEntities ctx = new DDMSEntities())
            {
                ddlMode.Items.Clear();
                ddlMode.DataTextField = "ReasonName";
                ddlMode.DataValueField = "ReasonID";
                ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID }).OrderBy(x => x.ReasonName).ToList();
                ddlMode.DataBind();
                ddlMode.Items.Add(new ListItem("--- select ---", "0"));
            }
        }
    }

    #endregion

    #region Button Click

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs(false);
            if (String.IsNullOrEmpty(txtDate.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
                txtDate.Text = "";
                txtDate.Focus();
                return;
            }
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetClaimDetailParent";

            Decimal DistID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
            DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
            DateTime Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));

            int ReasonID = Convert.ToInt32(ddlMode.SelectedValue);
            ORSN ReasonData = null;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                ReasonData = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonID);
            }
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@CustomerID", DistID);
            Cm.Parameters.AddWithValue("@FromDate", Fromdate.ToString("yyyyMMdd"));
            Cm.Parameters.AddWithValue("@ToDate", Todate.ToString("yyyyMMdd"));
            Cm.Parameters.AddWithValue("@Mode", ReasonData.ReasonDesc);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                gvCommon.DataSource = ds.Tables[0];
                gvCommon.DataBind();
                gvCommon.Visible = true;
                txtCustCode.Enabled = txtDate.Enabled = ddlMode.Enabled = false;
            }
            if (ddlMode.SelectedValue != "4" || ddlMode.SelectedValue != "5" || ddlMode.SelectedValue != "12" || ddlMode.SelectedValue != "13" || ddlMode.SelectedValue != "14" || ddlMode.SelectedValue != "15" || ddlMode.SelectedValue != "65" || ddlMode.SelectedValue != "70" || ddlMode.SelectedValue != "72")
            {
                if (Session["IsDistLogin"].ToString() != "True")
                {
                    // DateTime ClaimRequestDate = Convert.ToDateTime(ds.Tables[0].Rows[0]["UpdatedDate"].ToString());
                    Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                    SqlCommand Cmd = new SqlCommand();
                    Cmd.Parameters.Clear();
                    Cmd.CommandType = CommandType.StoredProcedure;
                    Cmd.CommandText = "usp_CheckDistributorClaimLockingPeriod";
                    Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                    Cmd.Parameters.AddWithValue("@UserID", UserID);
                    //Cmd.Parameters.AddWithValue("@CustomerId", 0);
                    DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                    if (dsdata.Tables.Count > 0)
                    {
                        if (dsdata.Tables[0].Rows.Count > 0)
                        {
                            DateTime LockingDate = Todate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                            if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                            {
                                btnSumbit.Enabled = false;

                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim period is over. " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                //  return;
                            }
                            else
                            {
                                btnSumbit.Enabled = true;
                            }
                        }
                    }
                    else
                    {
                        btnSumbit.Enabled = true;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnSumbit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                if (String.IsNullOrEmpty(txtDate.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
                    txtDate.Text = "";
                    txtDate.Focus();
                    return;
                }
                Decimal DecNum = 0;
                Int32 IntNum = 0;
                DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
                DateTime enddate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));
                if (ddlMode.SelectedValue != "4" || ddlMode.SelectedValue != "5" || ddlMode.SelectedValue != "12" || ddlMode.SelectedValue != "13" || ddlMode.SelectedValue != "14" || ddlMode.SelectedValue != "15" || ddlMode.SelectedValue != "65" || ddlMode.SelectedValue != "70" || ddlMode.SelectedValue != "72")
                {
                    if (Session["IsDistLogin"].ToString() != "True")
                    {
                        // DateTime ClaimRequestDate = Convert.ToDateTime(ds.Tables[0].Rows[0]["UpdatedDate"].ToString());
                        Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                        SqlCommand Cmd = new SqlCommand();
                        Cmd.Parameters.Clear();
                        Cmd.CommandType = CommandType.StoredProcedure;
                        Cmd.CommandText = "usp_CheckDistributorClaimLockingPeriod";
                        Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                        Cmd.Parameters.AddWithValue("@UserID", UserID);
                        //Cmd.Parameters.AddWithValue("@CustomerId", 0);
                        DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                        if (dsdata.Tables.Count > 0)
                        {
                            if (dsdata.Tables[0].Rows.Count > 0)
                            {
                                DateTime LockingDate = enddate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                {
                                    btnSumbit.Enabled = false;

                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim period is over. " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                    //  return;
                                }
                                else
                                {
                                    btnSumbit.Enabled = true;
                                }
                            }
                        }
                        else
                        {
                            btnSumbit.Enabled = true;
                        }
                    }
                }
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int ReasonID = Convert.ToInt32(ddlMode.SelectedValue);
                    string ReasonCode = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonID).SAPReasonItemCode;
                    int Count = ctx.GetKey("OCLMCLD", "ClaimChildID", "", ParentID, 0).FirstOrDefault().Value;

                    // Check Unit Mapping entry found or not  T90001150  10-Oct-22
                    if (!ctx.OCUMs.Any(x => x.CustID == ParentID))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('your unit entry not found please contact mktg department',3);", true);
                        return;
                    }

                    //
                    //Check Validation File Upload Images for Claim Submit // T900011560
                    if (!flpFileUpload.HasFile)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you have to upload Claim report pages',3);", true);
                        return;
                    }
                    HttpFileCollection uploadedFiles = Request.Files;
                    string filepath = Server.MapPath("\\Document\\ClaimDocument");

                    for (int i = 0; i < uploadedFiles.Count; i++)
                    {

                        HttpPostedFile userPostedFile = uploadedFiles[i];
                        string ext = System.IO.Path.GetExtension(userPostedFile.FileName);
                        if (ext.ToLower() == ".png" || ext.ToLower() == ".jpg" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf")
                        {
                            double filesize = userPostedFile.ContentLength;
                            if (filesize < (1024000))   // 1 MB File Size
                            {

                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not upload more than 1 MB File size.!',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select jpg, png,  jpeg, pdf file!',3);", true);
                            return;
                        }

                    }

                    //
                    foreach (GridViewRow item in gvCommon.Rows)
                    {
                        HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                        HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                        IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                        DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;
                        int CLM2ID = ctx.GetKey("CLM2", "CLM2ID", "", ParentID, 0).FirstOrDefault().Value;

                        OCLMP objOCLMP = ctx.OCLMPs.FirstOrDefault(x => x.ParentClaimID == IntNum && x.ParentID == DecNum);
                        if (objOCLMP != null)
                        {
                            if (!ctx.OCLMCLDs.Any(x => x.ParentClaimID == IntNum && x.CustomerID == DecNum))
                            {
                                OCLMCLD objOCLMCLD = new OCLMCLD();

                                Label lblApproved = (Label)item.FindControl("lblApproved");
                                Label lblTotalPurchase = (Label)item.FindControl("lblTotalPurchase");
                                Label lblMonthSale = (Label)item.FindControl("lblMonthSale");
                                Label lblIsAuto = (Label)item.FindControl("lblIsAuto");

                                objOCLMCLD.ClaimChildID = Count++;
                                objOCLMCLD.ParentID = ParentID;
                                objOCLMCLD.DocNo = DateTime.Now.ToString("yyMMdd") + objOCLMCLD.ClaimChildID.ToString("D7");
                                objOCLMCLD.CustomerID = objOCLMP.ParentID;
                                objOCLMCLD.ParentClaimID = objOCLMP.ParentClaimID;
                                objOCLMCLD.FromDate = objOCLMP.FromDate;
                                objOCLMCLD.ToDate = objOCLMP.ToDate;
                                objOCLMCLD.ClaimDate = objOCLMP.CreatedDate;
                                objOCLMCLD.SchemeAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                objOCLMCLD.Deduction = 0;
                                objOCLMCLD.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                objOCLMCLD.DeductionRemarks = null;
                                objOCLMCLD.ReasonCode = ReasonCode;
                                objOCLMCLD.IsAuto = Convert.ToBoolean(lblIsAuto.Text);
                                objOCLMCLD.TotalSale = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;
                                objOCLMCLD.SchemeSale = Decimal.TryParse(lblTotalPurchase.Text, out DecNum) ? DecNum : 0;
                                objOCLMCLD.CreatedDate = DateTime.Now;
                                objOCLMCLD.CreatedBy = UserID;
                                objOCLMCLD.UpdatedDate = DateTime.Now;
                                objOCLMCLD.UpdatedBy = UserID;
                                objOCLMCLD.Status = 1;
                                ctx.OCLMCLDs.Add(objOCLMCLD);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You already submitted same claim. please refresh page try again',3);", true);
                                return;
                            }
                            // File Upload
                            string[] ArrFileName = new string[uploadedFiles.Count];
                            for (int i = 0; i < uploadedFiles.Count; i++)
                            {
                                string strFilePath = "";
                                HttpPostedFile userPostedFile = uploadedFiles[i];
                                string ext = System.IO.Path.GetExtension(userPostedFile.FileName);
                                if (ext.ToLower() == ".png" || ext.ToLower() == ".jpg" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf")
                                {
                                    double filesize = userPostedFile.ContentLength;
                                    if (filesize < (1024000))   // 1 MB File Size
                                    {
                                        strFilePath = ParentID + "_" + ddlMode.SelectedValue.ToString() + "_" + Fromdate.Month + "_" + Fromdate.Year + "_" + i.ToString() + ext;
                                        userPostedFile.SaveAs(filepath + "\\" + Path.GetFileName(strFilePath));
                                        ArrFileName[i] = strFilePath;
                                    }
                                    else
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not upload more than 1 MB File size.!',3);", true);
                                        return;
                                    }
                                }
                                else
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select jpg, png,  jpeg, pdf file!',3);", true);
                                    return;
                                }

                            }
                            // Store File in Table
                            for (int j = 0; j < ArrFileName.Length; j++)
                            {

                                CLM2 objCLM2 = new CLM2();
                                objCLM2.CLM2ID = CLM2ID++;
                                objCLM2.ParentID = ParentID;
                                objCLM2.ParentClaimID = objOCLMP.ParentClaimID;
                                objCLM2.SchemeType = ddlMode.SelectedValue;
                                objCLM2.ImageName = ArrFileName[j].ToString();
                                ctx.CLM2.Add(objCLM2);
                            }
                            //End File storage
                            // ENd File Upload
                        }
                    }

                    ctx.SaveChanges();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Detail Submittd Successfully',1);", true);
                    ClearAllInputs(true);
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        ClearAllInputs(true);
        btnSumbit.Enabled = true;
    }

    #endregion

    #region Gridview Events

    protected void gvCommon_PreRender(object sender, EventArgs e)
    {
        if (gvCommon.Rows.Count > 0)
        {
            gvCommon.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvCommon.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion
}