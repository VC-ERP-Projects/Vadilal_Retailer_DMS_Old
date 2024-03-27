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

public partial class Asset_MyAssets : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    String TempPath = Path.GetTempPath();

    public List<AstConf> MSTCFLIST
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
            MSTCFLIST = new List<AstConf>();
            GetAllAssetList();
        }
    }

    public void GetAllAssetList()
    {
        decimal ParentID = Convert.ToDecimal(Session["ParentID"].ToString());

        List<OAST> listAssets = ctx.OASTs.Where(x => x.HoldByCustomerID == ParentID && x.Active).ToList();

        AstConf objConf = null;
        MSTCFLIST.Clear();

        foreach (OAST obj in listAssets)
        {
            objConf = new AstConf();
            objConf.AssetCode = obj.AssetCode;
            objConf.AssetName = obj.AssetName;
            objConf.AssetID = obj.AssetID;
            objConf.AssetTransferID = 0;
            objConf.AssetConditionID = 0;
            objConf.AssetStatusID = 0;
            objConf.AttachFileName = "";

            MSTCFLIST.Add(objConf);
        }

        gvAsset.DataSource = MSTCFLIST;
        gvAsset.DataBind();

    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            MSTCF objMSTCF = null;
            string serverPath = "";
            int assetID = 0;
            int assetTransferID = 0;

            serverPath = Server.MapPath(Constant.AssetConfirm) + "/" + ParentID;
            bool result = false;
            bool errFound = false;

            int astConfID = ctx.GetKey("MSTCF", "AssetConfirmID", "", 0, 0).FirstOrDefault().Value;
            foreach (GridViewRow row in gvAsset.Rows)
            {
                errFound = false;

                CheckBox chkSelect = (CheckBox)row.FindControl("chkSelect");
                if (chkSelect.Checked == true)
                {
                    TextBox txtCnfDate = (TextBox)row.FindControl("txtConfirmDate");
                    TextBox txtCnfTime = (TextBox)row.FindControl("txtConfirmTime");
                    DropDownList ddlCondition = (DropDownList)row.FindControl("ddlCondition");
                    DropDownList ddlStatus = (DropDownList)row.FindControl("ddlStatus");
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
                        result = true;
                        objMSTCF = new MSTCF();

                        assetID = Convert.ToInt32(row.Cells[0].Text);
                        assetTransferID = Convert.ToInt32(row.Cells[1].Text);

                        objMSTCF.AssetConfirmID = astConfID++;
                        objMSTCF.AssetID = assetID;
                        objMSTCF.ConfirmDate = Convert.ToDateTime(txtCnfDate.Text);
                        objMSTCF.ConfirmTime = txtCnfTime.Text;
                        objMSTCF.ConfirmConditionID = Convert.ToInt32(ddlCondition.SelectedValue);
                        objMSTCF.ConfirmStatusID = Convert.ToInt32(ddlStatus.SelectedValue);
                        objMSTCF.Remarks = txtRemark.Text;

                        // Asset Transfer ID
                        if (row.Cells[1].Text != "0")
                            objMSTCF.AssetTransferID = Convert.ToInt32(row.Cells[1].Text);

                        objMSTCF.ConfirmCustomerID = ParentID;
                        objMSTCF.CreatedDate = DateTime.Now;
                        objMSTCF.CreatedBy = Convert.ToInt32(Session["UserID"]);
                        objMSTCF.UpdatedDate = DateTime.Now;
                        objMSTCF.UpdatedBy = Convert.ToInt32(Session["UserID"]);
                        objMSTCF.Active = true;

                        var objTmp = MSTCFLIST.Find(x => x.AssetID == assetID);
                        if (objTmp.AttachFileName != null)
                        {
                            objMSTCF.AttachFileName = objTmp.AttachFileName;
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

                        ctx.MSTCFs.Add(objMSTCF);           // ADD Asset Confirmation Record

                        var objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetID == assetID);

                        // Same Time Update the  Record in OAST (Asset Registration for HoldBy)

                        objOAST.UpdatedDate = DateTime.Now;
                        objOAST.UpdatedBy = Convert.ToInt32(Session["UserID"]);
                        objOAST.HoldByCustomerID = ParentID;

                        ctx.Entry(objOAST).State = System.Data.EntityState.Modified;
                    }
                }
            }   // end for

            if (result == true)
            {
                ctx.SaveChanges();
                GetAllAssetList();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Asset confirmed successfully',1);", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one checkbox to confirm asset', 3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
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

                    //decimal empCode = 0;
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

                    MSTCF objConf = _dbContext.MSTCFs.FirstOrDefault(x => x.AssetTransferID == assetTransferID);

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

                    // decimal empCode = 0;
                    string path = "";

                    // empCode = _dbContext.OCRDs.FirstOrDefault(x => x.CustomerID == assignto).CustomerID;
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

                List<MSTCF> listMSTCF = _dbContext.MSTCFs.Where(x => x.AssetID == assetID).OrderByDescending(x => x.CreatedDate).ToList();
                string confirmby = "";
                OCRD empobj = null;
                string path = "";
                foreach (MSTCF obj in listMSTCF)
                {
                    empobj = _dbContext.OCRDs.FirstOrDefault(x => x.CustomerID == obj.ConfirmCustomerID);
                    confirmby = empobj.CustomerName + " - " + empobj.CustomerCode;
                    //path = empobj.CustomerID + "\\Assets\\Confirm";
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

    [WebMethod]
    public static List<dynamic> GetMyAssetsDetailsByIDForPopup(int assetID)
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

            cs.RegisterArrayDeclaration("chkSelect_chk", String.Concat("'", chkSelect.ClientID, "'"));
            cs.RegisterArrayDeclaration("txtCnfDate_Txt", String.Concat("'", txtCnfDate.ClientID, "'"));
            cs.RegisterArrayDeclaration("txtCnfTime_Txt", String.Concat("'", txtCnfTime.ClientID, "'"));
            cs.RegisterArrayDeclaration("txtRemark_Txt", String.Concat("'", txtRemark.ClientID, "'"));
            cs.RegisterArrayDeclaration("ddlCondition_ddl", String.Concat("'", ddlCondition.ClientID, "'"));
            cs.RegisterArrayDeclaration("ddlStatus_ddl", String.Concat("'", ddlStatus.ClientID, "'"));

        }
    }
}