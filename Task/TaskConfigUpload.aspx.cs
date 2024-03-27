using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Validation;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Task_TaskConfigUpload : System.Web.UI.Page
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

    private void ClearAllInputs()
    {
        txtTtlRecords.Text = txtSucsRecords.Text = txtFailRecords.Text = txtEMttlRcrds.Text = txtEMSuccessRcrds.Text = txtEMFailRcrds.Text = "";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(btnPDUpload);
        scriptManager.RegisterPostBackControl(btnEmpUpload);
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        gvMissdataPDU.DataSource = null;
        gvMissdataPDU.DataBind();

        gvMissdataAEM.DataSource = null;
        gvMissdataAEM.DataBind();
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

    private void TraceService(string path, string content)
    {
        FileStream fs = new FileStream(path, FileMode.OpenOrCreate, FileAccess.Write);
        StreamWriter sw = new StreamWriter(fs);
        sw.BaseStream.Seek(0, SeekOrigin.End);
        sw.WriteLine(content);
        sw.Close();
    }

    #endregion

    #region Button Click

    protected void btnPDUpload_Click(object sender, EventArgs e)
    {
        DataTable missdata = new DataTable();
        missdata.Columns.Add("AssetCode");
        missdata.Columns.Add("ErrorMsg");
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                bool flag = true;
                int ttlRecords = 0;
                int failedRecords = 0;
                int successRecords = 0;

                if (flPDUpload.HasFile)
                {
                    if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                        System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                    string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flPDUpload.PostedFile.FileName));
                    flPDUpload.PostedFile.SaveAs(fileName);
                    string ext = Path.GetExtension(flPDUpload.PostedFile.FileName);
                    if (ext.ToLower() == ".csv")
                    {
                        DataTable dtDATA = new DataTable();
                        try
                        {
                            TransferCSVToTable(fileName, dtDATA);
                        }
                        catch (Exception ex)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                            return;
                        }

                        if (dtDATA != null && dtDATA.Rows != null && dtDATA.Rows.Count > 0)
                        {
                            var duplicates = dtDATA.AsEnumerable()
                                                            .Select(dr => dr.Field<string>("AssetSerialNumber").Trim())
                                                            .GroupBy(x => x)
                                                            .Where(g => g.Count() > 1)
                                                            .Select(g => g.Key)
                                                            .ToList();
                            foreach (var item in duplicates)
                            {
                                failedRecords = failedRecords + 1;
                                DataRow missdr = missdata.NewRow();
                                missdr["AssetCode"] = item.ToString();
                                missdr["ErrorMsg"] = "Duplicate Entry Found for Asset No: " + item.ToString();
                                missdata.Rows.Add(missdr);
                                flag = false;
                            }

                            if (!flag)
                                return;
                        }

                        if (dtDATA != null && dtDATA.Rows != null && dtDATA.Rows.Count > 0)
                        {
                            ttlRecords = dtDATA.Rows.Count;

                            foreach (DataRow item in dtDATA.Rows)
                            {
                                try
                                {
                                    String AssetSerialNumber = item["AssetSerialNumber"].ToString();
                                    Int32 PreventiveDays = 0;

                                    var objOAST = ctx.OASTs.FirstOrDefault(x => x.SerialNumber == AssetSerialNumber && x.Active);
                                    if (objOAST != null)
                                    {
                                        if (objOAST.PlantSection != "SCR" && objOAST.PlantSection != "WOF")
                                        {
                                            if (Int32.TryParse(item["NoOfDays"].ToString(), out PreventiveDays) && PreventiveDays > 0)
                                            {
                                                if (objOAST.MechanicEmpID.GetValueOrDefault(0) > 0)
                                                {
                                                    if (objOAST.HoldByCustomerID.GetValueOrDefault(0) > 0)
                                                    {
                                                        //if (!string.IsNullOrEmpty(objOAST.LastMaintainanceDate.ToString()))
                                                        //{
                                                        if (!objOAST.LastMaintainanceDate.HasValue)
                                                        {
                                                            objOAST.LastMaintainanceDate = DateTime.Now;
                                                        }
                                                        objOAST.PreventiveDays = PreventiveDays;

                                                        OTASK objOTASK = ctx.OTASKs.FirstOrDefault(x => x.AssetID == objOAST.AssetID && x.TaskTypeID == 1 && !x.IsCompleted && x.TaskStatusID != 8);//TODO
                                                        TASK1 objTASK1 = new TASK1();
                                                        var Address = objOAST.OCRD1.CRD1.Select(x => x.Address1 + ", " + x.Address2 + ", " + x.Location).FirstOrDefault();
                                                        if (objOTASK == null)
                                                        {
                                                            objOTASK = new OTASK();
                                                            objOTASK.TaskTypeID = 1;
                                                            objOTASK.TaskName = "Auto PM Task For Serial Number: " + AssetSerialNumber;
                                                            objOTASK.CustomerID = objOAST.HoldByCustomerID.GetValueOrDefault(0);
                                                            objOTASK.ConflictCustomerID = objOAST.HoldByCustomerID.GetValueOrDefault(0);
                                                            objOTASK.CustAddress = Address;
                                                            objOTASK.CustLocation = objOAST.OCRD1.CRD1.FirstOrDefault().Location;
                                                            objOTASK.CustCityID = objOAST.OCRD1.CRD1.FirstOrDefault().CityID;
                                                            objOTASK.CustStateID = objOAST.OCRD1.CRD1.FirstOrDefault().StateID;
                                                            objOTASK.CountryID = 1;
                                                            objOTASK.CustPhone1 = objOAST.OCRD1.Phone;
                                                            objOTASK.CustPhone2 = objOAST.OCRD1.CRD1.FirstOrDefault().PhoneNumber;
                                                            objOTASK.CustEmail = objOAST.OCRD1.EMail1;
                                                            objOTASK.TaskStatusID = 1;
                                                            objOTASK.IsCompleted = false;
                                                            objOTASK.TaskDate = DateTime.Now.Date;
                                                            objOTASK.TaskTime = DateTime.Now.TimeOfDay;
                                                            objOTASK.AssetID = objOAST.AssetID;
                                                            if (objOAST.WarrantyExpDate != null)
                                                            {
                                                                objOTASK.UnderWarranty = objOAST.WarrantyExpDate >= DateTime.Now.Date ? true : false;
                                                                objOTASK.WarrantyEndDate = objOAST.WarrantyExpDate;
                                                            }
                                                            else
                                                                objOTASK.UnderWarranty = false;

                                                            objOTASK.TaskCreatedFromID = 2;
                                                            objOTASK.CityFlag = true;
                                                            objOTASK.CreatedBy = UserID;
                                                            objOTASK.CreatedDate = DateTime.Now;
                                                            ctx.OTASKs.Add(objOTASK);

                                                            objTASK1.LevelNo = 1;
                                                            objTASK1.TaskStatusID = 1;
                                                            objOTASK.TaskStatusID = 1;
                                                        }
                                                        else
                                                        {
                                                            objTASK1.LevelNo = objOTASK.TASK1.OrderByDescending(x => x.LevelNo).Select(x => x.LevelNo).FirstOrDefault() + 1;
                                                            objTASK1.TaskStatusID = 5;
                                                            objOTASK.TaskStatusID = 5;
                                                        }
                                                        objOTASK.AssignEmpID = objOAST.MechanicEmpID.GetValueOrDefault(0);
                                                        objOTASK.IsConflict = false;
                                                        objOTASK.DueDate = Convert.ToDateTime(objOAST.LastMaintainanceDate).AddDays(PreventiveDays);
                                                        objOTASK.DueTime = DateTime.Now.TimeOfDay;
                                                        objOTASK.ProblemID = ctx.OPLMs.FirstOrDefault(x => x.TaskTypeID == 1).ProblemID;
                                                        objOTASK.IsAuto = true;
                                                        objOTASK.UpdatedBy = UserID;
                                                        objOTASK.UpdatedDate = DateTime.Now;

                                                        objTASK1.TaskID = objOTASK.TaskID;
                                                        objTASK1.FromEmpID = UserID;
                                                        objTASK1.ToEmpID = objOTASK.AssignEmpID;
                                                        objTASK1.CustomerID = objOTASK.CustomerID;
                                                        objTASK1.TaskCreatedFromID = objOTASK.TaskCreatedFromID;
                                                        objTASK1.ReasonID = null;
                                                        objTASK1.Remarks = objOTASK.TaskRemarks;
                                                        objTASK1.CreatedDate = DateTime.Now.Date;
                                                        objTASK1.CreatedTime = DateTime.Now.TimeOfDay;
                                                        objTASK1.Createdby = UserID;
                                                        ctx.TASK1.Add(objTASK1);

                                                        ctx.SaveChanges();
                                                        successRecords = successRecords + 1;

                                                        //if (ctx.OEMPs.Any(x=>x.EmpID == objOAST.MechanicEmpID)) //SMS
                                                        //{
                                                        //    string Message = "Dear+Employee,+Preventive+Maintainance+Task+with+Task+No.+" + objOTASK.TaskCode + "+Name+" + objOTASK.TaskName
                                                        //        + "+for+Customer+" + objOAST.OCRD.CustomerCode + " # " + objOAST.OCRD.CustomerName
                                                        //        + "+for+Date+:+" + Common.DateTimeConvert(objOTASK.DueDate) + "+Time+" + objOTASK.DueTime
                                                        //        + "+is+created+from+Back+Office+for+Asset+Serial+No." + objOAST.SerialNumber;
                                                        //    Service wb = new Service();
                                                        //    wb.SendSMS(objOAST.OCRD1.Phone, Message);
                                                        //}
                                                        var CustData = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == objOTASK.CustomerID);
                                                        if (objOTASK != null) //Notification
                                                        {
                                                            string body = "PM Task # " + objOTASK.TaskCode + " # " + objOTASK.TaskName +
                                                                " created from DMS for Serial Number # " + objOTASK.OAST.SerialNumber + " for Date & Time " +
                                                                Common.DateTimeConvert(objOTASK.DueDate) + " : " + DateTime.Today.Add(objOTASK.DueTime).ToString("hh:mm tt") + " for Customer "
                                                                + CustData.CustomerCode + " # " + CustData.CustomerName;
                                                            string title = "PM Task # " + objOTASK.TaskCode;

                                                            Thread t = new Thread(() => { Service.SendNotificationFlow(5001, objOTASK.AssignEmpID, 1000010000000000, body, title, 0); });
                                                            t.Name = Guid.NewGuid().ToString();
                                                            t.Start();
                                                        }

                                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                                                        //}
                                                        //else
                                                        //{
                                                        //    failedRecords = failedRecords + 1;
                                                        //    DataRow missdr = missdata.NewRow();
                                                        //    missdr["AssetCode"] = AssetSerialNumber;
                                                        //    missdr["ErrorMsg"] = "Asset No: '" + AssetSerialNumber + "' does not have Last Maintainence date Assigned to it.";
                                                        //    missdata.Rows.Add(missdr);
                                                        //    flag = false;
                                                        //}
                                                    }
                                                    else
                                                    {
                                                        failedRecords = failedRecords + 1;
                                                        DataRow missdr = missdata.NewRow();
                                                        missdr["AssetCode"] = AssetSerialNumber;
                                                        missdr["ErrorMsg"] = "Asset No: '" + AssetSerialNumber + "' does not have Customer Assigned to it.";
                                                        missdata.Rows.Add(missdr);
                                                        flag = false;
                                                    }
                                                }
                                                else
                                                {
                                                    failedRecords = failedRecords + 1;
                                                    DataRow missdr = missdata.NewRow();
                                                    missdr["AssetCode"] = AssetSerialNumber;
                                                    missdr["ErrorMsg"] = "Asset No: '" + AssetSerialNumber + "' does not have Mechanic Assigned to it.";
                                                    missdata.Rows.Add(missdr);
                                                    flag = false;
                                                }
                                            }
                                            else
                                            {
                                                failedRecords = failedRecords + 1;
                                                DataRow missdr = missdata.NewRow();
                                                missdr["AssetCode"] = AssetSerialNumber;
                                                missdr["ErrorMsg"] = "Data in No Of Days " + item["NoOfDays"].ToString() + " is not proper.";
                                                missdata.Rows.Add(missdr);
                                                flag = false;
                                            }
                                        }
                                        else
                                        {
                                            OTASK objOTASK = ctx.OTASKs.FirstOrDefault(x => x.AssetID == objOAST.AssetID && x.TaskTypeID == 1);//TODO
                                            if (objOTASK != null)
                                            {
                                                objOTASK.TaskStatusID = 7;
                                                objOTASK.UpdatedBy = UserID;
                                                objOTASK.UpdatedDate = DateTime.Now;

                                                TASK1 objTASK1 = new TASK1();
                                                objTASK1.LevelNo = objOTASK.TASK1.OrderByDescending(x => x.LevelNo).Select(x => x.LevelNo).FirstOrDefault() + 1;
                                                objTASK1.TaskStatusID = 7;
                                                objTASK1.TaskID = objOTASK.TaskID;
                                                objTASK1.FromEmpID = UserID;
                                                objTASK1.ToEmpID = objOTASK.AssignEmpID;
                                                objTASK1.CustomerID = objOTASK.CustomerID;
                                                objTASK1.TaskCreatedFromID = objOTASK.TaskCreatedFromID;
                                                objTASK1.ReasonID = null;
                                                objTASK1.Remarks = objOTASK.TaskRemarks;
                                                objTASK1.CreatedDate = DateTime.Now.Date;
                                                objTASK1.CreatedTime = DateTime.Now.TimeOfDay;
                                                objTASK1.Createdby = UserID;

                                                ctx.TASK1.Add(objTASK1);

                                                ctx.SaveChanges();
                                                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                                            }

                                            failedRecords = failedRecords + 1;
                                            DataRow missdr = missdata.NewRow();
                                            missdr["AssetCode"] = AssetSerialNumber;
                                            missdr["ErrorMsg"] = "Asset No: '" + AssetSerialNumber + "' is Scrap or Write-Off.";
                                            missdata.Rows.Add(missdr);
                                            flag = false;
                                        }
                                    }
                                    else
                                    {
                                        failedRecords = failedRecords + 1;
                                        DataRow missdr = missdata.NewRow();
                                        missdr["AssetCode"] = AssetSerialNumber;
                                        missdr["ErrorMsg"] = "Asset No: '" + AssetSerialNumber + "' does not exist or not active.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
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

                            txtFailRecords.Text = failedRecords.ToString();
                            txtSucsRecords.Text = successRecords.ToString();
                            txtTtlRecords.Text = ttlRecords.ToString();
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
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        finally
        {
            try
            {
                gvMissdataPDU.DataSource = missdata;
                gvMissdataPDU.DataBind();
            }
            catch (Exception)
            {
            }
        }
    }

    protected void btnEmpUpload_Click(object sender, EventArgs e)
    {
        DataTable missdata = new DataTable();
        missdata.Columns.Add("AssetCode");
        missdata.Columns.Add("ErrorMsg");
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                bool flag = true;
                int ttlRecords = 0;
                int failedRecords = 0;
                int successRecords = 0;

                if (flEmpUpload.HasFile)
                {
                    if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                        System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                    string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flEmpUpload.PostedFile.FileName));
                    flEmpUpload.PostedFile.SaveAs(fileName);
                    string ext = Path.GetExtension(flEmpUpload.PostedFile.FileName);
                    if (ext.ToLower() == ".csv")
                    {
                        DataTable dtDATA = new DataTable();
                        try
                        {
                            TransferCSVToTable(fileName, dtDATA);
                        }
                        catch (Exception ex)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                            return;
                        }

                        if (dtDATA != null && dtDATA.Rows != null && dtDATA.Rows.Count > 0)
                        {
                            var duplicates = dtDATA.AsEnumerable()
                                                            .Select(dr => dr.Field<string>("AssetSerialNumber").Trim())
                                                            .GroupBy(x => x)
                                                            .Where(g => g.Count() > 1)
                                                            .Select(g => g.Key)
                                                            .ToList();
                            foreach (var item in duplicates)
                            {
                                failedRecords = failedRecords + 1;
                                DataRow missdr = missdata.NewRow();
                                missdr["AssetCode"] = item.ToString();
                                missdr["ErrorMsg"] = "Duplicate Entry Found for Asset No: " + item.ToString();
                                missdata.Rows.Add(missdr);
                                flag = false;
                            }

                            if (!flag)
                                return;
                        }

                        if (dtDATA != null && dtDATA.Rows != null && dtDATA.Rows.Count > 0)
                        {
                            ttlRecords = dtDATA.Rows.Count;

                            foreach (DataRow item in dtDATA.Rows)
                            {
                                try
                                {
                                    String AssetSerialNumber = item["AssetSerialNumber"].ToString();
                                    string Emp = item["EmpCode"].ToString();
                                    DateTime AuditDate;

                                    var objOAST = ctx.OASTs.FirstOrDefault(x => x.SerialNumber == AssetSerialNumber && x.Active);
                                    if (objOAST != null)
                                    {
                                        if (objOAST.PlantSection != "SCR" && objOAST.PlantSection != "WOF")
                                        {
                                            if (!string.IsNullOrEmpty(item["EmpCode"].ToString()) && ctx.OEMPs.Any(x => x.EmpCode == Emp && x.Active))
                                            {
                                                if (!string.IsNullOrEmpty(item["AuditDate"].ToString()) && DateTime.TryParse(item["AuditDate"].ToString(), out AuditDate))
                                                {
                                                    if (AuditDate > DateTime.Now)
                                                    {
                                                        //if (objOAST.MechanicEmpID.GetValueOrDefault(0) > 0)
                                                        //{
                                                        var EmpID = ctx.OEMPs.FirstOrDefault(x => x.EmpCode == Emp && x.Active).EmpID;
                                                        int[] Tasks = new int[] { 8, 4 };
                                                        if (objOAST.HoldByCustomerID.GetValueOrDefault(0) > 0)
                                                        {
                                                            OTASK objOTASK = ctx.OTASKs.FirstOrDefault(x => x.AssetID == objOAST.AssetID && x.TaskTypeID == 3 && !x.IsCompleted && !Tasks.Contains(x.TaskStatusID));

                                                            TASK1 objTASK1 = new TASK1();
                                                            var Address = objOAST.OCRD1.CRD1.Select(x => x.Address1 + ", " + x.Address2 + ", " + x.Location).FirstOrDefault();

                                                            if (objOTASK == null)
                                                            {
                                                                objOTASK = new OTASK();
                                                                objOTASK.TaskTypeID = 3;
                                                                objOTASK.TaskName = "AM Task For Serial Number: " + AssetSerialNumber;
                                                                objOTASK.CustomerID = objOAST.HoldByCustomerID.GetValueOrDefault(0);
                                                                objOTASK.ConflictCustomerID = objOAST.HoldByCustomerID.GetValueOrDefault(0);
                                                                objOTASK.CustAddress = Address;
                                                                objOTASK.CustLocation = objOAST.OCRD1.CRD1.Select(x => x.Location).FirstOrDefault();
                                                                objOTASK.CustCityID = objOAST.OCRD1.CRD1.Select(x => x.CityID).FirstOrDefault();
                                                                objOTASK.CustStateID = objOAST.OCRD1.CRD1.Select(x => x.StateID).FirstOrDefault();
                                                                objOTASK.CountryID = 1;
                                                                objOTASK.CustPhone1 = objOAST.OCRD1.Phone;
                                                                objOTASK.CustPhone2 = objOAST.OCRD1.CRD1.Select(x => x.PhoneNumber).FirstOrDefault();
                                                                objOTASK.CustEmail = objOAST.OCRD1.EMail1;
                                                                objOTASK.TaskStatusID = 1;
                                                                objOTASK.IsCompleted = false;
                                                                objOTASK.TaskDate = DateTime.Now.Date;
                                                                objOTASK.TaskTime = DateTime.Now.TimeOfDay;
                                                                objOTASK.AssetID = objOAST.AssetID;
                                                                if (objOAST.WarrantyExpDate != null)
                                                                {
                                                                    objOTASK.UnderWarranty = objOAST.WarrantyExpDate >= DateTime.Now.Date ? true : false;
                                                                    objOTASK.WarrantyEndDate = objOAST.WarrantyExpDate;
                                                                }
                                                                else
                                                                    objOTASK.UnderWarranty = false;

                                                                objOTASK.TaskCreatedFromID = 2;
                                                                objOTASK.CityFlag = true;
                                                                objOTASK.CreatedBy = UserID;
                                                                objOTASK.CreatedDate = DateTime.Now;
                                                                ctx.OTASKs.Add(objOTASK);

                                                                objTASK1.LevelNo = 1;
                                                                objTASK1.TaskStatusID = 1;
                                                            }
                                                            else
                                                            {
                                                                objTASK1.LevelNo = objOTASK.TASK1.OrderByDescending(x => x.LevelNo).Select(x => x.LevelNo).FirstOrDefault() + 1;
                                                                objTASK1.TaskStatusID = 5;
                                                            }
                                                            objOTASK.AssignEmpID = EmpID;
                                                            objOTASK.IsConflict = false;
                                                            objOTASK.DueDate = AuditDate;
                                                            objOTASK.DueTime = DateTime.Now.TimeOfDay;
                                                            objOTASK.ProblemID = ctx.OPLMs.FirstOrDefault(x => x.TaskTypeID == 3).ProblemID;
                                                            objOTASK.IsAuto = true;
                                                            objOTASK.UpdatedBy = UserID;
                                                            objOTASK.UpdatedDate = DateTime.Now;

                                                            objTASK1.TaskID = objOTASK.TaskID;
                                                            objTASK1.FromEmpID = UserID;
                                                            objTASK1.ToEmpID = objOTASK.AssignEmpID;
                                                            objTASK1.CustomerID = objOTASK.CustomerID;
                                                            objTASK1.TaskCreatedFromID = objOTASK.TaskCreatedFromID;
                                                            objTASK1.ReasonID = null;
                                                            objTASK1.CreatedDate = DateTime.Now.Date;
                                                            objTASK1.CreatedTime = DateTime.Now.TimeOfDay;
                                                            objTASK1.Createdby = UserID;
                                                            ctx.TASK1.Add(objTASK1);

                                                            ctx.SaveChanges();
                                                            successRecords = successRecords + 1;

                                                            var CustData = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == objOTASK.CustomerID);
                                                            if (objOTASK != null) //Notification
                                                            {
                                                                string body = "AM Task # " + objOTASK.TaskCode + " # " + objOTASK.TaskName +
                                                                    " created from DMS for Serial Number # " + objOTASK.OAST.SerialNumber + " for Date & Time " +
                                                                    Common.DateTimeConvert(objOTASK.DueDate) + " : " + DateTime.Today.Add(objOTASK.DueTime).ToString("hh:mm tt") + " for Customer "
                                                                    + CustData.CustomerCode + " # " + CustData.CustomerName;
                                                                string title = "AM Task # " + objOTASK.TaskCode;

                                                                Thread t = new Thread(() => { Service.SendNotificationFlow(5002, objOTASK.AssignEmpID, 1000010000000000, body, title, 0); });
                                                                t.Name = Guid.NewGuid().ToString();
                                                                t.Start();
                                                            }
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                                                            //}
                                                            //else
                                                            //{
                                                            //    failedRecords = failedRecords + 1;
                                                            //    DataRow missdr = missdata.NewRow();
                                                            //    missdr["AssetCode"] = AssetSerialNumber;
                                                            //    missdr["ErrorMsg"] = "Asset No: '" + AssetSerialNumber + "' does not have Mechanic Assigned to it.";
                                                            //    missdata.Rows.Add(missdr);
                                                            //    flag = false;
                                                            //}
                                                        }
                                                        else
                                                        {
                                                            failedRecords = failedRecords + 1;
                                                            DataRow missdr = missdata.NewRow();
                                                            missdr["AssetCode"] = AssetSerialNumber;
                                                            missdr["ErrorMsg"] = "Asset No: '" + AssetSerialNumber + "' does not have Customer Assigned to it.";
                                                            missdata.Rows.Add(missdr);
                                                            flag = false;
                                                        }
                                                    }
                                                    else
                                                    {
                                                        failedRecords = failedRecords + 1;
                                                        DataRow missdr = missdata.NewRow();
                                                        missdr["AssetCode"] = AssetSerialNumber;
                                                        missdr["ErrorMsg"] = "Audit Date: '" + item["AuditDate"].ToString() + "', Should Not Be Today Or Earlier Than Today's Date.";
                                                        missdata.Rows.Add(missdr);
                                                        flag = false;
                                                    }
                                                }
                                                else
                                                {
                                                    failedRecords = failedRecords + 1;
                                                    DataRow missdr = missdata.NewRow();
                                                    missdr["AssetCode"] = AssetSerialNumber;
                                                    missdr["ErrorMsg"] = "Audit Date: '" + item["AuditDate"].ToString() + "', data is not proper.";
                                                    missdata.Rows.Add(missdr);
                                                    flag = false;
                                                }
                                            }
                                            else
                                            {
                                                failedRecords = failedRecords + 1;
                                                DataRow missdr = missdata.NewRow();
                                                missdr["AssetCode"] = AssetSerialNumber;
                                                missdr["ErrorMsg"] = "Employee Code: '" + item["EmpCode"].ToString() + "' does not exist or not active.";
                                                missdata.Rows.Add(missdr);
                                                flag = false;
                                            }
                                        }
                                        else
                                        {
                                            OTASK objOTASK = ctx.OTASKs.FirstOrDefault(x => x.AssetID == objOAST.AssetID && x.TaskTypeID == 1);//TODO
                                            if (objOTASK != null)
                                            {
                                                objOTASK.TaskStatusID = 7;
                                                objOTASK.UpdatedBy = UserID;
                                                objOTASK.UpdatedDate = DateTime.Now;

                                                TASK1 objTASK1 = new TASK1();
                                                objTASK1.TaskID = objOTASK.TaskID;
                                                objTASK1.TaskStatusID = 7;
                                                objTASK1.LevelNo = objOTASK.TASK1.OrderByDescending(x => x.LevelNo).Select(x => x.LevelNo).DefaultIfEmpty(0).FirstOrDefault() + 1;
                                                objTASK1.CustomerID = objOTASK.CustomerID;
                                                objTASK1.FromEmpID = objOTASK.AssignEmpID;
                                                objTASK1.ToEmpID = UserID;
                                                objTASK1.TaskCreatedFromID = 3;
                                                objTASK1.ReasonID = objOTASK.ReasonID;
                                                objTASK1.Remarks = "Force closed as this asset is Scrap or Write-Off";
                                                objTASK1.CreatedDate = DateTime.Now.Date;
                                                objTASK1.CreatedTime = DateTime.Now.TimeOfDay;
                                                objTASK1.Createdby = UserID;
                                                ctx.TASK1.Add(objTASK1);
                                                ctx.SaveChanges();
                                                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                                            }

                                            failedRecords = failedRecords + 1;
                                            DataRow missdr = missdata.NewRow();
                                            missdr["AssetCode"] = AssetSerialNumber;
                                            missdr["ErrorMsg"] = "Asset No: '" + AssetSerialNumber + "' is Scrap or Write-Off.";
                                            missdata.Rows.Add(missdr);
                                            flag = false;
                                        }
                                    }
                                    else
                                    {
                                        failedRecords = failedRecords + 1;
                                        DataRow missdr = missdata.NewRow();
                                        missdr["AssetCode"] = AssetSerialNumber;
                                        missdr["ErrorMsg"] = "Asset No: '" + AssetSerialNumber + "' does not exist or not active.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
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
                            txtEMFailRcrds.Text = failedRecords.ToString();
                            txtEMSuccessRcrds.Text = successRecords.ToString();
                            txtEMttlRcrds.Text = ttlRecords.ToString();
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
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        finally
        {
            try
            {
                gvMissdataAEM.DataSource = missdata;
                gvMissdataAEM.DataBind();
            }
            catch (Exception)
            {
            }
        }
    }

    protected void btnSendNoti_Click(object sender, EventArgs e)
    {

    }

    #endregion

    #region Griedview Events

    protected void gvMissdataPDU_PreRender(object sender, EventArgs e)
    {
        if (gvMissdataPDU.Rows.Count > 0)
        {
            gvMissdataPDU.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMissdataPDU.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvMissdataAEM_PreRender(object sender, EventArgs e)
    {
        if (gvMissdataAEM.Rows.Count > 0)
        {
            gvMissdataAEM.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMissdataAEM.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    #endregion
}