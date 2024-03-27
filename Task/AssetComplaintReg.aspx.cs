using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Task_AssetComplaintReg : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            ddlProbType.Items.Clear();
            ddlProbType.DataSource = null;
            ddlProbType.DataBind();
            txtTaskDate.Text = "Task Date : " + DateTime.Now.ToString("dd/MM/yyyy");
            var ProbType = ctx.OPLMs.Where(x => x.Active).ToList();
            ddlProbType.DataSource = ProbType;
            ddlProbType.DataBind();
            ddlProbType.Items.Insert(0, new ListItem("---Select---", ""));

            var EmpList = (from a in ctx.OEMPs.Where(x => x.Active && x.ParentID == ParentID && x.OGRP.EmpGroupDesc == "RSD")//TODO Manual Grp Specified
                           join b in ctx.OCSTs on a.EMP1.FirstOrDefault().StateID equals b.StateID into f
                           from dpem in f.DefaultIfEmpty()
                           select new
                           {
                               a.EmpID,
                               Emp = a.Name + " # " + a.EmpCode + " # " + dpem.StateName
                           }).ToList();

            ddlEmpList.Text = ddlEmpVerList.Text = txtAssetNo.Text = txtIdentifier.Text = txtModelNo.Text = txtType.Text = txtSize.Text = txtBrand.Text = txtCustCode.Text = txtCustAdd.Text = txtCustAdd2.Text = txtContactP.Text = txtLocation.Text =
            txtCity.Text = txtState.Text = txtRSDLocation.Text = txtPhone1.Text = txtPhone2.Text = txtEmail.Text = ddlUnderWrnty.SelectedValue = ddlUnderWrnty.Text = txtWrntyDate.Text =
            txtRemarks.Text = txtProbRemark.Text = txtTaskName.Text = txtDueDate.Text = txtDueTime.Text = "";
            txtAssetCode.Text = txtInCustAdd.Text = txtInCustAdd2.Text = txtCustGrp.Text = txtInCustGrp.Text = txtContactP.Text = txtInLocation.Text = txtInCity.Text = txtInState.Text = txtInPhone1.Text = txtInPhone2.Text = txtInEmail.Text = "";
            hdnTab1Btn.Value = "0";
        }
        hfTab.Value = "tabs-1";
    }

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                int CustType = Convert.ToInt32(Session["Type"]);
                var UserType = Session["UserType"].ToString();
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                int menuid = ctx.OMNUs.FirstOrDefault(x => x.PageName == pagename && (UserType == "b" ? true : x.MenuType == UserType)).MenuID;
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.MenuID == menuid && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    AuthType = Auth.AuthorizationType;
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
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region ButtonClick

    protected void btnGo_Click(object sender, EventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(txtAssetSerialNo.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Search for Asset.!',3);", true);
                return;
            }
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (!ctx.OASTs.Any(x => x.SerialNumber == txtAssetSerialNo.Text))
                {
                    ClearAllInputs();
                    txtAssetSerialNo.Text = "";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Search proper Asset.!',3);", true);
                    return;
                }
            }

            ClearAllInputs();
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetAssetDetail";
            Cm.Parameters.AddWithValue("@SerialNumber", txtAssetSerialNo.Text);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    txtAssetCode.Text = ds.Tables[0].Rows[0][0].ToString();
                    txtAssetNo.Text = ds.Tables[0].Rows[0][1].ToString();
                    txtIdentifier.Text = ds.Tables[0].Rows[0][2].ToString();
                    txtModelNo.Text = ds.Tables[0].Rows[0][3].ToString();
                    txtType.Text = ds.Tables[0].Rows[0][4].ToString();
                    txtSize.Text = ds.Tables[0].Rows[0][5].ToString();
                    txtBrand.Text = ds.Tables[0].Rows[0][6].ToString();
                    txtCustCode.Text = ds.Tables[0].Rows[0][7].ToString();
                    txtCustAdd.Text = ds.Tables[0].Rows[0][8].ToString();
                    txtLocation.Text = ds.Tables[0].Rows[0][9].ToString();

                    txtCity.Text = ds.Tables[0].Rows[0][10].ToString();
                    txtState.Text = ds.Tables[0].Rows[0][11].ToString();
                    txtRSDLocation.Text = ds.Tables[0].Rows[0][12].ToString();
                    txtPhone1.Text = ds.Tables[0].Rows[0][13].ToString();
                    txtPhone2.Text = ds.Tables[0].Rows[0][14].ToString();
                    txtEmail.Text = ds.Tables[0].Rows[0][15].ToString();
                    ddlUnderWrnty.SelectedValue = ds.Tables[0].Rows[0][17].ToString();
                    txtWrntyDate.Text = ds.Tables[0].Rows[0][18].ToString();
                    ddlEmpList.Text = ds.Tables[0].Rows[0][20].ToString();
                    ddlEmpVerList.Text = ds.Tables[0].Rows[0][20].ToString();
                    txtCustAdd2.Text = ds.Tables[0].Rows[0][21].ToString();
                    txtContactP.Text = ds.Tables[0].Rows[0][22].ToString();
                    txtCustGrp.Text = ds.Tables[0].Rows[0][23].ToString();

                    hdnTab1Btn.Value = "0";
                    hfTab.Value = "tabs-1";
                }
            }
            if (string.IsNullOrEmpty(txtCustCode.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('There is no customer found with this asset!',3);", true);
                ClearAllInputs();
                return;
            }
        }
        catch (Exception ex)
        {
            throw;
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        hfTab.Value = "tabs-2";
        hdnTab1Btn.Value = "1";

        txtInCustCode.Text = txtCustCode.Text;
        txtInCustAdd.Text = txtCustAdd.Text;
        txtInCustAdd2.Text = txtCustAdd2.Text;
        txtInContactP.Text = txtContactP.Text;
        txtInLocation.Text = txtLocation.Text;
        txtInCity.Text = txtCity.Text;
        txtInState.Text = txtState.Text;
        txtInPhone1.Text = txtPhone1.Text;
        txtInPhone2.Text = txtPhone2.Text;
        txtInEmail.Text = txtEmail.Text;
        txtInCustGrp.Text = txtCustGrp.Text;
        txtInCustCode.Enabled = false;
        txtInCustAdd.Enabled = false;
        txtInCustAdd2.Enabled = false;
        txtInContactP.Enabled = false;
        txtInLocation.Enabled = false;
        txtInCity.Enabled = false;
        txtInState.Enabled = false;
        txtInPhone1.Enabled = false;
        txtInPhone2.Enabled = false;
        txtInEmail.Enabled = false;

        using (DDMSEntities ctx = new DDMSEntities())
        {
            Int32 ProbId = Int32.TryParse(ddlProbType.SelectedValue, out ProbId) ? ProbId : 0;
            Int64 ResolveMins = ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId) != null ? ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId).InCityMins.GetValueOrDefault(0) : 0;
            txtDueDate.Text = DateTime.Now.AddMinutes(ResolveMins).ToString("dd/MM/yyyy");
            txtDueTime.Text = DateTime.Now.AddMinutes(ResolveMins).ToString("HH:mm");
        }

        txtInCustCode.Style.Remove("background-color");
        txtInCity.Style.Remove("background-color");
        txtInState.Style.Remove("background-color");
        txtTaskName.Text = "BreakDown Task for " + (!string.IsNullOrEmpty(txtInCustCode.Text) ? txtInCustCode.Text.Split("-".ToArray())[1].Trim() : "");
    }

    protected void btnConflict_Click(object sender, EventArgs e)
    {
        hfTab.Value = "tabs-2";
        hdnTab1Btn.Value = "2";

        if (string.IsNullOrEmpty(txtRemarks.Text))
        {
            hfTab.Value = "tabs-1";
            return;
        }

        txtInCustCode.Text = "";
        txtInCustAdd.Text = "";
        txtInCustAdd2.Text = "";
        txtInContactP.Text = "";
        txtInLocation.Text = "";
        txtInCity.Text = "";
        txtInState.Text = "";
        txtInPhone1.Text = "";
        txtInPhone2.Text = "";
        txtInEmail.Text = "";

        txtInCustCode.Enabled = true;
        txtInCustAdd.Enabled = true;
        txtInCustAdd2.Enabled = true;
        txtInContactP.Enabled = true;
        txtInLocation.Enabled = true;
        txtInCity.Enabled = true;
        txtInState.Enabled = true;
        txtInPhone1.Enabled = true;
        txtInPhone2.Enabled = true;
        txtInEmail.Enabled = true;

        using (DDMSEntities ctx = new DDMSEntities())
        {
            Int32 ProbId = Int32.TryParse(ddlProbType.SelectedValue, out ProbId) ? ProbId : 0;
            Int64 ResolveMins = ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId) != null ? ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId).InCityMins.GetValueOrDefault(0) : 0;
            txtDueDate.Text = DateTime.Now.AddMinutes(ResolveMins).ToString("dd/MM/yyyy");
            txtDueTime.Text = DateTime.Now.AddMinutes(ResolveMins).ToString("HH:mm");
        }
        txtInCustCode.Style.Add("background-color", "rgb(250, 255, 189);");
        txtInCity.Style.Add("background-color", "rgb(250, 255, 189);");
        txtInState.Style.Add("background-color", "rgb(250, 255, 189);");
        txtTaskName.Text = "";
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            Decimal CustomerID = 0;
            Decimal ScanCustomerID = 0;

            if (string.IsNullOrEmpty(txtTaskName.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Task Name is mandatory!',3);", true);
                return;
            }
            if (string.IsNullOrEmpty(ddlEmpList.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Assign Mechanic not found for following asset!',3);", true);
                return;
            }
            if (string.IsNullOrEmpty(ddlEmpVerList.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Assign Mechanic not found for following asset!',3);", true);
                return;
            }
            if (string.IsNullOrEmpty(txtDueDate.Text) || string.IsNullOrEmpty(txtDueTime.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Due Date and Time are mandatory!',3);", true);
                return;
            }
            CustomerID = Decimal.TryParse(txtInCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
            ScanCustomerID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out ScanCustomerID) ? ScanCustomerID : 0;

            if (hdnTab1Btn.Value == "2")
            {
                if ((string.IsNullOrEmpty(txtProbRemark.Text) || string.IsNullOrEmpty(txtRemarks.Text)))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('In Case Of Conflict Both Remarks are mandatory!',3);", true);
                    return;
                }
                if (string.IsNullOrEmpty(txtInCustCode.Text) || string.IsNullOrEmpty(txtInCustAdd.Text) || string.IsNullOrEmpty(txtInCity.Text) || string.IsNullOrEmpty(txtInState.Text) || string.IsNullOrEmpty(txtInPhone1.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('In this Case Of Conflict Please Fill Proper Customer Detail. Such as Phone,State,City,Address',3);", true);
                    return;
                }
                if (CustomerID == ScanCustomerID)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('In Case Of Conflict, Conflict and Confirm customer cannot be same!',3);", true);
                    return;
                }
            }

            using (DDMSEntities ctx = new DDMSEntities())
            {
                Int32 CityID = Int32.TryParse(txtInCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
                Int32 StateID = Int32.TryParse(txtInState.Text.Split("-".ToArray()).Last().Trim(), out StateID) ? StateID : 0;
                Int32 AssetID = ctx.OASTs.FirstOrDefault(x => x.SerialNumber == txtAssetSerialNo.Text && (x.PlantSection != "SCR" && x.PlantSection != "WOF")).AssetID;

                int AssignEmp = Int32.TryParse(ddlEmpList.Text.Split("#".ToArray()).Last().Trim(), out AssignEmp) ? AssignEmp : 0;
                if (AssetID > 0)
                {
                    if (AssignEmp > 0)
                    {
                        if (ctx.OEMPs.Count(x => x.ParentID == ParentID && x.EmpID == UserID && !x.IsAdmin) > 0)
                        {
                            if (!ctx.EmployeeList(ParentID, UserID).ToList().Select(x => x.EmpID).Contains(AssignEmp))
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This asset was not linked with Login User',3);", true);
                                return;
                            }
                        }
                        OTASK objOTASK = new OTASK();
                        objOTASK.TaskTypeID = 2;
                        objOTASK.TaskName = txtTaskName.Text;
                        objOTASK.TaskRemarks = txtRemarks.Text;
                        objOTASK.CustomerID = CustomerID;
                        objOTASK.ConflictCustomerID = ScanCustomerID;
                        objOTASK.CustAddress = txtInCustAdd.Text + ", " + txtInCustAdd2.Text;
                        objOTASK.CustLocation = txtInLocation.Text;
                        objOTASK.CustCityID = CityID;
                        objOTASK.CustStateID = StateID;
                        objOTASK.CountryID = 1;
                        objOTASK.CustPhone1 = txtInPhone1.Text;
                        objOTASK.CustPhone2 = txtInPhone2.Text;
                        objOTASK.CustEmail = txtInEmail.Text;
                        objOTASK.IsConflict = hdnTab1Btn.Value == "2" ? true : false;
                        objOTASK.AssignEmpID = AssignEmp;
                        objOTASK.TaskStatusID = 1;
                        objOTASK.IsCompleted = false;
                        objOTASK.TaskDate = DateTime.Now.Date;
                        objOTASK.TaskTime = DateTime.Now.TimeOfDay;
                        objOTASK.DueDate = Convert.ToDateTime(txtDueDate.Text);
                        objOTASK.DueTime = TimeSpan.Parse(txtDueTime.Text);
                        objOTASK.AssetID = AssetID;
                        objOTASK.ProblemID = Convert.ToInt16(ddlProbType.SelectedValue);
                        objOTASK.ProblemRemarks = txtProbRemark.Text;
                        if (!string.IsNullOrEmpty(txtWrntyDate.Text))
                        {
                            objOTASK.UnderWarranty = ddlUnderWrnty.SelectedValue == "1" ? true : false;
                            objOTASK.WarrantyEndDate = Convert.ToDateTime(txtWrntyDate.Text);
                        }
                        else
                            objOTASK.UnderWarranty = false;

                        objOTASK.TaskCreatedFromID = 3;
                        objOTASK.CityFlag = ddlCityFlag.SelectedValue == "1" ? true : false;
                        objOTASK.IsAuto = false;
                        objOTASK.CreatedBy = UserID;
                        objOTASK.CreatedDate = DateTime.Now;
                        objOTASK.UpdatedBy = UserID;
                        objOTASK.UpdatedDate = DateTime.Now;
                        ctx.OTASKs.Add(objOTASK);

                        TASK1 objTASK1 = new TASK1();
                        objTASK1.TaskID = objOTASK.TaskID;
                        objTASK1.TaskStatusID = 1;
                        objTASK1.LevelNo = 1;
                        objTASK1.FromEmpID = UserID;
                        objTASK1.CustomerID = objOTASK.CustomerID;
                        objTASK1.ToEmpID = objOTASK.AssignEmpID;
                        objTASK1.TaskCreatedFromID = objOTASK.TaskCreatedFromID;
                        objTASK1.ReasonID = null;
                        objTASK1.Remarks = objOTASK.TaskRemarks;
                        objTASK1.CreatedDate = DateTime.Now.Date;
                        objTASK1.CreatedTime = DateTime.Now.TimeOfDay;
                        objTASK1.Createdby = UserID;
                        ctx.TASK1.Add(objTASK1);

                        ctx.SaveChanges();
                        var CustData = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == objOTASK.CustomerID);
                        if (objOTASK != null) //Notification
                        {
                            string body = "BM Task # " + objOTASK.TaskCode + " # " + objOTASK.TaskName +
                                " created from DMS for Serial Number # " + objOTASK.OAST.SerialNumber + " for Date & Time " +
                                Common.DateTimeConvert(objOTASK.DueDate) + " : " + DateTime.Today.Add(objOTASK.DueTime).ToString("hh:mm tt") + " for Customer "
                                + CustData.CustomerCode + " # " + CustData.CustomerName;
                            string title = "BM Task # " + objOTASK.TaskCode;

                            Thread t = new Thread(() => { Service.SendNotificationFlow(5003, objOTASK.AssignEmpID, 1000010000000000, body, title, 0); });
                            t.Name = Guid.NewGuid().ToString();
                            t.Start();
                        }

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Process Completed Successfully And Task Number is :" + objOTASK.TaskCode + "',1);", true);
                        ClearAllInputs();

                        //For E-Mail
                        if (objOTASK.UnderWarranty == true)
                        {
                            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                            SqlCommand Cm = new SqlCommand();
                            Cm.Parameters.Clear();
                            Cm.CommandType = CommandType.StoredProcedure;
                            Cm.CommandText = "Mech_WarrantyComplaint";
                            Cm.Parameters.AddWithValue("@TaskID", objOTASK.TaskID);
                            DataSet ds = objClass.CommonFunctionForSelect(Cm);
                            DataTable dt = ds.Tables[0];
                            if (ds.Tables.Count > 0)
                            {
                                StringBuilder sb = new StringBuilder();
                                for (int i = 0; i < dt.Rows.Count; i++)
                                {
                                    for (int j = 0; j < dt.Columns.Count; j++)
                                    {
                                        sb.Append(dt.Rows[i][j].ToString().Replace(",", "") + ",");
                                    }
                                    sb.Append("\r\n");
                                }

                                string FileName = "WarrantyComplaint_" + ds.Tables[1].Rows[0][0].ToString() + ".csv";
                                string fullPath = Path.Combine(Server.MapPath("~/Document/WarrantyComplaint"), FileName);
                                if (!Directory.Exists(Server.MapPath("~/Document/WarrantyComplaint")))
                                    Directory.CreateDirectory(Server.MapPath("~/Document/WarrantyComplaint"));

                                FileStream fs = new FileStream(fullPath, FileMode.OpenOrCreate, FileAccess.Write);
                                StreamWriter sw = new StreamWriter(fs);
                                sw.BaseStream.Seek(0, SeekOrigin.End);
                                sw.WriteLine(sb.ToString());
                                sw.Close();

                                List<string> Attachments = new List<string>();
                                Attachments.Add(fullPath);
                                try
                                {
                                    Common.SendMail("Auto Warranty Complaint Mail", "Please Find Attachment with list of warranty Complaint with mentioned customers", ds.Tables[1].Rows[0][1].ToString(), "", Attachments, null);
                                }
                                catch (Exception ex)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
                                }
                                finally
                                {
                                    FileInfo fi = new FileInfo(fullPath);
                                    fi.Delete();
                                }
                            }
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Please select Mechanic Employee with Selected Asset',3);", true);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('This asset is Scrap or Write-Off',3);", true);
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
        txtAssetSerialNo.Text = "";
    }

    #endregion

    #region TextChangeEvent

    protected void txtInCity_TextChanged(object sender, EventArgs e)
    {
        try
        {
            int CityID = Int32.TryParse(txtInCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
            if (CityID > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var state = ctx.OCTies.Include("OCST").Include("OCST.OCRY").FirstOrDefault(x => x.CityID == CityID);

                    if (state.OCST != null && !string.IsNullOrEmpty(state.OCST.StateID.ToString()))
                    {
                        var Data = ctx.OCSTs.Where(x => x.StateID == state.OCST.StateID).Select(x => new { x.StateDesc, x.StateName, x.StateID }).FirstOrDefault();
                        txtInState.Text = Data.StateDesc + " - " + Data.StateName + " - " + Data.StateID;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtInCity.Focus();
        hfTab.Value = "tabs-2";
    }

    protected void ddlProbType_SelectedIndexChanged(object sender, EventArgs e)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            Int32 ProbId = Int32.TryParse(ddlProbType.SelectedValue, out ProbId) ? ProbId : 0;
            Int64 ResolveMins = 0;
            if (ddlCityFlag.SelectedValue == "1")
                ResolveMins = ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId) != null ? ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId).InCityMins.GetValueOrDefault(0) : ResolveMins;
            else if (ddlCityFlag.SelectedValue == "0")
                ResolveMins = ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId) != null ? ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId).OutCityMins.GetValueOrDefault(0) : ResolveMins;

            txtDueDate.Text = DateTime.Now.AddMinutes(ResolveMins).ToString("dd/MM/yyyy");
            txtDueTime.Text = DateTime.Now.AddMinutes(ResolveMins).ToString("HH:mm");
        }
    }

    protected void ddlCityFlag_SelectedIndexChanged(object sender, EventArgs e)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            Int32 ProbId = Int32.TryParse(ddlProbType.SelectedValue, out ProbId) ? ProbId : 0;
            Int64 ResolveMins = 0;
            if (ddlCityFlag.SelectedValue == "1")
                ResolveMins = ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId) != null ? ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId).InCityMins.GetValueOrDefault(0) : ResolveMins;
            else if (ddlCityFlag.SelectedValue == "0")
                ResolveMins = ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId) != null ? ctx.OPLMs.FirstOrDefault(x => x.ProblemID == ProbId).OutCityMins.GetValueOrDefault(0) : ResolveMins;

            txtDueDate.Text = DateTime.Now.AddMinutes(ResolveMins).ToString("dd/MM/yyyy");
            txtDueTime.Text = DateTime.Now.AddMinutes(ResolveMins).ToString("hh:mm");
        }
    }

    protected void txtInCustCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (txtInCustCode.Text.Split("-".ToArray()).Length == 3)
            {
                string CustID = txtInCustCode.Text.Split("-".ToArray())[2].Trim();

                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();
                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "GetCustDetail";
                Cm.Parameters.AddWithValue("@CustID", CustID);
                DataSet ds = objClass.CommonFunctionForSelect(Cm);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        txtInCustAdd.Text = ds.Tables[0].Rows[0][0].ToString();
                        txtInLocation.Text = ds.Tables[0].Rows[0][1].ToString();
                        txtInCity.Text = ds.Tables[0].Rows[0][2].ToString();
                        txtInState.Text = ds.Tables[0].Rows[0][3].ToString();
                        txtInPhone1.Text = ds.Tables[0].Rows[0][5].ToString();
                        txtInPhone2.Text = ds.Tables[0].Rows[0][6].ToString();
                        txtInEmail.Text = ds.Tables[0].Rows[0][7].ToString();
                        txtInCustAdd2.Text = ds.Tables[0].Rows[0][9].ToString();
                        txtInContactP.Text = ds.Tables[0].Rows[0][10].ToString();
                        txtInCustGrp.Text = ds.Tables[0].Rows[0][11].ToString();

                        txtTaskName.Text = "BreakDown Task for " + (!string.IsNullOrEmpty(txtInCustCode.Text) ? txtInCustCode.Text.Split("-".ToArray())[1].Trim() : "");
                    }
                }

                hfTab.Value = "tabs-2";
            }
        }
        catch (Exception ex)
        {
            throw;
        }
    }

    #endregion

    protected void txtAssetSerialNo_TextChanged(object sender, EventArgs e)
    {

    }
}