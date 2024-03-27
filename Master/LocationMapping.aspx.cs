using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Text;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using System.Data.Objects.SqlClient;
using System.Threading;
using System.Data.SqlClient;
using Newtonsoft.Json;
using System.Data.Entity.Validation;

public partial class Master_LocationMapping : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType, UserName;


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

                    UserName = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + "," + x.Name).FirstOrDefault().ToString();
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

    private void ClearAllInputs()
    {
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData(string strSearchBy)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            int UserID = Convert.ToInt16(HttpContext.Current.Session["UserID"]);
            List<String> StrCust = new List<string>();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (strSearchBy == "1")
                {
                    StrCust = ctx.OCSTs.OrderBy(x => x.StateName).Select(x => x.GSTStateCode + " - " + x.StateName + " - " + SqlFunctions.StringConvert((double)x.StateID).Trim()).ToList();
                }
                else if (strSearchBy == "2")
                {
                    StrCust = ctx.OCTies.OrderBy(x => x.CityName.Trim()).Where(x => x.Active).Select(x => x.CityName.Trim() + " - " + SqlFunctions.StringConvert((double)x.CityID).Trim()).ToList();
                }
                else if (strSearchBy == "3")
                {
                    StrCust = ctx.OPLTs.OrderBy(x => x.PlantName).Select(x => x.PlantCode + " - " + x.PlantName + " - " + SqlFunctions.StringConvert((double)x.PlantID).Trim()).ToList();
                }

                //Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                //SqlCommand Cm = new SqlCommand();

                //Cm.Parameters.Clear();
                //Cm.CommandType = CommandType.StoredProcedure;
                //Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

                //Cm.Parameters.AddWithValue("@Type", Type);
                //Cm.Parameters.AddWithValue("@UserID", UserID);
                //Cm.Parameters.AddWithValue("@ParentID", ParentID);
                //Cm.Parameters.AddWithValue("@Prefix", strPrefix);
                //Cm.Parameters.AddWithValue("@Count", 0);
                //Cm.Parameters.AddWithValue("@StateID", 0);
                //Cm.Parameters.AddWithValue("@CityID", 0);
                //Cm.Parameters.AddWithValue("@PlantID", 0);
                //Cm.Parameters.AddWithValue("@SSID", 0);
                //Cm.Parameters.AddWithValue("@DistID", 0);

                //DataSet ds = objClass.CommonFunctionForSelect(Cm);
                //StrCust = ds.Tables[0].AsEnumerable()
                //               .Select(r => r.Field<string>("Data"))
                //               .ToList();
                result.Add(StrCust);
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR#" + "" + Common.GetString(ex));
        }
        return result;
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

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputs();
            //var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            //ddlDivision.DataSource = Division;
            //ddlDivision.DataBind();
        }
    }
    #endregion

    #region Button Click

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetDetail(string strSearchID, string strSearchBy, string strSearchFor)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (!string.IsNullOrEmpty(strSearchBy) || !string.IsNullOrEmpty(strSearchFor))
                {
                    decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                    int UserID = Convert.ToInt16(HttpContext.Current.Session["UserID"]);
                    Int32 SearchID = Int32.TryParse(strSearchID, out SearchID) ? SearchID : 0;
                    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                    SqlCommand Cm = new SqlCommand();

                    Cm.Parameters.Clear();
                    Cm.CommandType = CommandType.StoredProcedure;
                    Cm.CommandText = "GetLocationDataForMapping";

                    Cm.Parameters.AddWithValue("@UserID", UserID);
                    Cm.Parameters.AddWithValue("@ParentID", ParentID);
                    Cm.Parameters.AddWithValue("@SearchBy", strSearchBy);
                    Cm.Parameters.AddWithValue("@SearchFor", strSearchFor);
                    Cm.Parameters.AddWithValue("@SearchID", SearchID);

                    DataSet ds = objClass.CommonFunctionForSelect(Cm);
                    dynamic Data = "";

                    Data = ds.Tables[0].AsEnumerable()
                                   .Select(r => new { CodeName = r.Field<string>("Data"), Address = r.Field<string>("Address"), HomeLat = r.Field<string>("Latitude"), HomeLong = r.Field<string>("Longitude"), OfficeLat = r.Field<string>("OfficeLatitude"), OfficeLong = r.Field<string>("OfficeLongitude"), UpdatedBy = r.Field<string>("UpdatedBy"), UpdatedDate = r.Field<string>("UpdatedDate") })
                                   .ToList();

                    result.Add(Data);
                }
                else
                    result.Add("ERROR=Select atleast one parameter");
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {

    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            if (txtSearch.Text == "")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select Any Search With option.',3);", true);
                return;
            }
            if (ddlSearchFor.SelectedValue == "3" && ddlSearchBy.SelectedValue == "1")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select Any Search By option.',3);", true);
                return;
            }

            Int32 SearchID = Int32.TryParse(txtSearch.Text.Split('-').Last().Trim(), out SearchID) ? SearchID : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetLocationDataForMapping";
            Cm.Parameters.AddWithValue("@UserID", UserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@SearchBy", ddlSearchBy.SelectedValue);
            Cm.Parameters.AddWithValue("@SearchFor", ddlSearchFor.SelectedValue);
            Cm.Parameters.AddWithValue("@SearchID", SearchID);
            DataTable dt = objClass.CommonFunctionForSelect(Cm).Tables[0];

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            if (dt.Rows.Count > 0)
            {
                DataTableReader reader = dt.CreateDataReader();
                StringWriter writer = new StringWriter();
                do
                {
                    writer.WriteLine("Search By ," + ddlSearchBy.SelectedItem.Text);
                    writer.WriteLine("Search With ," + txtSearch.Text);
                    writer.WriteLine("Search For ," + ddlSearchFor.SelectedItem.Text);
                    writer.WriteLine("User Id ," + UserName);
                    writer.WriteLine("Created On ," + DateTime.Now);
                    writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetName).ToList()));
                    int count = 0;
                    while (reader.Read())
                    {
                        writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetValue).ToList()));
                        if (++count % 100 == 0)
                        {
                            writer.Flush();
                        }
                    }
                }
                while (reader.NextResult());

                string filepath = "LocationMapping_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv";
                Response.AddHeader("content-disposition", "attachment;filename=" + filepath);
                Response.Output.Write(writer.ToString());
                Response.Flush();
                Response.End();
            }

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnMappingUpload_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("Type");
            missdata.Columns.Add("Data");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;

            if (flIMappingUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flIMappingUpload.PostedFile.FileName));
                flIMappingUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flIMappingUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtLocData = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtLocData);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    if (dtLocData != null && dtLocData.Rows != null && dtLocData.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtLocData.Rows)
                            {
                                String UploadType = item["Type"].ToString().Trim();
                                String Customer = item["Data"].ToString().Trim().Split('-')[0].Trim();

                                if (string.IsNullOrEmpty(UploadType) || !(UploadType.ToLower() == "e" || UploadType.ToLower() == "c"))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Type"] = UploadType;
                                    missdr["Data"] = Customer;
                                    missdr["ErrorMsg"] = "Please enter data properly in Type Column at Row No.: " + (dtLocData.Rows.IndexOf(item) + 1).ToString();
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                    goto CheckFlag;
                                }
                                else if (UploadType.ToLower() == "c" && !string.IsNullOrEmpty(Customer) && !ctx.OCRDs.Any(x => x.CustomerCode == Customer))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Type"] = UploadType;
                                    missdr["Data"] = Customer;
                                    missdr["ErrorMsg"] = "Please Enter proper Customer at Row No.: " + (dtLocData.Rows.IndexOf(item) + 1).ToString();
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                    goto CheckFlag;
                                }
                                else if (UploadType.ToLower() == "e" && !string.IsNullOrEmpty(Customer) && !ctx.OEMPs.Any(x => x.EmpCode == Customer))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Type"] = UploadType;
                                    missdr["Data"] = Customer;
                                    missdr["ErrorMsg"] = "Please Enter proper Employee at Row No.: " + (dtLocData.Rows.IndexOf(item) + 1).ToString();
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                    goto CheckFlag;
                                }
                            }

                        CheckFlag:
                            if (flag)
                            {
                                try
                                {
                                    foreach (DataRow item in dtLocData.Rows)
                                    {
                                        String UploadType = item["Type"].ToString().Trim();
                                        String Customer = item["Data"].ToString().Trim();
                                        String HomeLatitude = item["HomeLatitude"].ToString().Trim();
                                        String HomeLongitude = item["HomeLongitude"].ToString().Trim();
                                        String OfficeLatitude = item["OfficeLatitude"].ToString().Trim();
                                        String OfficeLongitude = item["OfficeLongitude"].ToString().Trim();
                                        Customer = Customer.Split('-')[0].Trim();

                                        if (UploadType.ToLower().Trim() == "e")
                                        {
                                            OEMP EmpData = ctx.OEMPs.FirstOrDefault(x => x.EmpCode == Customer && x.ParentID == ParentID);

                                            EmpData.GCMID = HomeLatitude + "#" + HomeLongitude;
                                            EmpData.GCM2ID = OfficeLatitude + "#" + OfficeLongitude;
                                        }
                                        else if (UploadType.ToLower().Trim() == "c")
                                        {
                                            OCRD CustData = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Customer);

                                            CustData.Latitude = HomeLatitude;
                                            CustData.Longitude = HomeLongitude;
                                        }

                                    }

                                    ctx.SaveChanges();
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Mapping Inserted Successfully.',1);", true);
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
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + missdata.Rows[0][6].ToString() + "',3);", true);
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

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string SearchFor, string hidJsonInputMaterial)
    {
        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);

            var DetailData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());

            if (DetailData != null)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    foreach (var data in DetailData)
                    {
                        String HomeLatitude = data["HomeLatitude"].ToString().Trim();
                        String HomeLongitude = data["HomeLongitude"].ToString().Trim();

                        string CustomerID = data["Customer"].ToString().Trim();

                        if (!string.IsNullOrEmpty(CustomerID))
                        {
                            if (SearchFor == "1")
                            {
                                String OfficeLatitude = data["OfficeLatitude"].ToString().Trim();
                                String OfficeLongitude = data["OfficeLongitude"].ToString().Trim();

                                OEMP EmpData = ctx.OEMPs.FirstOrDefault(x => x.EmpCode == CustomerID && x.ParentID == ParentID);

                                EmpData.GCMID = HomeLatitude + "#" + HomeLongitude;
                                EmpData.GCM2ID = OfficeLatitude + "#" + OfficeLongitude;
                            }
                            else
                            {
                                OCRD CustData = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustomerID);

                                CustData.Latitude = HomeLatitude;
                                CustData.Longitude = HomeLongitude;
                            }
                        }
                    }
                    ctx.SaveChanges();
                    return "SUCCESS=Mapping Inserted Successfully";
                }
            }
            else
                return "ERROR=Please select atleast one Item";
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }

    #endregion

}