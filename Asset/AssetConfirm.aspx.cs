using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Asset_AssetConfirm : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    String TempPath = Path.GetTempPath();

    public List<AstConf> ASTCFLIST
    {
        get { return Session["AstConf"] as List<AstConf>; }
        set { Session["AstConf"] = value; }
    }

    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();

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
                        var unit = xml.Descendants("employee_master");
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

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!Page.IsPostBack)
        {
            ASTCFLIST = new List<AstConf>();
            GetAllAssetList();
            ClearAllInputs();
        }
    }

    public void ClearAllInputs()
    {
        txtAssetCodeAdd.Text = txtAssetNameAdd.Text = txtExtraRemarksAdd.Text = "";
        // txtAssetCodeLess.Text = txtAssetNameLess.Text = txtExtraRemarksLess.Text = "";
    }

    public void GetAllAssetList()
    {
        decimal ParentID = Convert.ToDecimal(Session["ParentID"].ToString());

        List<OAST> assetList = ctx.OASTs.Where(x => x.AssignToCustomerID == ParentID && x.HoldByCustomerID == null && x.Active).ToList();
        AstConf objConf = null;
        ASTCFLIST.Clear();

        foreach (OAST obj in assetList)
        {
            objConf = new AstConf();
            objConf.AssetCode = obj.AssetCode;
            objConf.AssetName = obj.AssetName;
            objConf.AssetID = obj.AssetID;
            objConf.AssetTransferID = 0;
            objConf.AssetConditionID = 0;
            objConf.AssetStatusID = 0;
            objConf.AttachFileName = "";

            ASTCFLIST.Add(objConf);
        }

        List<OASTF> listTransfers = ctx.OASTFs.Where(x => x.TransferToCustomerID == ParentID && x.IsConfirm == false).ToList();

        foreach (OASTF obj in listTransfers)
        {
            objConf = new AstConf();
            objConf.AssetCode = obj.OAST.AssetCode;
            objConf.AssetName = obj.OAST.AssetName;
            objConf.AssetID = obj.AssetID.Value;
            objConf.AssetTransferID = obj.AssetTransferID;
            objConf.AssetConditionID = 0;
            objConf.AssetStatusID = 0;
            objConf.AttachFileName = "";

            ASTCFLIST.Add(objConf);
        }

        gvAsset.DataSource = ASTCFLIST;
        gvAsset.DataBind();

    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            ASTCF objASTCF = null;
            string serverPath = "";
            int assetID = 0;
            int assetTransferID = 0;

            serverPath = Server.MapPath(Constant.AssetConfirm) + "/" + ParentID;
            bool result = false;

            bool errFound = false;
            string confirmType = "";

            bool exAst = false;
            // for Extra Assets
            if (!string.IsNullOrEmpty(txtAssetCodeAdd.Text) && !string.IsNullOrEmpty(txtAssetNameAdd.Text))
            {
                if (ddlAssetBrand.SelectedValue == "0")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select asset brand.', 3);", true);
                    errFound = true;
                    return;
                }

                if (ddlAssetSize.SelectedValue == "0")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select asset size.', 3);", true);
                    errFound = true;
                    return;
                }

                EXAST objExAdd = new EXAST();
                int exAstID = ctx.GetKey("EXAST", "ExtraAssetID", "", 0, 0).FirstOrDefault().Value;
                objExAdd.ExtraAssetID = exAstID++;
                objExAdd.ExtraAssetType = "Extra";
                objExAdd.AssetCode = txtAssetCodeAdd.Text;
                objExAdd.AssetName = txtAssetNameAdd.Text;
                objExAdd.ExtraAssetRemarks = txtExtraRemarksAdd.Text;
                objExAdd.AssetBrandID = Convert.ToInt32(ddlAssetBrand.SelectedValue.ToString());
                objExAdd.AssetSizeID = Convert.ToInt32(ddlAssetSize.SelectedValue.ToString());
                objExAdd.ConfirmByCustomerID = ParentID;
                objExAdd.CreatedDate = DateTime.Now;
                objExAdd.CreatedBy = Convert.ToInt32(Session["UserID"]);
                objExAdd.UpdatedDate = DateTime.Now;
                objExAdd.UpdatedBy = Convert.ToInt32(Session["UserID"]);
                objExAdd.Active = true;
                ctx.EXASTs.Add(objExAdd);
                ctx.SaveChanges();
                exAst = true;
            }
            //if (!string.IsNullOrEmpty(txtAssetCodeLess.Text) && !string.IsNullOrEmpty(txtAssetNameLess.Text))
            //{
            //    EXAST objExLess = new EXAST();
            //    objExLess.ExtraAssetType = "Less";
            //    objExLess.AssetCode = txtAssetCodeLess.Text;
            //    objExLess.AssetName = txtAssetNameLess.Text;
            //    objExLess.ExtraAssetRemarks = txtExtraRemarksLess.Text;
            //    objExLess.ConfirmByCustomerID = ParentID;
            //    objExLess.CreatedDate = DateTime.Now;
            //    objExLess.CreatedBy = Convert.ToInt32(Session["UserID"]);
            //    objExLess.UpdatedDate = DateTime.Now;
            //    objExLess.UpdatedBy = Convert.ToInt32(Session["UserID"]);
            //    objExLess.Active = true;
            //    ctx.EXASTs.Add(objExLess);
            //    ctx.SaveChanges();
            //    exAst = true;
            //}

            int astConfID = ctx.GetKey("ASTCF", "AssetConfirmID", "", 0, 0).FirstOrDefault().Value;
            foreach (GridViewRow row in gvAsset.Rows)
            {
                errFound = false;
                CheckBox chkAccept = (CheckBox)row.FindControl("chkAccept");
                CheckBox chkReject = (CheckBox)row.FindControl("chkReject");

                if (chkAccept.Checked == true || chkReject.Checked == true)
                {
                    DropDownList ddlCondition = (DropDownList)row.FindControl("ddlCondition");
                    DropDownList ddlStatus = (DropDownList)row.FindControl("ddlStatus");
                    TextBox txtCnfDate = (TextBox)row.FindControl("txtConfirmDate");
                    TextBox txtCnfTime = (TextBox)row.FindControl("txtConfirmTime");
                    TextBox txtRemark = (TextBox)row.FindControl("txtRemark");

                    if (ddlCondition.SelectedValue == "0")
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select asset Condition in checked row.', 3);", true);
                        errFound = true;
                    }

                    if (ddlStatus.SelectedValue == "0")
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select asset status in checked row.', 3);", true);
                        errFound = true;
                    }

                    if (txtCnfDate.Text == "")
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter confirm date in checked row.', 3);", true);
                        errFound = true;
                    }

                    if (txtCnfTime.Text == "")
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter confirm time in checked row.', 3);", true);
                        errFound = true;
                    }

                    if (txtRemark.Text == "")
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter remarks in checked row.', 3);", true);
                        errFound = true;
                    }

                    if (errFound == false)
                    {
                        if (chkAccept.Checked == true)
                            confirmType = "Accept";
                        else
                            confirmType = "Reject";

                        result = true;
                        objASTCF = new ASTCF();

                        assetID = Convert.ToInt32(row.Cells[0].Text);
                        assetTransferID = Convert.ToInt32(row.Cells[1].Text);

                        objASTCF.AssetConfirmID = astConfID++;
                        objASTCF.AssetID = assetID;
                        objASTCF.ConfirmDate = Convert.ToDateTime(txtCnfDate.Text);
                        objASTCF.ConfirmTime = txtCnfTime.Text;
                        objASTCF.ConfirmConditionID = Convert.ToInt32(ddlCondition.SelectedValue);
                        objASTCF.ConfirmStatusID = Convert.ToInt32(ddlStatus.SelectedValue);
                        objASTCF.Remarks = txtRemark.Text;
                        objASTCF.ConfirmType = confirmType;

                        // Asset Transfer ID
                        if (row.Cells[1].Text != "0")
                            objASTCF.AssetTransferID = Convert.ToInt32(row.Cells[1].Text);

                        objASTCF.ConfirmCustomerID = ParentID;
                        objASTCF.CreatedDate = DateTime.Now;
                        objASTCF.CreatedBy = Convert.ToInt32(Session["UserID"]);
                        objASTCF.UpdatedDate = DateTime.Now;
                        objASTCF.UpdatedBy = Convert.ToInt32(Session["UserID"]);
                        objASTCF.Active = true;

                        var objTmp = ASTCFLIST.Find(x => x.AssetID == assetID);
                        if (objTmp.AttachFileName != null)
                        {
                            objASTCF.AttachFileName = objTmp.AttachFileName;
                            var dir = Path.GetTempPath();

                            if (File.Exists(Path.Combine(dir, objTmp.AttachFileName)))
                            {
                                if (!Directory.Exists(serverPath))
                                {
                                    Directory.CreateDirectory(serverPath);
                                }
                                File.Copy(Path.Combine(dir, objTmp.AttachFileName), Path.Combine(serverPath, objTmp.AttachFileName));
                            }
                        }

                        ctx.ASTCFs.Add(objASTCF);           // ADD Asset Confirmation Record

                        var objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetID == assetID);
                        OASTF objOASTF = null;

                        if (!(objOAST.AssignToCustomerID == ParentID && objOAST.HoldByCustomerID == null))
                        {
                            objOASTF = ctx.OASTFs.FirstOrDefault(x => x.AssetTransferID == assetTransferID);

                            objOASTF.UpdatedDate = DateTime.Now;
                            objOASTF.UpdatedBy = Convert.ToInt32(Session["UserID"]);
                            objOASTF.IsConfirm = true;

                            ctx.Entry(objOASTF).State = System.Data.EntityState.Modified;
                        }

                        // Same Time Update the  Record in OAST (Asset Registration for HoldBy)
                        if (confirmType == "Accept")
                        {
                            objOAST.UpdatedDate = DateTime.Now;
                            objOAST.UpdatedBy = Convert.ToInt32(Session["UserID"]);
                            objOAST.HoldByCustomerID = ParentID;
                        }
                        else
                        {
                            // assign to the created user
                            if (objOASTF != null)
                            {
                                objOAST.HoldByCustomerID = objOASTF.TransferByCustomerID;
                            }
                            else
                            {
                                objOAST.HoldByCustomerID = objOAST.RegisterByCustomerID;
                            }

                            objOAST.UpdatedDate = DateTime.Now;
                            objOAST.UpdatedBy = Convert.ToInt32(Session["UserID"]);
                        }

                        ctx.Entry(objOAST).State = System.Data.EntityState.Modified;
                    }
                }
            }   // end for

            if (result == true)
            {
                ctx.SaveChanges();
                GetAllAssetList();
                exAst = false;
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Asset confirmed successfully',1);", true);
            }

            if (exAst == true)
            {
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Asset confirmed successfully',1);", true);
            }

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    [WebMethod]
    public static List<dynamic> GetAssetTransferDetailsByIDForPopup(int assetID)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities _dbContext = new DDMSEntities())
            {
                OAST objAsset = _dbContext.OASTs.FirstOrDefault(x => x.AssetID == assetID);
                string holdPerson = string.Empty;

                if (objAsset.HoldByCustomerID != null)
                    holdPerson = _dbContext.OCRDs.FirstOrDefault(x => x.CustomerID == objAsset.HoldByCustomerID).CustomerName;
                else
                    holdPerson = "Company";

                var temp1 = new
                {
                    AssetCode = objAsset.AssetCode,
                    AssetName = objAsset.AssetName,
                    HoldBy = holdPerson,
                    Brand = objAsset.OASTB.AssetBrandName,
                    Model = objAsset.ModelNumber,
                    SerialNo = objAsset.SerialNumber,
                    Description = objAsset.Description,
                    AssetType = objAsset.OASTY.AssetTypeName,
                    AssetGroup = objAsset.OASTG.AssetGroupName,
                    AssetStatus = objAsset.OASTU.AssetStatusName,
                    AssetCondition = objAsset.OASTC.AssetConditionName,
                    AssetID = objAsset.AssetID,
                    Asttype = "Register"
                };

                result.Add(temp1);

                List<OASTF> listOASTF = _dbContext.OASTFs.Where(x => x.AssetID == assetID).OrderByDescending(x => x.CreatedDate).ToList();
                string transferTo = "";

                foreach (OASTF obj in listOASTF)
                {
                    transferTo = _dbContext.OCRDs.FirstOrDefault(x => x.CustomerID == obj.TransferToCustomerID).CustomerName;
                    var temp = new
                    {
                        TransferToUser = transferTo,
                        TransferDate = obj.TransferDate,
                        TransferTime = obj.TransferTime,
                        DocumentDate = obj.AssetTransferDate,
                        DocumentNo = obj.AssetTransferCode,
                        Reason = obj.OASTR.AssetTransferReasonName,
                        Condition = obj.OASTC.AssetConditionName,
                        Status = obj.OASTU.AssetStatusName,
                        Remarks = (obj.Remarks == null ? "" : obj.Remarks),
                        AssetTransferID = obj.AssetTransferID,
                        Asttype = "Transfer"
                    };
                    result.Add(temp);
                }
                return result;
            }
        }
        catch (Exception ex)
        {
            return result;
        }
    }

    [WebMethod]
    public static List<dynamic> GetAssetTransferAttachmentsForPopup(int assetTransferID, string type)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            using (DDMSEntities _dbContext = new DDMSEntities())
            {
                if (type == "Transfer")
                {
                    List<ASTF1> listAttach = _dbContext.ASTF1.Where(x => x.AssetTransferID == assetTransferID && x.Active).ToList();

                    decimal transferTo = _dbContext.OASTFs.FirstOrDefault(x => x.AssetTransferID == assetTransferID).TransferToCustomerID.Value;

                    //  decimal empCode = 0;
                    string path = "";

                    //empCode = _dbContext.OCRDs.FirstOrDefault(x => x.CustomerID == transferTo).CustomerID;
                    path = Constant.AssetTransfer + transferTo;

                    foreach (ASTF1 obj in listAttach)
                    {
                        var tmp = new
                        {
                            Type = obj.Type,
                            Subject = obj.Subject,
                            Notes = obj.Notes,
                            FileName = obj.FileName,
                            FilePath = path.Remove(0, 1)
                        };
                        result.Add(tmp);
                    }

                    ASTCF objConf = _dbContext.ASTCFs.FirstOrDefault(x => x.AssetTransferID == assetTransferID);

                    if (objConf != null)
                    {
                        decimal confirmUser = _dbContext.OCRDs.FirstOrDefault(x => x.CustomerID == objConf.ConfirmCustomerID.Value).CustomerID;
                        string newpath = Constant.AssetConfirm + confirmUser;

                        var tmp1 = new
                        {
                            Type = "Confirmation",
                            Subject = "",
                            Notes = objConf.Remarks,
                            FileName = objConf.AttachFileName,
                            FilePath = newpath.Remove(0, 1)
                        };
                        result.Add(tmp1);
                    }
                }
                else
                {
                    List<AST1> listAttach = _dbContext.AST1.Where(x => x.AssetID == assetTransferID && x.Active).ToList();

                    decimal assignto = _dbContext.OASTs.FirstOrDefault(x => x.AssetID == assetTransferID).AssignToCustomerID.Value;

                    //  decimal empCode = 0;
                    string path = "";

                    //empCode = _dbContext.OCRDs.FirstOrDefault(x => x.CustomerID == assignto).CustomerID;
                    path = Constant.AssetRegister + assignto;

                    foreach (AST1 obj in listAttach)
                    {
                        var tmp = new
                        {
                            Type = "Register",
                            Subject = obj.Subject,
                            Notes = obj.Notes,
                            FileName = obj.FileName,
                            FilePath = path.Remove(0, 1)
                        };
                        result.Add(tmp);
                    }
                }
                return result;
            }
        }
        catch (Exception ex)
        {
            return result;
        }
    }

    [WebMethod]
    public static List<dynamic> GetAssetConfirmDetailsByIDForPopup(int assetID)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            using (DDMSEntities _dbContext = new DDMSEntities())
            {

                OAST objAsset = _dbContext.OASTs.FirstOrDefault(x => x.AssetID == assetID);
                string holdPerson = string.Empty;

                if (objAsset.HoldByCustomerID != null)
                    holdPerson = _dbContext.OCRDs.FirstOrDefault(x => x.CustomerID == objAsset.HoldByCustomerID).CustomerName;
                else
                    holdPerson = "Company";

                var temp1 = new
                {
                    AssetCode = objAsset.AssetCode,
                    AssetName = objAsset.AssetName,
                    HoldBy = holdPerson,
                    Brand = objAsset.OASTB.AssetBrandName,
                    Model = objAsset.ModelNumber,
                    SerialNo = objAsset.SerialNumber,
                    Description = objAsset.Description,
                    AssetType = objAsset.OASTY.AssetTypeName,
                    AssetGroup = objAsset.OASTG.AssetGroupName,
                    AssetStatus = objAsset.OASTU.AssetStatusName,
                    AssetCondition = objAsset.OASTC.AssetConditionName,
                    AssetID = objAsset.AssetID
                };

                result.Add(temp1);

                List<ASTCF> listASTCF = _dbContext.ASTCFs.Where(x => x.AssetID == assetID).OrderByDescending(x => x.CreatedDate).ToList();
                string confirmby = "";
                OCRD empobj = null;
                string path = "";
                foreach (ASTCF obj in listASTCF)
                {
                    empobj = _dbContext.OCRDs.FirstOrDefault(x => x.CustomerID == obj.ConfirmCustomerID);
                    confirmby = empobj.CustomerName + " - " + empobj.CustomerCode;
                    path = Constant.AssetConfirm + empobj.CustomerID;
                    var temp = new
                    {
                        ConfirmBy = confirmby,
                        ConfirmDate = obj.ConfirmDate,
                        ConfirmTime = obj.ConfirmTime,
                        Condition = obj.OASTC.AssetConditionName,
                        Status = obj.OASTU.AssetStatusName,
                        Remarks = (obj.Remarks == null ? "" : obj.Remarks),
                        FileName = obj.AttachFileName,
                        FilePath = path.Remove(0, 1)
                    };
                    result.Add(temp);
                }
                return result;
            }
        }
        catch (Exception ex)
        {
            return result;
        }
    }

    protected void gvAsset_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            TextBox txtConfirmDate = (TextBox)e.Row.FindControl("txtConfirmDate");
            TextBox txtConfirmTime = (TextBox)e.Row.FindControl("txtConfirmTime");

            txtConfirmDate.Text = DateTime.Now.ToString("dd/MM/yyyy");
            txtConfirmTime.Text = DateTime.Now.ToString("hh:mm:ss");
        }
    }
    protected void btnCancelClick(object sender, EventArgs e)
    {
        Response.Redirect("Asset.aspx");
    }
    protected void gvAsset_PreRender(object sender, EventArgs e)
    {
        if (gvAsset.Rows.Count > 0)
        {
            gvAsset.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvAsset.FooterRow.TableSection = TableRowSection.TableFooter;
        }

        ClientScriptManager cs = Page.ClientScript;
        foreach (GridViewRow row in gvAsset.Rows)
        {
            CheckBox chkSelect = (CheckBox)row.FindControl("chkSelect");
            TextBox txtCnfDate = (TextBox)row.FindControl("txtConfirmDate");
            TextBox txtCnfTime = (TextBox)row.FindControl("txtConfirmTime");
            DropDownList ddlCondition = (DropDownList)row.FindControl("ddlCondition");
            DropDownList ddlStatus = (DropDownList)row.FindControl("ddlStatus");
            TextBox txtRemark = (TextBox)row.FindControl("txtRemark");

            //  cs.RegisterArrayDeclaration("chkSelect_chk", String.Concat("'", chkSelect.ClientID, "'"));
            cs.RegisterArrayDeclaration("txtCnfDate_Txt", String.Concat("'", txtCnfDate.ClientID, "'"));
            cs.RegisterArrayDeclaration("txtCnfTime_Txt", String.Concat("'", txtCnfTime.ClientID, "'"));
            cs.RegisterArrayDeclaration("txtRemark_Txt", String.Concat("'", txtRemark.ClientID, "'"));
            cs.RegisterArrayDeclaration("ddlCondition_ddl", String.Concat("'", ddlCondition.ClientID, "'"));
            cs.RegisterArrayDeclaration("ddlStatus_ddl", String.Concat("'", ddlStatus.ClientID, "'"));

        }
    }
}