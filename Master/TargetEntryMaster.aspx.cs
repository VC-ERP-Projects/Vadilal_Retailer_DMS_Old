using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Validation;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_TargetEntryMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
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
        txtCode.Text = "";

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

    #region ChangeEvent

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetDetail(string strDivision, string strEmp)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            int Division;
            int EmpID;

            if (Int32.TryParse(strDivision, out Division) && Division > 0)
            {
                if (Int32.TryParse(strEmp, out EmpID) && EmpID > 0)
                {
                    decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        if (ctx.OTRGs.Any(x => x.EmpID == EmpID && x.ParentID == ParentID && x.DivisionID == Division))
                        {
                            var Data = (from C in ctx.OTRGs
                                        join D in ctx.OEMPs on new { C.ParentID, EmpID = C.CreatedBy } equals new { D.ParentID, D.EmpID } into pp
                                        from pl in pp.DefaultIfEmpty()
                                        where C.EmpID == EmpID && C.DivisionID == Division && C.Active
                                        select new
                                        {
                                            MonthYear = C.MonthYear,
                                            C.TargetAmount,
                                            C.OTRGID,
                                            UpdatedBy = pl.EmpCode + " - " + pl.Name,
                                            UpdatedDate = C.UpdatedDate,
                                        }).ToList().Select(x =>
                                        new
                                        {
                                            MonthYear = x.MonthYear.ToString("MM/yyyy"),
                                            x.TargetAmount,
                                            x.OTRGID,
                                            x.UpdatedBy,
                                            UpdatedDate = x.UpdatedDate.ToString("dd/MM/yyyy"),
                                        });
                            result.Add(Data);
                        }
                        else
                            result.Add("ERROR=" + "No Data Found.");
                    }
                }
                else
                {
                    result.Add("ERROR=" + "Please select Employee.");
                }
            }
            else
            {
                result.Add("ERROR=" + "Please select Division.");
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    #endregion

    #region Button click
    #region Submit button
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputMaterial, string hidJsonInputHeader)
    {
        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);

            var DetailData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());
            var HeaderData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputHeader.ToString());

            Int32 DivisionID = Convert.ToInt32(Convert.ToString(HeaderData["Division"]));
            Int32 EmpID = Convert.ToInt32(Convert.ToString(HeaderData["Emp"]));

            if (DetailData != null)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    List<OTRG> objOTRGs = ctx.OTRGs.Where(x => x.DivisionID == DivisionID && x.EmpID == EmpID).ToList();
                    objOTRGs.ForEach(x => x.Active = false);

                    foreach (var data in DetailData)
                    {
                        DateTime Month = Convert.ToDateTime(Convert.ToString(data["MonthYear"]));
                        Decimal TargetAmt = Decimal.TryParse(Convert.ToString(data["TargetAmt"]), out TargetAmt) ? TargetAmt : 0;

                        if (TargetAmt > 0)
                        {
                            OTRG objOTRG = objOTRGs.FirstOrDefault(x => x.MonthYear == Month);
                            if (objOTRG == null)
                            {
                                objOTRG = new OTRG();
                                objOTRG.ParentID = ParentID;
                                objOTRG.EmpID = EmpID;
                                objOTRG.DivisionID = DivisionID;
                                objOTRG.CreatedDate = DateTime.Now;
                                objOTRG.CreatedBy = UserID;
                                objOTRG.MonthYear = Month;
                                ctx.OTRGs.Add(objOTRG);
                            }
                            objOTRG.TargetAmount = TargetAmt;
                            objOTRG.Active = true;
                            objOTRG.UpdatedDate = DateTime.Now;
                            objOTRG.UpdatedBy = UserID;
                        }
                    }
                    ctx.SaveChanges();

                    return "SUCCESS= Target Inserted Successfully";
                }
            }
            else
                return "ERROR= Please select atleast one Item";
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }
    #endregion

    #region Download Upload Button


    protected void btnTargetEntryUpload_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("Employee Code");
            missdata.Columns.Add("Date");
            missdata.Columns.Add("Target Amount");
            missdata.Columns.Add("Division");
            missdata.Columns.Add("ErrorMsg");


            bool flag = true;

            if (flTargetEntry.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flTargetEntry.PostedFile.FileName));
                flTargetEntry.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flTargetEntry.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtTarget = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtTarget);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    if (dtTarget != null && dtTarget.Rows != null && dtTarget.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtTarget.Rows)
                            {
                                string EmpCode = item["Emp Code"].ToString();
                                string Date = item["Date"].ToString();
                                DateTime month = Convert.ToDateTime(Date);

                                string TargetAmt = item["Target Amount"].ToString();

                                string Division = item["Division"].ToString();

                                if (!string.IsNullOrEmpty(EmpCode) && !string.IsNullOrEmpty(Date) && !string.IsNullOrEmpty(TargetAmt) && !string.IsNullOrEmpty(Division))
                                {
                                    if (!ctx.OEMPs.Any(x => x.EmpCode == EmpCode && x.Active))
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Employee Code"] = EmpCode;
                                        missdr["Date"] = month;
                                        missdr["Target Amount"] = TargetAmt;
                                        missdr["Division"] = Division;
                                        missdr["ErrorMsg"] = "Employee Code: '" + EmpCode + "' does not exist or not active.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                    if (!ctx.ODIVs.Any(x => x.DivisionName == Division && x.Active))
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Employee Code"] = EmpCode;
                                        missdr["Date"] = month;
                                        missdr["Target Amount"] = TargetAmt;
                                        missdr["Division"] = Division;
                                        missdr["ErrorMsg"] = "Division Name: '" + Division + "' does not exist or not active.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                    Decimal TargetAmount = Decimal.TryParse(Convert.ToString(TargetAmt), out TargetAmount) ? TargetAmount : 0;
                                    if (TargetAmount <= 0)
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Employee Code"] = EmpCode;
                                        missdr["Date"] = month;
                                        missdr["Target Amount"] = TargetAmt;
                                        missdr["Division"] = Division;
                                        missdr["ErrorMsg"] = "Target amount can not be Negative or 0.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Employee Code"] = EmpCode;
                                    missdr["Leave Type"] = month;
                                    missdr["Balance"] = TargetAmt;
                                    missdr["ErrorMsg"] = "Data is not proper.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                            }
                        }
                    }

                    if (flag)
                    {
                        if (dtTarget != null && dtTarget.Rows != null && dtTarget.Rows.Count > 0)
                        {
                            using (DDMSEntities ctx = new DDMSEntities())
                            {
                                int LeaveBalID = ctx.GetKey("OLVBL", "LeaveBalanceID", "", 0, 0).FirstOrDefault().Value;

                                foreach (DataRow item in dtTarget.Rows)
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
                        //gvMissdata.DataSource = missdata;
                        //gvMissdata.DataBind();
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

    #endregion
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
}