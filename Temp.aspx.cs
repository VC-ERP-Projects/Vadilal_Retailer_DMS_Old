using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Temp : System.Web.UI.Page
{
    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

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

            }
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }

    }
    private void ClearAllInputs()
    {
        txtFromDate.Text = txtTodate.Text = "";

    }
    protected void Page_Load(object sender, EventArgs e)
    {
        //ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
            scriptManager.RegisterPostBackControl(btnExportSales);
            scriptManager.RegisterPostBackControl(btnExportPurchase);

        }
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtTodate.Text))
        {
            if (ParentID != null || ParentID != 0)
            {
                DateTime FromDate = Convert.ToDateTime(txtFromDate.Text);
                DateTime ToDate = Convert.ToDateTime(txtTodate.Text);
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();
                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "SalesRegister_old";
                Cm.Parameters.AddWithValue("@FromDate", FromDate);
                Cm.Parameters.AddWithValue("@ToDate", ToDate);
                Cm.Parameters.AddWithValue("@ParentID", ParentID);
                Cm.Parameters.AddWithValue("@CustomerID", 0);
                DataSet ds = objClass.CommonFunctionForSelect(Cm);
                DataTable dt = ds.Tables[0];


                TransferCreateExcel("SalesRegister_Export_" + DateTime.Now.Date.ToString("ddMMyyyy"), dt, dt.Select());
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Login',2);", true);
            }

        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select FromDate And ToDate',2);", true);
        }

    }

    #region Transfer Excel

    public static void TransferCreateExcel(string filePath, DataTable dt, DataRow[] drs)
    {
        try
        {

            HttpResponse response = HttpContext.Current.Response;
            response.Clear();
            response.ClearHeaders();
            response.ClearContent();
            response.Charset = Encoding.UTF8.WebName;
            response.AddHeader("content-disposition", "attachment; filename=" + filePath + ".xls");
            response.AddHeader("Content-Type", "application/Excel");
            response.ContentType = "application/vnd.xlsx";
            //response.AddHeader("Content-Length", file.Length.ToString());


            // create a string writer
            using (StringWriter sw = new StringWriter())
            {
                using (HtmlTextWriter htw = new HtmlTextWriter(sw)) //datatable'a aldığımız sorguyu bir datagrid'e atayıp html'e çevir.
                {
                    // instantiate a datagrid
                    DataGrid dg = new DataGrid();
                    dg.DataSource = dt;
                    dg.DataBind();
                    dg.RenderControl(htw);
                    response.Write(sw.ToString());
                    dg.Dispose();
                    dt.Dispose();
                    response.End();
                }
            }
        }
        catch (Exception ex)
        {

        }
    }


    #endregion

    protected void btnExportPurchase_Click(object sender, EventArgs e)
    {
        Decimal ParentID = 1000010000000000;

        string BaseDir = AppDomain.CurrentDomain.BaseDirectory;

        string strPath = BaseDir + "Document\\log.txt";

        TraceService(strPath, "Code Start : " + DateTime.Now);

        using (DDMSEntities ctx = new DDMSEntities())
        {
            SqlConnection sConnection = ((SqlConnection)ctx.Database.Connection);
            try
            {
                OEML objOEML = ctx.OEMLs.FirstOrDefault(x => x.ParentID == ParentID);
                if (objOEML != null)
                {
                    var objEML1 = ctx.EML1.Where(x => x.Active && x.EmailID == 10 && x.ParentID == ParentID).Select(x => new { x.EmailID, x.EmpID, x.OEMP.WorkEmail, x.OEMP.Name }).ToList();
                    if (objEML1 != null && objEML1.Count > 0)
                    {
                        var objEEML = ctx.EEMLs.Where(x => x.EmailID == 10 && x.ParentID == ParentID && x.Active).ToList();

                        if (objEEML != null && objEEML.Count > 0)
                        {
                            if (sConnection != null && sConnection.State == ConnectionState.Closed)
                                sConnection.Open();

                            DateTime date = DateTime.Now;
                            foreach (EEML item in objEEML)
                            {
                                try
                                {
                                    //if (date.Year >= item.NextDate.Year && date.Month >= item.NextDate.Month && date.Day >= item.NextDate.Day && date.TimeOfDay >= item.FreqTime)
                                    //{
                                    item.NextDate = date.AddDays(item.FreqDay);
                                    DataTable dt = new DataTable();
                                    SqlDataAdapter com = new SqlDataAdapter(item.SQLQuery, sConnection);
                                    com.Fill(dt);
                                    string emailIDs = dt.Rows[0][7].ToString();
                                    try
                                    {
                                        List<string> Emails = emailIDs.Split(",".ToArray()).ToList();
                                        foreach (string EmailIDs in Emails)
                                        {
                                            MailMessage message = new MailMessage();
                                            message.From = new MailAddress(objOEML.Email);
                                            message.To.Add(new MailAddress(EmailIDs.Trim()));
                                            //message.CC.Add(new MailAddress("dmssupport@vadilalgroup.com"));
                                            message.Subject = "Auto Email From DMS";

                                            SmtpClient client = new SmtpClient();
                                            client.Host = objOEML.Domain;
                                            client.Port = Convert.ToInt32(objOEML.Port);
                                            client.UseDefaultCredentials = true;
                                            client.EnableSsl = true;
                                            if (!string.IsNullOrEmpty(objOEML.UserName))
                                                client.Credentials = new System.Net.NetworkCredential(objOEML.UserName, objOEML.Password);
                                            else
                                                client.Credentials = new System.Net.NetworkCredential(objOEML.Email, objOEML.Password);

                                            string bodystr = "Dear Sir, <br /><br /> Beat not available for following dealers so, please arrange for Beat Creation for the same. <br /> <br />";
                                            bodystr += "<table border='1' style='border-collapse:collapse;margin-top:5px' width='100%'>";
                                            bodystr += "<thead style='background-color:#E6E6E6; font-size:12px;'><tr>";
                                            bodystr += "<th width='6%'>Dealer Code</th><th width='25%'>Name</th><th width='10%'>City</th><th width='4%'>Boxes</th><th width='8%'>Gross Amount</th><th width='6%'>Dist. Code</th><th width='25%'>Dist. Name</th></tr></thead>";
                                            bodystr += "<tbody>";
                                            for (int i = 0; i < dt.Rows.Count; i++)
                                            {
                                                bodystr += "<tr >";
                                                for (int j = 0; j < 7; j++)
                                                {
                                                    if (j == 3 || j == 4)
                                                    {
                                                        bodystr += "<td align='right' style='font-size:11px;' >";
                                                        bodystr += dt.Rows[i][j].ToString();
                                                        bodystr += "</td >";
                                                    }
                                                    else
                                                    {
                                                        bodystr += "<td style='font-size:11px'>";
                                                        bodystr += dt.Rows[i][j].ToString();
                                                        bodystr += "</td >";
                                                    }
                                                }
                                                bodystr += "</tr >";
                                            }
                                            bodystr += "</tbody>";
                                            bodystr += "</table>";
                                            bodystr += "<br /><br /> Thanks & Regards, <br /> Team DMS.";

                                            message.Body = bodystr;
                                            message.IsBodyHtml = true;
                                            client.Send(message);
                                        }
                                    }
                                    catch (Exception ex)
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
                                        TraceService(strPath, "Error in sending mail @ " + Common.GetString(ex) + " @ " + DateTime.Now.ToString());
                                    }
                                    //}
                                }
                                catch (Exception ex)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
                                    TraceService(strPath, Common.GetString(ex) + " @ " + DateTime.Now.ToString());
                                }
                            }
                            TraceService(strPath, "Process Completed. @ " + DateTime.Now.ToString());
                        }
                        else
                            TraceService(strPath, "No Email Query found @ " + DateTime.Now.ToString());
                    }
                    else
                        TraceService(strPath, "No Mapping found @ " + DateTime.Now.ToString());
                }
                else
                    TraceService(strPath, "No Email Setting " + DateTime.Now.ToString());
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
                TraceService(strPath, Common.GetString(ex) + " @ " + DateTime.Now.ToString());
            }
            finally
            {
                sConnection.Close();
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

    //protected void btnClick_Click(object sender, EventArgs e)
    //{
    //    StringBuilder sb = new StringBuilder();
    //    using (DDMSEntities ctx = new DDMSEntities())
    //    {
    //        var Name = "";
    //        var FilePath = Server.MapPath("~/Document/Escalation_" + Name + "/");
    //        if (!Directory.Exists(FilePath))
    //        {
    //            Directory.CreateDirectory(FilePath);
    //        }
    //        var FileName = FilePath + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".txt";
    //        try
    //        {
    //            var WrkList = ctx.OAWRKs.Where(x => new int[] { 9120, 9112, 9121, 9114 }.Contains(x.RequestTypeMenuID)).ToList();
    //            if (WrkList != null && WrkList.FirstOrDefault().EscDays > 0)
    //            {
    //                #region Expense
    //                if (WrkList.Any(x => x.RequestTypeMenuID == 9120)) //Expense Approval
    //                {
    //                    Name = "Expense";
    //                    List<OERQ> listOERQ = ctx.OERQs.Where(x => new int[] { 1, 4 }.Contains(x.Status)).ToList();
    //                    int OEAPCount = ctx.GetKey("OEAP", "OEAPID", "", ParentID, 0).FirstOrDefault().Value;
    //                    foreach (OERQ req in listOERQ)
    //                    {
    //                        OEAP objOERA = ctx.OEAPs.Where(x => x.OERQID == req.OERQID && x.ParentID == req.ParentID).OrderByDescending(x => x.LevelNo).FirstOrDefault();
    //                        if (objOERA != null)
    //                        {
    //                            //Atleast one approval done
    //                            OAWRK data = WrkList.FirstOrDefault(x => x.LevelNo == objOERA.LevelNo + 1 && x.RequestTypeMenuID == 9120);
    //                            var NxtManager = WrkList.FirstOrDefault(x => x.LevelNo == data.LevelNo + 1 && x.RequestTypeMenuID == 9120);
    //                            int status = 0;
    //                            int? NxtMgr = 0;
    //                            if (NxtManager != null)
    //                            {
    //                                if (NxtManager.IsManager)
    //                                    NxtMgr = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOERA.EmpID).ManagerID.Value;
    //                                else
    //                                    NxtMgr = NxtManager.UserID;
    //                                status = 4;
    //                            }
    //                            else
    //                            {
    //                                NxtMgr = null;
    //                                status = 2;
    //                            }
    //                            Int32 Createdby = 0;
    //                            if (data.IsManager)
    //                                Createdby = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOERA.CreatedBy).ManagerID.Value;
    //                            else
    //                                Createdby = data.UserID.Value;
    //                            if (data != null && data.EscDays > 0 && (DateTime.Now - objOERA.CreatedDate).Days > data.EscDays)
    //                            {
    //                                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
    //                                SqlCommand Cm = new SqlCommand();
    //                                Cm.Parameters.Clear();
    //                                Cm.CommandType = CommandType.StoredProcedure;
    //                                Cm.CommandText = "SFA_CheckBudget";
    //                                Cm.Parameters.AddWithValue("@ParentID", req.ParentID);
    //                                Cm.Parameters.AddWithValue("@EmpID", req.BudgeterID);
    //                                Cm.Parameters.AddWithValue("@FromDate", DateTime.Now);
    //                                Cm.Parameters.AddWithValue("@ToDate", DateTime.Now);
    //                                DataSet ds = objClass.CommonFunctionForSelect(Cm);
    //                                var OSFBID = Convert.ToInt32(ds.Tables[0].Rows[0][2].ToString());
    //                                SFB1 objSFB1 = ctx.SFB1.FirstOrDefault(x => x.OSFBID == OSFBID && x.TypeID == req.ExpTypeID);

    //                                if (objSFB1 != null)
    //                                {
    //                                    if (objSFB1.AvailableBudget > objOERA.AppAmount)
    //                                    {
    //                                        OEAP objOEAP = new OEAP();
    //                                        objOEAP.OEAPID = OEAPCount++;
    //                                        objOEAP.OERQID = objOERA.OERQID;
    //                                        objOEAP.EmpID = objOERA.EmpID;
    //                                        objOEAP.ParentID = objOERA.ParentID;
    //                                        objOEAP.LevelNo = data.LevelNo;
    //                                        objOEAP.NextManagerID = NxtMgr;
    //                                        objOEAP.AvailBudget = objOERA.AvailBudget;
    //                                        objOEAP.AppAmount = objOERA.AppAmount;
    //                                        objOEAP.PrevAmount = objOERA.PrevAmount;
    //                                        objOEAP.Status = 2;
    //                                        objOEAP.Notes = "Auto Approved";
    //                                        objOEAP.CreatedDate = DateTime.Now;
    //                                        objOEAP.CreatedBy = Createdby;
    //                                        objOEAP.UpdatedDate = DateTime.Now;
    //                                        objOEAP.UpdatedBy = Createdby;

    //                                        objSFB1.UpdatedDate = DateTime.Now;
    //                                        objSFB1.UpdatedBy = Createdby;
    //                                        req.LevelNo = data.LevelNo;
    //                                        req.Status = status;
    //                                        req.NextManagerID = NxtMgr;
    //                                        ctx.OEAPs.Add(objOEAP);
    //                                    }
    //                                }
    //                            }
    //                        }
    //                        else
    //                        {
    //                            //Only Requested, no approval
    //                            OAWRK data = WrkList.FirstOrDefault(x => x.LevelNo == req.LevelNo && x.RequestTypeMenuID == 9120);
    //                            var NxtManager = WrkList.FirstOrDefault(x => x.LevelNo == data.LevelNo + 1 && x.RequestTypeMenuID == 9120);
    //                            int status = 0;
    //                            int? NxtMgr = 0;
    //                            if (NxtManager != null)
    //                            {
    //                                if (NxtManager.IsManager)
    //                                    NxtMgr = ctx.OEMPs.FirstOrDefault(x => x.EmpID == req.EmpID).ManagerID.Value;
    //                                else
    //                                    NxtMgr = NxtManager.UserID;
    //                                status = 4;
    //                            }
    //                            else
    //                            {
    //                                NxtMgr = null;
    //                                status = 2;
    //                            }
    //                            Int32 CreatedBy = 0;
    //                            if (data.IsManager)
    //                                CreatedBy = ctx.OEMPs.FirstOrDefault(x => x.EmpID == req.CreatedBy).ManagerID.Value;
    //                            else
    //                                CreatedBy = data.UserID.Value;
    //                            if (data != null && data.EscDays > 0 && (DateTime.Now - req.ApplicationDate).Days > data.EscDays)
    //                            {
    //                                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
    //                                SqlCommand Cm = new SqlCommand();
    //                                Cm.Parameters.Clear();
    //                                Cm.CommandType = CommandType.StoredProcedure;
    //                                Cm.CommandText = "SFA_CheckBudget";
    //                                Cm.Parameters.AddWithValue("@ParentID", req.ParentID);
    //                                Cm.Parameters.AddWithValue("@EmpID", req.BudgeterID);
    //                                Cm.Parameters.AddWithValue("@FromDate", DateTime.Now);
    //                                Cm.Parameters.AddWithValue("@ToDate", DateTime.Now);
    //                                DataSet ds = objClass.CommonFunctionForSelect(Cm);
    //                                var OSFBID = Convert.ToInt32(ds.Tables[0].Rows[0][2].ToString());
    //                                SFB1 objSFB1 = ctx.SFB1.FirstOrDefault(x => x.OSFBID == OSFBID && x.TypeID == req.ExpTypeID);

    //                                if (objSFB1 != null)
    //                                {
    //                                    if (objSFB1.AvailableBudget > req.ExpAmount)
    //                                    {
    //                                        OEAP objOEAP = new OEAP();
    //                                        objOEAP.OEAPID = OEAPCount++;
    //                                        objOEAP.OERQID = req.OERQID;
    //                                        objOEAP.EmpID = req.EmpID;
    //                                        objOEAP.ParentID = req.ParentID;
    //                                        objOEAP.LevelNo = data.LevelNo;
    //                                        objOEAP.NextManagerID = NxtMgr;
    //                                        objOEAP.AppAmount = req.ExpAmount;
    //                                        objOEAP.PrevAmount = req.ExpAmount;
    //                                        objOEAP.Status = 2;
    //                                        objOEAP.Notes = "Auto Approved";
    //                                        objOEAP.CreatedDate = DateTime.Now;
    //                                        objOEAP.CreatedBy = CreatedBy;
    //                                        objOEAP.UpdatedDate = DateTime.Now;
    //                                        objOEAP.UpdatedBy = CreatedBy;

    //                                        objSFB1.AvailableBudget -= objOEAP.AppAmount;
    //                                        objOEAP.AvailBudget = objSFB1.AvailableBudget;
    //                                        objSFB1.UpdatedDate = DateTime.Now;
    //                                        objSFB1.UpdatedBy = CreatedBy;
    //                                        if (NxtManager == null)
    //                                            req.LevelNo = data.LevelNo;
    //                                        else
    //                                            req.LevelNo = NxtManager.LevelNo;
    //                                        req.Status = status;
    //                                        req.NextManagerID = NxtMgr;
    //                                        ctx.OEAPs.Add(objOEAP);
    //                                    }
    //                                }
    //                            }
    //                        }
    //                    }
    //                    //ctx.SaveChanges();
    //                    sb.Append("{\"Status\":\"1\",\"Error\":\"\",\"Result\":\"Process Completed.\"}");
    //                }
    //                #endregion

    //                #region Asset
    //                if (WrkList.Any(x => x.RequestTypeMenuID == 9112)) //Asset Approval
    //                {
    //                    Name = "Asset";
    //                    List<OASTQ> listOASTQ = ctx.OASTQs.Where(x => new int[] { 1, 4 }.Contains(x.Status)).ToList();
    //                    int OASTPCount = ctx.GetKey("OASTP", "AssetApproveID", "", ParentID, 0).FirstOrDefault().Value;
    //                    foreach (OASTQ req in listOASTQ)
    //                    {
    //                        OASTP objOASTA = ctx.OASTPs.Where(x => x.AsseRequsttID == req.AsseRequsttID && x.ParentID == req.ParentID).OrderByDescending(x => x.LevelNo).FirstOrDefault();
    //                        if (objOASTA != null)
    //                        {
    //                            //Atleast one approval done
    //                            OAWRK data = WrkList.FirstOrDefault(x => x.LevelNo == objOASTA.LevelNo + 1 && x.RequestTypeMenuID == 9112);
    //                            var NxtManager = WrkList.FirstOrDefault(x => x.LevelNo == data.LevelNo + 1 && x.RequestTypeMenuID == 9112);
    //                            int status = 0;
    //                            int? NxtMgr = 0;
    //                            if (NxtManager != null)
    //                            {
    //                                if (NxtManager.IsManager)
    //                                    NxtMgr = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOASTA.EmpID).ManagerID.Value;
    //                                else
    //                                    NxtMgr = data.UserID;
    //                                status = 4;
    //                            }
    //                            else
    //                            {
    //                                NxtMgr = null;
    //                                status = 2;
    //                            }
    //                            Int32 CreatedBy = 0;
    //                            if (data.IsManager)
    //                                CreatedBy = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOASTA.CreatedBy).ManagerID.Value;
    //                            else
    //                                CreatedBy = data.UserID.Value;
    //                            if (data != null && data.EscDays > 0 && (DateTime.Now - objOASTA.CreatedDate).Days > data.EscDays)
    //                            {
    //                                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
    //                                SqlCommand Cm = new SqlCommand();
    //                                Cm.Parameters.Clear();
    //                                Cm.CommandType = CommandType.StoredProcedure;
    //                                Cm.CommandText = "SFA_CheckBudget";
    //                                Cm.Parameters.AddWithValue("@ParentID", req.ParentID);
    //                                Cm.Parameters.AddWithValue("@EmpID", req.BudgeterID);
    //                                Cm.Parameters.AddWithValue("@FromDate", DateTime.Now);
    //                                Cm.Parameters.AddWithValue("@ToDate", DateTime.Now);
    //                                DataSet ds = objClass.CommonFunctionForSelect(Cm);
    //                                var OSFBID = Convert.ToInt32(ds.Tables[0].Rows[0][2].ToString());
    //                                SFB1 objSFB1 = ctx.SFB1.FirstOrDefault(x => x.OSFBID == OSFBID && x.TypeID == req.AssetTypeID);

    //                                if (objSFB1 != null)
    //                                {
    //                                    if (objSFB1.AvailableBudget > objOASTA.AppAmount)
    //                                    {
    //                                        OASTP objOASTP = new OASTP();
    //                                        objOASTP.AssetApproveID = OASTPCount++;
    //                                        objOASTP.AsseRequsttID = objOASTA.AsseRequsttID;
    //                                        objOASTP.EmpID = objOASTA.EmpID;
    //                                        objOASTP.ParentID = objOASTA.ParentID;
    //                                        objOASTP.AssetTypeID = objOASTA.AssetTypeID;
    //                                        objOASTP.AssetSubTypeID = objOASTA.AssetSubTypeID;
    //                                        objOASTP.AssetBrandID = objOASTA.AssetBrandID;
    //                                        objOASTP.AssetSizeID = objOASTA.AssetSizeID;
    //                                        objOASTP.AssetConditionID = objOASTA.AssetConditionID;
    //                                        objOASTP.CustomerID = objOASTA.CustomerID;
    //                                        objOASTP.LevelNo = data.LevelNo;
    //                                        objOASTP.NextManagerID = NxtMgr;
    //                                        objOASTP.AvailBudget = objOASTA.AvailBudget;
    //                                        objOASTP.AppQty = objOASTA.AppQty;
    //                                        objOASTP.AppAmount = objOASTA.AppAmount;
    //                                        objOASTP.PrevAmount = objOASTA.PrevAmount;
    //                                        objOASTP.Status = 2;
    //                                        objOASTP.Remarks = "Auto Approved";
    //                                        objOASTP.CreatedDate = DateTime.Now;
    //                                        objOASTP.CreatedBy = CreatedBy;
    //                                        objOASTP.UpdatedDate = DateTime.Now;
    //                                        objOASTP.UpdatedBy = CreatedBy;

    //                                        objSFB1.UpdatedDate = DateTime.Now;
    //                                        objSFB1.UpdatedBy = CreatedBy;
    //                                        req.LevelNo = data.LevelNo;
    //                                        req.Status = status;
    //                                        req.NextManagerID = NxtMgr;
    //                                        ctx.OASTPs.Add(objOASTP);
    //                                    }
    //                                }
    //                            }
    //                        }
    //                        else
    //                        {
    //                            //Only Requested, no approval
    //                            OAWRK data = WrkList.FirstOrDefault(x => x.LevelNo == req.LevelNo && x.RequestTypeMenuID == 9112);
    //                            var NxtManager = WrkList.FirstOrDefault(x => x.LevelNo == data.LevelNo + 1 && x.RequestTypeMenuID == 9112);
    //                            int status = 0;
    //                            int? NxtMgr = 0;
    //                            if (NxtManager != null)
    //                            {
    //                                if (NxtManager.IsManager)
    //                                    NxtMgr = ctx.OEMPs.FirstOrDefault(x => x.EmpID == req.CreatedBy).ManagerID.Value;
    //                                else
    //                                    NxtMgr = NxtManager.UserID;
    //                                status = 4;
    //                            }
    //                            else
    //                            {
    //                                NxtMgr = null;
    //                                status = 2;
    //                            }
    //                            Int32 CreatedBy = 0;
    //                            if (data.IsManager)
    //                                CreatedBy = ctx.OEMPs.FirstOrDefault(x => x.EmpID == req.CreatedBy).ManagerID.Value;
    //                            else
    //                                CreatedBy = data.UserID.Value;
    //                            if (data != null && data.EscDays > 0 && (DateTime.Now - req.ApplicationDate).Days > data.EscDays)
    //                            {
    //                                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
    //                                SqlCommand Cm = new SqlCommand();
    //                                Cm.Parameters.Clear();
    //                                Cm.CommandType = CommandType.StoredProcedure;
    //                                Cm.CommandText = "SFA_CheckBudget";
    //                                Cm.Parameters.AddWithValue("@ParentID", req.ParentID);
    //                                Cm.Parameters.AddWithValue("@EmpID", req.BudgeterID);
    //                                Cm.Parameters.AddWithValue("@FromDate", DateTime.Now);
    //                                Cm.Parameters.AddWithValue("@ToDate", DateTime.Now);
    //                                DataSet ds = objClass.CommonFunctionForSelect(Cm);
    //                                var OSFBID = Convert.ToInt32(ds.Tables[0].Rows[0][2].ToString());
    //                                SFB1 objSFB1 = ctx.SFB1.FirstOrDefault(x => x.OSFBID == OSFBID && x.TypeID == req.AssetTypeID);

    //                                if (objSFB1 != null)
    //                                {
    //                                    if (objSFB1.AvailableBudget > req.Amount)
    //                                    {
    //                                        OASTP objOASTP = new OASTP();
    //                                        objOASTP.AssetApproveID = OASTPCount++;
    //                                        objOASTP.AsseRequsttID = req.AsseRequsttID;
    //                                        objOASTP.EmpID = req.CreatedBy;
    //                                        objOASTP.ParentID = req.ParentID;
    //                                        objOASTP.AssetTypeID = req.AssetTypeID;
    //                                        objOASTP.AssetSubTypeID = req.AssetSubTypeID;
    //                                        objOASTP.AssetBrandID = req.AssetBrandID;
    //                                        objOASTP.AssetSizeID = req.AssetSizeID;
    //                                        objOASTP.AssetConditionID = req.AssetConditionID;
    //                                        objOASTP.CustomerID = req.CustomerID;
    //                                        objOASTP.LevelNo = data.LevelNo;
    //                                        objOASTP.NextManagerID = NxtMgr;
    //                                        objOASTP.AppAmount = req.Amount;
    //                                        objOASTP.AppQty = req.Qty;
    //                                        objOASTP.PrevAmount = req.Amount;
    //                                        objOASTP.Status = 2;
    //                                        objOASTP.Remarks = "Auto Approved";
    //                                        objOASTP.CreatedDate = DateTime.Now;
    //                                        objOASTP.CreatedBy = CreatedBy;
    //                                        objOASTP.UpdatedDate = DateTime.Now;
    //                                        objOASTP.UpdatedBy = CreatedBy;

    //                                        objSFB1.AvailableBudget -= objOASTP.AppAmount;
    //                                        objOASTP.AvailBudget = objSFB1.AvailableBudget;
    //                                        objSFB1.UpdatedDate = DateTime.Now;
    //                                        objSFB1.UpdatedBy = CreatedBy;
    //                                        if (NxtManager == null)
    //                                            req.LevelNo = data.LevelNo;
    //                                        else
    //                                            req.LevelNo = NxtManager.LevelNo;
    //                                        req.Status = status;
    //                                        req.NextManagerID = NxtMgr;
    //                                        ctx.OASTPs.Add(objOASTP);
    //                                    }
    //                                }
    //                            }
    //                        }
    //                    }
    //                    //ctx.SaveChanges();
    //                    sb.Append("{\"Status\":\"1\",\"Error\":\"\",\"Result\":\"Process Completed.\"}");
    //                }
    //                #endregion

    //                #region Travel
    //                if (WrkList.Any(x => x.RequestTypeMenuID == 9121))
    //                {
    //                    Name = "Travel"; //Travel Approval
    //                    List<OTRQ> listOTRQ = ctx.OTRQs.Where(x => new int[] { 1, 4 }.Contains(x.Status)).ToList();
    //                    int OTAPCount = ctx.GetKey("OTAP", "OTAPID", "", ParentID, 0).FirstOrDefault().Value;
    //                    foreach (OTRQ req in listOTRQ)
    //                    {
    //                        OTAP objOTAA = ctx.OTAPs.Where(x => x.OTRQID == req.OTRQID && x.ParentID == req.ParentID).OrderByDescending(x => x.LevelNo).FirstOrDefault();
    //                        if (objOTAA != null)
    //                        {
    //                            //Atleast one approval done
    //                            OAWRK data = WrkList.FirstOrDefault(x => x.LevelNo == objOTAA.LevelNo + 1 && x.RequestTypeMenuID == 9121);
    //                            var NxtManager = WrkList.FirstOrDefault(x => x.LevelNo == data.LevelNo + 1 && x.RequestTypeMenuID == 9121);
    //                            int status = 0;
    //                            int? NxtMgr = 0;
    //                            if (NxtManager != null)
    //                            {
    //                                if (NxtManager.IsManager)
    //                                    NxtMgr = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOTAA.EmpID).ManagerID.Value;
    //                                else
    //                                    NxtMgr = NxtManager.UserID;
    //                                status = 4;
    //                            }
    //                            else
    //                            {
    //                                NxtMgr = null;
    //                                status = 2;
    //                            }
    //                            Int32 CreatedBy = 0;
    //                            if (data.IsManager)
    //                                CreatedBy = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOTAA.CreatedBy).ManagerID.Value;
    //                            else
    //                                CreatedBy = data.UserID.Value;
    //                            if (data != null && data.EscDays > 0 && (DateTime.Now - objOTAA.CreatedDate).Days > data.EscDays)
    //                            {
    //                                OTAP objOTAP = new OTAP();
    //                                objOTAP.OTAPID = OTAPCount++;
    //                                objOTAP.OTRQID = objOTAA.OTRQID;
    //                                objOTAP.EmpID = objOTAA.EmpID;
    //                                objOTAP.ParentID = objOTAA.ParentID;
    //                                objOTAP.LevelNo = data.LevelNo;
    //                                objOTAP.NextManagerID = NxtMgr;
    //                                objOTAP.AppAmount = objOTAA.AppAmount;
    //                                objOTAP.PrevAmount = objOTAA.PrevAmount;
    //                                objOTAP.Status = 2;
    //                                objOTAP.Notes = "Auto Approved";
    //                                objOTAP.CreatedDate = DateTime.Now;
    //                                objOTAP.CreatedBy = CreatedBy;
    //                                objOTAP.UpdatedDate = DateTime.Now;
    //                                objOTAP.UpdatedBy = CreatedBy;

    //                                req.LevelNo = data.LevelNo;
    //                                req.Status = status;
    //                                req.NextManagerID = NxtMgr;
    //                                ctx.OTAPs.Add(objOTAP);

    //                                #region OAAP

    //                                if (req.InAdvance == true)
    //                                {
    //                                    int OAAPCount = ctx.GetKey("OAAP", "OAAPID", "", ParentID, 0).FirstOrDefault().Value;
    //                                    List<OARQ> listOARQ = ctx.OARQs.Where(x => new int[] { 1, 4 }.Contains(x.Status) && x.OTRQID == req.OTRQID).ToList();
    //                                    foreach (OARQ ADVreq in listOARQ)
    //                                    {
    //                                        OAAP objOARA = ctx.OAAPs.Where(x => x.OARQID == ADVreq.OARQID && x.ParentID == ADVreq.ParentID).OrderByDescending(x => x.LevelNo).FirstOrDefault();
    //                                        //Atleast one approval done
    //                                        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
    //                                        SqlCommand Cm = new SqlCommand();
    //                                        Cm.Parameters.Clear();
    //                                        Cm.CommandType = CommandType.StoredProcedure;
    //                                        Cm.CommandText = "SFA_CheckBudget";
    //                                        Cm.Parameters.AddWithValue("@ParentID", ADVreq.ParentID);
    //                                        Cm.Parameters.AddWithValue("@EmpID", req.BudgeterID);
    //                                        Cm.Parameters.AddWithValue("@FromDate", DateTime.Now);
    //                                        Cm.Parameters.AddWithValue("@ToDate", DateTime.Now);
    //                                        DataSet ds = objClass.CommonFunctionForSelect(Cm);
    //                                        var OSFBID = Convert.ToInt32(ds.Tables[0].Rows[0][2].ToString());
    //                                        SFB1 objSFB1 = ctx.SFB1.FirstOrDefault(x => x.OSFBID == OSFBID && x.TypeID == ADVreq.ExpTypeID);

    //                                        if (objSFB1 != null)
    //                                        {
    //                                            if (objSFB1.AvailableBudget > objOARA.AppAmount)
    //                                            {
    //                                                OAAP objOAAP = new OAAP();
    //                                                objOAAP.OAAPID = OAAPCount++;
    //                                                objOAAP.OARQID = objOARA.OARQID;
    //                                                objOAAP.EmpID = objOARA.EmpID;
    //                                                objOAAP.ParentID = objOARA.ParentID;
    //                                                objOAAP.LevelNo = data.LevelNo;
    //                                                objOAAP.NextManagerID = NxtMgr;
    //                                                objOAAP.AvailBudget = objOARA.AvailBudget;
    //                                                objOAAP.AppAmount = objOARA.AppAmount;
    //                                                objOAAP.PrevAmount = objOARA.PrevAmount;
    //                                                objOAAP.Status = 2;
    //                                                objOAAP.Notes = "Auto Approved";
    //                                                objOAAP.CreatedDate = DateTime.Now;
    //                                                objOAAP.CreatedBy = CreatedBy;
    //                                                objOAAP.UpdatedDate = DateTime.Now;
    //                                                objOAAP.UpdatedBy = CreatedBy;

    //                                                ADVreq.LevelNo = data.LevelNo;
    //                                                ADVreq.Status = status;
    //                                                ADVreq.NextManagerID = NxtMgr;
    //                                                ctx.OAAPs.Add(objOAAP);
    //                                            }
    //                                        }
    //                                    }
    //                                }
    //                                #endregion
    //                            }
    //                        }
    //                        else
    //                        {
    //                            //Only Requested, no approval
    //                            OAWRK data = WrkList.FirstOrDefault(x => x.LevelNo == req.LevelNo && x.RequestTypeMenuID == 9121);
    //                            var NxtManager = WrkList.FirstOrDefault(x => x.LevelNo == data.LevelNo + 1 && x.RequestTypeMenuID == 9121);
    //                            int status = 0;
    //                            int? NxtMgr = 0;
    //                            if (NxtManager != null)
    //                            {
    //                                if (NxtManager.IsManager)
    //                                    NxtMgr = ctx.OEMPs.FirstOrDefault(x => x.EmpID == req.CreatedBy).ManagerID.Value;
    //                                else
    //                                    NxtMgr = NxtManager.UserID;
    //                                status = 4;
    //                            }
    //                            else
    //                            {
    //                                NxtMgr = null;
    //                                status = 2;
    //                            }
    //                            Int32 CreatedBy = 0;
    //                            if (data.IsManager)
    //                                CreatedBy = ctx.OEMPs.FirstOrDefault(x => x.EmpID == req.CreatedBy).ManagerID.Value;
    //                            else
    //                                CreatedBy = data.UserID.Value;
    //                            if (data != null && data.EscDays > 0 && (DateTime.Now - req.ApplicationDate).Days > data.EscDays)
    //                            {
    //                                OTAP objOTAP = new OTAP();
    //                                objOTAP.OTAPID = OTAPCount++;
    //                                objOTAP.OTRQID = req.OTRQID;
    //                                objOTAP.EmpID = req.CreatedBy;
    //                                objOTAP.ParentID = req.ParentID;
    //                                objOTAP.LevelNo = data.LevelNo;
    //                                objOTAP.NextManagerID = NxtMgr;
    //                                objOTAP.AppAmount = req.ReqAmount;
    //                                objOTAP.PrevAmount = req.ReqAmount;
    //                                objOTAP.Status = 2;
    //                                objOTAP.Notes = "Auto Approved";
    //                                objOTAP.CreatedDate = DateTime.Now;
    //                                objOTAP.CreatedBy = CreatedBy;
    //                                objOTAP.UpdatedDate = DateTime.Now;
    //                                objOTAP.UpdatedBy = CreatedBy;

    //                                if (NxtManager == null)
    //                                    req.LevelNo = data.LevelNo;
    //                                else
    //                                    req.LevelNo = NxtManager.LevelNo;
    //                                req.Status = status;
    //                                req.NextManagerID = NxtMgr;
    //                                ctx.OTAPs.Add(objOTAP);

    //                                #region OAAP
    //                                if (req.InAdvance == true)
    //                                {
    //                                    int OAAPCount = ctx.GetKey("OAAP", "OAAPID", "", ParentID, 0).FirstOrDefault().Value;
    //                                    List<OARQ> listOARQ = ctx.OARQs.Where(x => new int[] { 1, 4 }.Contains(x.Status) && x.OTRQID == req.OTRQID).ToList();
    //                                    foreach (OARQ ADVreq in listOARQ)
    //                                    {
    //                                        //Only Requested, no approval

    //                                        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
    //                                        SqlCommand Cm = new SqlCommand();
    //                                        Cm.Parameters.Clear();
    //                                        Cm.CommandType = CommandType.StoredProcedure;
    //                                        Cm.CommandText = "SFA_CheckBudget";
    //                                        Cm.Parameters.AddWithValue("@ParentID", ADVreq.ParentID);
    //                                        Cm.Parameters.AddWithValue("@EmpID", req.BudgeterID);
    //                                        Cm.Parameters.AddWithValue("@FromDate", DateTime.Now);
    //                                        Cm.Parameters.AddWithValue("@ToDate", DateTime.Now);
    //                                        DataSet ds = objClass.CommonFunctionForSelect(Cm);
    //                                        var OSFBID = Convert.ToInt32(ds.Tables[0].Rows[0][2].ToString());
    //                                        SFB1 objSFB1 = ctx.SFB1.FirstOrDefault(x => x.OSFBID == OSFBID && x.TypeID == ADVreq.ExpTypeID);

    //                                        if (objSFB1 != null)
    //                                        {
    //                                            if (objSFB1.AvailableBudget > ADVreq.AdvAmount)
    //                                            {
    //                                                OAAP objOAAP = new OAAP();
    //                                                objOAAP.OAAPID = OAAPCount++;
    //                                                objOAAP.OARQID = ADVreq.OARQID;
    //                                                objOAAP.EmpID = ADVreq.EmpID;
    //                                                objOAAP.ParentID = ADVreq.ParentID;
    //                                                objOAAP.LevelNo = data.LevelNo;
    //                                                objOAAP.NextManagerID = NxtMgr;
    //                                                objOAAP.AvailBudget = objSFB1.AvailableBudget;
    //                                                objOAAP.AppAmount = ADVreq.AdvAmount;
    //                                                objOAAP.PrevAmount = ADVreq.AdvAmount;
    //                                                objOAAP.Status = 2;
    //                                                objOAAP.Notes = "Auto Approved";
    //                                                objOAAP.CreatedDate = DateTime.Now;
    //                                                objOAAP.CreatedBy = CreatedBy;
    //                                                objOAAP.UpdatedDate = DateTime.Now;
    //                                                objOAAP.UpdatedBy = CreatedBy;

    //                                                if (NxtManager == null)
    //                                                    req.LevelNo = data.LevelNo;
    //                                                else
    //                                                    req.LevelNo = NxtManager.LevelNo;
    //                                                ADVreq.Status = status;
    //                                                ADVreq.NextManagerID = NxtMgr;
    //                                                ctx.OAAPs.Add(objOAAP);
    //                                            }
    //                                        }
    //                                    }
    //                                }
    //                                #endregion
    //                            }
    //                        }
    //                    }
    //                    //ctx.SaveChanges();
    //                    sb.Append("{\"Status\":\"1\",\"Error\":\"\",\"Result\":\"Process Completed.\"}");
    //                }
    //                #endregion

    //                #region Leave
    //                if (WrkList.Any(x => x.RequestTypeMenuID == 9114)) //Leave Approval
    //                {
    //                    Name = "Leave";
    //                    List<OLVRQ> listOLVRQ = ctx.OLVRQs.Where(x => new int[] { 1, 4 }.Contains(x.Status)).ToList();
    //                    int OLVAPCount = ctx.GetKey("OLVAP", "OLVAPID", "", ParentID, 0).FirstOrDefault().Value;
    //                    foreach (OLVRQ req in listOLVRQ)
    //                    {
    //                        OLVBL objOLVBL = ctx.OLVBLs.FirstOrDefault(x => x.ParentID == req.ParentID && x.EmpID == req.EmpID && x.LeaveTypeID == req.LeaveTypeID);
    //                        OLVAP objOLVRA = ctx.OLVAPs.Where(x => x.LeaveReqID == req.LeaveReqID && x.ParentID == req.ParentID).OrderByDescending(x => x.LevelNo).FirstOrDefault();
    //                        if (objOLVRA != null)
    //                        {
    //                            //Atleast one approval done
    //                            OAWRK data = WrkList.FirstOrDefault(x => x.LevelNo == objOLVRA.LevelNo + 1 && x.RequestTypeMenuID == 9114);
    //                            var NxtManager = WrkList.FirstOrDefault(x => x.LevelNo == data.LevelNo + 1 && x.RequestTypeMenuID == 9114);
    //                            int status = 0;
    //                            int? NxtMgr = 0;
    //                            if (NxtManager != null)
    //                            {
    //                                if (NxtManager.IsManager)
    //                                    NxtMgr = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOLVRA.EmpID).ManagerID.Value;
    //                                else
    //                                    NxtMgr = data.UserID;
    //                                status = 4;
    //                            }
    //                            else
    //                            {
    //                                NxtMgr = null;
    //                                status = 2;
    //                            }
    //                            Int32 CreatedBy = 0;
    //                            if (data.IsManager)
    //                                CreatedBy = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOLVRA.CreatedBy).ManagerID.Value;
    //                            else
    //                                CreatedBy = data.UserID.Value;
    //                            if (data != null && data.EscDays > 0 && (DateTime.Now - objOLVRA.CreatedDate).Days > data.EscDays)
    //                            {
    //                                OLVAP objOLVAP = new OLVAP();
    //                                objOLVAP.OLVAPID = OLVAPCount++;
    //                                objOLVAP.LeaveReqID = objOLVRA.LeaveReqID;
    //                                objOLVAP.EmpID = objOLVRA.EmpID;
    //                                objOLVAP.ParentID = objOLVRA.ParentID;
    //                                objOLVAP.ManagerID = objOLVRA.ManagerID;
    //                                objOLVRA.LeaveTypeID = objOLVRA.LeaveTypeID;
    //                                objOLVAP.NoOfDays = objOLVRA.NoOfDays;
    //                                objOLVAP.LevelNo = data.LevelNo;
    //                                objOLVAP.NextManagerID = NxtMgr;
    //                                objOLVAP.Status = 2;
    //                                objOLVAP.Notes = "Auto Approved";
    //                                objOLVAP.CreatedDate = DateTime.Now;
    //                                objOLVAP.CreatedBy = CreatedBy;
    //                                objOLVAP.UpdatedDate = DateTime.Now;
    //                                objOLVAP.UpdatedBy = CreatedBy;

    //                                objOLVBL.UpdatedDate = DateTime.Now;
    //                                objOLVBL.UpdatedBy = CreatedBy;
    //                                req.LevelNo = data.LevelNo;
    //                                req.Status = status;
    //                                req.NextManagerID = NxtMgr;
    //                                ctx.OLVAPs.Add(objOLVAP);
    //                            }
    //                        }
    //                        else
    //                        {
    //                            //Only Requested, no approval
    //                            OAWRK data = WrkList.FirstOrDefault(x => x.LevelNo == req.LevelNo && x.RequestTypeMenuID == 9114);
    //                            var NxtManager = WrkList.FirstOrDefault(x => x.LevelNo == data.LevelNo + 1 && x.RequestTypeMenuID == 9114);
    //                            int status = 0;
    //                            int? NxtMgr = 0;
    //                            if (NxtManager != null)
    //                            {
    //                                if (NxtManager.IsManager)
    //                                    NxtMgr = ctx.OEMPs.FirstOrDefault(x => x.EmpID == req.EmpID).ManagerID.Value;
    //                                else
    //                                    NxtMgr = NxtManager.UserID;
    //                                status = 4;
    //                            }
    //                            else
    //                            {
    //                                NxtMgr = null;
    //                                status = 2;
    //                            }
    //                            Int32 CreatedBy = 0;
    //                            if (data.IsManager)
    //                                CreatedBy = ctx.OEMPs.FirstOrDefault(x => x.EmpID == req.CreatedBy).ManagerID.Value;
    //                            else
    //                                CreatedBy = data.UserID.Value;
    //                            if (data != null && data.EscDays > 0 && (DateTime.Now - req.CreatedDate).Days > data.EscDays)
    //                            {
    //                                OLVAP objOLVAP = new OLVAP();
    //                                objOLVAP.OLVAPID = OLVAPCount++;
    //                                objOLVAP.LeaveReqID = req.LeaveReqID;
    //                                objOLVAP.EmpID = req.EmpID;
    //                                objOLVAP.ParentID = req.ParentID;
    //                                objOLVAP.LevelNo = data.LevelNo;
    //                                objOLVAP.ManagerID = ctx.OEMPs.FirstOrDefault(x => x.EmpID == req.CreatedBy).ManagerID.Value;
    //                                objOLVAP.LeaveTypeID = req.LeaveTypeID;
    //                                objOLVAP.NoOfDays = req.NoOfDays;
    //                                objOLVAP.NextManagerID = NxtMgr;
    //                                objOLVAP.Status = 2;
    //                                objOLVAP.Notes = "Auto Approved";
    //                                objOLVAP.CreatedDate = DateTime.Now;
    //                                objOLVAP.CreatedBy = CreatedBy;
    //                                objOLVAP.UpdatedDate = DateTime.Now;
    //                                objOLVAP.UpdatedBy = CreatedBy;

    //                                objOLVBL.LeaveBalance -= req.NoOfDays;
    //                                objOLVBL.UpdatedDate = DateTime.Now;
    //                                objOLVBL.UpdatedBy = CreatedBy;
    //                                if (NxtManager == null)
    //                                    req.LevelNo = data.LevelNo;
    //                                else
    //                                    req.LevelNo = NxtManager.LevelNo;
    //                                req.Status = status;
    //                                req.NextManagerID = NxtMgr;
    //                                ctx.OLVAPs.Add(objOLVAP);
    //                            }
    //                        }
    //                    }
    //                    //ctx.SaveChanges();
    //                    sb.Append("{\"Status\":\"1\",\"Error\":\"\",\"Result\":\"Process Completed.\"}");
    //                }
    //                #endregion
    //            }
    //        }
    //        catch (Exception ex)
    //        {
    //            TraceService(FileName, ex.Message);
    //        }
    //    }
    //}
}
