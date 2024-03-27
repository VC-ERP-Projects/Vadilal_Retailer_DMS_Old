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
using System.Web.UI.HtmlControls;
using System.Text;

public partial class Master_ItemMapping : System.Web.UI.Page
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
                            var unit = xml.Descendants("Inward");
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
        txtPlant.Style.Add("background-color", "rgb(250, 255, 189);");
        txtPlant.Text = "";

        gvItem.DataSource = null;
        gvItem.DataBind();
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnExport);
        scriptManager.RegisterPostBackControl(this.btnImport);
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }



    }

    #endregion

    #region Change Event

    protected void txtPlant_TextChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(txtPlant.Text))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int PlantID;

                if (Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) && PlantID > 0)
                {
                    var objOGITM = (from c in ctx.OITMs
                                    join d in ctx.PLT1.Where(x => x.PlantID == PlantID) on c.ItemID equals d.ItemID into f
                                    from dpem in f.DefaultIfEmpty()
                                    where c.OGITMs.Any(x => x.PlantID == PlantID) && c.Active
                                    select new
                                    {
                                        ItemID = c.ItemID,
                                        ItemCode = c.ItemCode,
                                        ItemName = c.ItemName,
                                        Active = dpem == null ? false : dpem.Active,
                                        CreatedDate = dpem == null ? null : dpem.CreatedDate,
                                        CreatedBy = dpem == null ? "" : ctx.OEMPs.Where(x => x.EmpID == dpem.CreatedBy && x.ParentID == dpem.ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault(),
                                        UpdatedDate = dpem == null ? null : dpem.UpdatedDate,
                                        UpdatedBy = dpem == null ? "" : ctx.OEMPs.Where(x => x.EmpID == dpem.UpdatedBy && x.ParentID == dpem.ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault(),
                                    }).OrderBy(x => x.ItemCode).ToList();

                    gvItem.DataSource = objOGITM;
                    gvItem.DataBind();
                }
            }
        }
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

    #region Button Events

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) ? PlantID : 0;
                    int PLT1Count = ctx.GetKey("PLT1", "PLT1ID", "", 0, 0).FirstOrDefault().Value;

                    List<int> IDs = new List<int>();
                    if (PlantID > 0)
                    {
                        for (int i = 0; i < gvItem.Rows.Count; i++)
                        {
                            HtmlInputCheckBox chk = (HtmlInputCheckBox)gvItem.Rows[i].FindControl("chkCheck");
                            HiddenField lblItemID = (HiddenField)gvItem.Rows[i].FindControl("lblItemID");

                            int ItemID = Int32.TryParse(lblItemID.Value, out ItemID) ? ItemID : 0;

                            if (ItemID > 0)
                            {
                                PLT1 objPLT1 = ctx.PLT1.FirstOrDefault(x => x.ItemID == ItemID && x.PlantID == PlantID);
                                if (objPLT1 == null)
                                {
                                    objPLT1 = new PLT1();
                                    objPLT1.PLT1ID = PLT1Count++;
                                    objPLT1.ParentID = ParentID;
                                    objPLT1.ItemID = ItemID;
                                    objPLT1.PlantID = PlantID;
                                    objPLT1.Active = chk.Checked;
                                    objPLT1.UpdatedBy = UserID;
                                    objPLT1.UpdatedDate = DateTime.Now;
                                    objPLT1.CreatedBy = UserID;
                                    objPLT1.CreatedDate = DateTime.Now;
                                    ctx.PLT1.Add(objPLT1);
                                }
                                else if (objPLT1.Active != chk.Checked)
                                {
                                    objPLT1.Active = chk.Checked;
                                    objPLT1.UpdatedBy = UserID;
                                    objPLT1.UpdatedDate = DateTime.Now;
                                }

                                IDs.Add(ItemID);
                            }
                        }

                        ctx.PLT1.Where(x => x.PlantID == PlantID && !IDs.Contains(x.ItemID)).ToList().ForEach(x => { x.Active = false; x.UpdatedDate = DateTime.Now; x.UpdatedBy = UserID; });

                        ctx.SaveChanges();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully',1);", true);
                        ClearAllInputs();
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select proper Plant!',3);", true);
                        return;
                    }

                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Page is invalid!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {

    }

    protected void btnImport_Click(object sender, EventArgs e)
    {
        DataTable missdata = new DataTable();
        missdata.Columns.Add("Item Code");
        missdata.Columns.Add("Plant Code");
        missdata.Columns.Add("Error Msg");

        try
        {
            bool flag = true;
            using (DDMSEntities ctx = new DDMSEntities())
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
                        DataTable dt = new DataTable();

                        TransferCSVToTable(fileName, dt);

                        if (dt != null && dt.Rows != null && dt.Rows.Count > 0)
                        {
                            foreach (DataRow item in dt.Rows)
                            {
                                try
                                {
                                    string PlantCode = item["PlantCode"].ToString();
                                    string ItemCode = item["ItemCode"].ToString();
                                    if (!string.IsNullOrEmpty(item["PlantCode"].ToString()) && !string.IsNullOrEmpty(item["ItemCode"].ToString()))
                                    {

                                        if (ctx.OPLTs.Any(x => x.PlantCode == PlantCode && x.Active))
                                        {
                                            if (ctx.OITMs.Any(x => x.ItemCode == ItemCode && x.Active))
                                            {

                                            }
                                            else
                                            {
                                                DataRow missdr = missdata.NewRow();
                                                missdr["Item Code"] = ItemCode;
                                                missdr["Plant Code"] = PlantCode;
                                                missdr["Error Msg"] = "Item Code : " + ItemCode + " does not exist.";
                                                missdata.Rows.Add(missdr);
                                                flag = false;
                                            }
                                        }
                                        else
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["Item Code"] = ItemCode;
                                            missdr["Plant Code"] = PlantCode;
                                            missdr["Error Msg"] = "Plant Code : " + PlantCode + " does not exist.";
                                            missdata.Rows.Add(missdr);
                                            flag = false;
                                        }
                                    }
                                    else
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Item Code"] = ItemCode;
                                        missdr["Plant Code"] = PlantCode;
                                        missdr["Error Msg"] = "Data is not proper.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                catch (Exception ex)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
                                }
                            }
                            if (flag)
                            {
                                Boolean firsttime = false;

                                int PLT1Count = ctx.GetKey("PLT1", "PLT1ID", "", 0, 0).FirstOrDefault().Value;
                                foreach (DataRow item in dt.Rows)
                                {
                                    try
                                    {
                                        if (!string.IsNullOrEmpty(item["PlantCode"].ToString()) && !string.IsNullOrEmpty(item["ItemCode"].ToString()))
                                        {
                                            string PlantCode = item["PlantCode"].ToString();
                                            string ItemCode = item["ItemCode"].ToString();

                                            int PlantID = ctx.OPLTs.FirstOrDefault(x => x.PlantCode == PlantCode).PlantID;
                                            int ItemID = ctx.OITMs.FirstOrDefault(x => x.ItemCode == ItemCode).ItemID;

                                            if (firsttime == false)
                                            {
                                                List<PLT1> objPLT1s = ctx.PLT1.Where(x => x.PlantID == PlantID).ToList();
                                                objPLT1s.ForEach(x => x.Active = false);
                                                firsttime = true;
                                            }

                                            PLT1 objItem = ctx.PLT1.FirstOrDefault(x => x.ItemID == ItemID && x.PlantID == PlantID);
                                            if (objItem == null)
                                            {
                                                objItem = new PLT1();
                                                objItem.PLT1ID = PLT1Count++;
                                                objItem.ItemID = ItemID;
                                                objItem.ParentID = ParentID;
                                                objItem.PlantID = PlantID;
                                                objItem.CreatedBy = UserID;
                                                objItem.CreatedDate = DateTime.Now;
                                                ctx.PLT1.Add(objItem);
                                            }
                                            objItem.Active = true;
                                            objItem.UpdatedBy = UserID;
                                            objItem.UpdatedDate = DateTime.Now;
                                        }
                                    }
                                    catch (Exception ex)
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
                                    }
                                }
                                ctx.SaveChanges();
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Process completed.',1);", true);
                            }
                            else
                            {
                                gvItem.Visible = false;
                                gvMissdata.DataSource = missdata;
                                gvMissdata.DataBind();
                            }
                        }
                        else

                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('No Record Found!',3);", true);
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);

                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) ? PlantID : 0;
                if (PlantID > 0)
                {

                    var qry = (from a in ctx.PLT1
                               join b in ctx.OPLTs on a.PlantID equals b.PlantID
                               join c in ctx.OITMs on a.ItemID equals c.ItemID
                               where a.PlantID == PlantID && a.Active
                               select new { ItemCode = c.ItemCode, ItemName = c.ItemName, PlantCode = b.PlantCode, PlantName = b.PlantName }).ToList();

                    Response.Clear();
                    Response.Buffer = true;
                    GridView grd = new GridView();
                    grd.DataSource = qry;
                    grd.DataBind();
                    string FileName = "ItemMapping_" + DateTime.Now.ToString("dd/MM/yyyy") + ".csv";
                    Response.AddHeader("content-disposition", "attachment;filename=" + FileName);
                    Response.Charset = "";
                    Response.ContentType = "application/text";
                    StringBuilder sBuilder = new System.Text.StringBuilder();
                    sBuilder.Append("ItemCode");
                    sBuilder.Append(",");
                    sBuilder.Append("ItemName");
                    sBuilder.Append(",");
                    sBuilder.Append("PlantCode");
                    sBuilder.Append(",");
                    sBuilder.Append("PlantName");

                    sBuilder.Append("\r\n");
                    for (int i = 0; i < grd.Rows.Count; i++)
                    {
                        for (int k = 0; k < grd.HeaderRow.Cells.Count; k++)
                        {
                            sBuilder.Append(grd.Rows[i].Cells[k].Text.Replace(",", "") + ",");
                        }
                        sBuilder.Append("\r\n");
                    }
                    Response.Output.Write(sBuilder.ToString());
                    Response.Flush();
                    Response.End();

                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select proper Plant!',3);", true);
                    return;

                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);

        }
    }
    #endregion

    #region Gridview Event

    protected void gvItem_PreRender(object sender, EventArgs e)
    {
        if (gvItem.Rows.Count > 0)
        {
            gvItem.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvItem.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion




}