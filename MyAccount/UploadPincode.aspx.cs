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

public partial class MyAccount_UploadPincode : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected string MainDir;
    protected String AuthType;
    DDMSEntities ctx;
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
        else
        {
            Response.Redirect("~/Login.aspx");
        }

    }

    #endregion

    #region Pageload
    protected void Page_Load(object sender, EventArgs e)
    {
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(btnCUpload);
        ValidateUser();
    }
    #endregion

    #region TransferCreateCSV
    public static void TransferCreateCSV(string filePath, DataTable dt, DataRow[] drs)
    {
        StreamWriter sw = null;
        int iColCount = dt.Columns.Count;
        if (!File.Exists(filePath))
        {
            sw = new StreamWriter(filePath, false);

            for (int i = 0; i < iColCount; i++)
            {
                sw.Write(dt.Columns[i]);
                if (i < iColCount - 1)
                {
                    sw.Write(",");
                }
            }
            sw.Write(sw.NewLine);
        }
        else
            sw = new StreamWriter(filePath, true);

        foreach (DataRow dr in drs)
        {
            for (int i = 0; i < iColCount; i++)
            {
                if (!Convert.IsDBNull(dr[i]))
                {
                    sw.Write(dr[i].ToString());
                }
                if (i < iColCount - 1)
                {
                    sw.Write(",");
                }
            }
            sw.Write(sw.NewLine);
        }
        sw.Close();
    }
    #endregion

    #region TransferCSVToTable
    public static void TransferCSVToTable(string filePath, DataTable dt)
    {
        try
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
        catch (Exception ex)
        {

        }
    }
    #endregion

    #region ButtonClick
    protected void btnCUpload_Click(object sender, EventArgs e)
    {
        string logfile = Server.MapPath("~/Document/UploadedFiles/Log.txt");
        try
        {
            if (flCUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flCUpload.PostedFile.FileName));
                flCUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flCUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtPOH = new DataTable();
                    DataTable dtErrPOH = new DataTable();
                    DataTable dtSucPOH = new DataTable();
                    TransferCSVToTable(fileName, dtPOH);

                    if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                    {
                        var machineSettings = (System.Transactions.Configuration.MachineSettingsSection)ConfigurationManager.GetSection("system.transactions/machineSettings");
                        //Allow modifications
                        var bReadOnly = (typeof(ConfigurationElement)).GetField("_bReadOnly", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                        bReadOnly.SetValue(machineSettings, false);
                        //Change max allowed timeout
                        machineSettings.MaxTimeout = TimeSpan.MaxValue;

                        using (var tx = new TransactionScope(TransactionScopeOption.Required, new TimeSpan(1, 0, 0)))
                        {
                            int CityCntID = ctx.GetKey("OCTY", "CityID", "", 0, 0).FirstOrDefault().Value;
                            int StateID = ctx.GetKey("OCST", "StateID", "", 0, 0).FirstOrDefault().Value;

                            int cnt = 0;
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                if (cnt > dtPOH.Rows.Count)
                                    break;
                                try
                                {
                                    OCTY objOCTY = null;
                                    OCST objOSCT = null;
                                    OPIN objOPIN = null;
                                    if (!String.IsNullOrEmpty(item["State"].ToString()))
                                    {
                                        var StateName = item["State"].ToString().ToUpper();
                                        objOSCT = ctx.OCSTs.FirstOrDefault(x => x.StateName.Contains(StateName));
                                        if (objOSCT == null)
                                        {
                                            objOSCT = new OCST();
                                            objOSCT.StateID = StateID++;
                                            objOSCT.CountryID = 1;
                                            objOSCT.StateName = item["State"].ToString().ToUpper();
                                            objOSCT.CreatedDate = DateTime.Now;
                                            objOSCT.CreatedBy = UserID;
                                            objOSCT.UpdatedDate = DateTime.Now;
                                            objOSCT.UpdatedBy = UserID;
                                            objOSCT.Active = true;
                                            ctx.OCSTs.Add(objOSCT);
                                        }

                                    }

                                    if (!String.IsNullOrEmpty(item["City"].ToString()))
                                    {
                                        var Cityname = item["City"].ToString().ToUpper();
                                        objOCTY = ctx.OCTies.FirstOrDefault(x => x.CityName.Contains(Cityname));
                                        if (objOCTY == null)
                                        {
                                            objOCTY = new OCTY();
                                            objOCTY.CityID = CityCntID++;
                                            objOCTY.StateID = objOSCT.StateID;
                                            objOCTY.CityName = item["City"].ToString().ToUpper();
                                            objOCTY.CreatedDate = DateTime.Now;
                                            objOCTY.CreatedBy = UserID;
                                            objOCTY.UpdatedDate = DateTime.Now;
                                            objOCTY.UpdatedBy = UserID;
                                            objOCTY.Active = true;
                                            ctx.OCTies.Add(objOCTY);
                                        }
                                    }

                                    int Pincode = Convert.ToInt32(item["Pincode"].ToString());
                                    objOPIN = ctx.OPINs.FirstOrDefault(x => x.PinCodeID == Pincode);
                                    if (objOPIN == null)
                                    {
                                        objOPIN = new OPIN();
                                        objOPIN.PinCodeID = Convert.ToInt32(item["Pincode"].ToString());
                                        objOPIN.CreatedDate = DateTime.Now;
                                        objOPIN.CreatedBy = UserID;
                                        ctx.OPINs.Add(objOPIN);
                                    }
                                    objOPIN.Area = item["ZONE"].ToString();
                                    objOPIN.UpdatedDate = DateTime.Now;
                                    objOPIN.UpdatedBy = UserID;
                                    objOPIN.Active = true;
                                    objOPIN.CityID = objOCTY.CityID;
                                    objOPIN.StateID = objOCTY.StateID;

                                    ctx.SaveChanges();
                                }
                                catch (DbEntityValidationException ex)
                                {
                                    var error = ex.EntityValidationErrors.First().ValidationErrors.First();
                                    if (error != null)
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + error.ErrorMessage.Replace("'", "") + "',2);", true);
                                    else
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Error.please check data in your file.',3);", true);
                                    return;
                                }
                                cnt++;

                            }
                            tx.Complete();
                        }

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
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
}
