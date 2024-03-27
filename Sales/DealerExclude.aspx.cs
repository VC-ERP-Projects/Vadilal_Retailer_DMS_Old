using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Validation;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Sales_DealerExclude : System.Web.UI.Page
{

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    private List<SCM1> SCM1s
    {
        get { return this.ViewState["SCM1"] as List<SCM1>; }
        set { this.ViewState["SCM1"] = value; }
    }


    protected void Page_Load(object sender, EventArgs e)
    {
         ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(btnMappingUpload);
    }
    private void ClearAllInputs()
    {
        ddlExclude.SelectedValue = "-1";
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
                            var unit = xml.Descendants("customer_grp_master");
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

    protected void btnMappingUpload_Click(object sender, EventArgs e)
    {
        if (ddlExclude.SelectedValue == "-1")
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please select line item include exclude!',3);", true);
            return;
        }
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("SchemeNo");
            missdata.Columns.Add("DealerCode");
            missdata.Columns.Add("AssetCode");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;

            if (flpLineItemExcInc.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flpLineItemExcInc.PostedFile.FileName));
                flpLineItemExcInc.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flpLineItemExcInc.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtPOH = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtPOH);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                    {
                        gvProductMappingMissData.DataSource = null;
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                String SchemeNo = item["SchemeNo"].ToString().Trim();
                                String DealerCode = item["DealerCode"].ToString().Trim();
                                String AssetCode = item["AssetCode"].ToString().Trim();


                                Int32 SchemeId = Int32.TryParse(item["SchemeNo"].ToString().Trim(), out SchemeId) ? SchemeId : 0;


                                if (string.IsNullOrEmpty(SchemeNo) && string.IsNullOrEmpty(DealerCode) && string.IsNullOrEmpty(AssetCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["SchemeNo"] = SchemeNo;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["AssetCode"] = AssetCode;
                                    missdr["ErrorMsg"] = "Blank row found please remove blank row.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }

                                else if (string.IsNullOrEmpty(SchemeNo) && string.IsNullOrEmpty(AssetCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["SchemeNo"] = SchemeNo;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["AssetCode"] = AssetCode;
                                    missdr["ErrorMsg"] = "Plesase Enter SchemeN0 and Asset code.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (SchemeId <= 0)
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["SchemeNo"] = SchemeNo;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["AssetCode"] = AssetCode;
                                    missdr["ErrorMsg"] = "Plesase Enter atleast one SchemeNo.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (string.IsNullOrEmpty(DealerCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["SchemeNo"] = SchemeNo;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["AssetCode"] = AssetCode;
                                    missdr["ErrorMsg"] = "Plesase Enter Dealer code.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(DealerCode) && !ctx.OCRDs.Any(x => x.CustomerCode == DealerCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["SchemeNo"] = SchemeNo;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["AssetCode"] = AssetCode;
                                    missdr["ErrorMsg"] = "Dealer Code : " + DealerCode + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (string.IsNullOrEmpty(AssetCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["SchemeNo"] = SchemeNo;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["AssetCode"] = AssetCode;
                                    missdr["ErrorMsg"] = "Plesase Enter Asset code.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                
                               
                                else if (!string.IsNullOrEmpty(AssetCode) && !ctx.OASTs.Any(x => x.AssetCode == AssetCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["SchemeNo"] = SchemeNo;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["AssetCode"] = AssetCode;
                                    missdr["ErrorMsg"] = "Asset Code : " + AssetCode + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (ddlExclude.SelectedValue == "false")
                                {
                                    OAST objAsset = ctx.OASTs.FirstOrDefault(x => x.AssetCode == AssetCode);
                                    OCRD ObjCust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode);
                                    SCM1 objSCM1 = ctx.SCM1.FirstOrDefault(x => x.CustomerID == ObjCust.CustomerID && x.AssetID == objAsset.AssetID && x.SchemeID == SchemeId && x.IsInclude == false);
                                    if (objSCM1 != null)
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["SchemeNo"] = SchemeNo;
                                        missdr["DealerCode"] = DealerCode;
                                        missdr["AssetCode"] = AssetCode;
                                        missdr["ErrorMsg"] = "Dealer Code : " + DealerCode + " and Asset code : " + AssetCode + " already exclude.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                                else if (ddlExclude.SelectedValue == "true")
                                {
                                    OAST objAsset = ctx.OASTs.FirstOrDefault(x => x.AssetCode == AssetCode);
                                    OCRD ObjCust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode);
                                    SCM1 objSCM1 = ctx.SCM1.FirstOrDefault(x => x.CustomerID == ObjCust.CustomerID && x.AssetID == objAsset.AssetID && x.SchemeID == SchemeId && x.IsInclude == true);
                                    if (objSCM1 != null)
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["SchemeNo"] = SchemeNo;
                                        missdr["DealerCode"] = DealerCode;
                                        missdr["AssetCode"] = AssetCode;
                                        missdr["ErrorMsg"] = "Dealer Code : " + DealerCode + " and Asset code : " + AssetCode + " already include.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                            }
                            if (flag)
                            {
                                try
                                {
                                    if (SCM1s == null)
                                        SCM1s = new List<SCM1>();

                                    foreach (DataRow item in dtPOH.Rows)
                                    {

                                        Int32 SchemeNo = Int32.TryParse(item["SchemeNo"].ToString().Trim(), out SchemeNo) ? SchemeNo : 0;
                                        String DealerCode = item["DealerCode"].ToString().Trim();
                                        String AssetCode = item["AssetCode"].ToString().Trim();


                                        if (SchemeNo > 0)
                                        {
                                            OAST objAsset = ctx.OASTs.FirstOrDefault(x => x.AssetCode == AssetCode);
                                            OCRD ObjCust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode);
                                            SCM1 objSCM1 = ctx.SCM1.FirstOrDefault(x => x.CustomerID == ObjCust.CustomerID && x.AssetID == objAsset.AssetID && x.SchemeID == SchemeNo);
                                            if (objSCM1 != null)
                                            {
                                                objSCM1.IsInclude = Convert.ToBoolean(ddlExclude.SelectedValue);
                                                objSCM1.CreatedDate = DateTime.Now;
                                            }
                                        }
                                    }
                                    ctx.SaveChanges();
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('file uploaded successfully!',1);", true);
                                    gvProductMappingMissData.Visible = false;

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
                            else
                            {
                                gvProductMappingMissData.Visible = true;
                                gvProductMappingMissData.DataSource = missdata;
                                gvProductMappingMissData.DataBind();
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
    protected void ddlExclude_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvProductMappingMissData.Visible = false;
        gvProductMappingMissData.DataSource = null;
        gvProductMappingMissData.DataBind();
    }
}