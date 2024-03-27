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

public partial class MyAccount_DistibutorUpload : System.Web.UI.Page
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

                        using (TransactionScope tx = new TransactionScope(TransactionScopeOption.Required, TimeSpan.MaxValue))
                        {
                            int BranchID = ctx.GetKey("CRD1", "BranchID", "", 0, 0).FirstOrDefault().Value;
                            int CityCntID = ctx.GetKey("OCTY", "CityID", "", 0, 0).FirstOrDefault().Value;
                            //int RegionID = ctx.GetKey("OREG", "RegionID", "", 0, 0).FirstOrDefault().Value;
                            int PlantID = ctx.GetKey("OPLT", "PlantID", "", 0, 0).FirstOrDefault().Value;

                            foreach (DataRow item in dtPOH.Rows)
                            {
                                try
                                {
                                    OCRD objOCRD = null;
                                    OCTY objOCTY = null;
                                    OEMP objOEMP = null;
                                    OPLT objOPLT = null;

                                    //Plant
                                    String PlantCode = item[2].ToString();

                                    objOPLT = ctx.OPLTs.FirstOrDefault(x => x.PlantCode == PlantCode);
                                    if (objOPLT == null)
                                    {
                                        objOPLT = new OPLT();
                                        //objOPLT.RegionID = objOREG.RegionID;
                                        objOPLT.PlantID = PlantID++;
                                        objOPLT.CreatedDate = DateTime.Now;
                                        objOPLT.CreatedBy = UserID;
                                        ctx.OPLTs.Add(objOPLT);
                                    }
                                    objOPLT.UpdatedDate = DateTime.Now;
                                    objOPLT.UpdatedBy = UserID;
                                    objOPLT.Active = true;
                                    objOPLT.PlantCode = item[2].ToString();
                                    objOPLT.PlantName = item[3].ToString();
                                    ctx.SaveChanges();


                                    if (!String.IsNullOrEmpty(item[8].ToString()))
                                    {
                                        var Cityname = item[8].ToString().ToUpper();
                                        objOCTY = ctx.OCTies.FirstOrDefault(x => x.CityName.Contains(Cityname));
                                        if (objOCTY == null)
                                        {
                                            objOCTY = new OCTY();
                                            objOCTY.CityID = CityCntID++;
                                            objOCTY.StateID = 1;
                                            objOCTY.CityName = item[4].ToString().ToUpper();
                                            objOCTY.CreatedDate = DateTime.Now;
                                            objOCTY.CreatedBy = UserID;
                                            objOCTY.UpdatedDate = DateTime.Now;
                                            objOCTY.UpdatedBy = UserID;
                                            objOCTY.Active = true;
                                            ctx.OCTies.Add(objOCTY);
                                        }
                                        ctx.SaveChanges();
                                    }

                                    String DistributorCode = item[4].ToString();
                                    if (!String.IsNullOrEmpty(DistributorCode))
                                    {
                                        //ParetID
                                        objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DistributorCode);
                                        decimal key = 0;
                                        if (objOCRD == null)
                                        {
                                            objOCRD = new OCRD();
                                            objOCRD.Type = Convert.ToInt32(Session["Type"]) + 1;
                                            string key1 = "";
                                            key1 = ctx.GetCustomerID("OCRD", "CustomerID", ParentID).FirstOrDefault().Value.ToString("D5");

                                            var cid = objOCRD.Type.ToString() + key1 + ParentID.ToString().Substring(1, 10);
                                            key = Convert.ToDecimal(cid);
                                            objOCRD.CustomerID = Convert.ToDecimal(cid);
                                            objOCRD.ParentID = ParentID;
                                            objOCRD.CustomerCode = DistributorCode;
                                            objOCRD.CreatedBy = UserID;
                                            objOCRD.CreatedDate = DateTime.Now;
                                            objOCRD.CustGroupID = objOCRD.CustGroupID = ctx.CGRPs.Where(x => x.Type == 2).FirstOrDefault().CustGroupID;
                                            ctx.OCRDs.Add(objOCRD);
                                        }
                                        else
                                        {
                                            key = objOCRD.CustomerID;
                                        }
                                        objOCRD.CustomerName = item[5].ToString();
                                        objOCRD.UpdatedBy = UserID;
                                        objOCRD.Active = true;
                                        //objOCRD.PlantID = objOPLT.PlantID;
                                        objOCRD.UpdatedDate = DateTime.Now;

                                        CRD1 objCRD1 = null;
                                        String Branch = item[8].ToString();
                                        objCRD1 = ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID);
                                        if (objCRD1 == null)
                                        {
                                            objCRD1 = new CRD1();
                                            objCRD1.CustomerID = objOCRD.CustomerID;
                                            objCRD1.BranchID = BranchID++;
                                            objCRD1.Branch = Branch;
                                            objCRD1.Type = "B";
                                            objCRD1.StateID = 1;
                                            objCRD1.CountryID = 1;
                                            ctx.CRD1.Add(objCRD1);
                                        }

                                        objCRD1.CityID = objOCTY.CityID;

                                        //OUTLET
                                        objOEMP = objOCRD.OEMPs.FirstOrDefault();
                                        if (objOEMP == null)
                                        {
                                            OGRP objOGRP = new OGRP();
                                            objOGRP.EmpGroupID = ctx.GetKey("OGRP", "EmpGroupID", "", objOCRD.CustomerID, 0).FirstOrDefault().Value;
                                            objOGRP.ParentID = objOCRD.CustomerID;
                                            objOGRP.EmpGroupName = "Admin";
                                            objOGRP.EmpGroupDesc = "Admin";
                                            objOGRP.CreatedDate = DateTime.Now;
                                            objOGRP.CreatedBy = UserID;
                                            objOGRP.UpdatedDate = DateTime.Now;
                                            objOGRP.UpdatedBy = UserID;
                                            objOGRP.Active = true;
                                            ctx.OGRPs.Add(objOGRP);

                                            objOEMP = new OEMP();
                                            objOEMP.EmpID = ctx.GetKey("OEMP", "EmpID", "", objOCRD.CustomerID, 0).FirstOrDefault().Value;
                                            objOEMP.ParentID = objOCRD.CustomerID;
                                            objOEMP.EmpCode = "E" + objOEMP.EmpID.ToString("D5");
                                            objOEMP.UserName = objOCRD.CustomerCode;
                                            objOEMP.Password = Common.EncryptNumber(objOEMP.UserName, objOEMP.UserName);
                                            objOEMP.Name = item[1].ToString();
                                            objOEMP.EmpGroupID = objOGRP.EmpGroupID;
                                            objOEMP.BranchID = objCRD1.BranchID;
                                            objOEMP.IsDiscount = false;
                                            objOEMP.UserType = "d";
                                            objOEMP.CreatedDate = DateTime.Now;
                                            objOEMP.CreatedBy = UserID;
                                            objOEMP.UpdatedDate = DateTime.Now;
                                            objOEMP.UpdatedBy = UserID;
                                            objOEMP.Active = true;

                                            objOCRD.OEMPs.Add(objOEMP);

                                            EMP1 objEMP1 = new EMP1();
                                            objEMP1.Emp1ID = ctx.GetKey("EMP1", "Emp1ID", "", objOCRD.CustomerID, 0).FirstOrDefault().Value;
                                            objEMP1.ParentID = objOCRD.CustomerID;
                                            objEMP1.EmpID = objOEMP.EmpID;
                                            objEMP1.Type = "0";
                                            objOEMP.EMP1.Add(objEMP1);

                                            List<OMNU> Menus = new List<OMNU>();
                                            if (objOCRD.Type == 1)
                                                Menus = ctx.OMNUs.Where(x => x.Active && x.Company).ToList();
                                            else if (objOCRD.Type == 2)
                                                Menus = ctx.OMNUs.Where(x => x.Active && x.CMS).ToList();
                                            else if (objOCRD.Type == 3)
                                                Menus = ctx.OMNUs.Where(x => x.Active && x.DMS).ToList();
                                            else if (objOCRD.Type == 4)
                                                Menus = ctx.OMNUs.Where(x => x.Active && x.SS).ToList();

                                            int CountGRP1 = ctx.GetKey("GRP1", "GRPID", "", objOCRD.CustomerID, 0).FirstOrDefault().Value;
                                            foreach (var item1 in Menus)
                                            {
                                                GRP1 objGRP1 = new GRP1();
                                                objGRP1.GRPID = CountGRP1++;
                                                objGRP1.ParentID = objOCRD.CustomerID;
                                                objGRP1.EmpGroupID = objOGRP.EmpGroupID;
                                                objGRP1.MenuID = item1.MenuID;
                                                objGRP1.AuthorizationType = "W";
                                                objGRP1.Active = true;
                                                objOGRP.GRP1.Add(objGRP1);
                                            }
                                        }

                                        //Customer Child
                                        String DealorCode = item[6].ToString();
                                        if (!String.IsNullOrEmpty(DealorCode))
                                        {
                                            objOCRD = ctx.OCRDs.FirstOrDefault(x => x.ParentID == key && x.CustomerCode == DealorCode);
                                            if (objOCRD == null)
                                            {
                                                objOCRD = new OCRD();
                                                objOCRD.Type = Convert.ToInt32(Session["Type"]) + 2;
                                                var key2 = ctx.GetCustomerID("OCRD", "CustomerID", key).FirstOrDefault().Value.ToString("D5");
                                                var cid = objOCRD.Type.ToString() + key2 + key.ToString().Substring(1, 10);
                                                objOCRD.CustomerID = Convert.ToDecimal(cid);
                                                objOCRD.ParentID = key;
                                                objOCRD.CustomerCode = DealorCode;
                                                objOCRD.CreatedBy = UserID;
                                                objOCRD.CreatedDate = DateTime.Now;
                                                objOCRD.CustGroupID = objOCRD.CustGroupID = ctx.CGRPs.Where(x => x.Type == 3).FirstOrDefault().CustGroupID;
                                                ctx.OCRDs.Add(objOCRD);
                                            }

                                            objOCRD.CustomerName = item[7].ToString();
                                            objOCRD.UpdatedBy = UserID;
                                            objOCRD.Active = true;
                                            objOCRD.UpdatedDate = DateTime.Now;
                                            //objOCRD.PlantID = objOPLT.PlantID;

                                            objCRD1 = null;
                                            Branch = item[8].ToString();
                                            objCRD1 = ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID);
                                            if (objCRD1 == null)
                                            {
                                                objCRD1 = new CRD1();
                                                objCRD1.CustomerID = objOCRD.CustomerID;
                                                objCRD1.BranchID = BranchID++;
                                                objCRD1.Branch = Branch;
                                                objCRD1.Type = "B";
                                                objCRD1.StateID = 1;
                                                objCRD1.CountryID = 1;
                                                ctx.CRD1.Add(objCRD1);
                                            }
                                            objCRD1.CityID = objOCTY.CityID;
                                        }
                                    }
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
                            }
                            ctx.SaveChanges();
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