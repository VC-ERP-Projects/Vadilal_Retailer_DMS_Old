using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.OleDb;
using System.IO;
using System.Configuration;
using System.Data.SqlClient;
using System.Transactions;
using System.Collections.Specialized;
using System.Net;
using System.Data.Entity.Validation;
using System.Xml.Linq;
using System.Data.Objects;

public partial class Master_UploadUtility : System.Web.UI.Page
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
                            var unit = xml.Descendants("change_password");
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

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        using (DDMSEntities ctx = new DDMSEntities())
        {
            gvLeaveType.DataSource = ctx.OLVTies.Where(m => m.Active).Select(x => new { x.LeaveCode, x.LeaveName }).ToList();
            gvLeaveType.DataBind();
        }

        gvMissdata.DataSource = null;
        gvMissdata.DataBind();


        gvMissdata2.DataSource = null;
        gvMissdata2.DataBind();

        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(btnLBUpload);
        scriptManager.RegisterPostBackControl(btnUploadMobile);
    }

    #endregion

    #region TransferCSVToTable

    public static void TransferCSVToTable(string filePath, DataTable dt)
    {

        string[] csvRows = System.IO.File.ReadAllLines(filePath);
        string[] fields = null;
        bool head = true;
        foreach (string csvRow in csvRows)
        {
            if (head)
            {
                if (dt.Columns.Count == 0)
                {
                    fields = csvRow.Split(',');
                    foreach (string column in fields)
                    {
                        DataColumn datecolumn = new DataColumn(column);
                        datecolumn.AllowDBNull = true;
                        dt.Columns.Add(datecolumn);
                    }
                }
                head = false;
            }
            else
            {
                fields = csvRow.Split(',');
                DataRow row = dt.NewRow();
                row.ItemArray = new object[fields.Length];
                row.ItemArray = fields;
                dt.Rows.Add(row);
            }
        }

    }

    #endregion

    #region Button Click

    protected void btnLBUpload_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("Employee Code");
            missdata.Columns.Add("Leave Type");
            missdata.Columns.Add("Balance");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;

            if (OLVBLUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(OLVBLUpload.PostedFile.FileName));
                OLVBLUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(OLVBLUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtLBL = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtLBL);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    if (dtLBL != null && dtLBL.Rows != null && dtLBL.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtLBL.Rows)
                            {
                                string EmpCode = item["Employee Code"].ToString();
                                string LeaveType = item["Leave Type"].ToString();
                                string Balance = item["Balance"].ToString();

                                if (!string.IsNullOrEmpty(EmpCode) && !string.IsNullOrEmpty(LeaveType))
                                {
                                    if (ctx.OEMPs.Any(x => x.EmpCode == EmpCode && x.Active))
                                    {
                                        if (ctx.OLVTies.Any(x => x.LeaveCode == LeaveType && x.Active))
                                        {
                                            Decimal DecNum = 0;
                                            if (Decimal.TryParse(Balance, out DecNum) && DecNum >= 0)
                                            {

                                            }
                                            else
                                            {
                                                DataRow missdr = missdata.NewRow();
                                                missdr["Employee Code"] = EmpCode + " # " + ctx.OEMPs.FirstOrDefault(x => x.EmpCode == EmpCode).Name;
                                                missdr["Leave Type"] = LeaveType;
                                                missdr["Balance"] = Balance;
                                                missdr["ErrorMsg"] = "Balance data is not proper.";
                                                missdata.Rows.Add(missdr);
                                                flag = false;
                                            }
                                        }
                                        else
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["Employee Code"] = EmpCode + " # " + ctx.OEMPs.FirstOrDefault(x => x.EmpCode == EmpCode).Name;
                                            missdr["Leave Type"] = LeaveType;
                                            missdr["Balance"] = Balance;
                                            missdr["ErrorMsg"] = "Leave Type: '" + LeaveType + "' does not exist or not active.";
                                            missdata.Rows.Add(missdr);
                                            flag = false;
                                        }
                                    }
                                    else
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Employee Code"] = EmpCode;
                                        missdr["Leave Type"] = LeaveType;
                                        missdr["Balance"] = Balance;
                                        missdr["ErrorMsg"] = "Employee Code: '" + EmpCode + "' does not exist or not active.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Employee Code"] = EmpCode;
                                    missdr["Leave Type"] = LeaveType;
                                    missdr["Balance"] = Balance;
                                    missdr["ErrorMsg"] = "Data is not proper.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                            }
                        }
                    }

                    if (flag)
                    {
                        if (dtLBL != null && dtLBL.Rows != null && dtLBL.Rows.Count > 0)
                        {
                            using (DDMSEntities ctx = new DDMSEntities())
                            {
                                int LeaveBalID = ctx.GetKey("OLVBL", "LeaveBalanceID", "", 0, 0).FirstOrDefault().Value;

                                foreach (DataRow item in dtLBL.Rows)
                                {
                                    try
                                    {
                                        string EmpCode = item["Employee Code"].ToString();
                                        string LeaveType = item["Leave Type"].ToString();
                                        string Balance = item["Balance"].ToString();

                                        var objOEMP = ctx.OEMPs.FirstOrDefault(x => x.EmpCode == EmpCode && x.Active == true);
                                        if (objOEMP != null)
                                        {
                                            Decimal DecNum = 0;
                                            var objOLVTY = ctx.OLVTies.FirstOrDefault(x => x.LeaveCode == LeaveType);
                                            OLVBL objOLVBL = ctx.OLVBLs.FirstOrDefault(x => x.EmpID == objOEMP.EmpID && x.LeaveTypeID == objOLVTY.LeaveTypeID);
                                            if (objOLVBL == null)
                                            {
                                                objOLVBL = new OLVBL();
                                                objOLVBL.LeaveBalanceID = LeaveBalID++;
                                                objOLVBL.ParentID = ParentID;
                                                objOLVBL.EmpID = objOEMP.EmpID;
                                                objOLVBL.LeaveTypeID = objOLVTY.LeaveTypeID;
                                                objOLVBL.LeaveBalance = Decimal.TryParse(Balance, out DecNum) ? DecNum : 0;
                                                objOLVBL.CreatedBy = UserID;
                                                objOLVBL.CreatedDate = DateTime.Now;
                                                objOLVBL.UpdatedBy = UserID;
                                                objOLVBL.UpdatedDate = DateTime.Now;
                                                objOLVBL.Active = true;
                                                ctx.OLVBLs.Add(objOLVBL);
                                            }
                                            objOLVBL.LeaveBalance = Decimal.TryParse(Balance, out DecNum) ? DecNum : 0;
                                            objOLVBL.UpdatedDate = DateTime.Now;
                                            objOLVBL.UpdatedBy = UserID;
                                            ctx.SaveChanges();
                                        }
                                    }
                                    catch (DbEntityValidationException ex)
                                    {
                                        var error = ex.EntityValidationErrors.First().ValidationErrors.First();
                                        if (error != null)
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + error.ErrorMessage.Replace("'", "") + "',2);", true);
                                        else
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                                        return;
                                    }
                                }
                            }
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                        }
                    }
                    else
                    {
                        gvMissdata.DataSource = missdata;
                        gvMissdata.DataBind();
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnUploadMobile_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("CustomerCode");
            missdata.Columns.Add("Phone");
            missdata.Columns.Add("Msg");
            if (fileUploadMobile.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(fileUploadMobile.PostedFile.FileName));
                fileUploadMobile.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(fileUploadMobile.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtLBL = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtLBL);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    if (dtLBL != null && dtLBL.Rows != null && dtLBL.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtLBL.Rows)
                            {
                                string CustCode = item["CustomerCode"].ToString();
                                string MobileNum = item["Phone"].ToString();

                                if (!string.IsNullOrEmpty(CustCode))
                                {
                                    if (ctx.OCRDs.Any(x => x.CustomerCode == CustCode && x.Active))
                                    {
                                        Int64 MobileNo = 0;
                                        if (MobileNum == "")
                                        {
                                            OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustCode && x.Active);
                                            objOCRD.Phone = "";
                                            ctx.SaveChanges();
                                        }
                                        else if (Int64.TryParse(MobileNum, out MobileNo) && MobileNo.ToString().Length == 10)
                                        {
                                            OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustCode && x.Active);
                                            objOCRD.Phone = MobileNo.ToString();
                                            ctx.SaveChanges();
                                        }
                                        else
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["CustomerCode"] = CustCode;
                                            missdr["Phone"] = MobileNo.ToString();
                                            missdr["Msg"] = "Phone data is not proper.";
                                            missdata.Rows.Add(missdr);
                                        }
                                    }
                                    else
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["CustomerCode"] = CustCode;
                                        missdr["Phone"] = MobileNum;
                                        missdr["Msg"] = "CustomerCode: '" + CustCode + "' does not exist or not active.";
                                        missdata.Rows.Add(missdr);
                                    }
                                }
                                else
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["CustomerCode"] = CustCode;
                                    missdr["Phone"] = MobileNum;
                                    missdr["Msg"] = "Data is not proper.";
                                    missdata.Rows.Add(missdr);
                                }
                            }
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);

                        }
                    }

                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }

            gvMissdata2.DataSource = missdata;
            gvMissdata2.DataBind();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    protected void gvLeaveType_PreRender(object sender, EventArgs e)
    {
        if (gvLeaveType.Rows.Count > 0)
        {
            gvLeaveType.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvLeaveType.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }


}