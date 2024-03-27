using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

[Serializable]
public class DALDaysValidate
{
    public int EMPDID { get; set; }
    public int EmpID { get; set; }
    public decimal CustomerID { get; set; }
    public String EmpGroupDesc { get; set; }
    public String CustomerDesc { get; set; }
    public int Days { get; set; }
    public String CreatedDate { get; set; }
    public string CreatedBy { get; set; }
    public String UpdatedDate { get; set; }
    public string UpdatedBy { get; set; }
}

public partial class EmployeeDALDays : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;


    public List<DALDaysValidate> DALDaysLIST
    {
        get { return ViewState["DALDaysValidation"] as List<DALDaysValidate>; }
        set { ViewState["DALDaysValidation"] = value; }
    }

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

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!Page.IsPostBack)
        {
            DALDaysLIST = new List<DALDaysValidate>();
        }
    }

    protected void gvDALDaysValidation_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            TextBox txtEmpGroupDesc = (TextBox)e.Row.FindControl("txtEmpGroupDesc");
            HiddenField EmpID = (HiddenField)e.Row.FindControl("EmpID");
            txtEmpGroupDesc.Enabled = EmpID != null && EmpID.Value != "0" ? true : false;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadEmpByType(string prefixText)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            List<string> items = new List<string>();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (prefixText == "*")
                {
                    items = (from c in ctx.OEMPs
                             join d in ctx.OGRPs on c.EmpGroupID equals d.EmpGroupID
                             where c.ParentID == 1000010000000000
                             select c.EmpCode + " - " + c.Name + " (" + d.EmpGroupDesc + ") " + " - " + SqlFunctions.StringConvert((double)c.EmpID).Trim()).Distinct().ToList();
                }
                else
                {
                    items = (from c in ctx.OEMPs
                             join d in ctx.OGRPs on c.EmpGroupID equals d.EmpGroupID
                             where c.ParentID == 1000010000000000 && (c.EmpCode.Contains(prefixText) || c.Name.Contains(prefixText))
                             select c.EmpCode + " - " + c.Name + " (" + d.EmpGroupDesc + ") " + " - " + SqlFunctions.StringConvert((double)c.EmpID).Trim()).Distinct().ToList();
                }
                result.Add(items);
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetEmployeeDetail(int EmpID, decimal CustomerID)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();

                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "GetEmpDealerDALDays";
                Cm.Parameters.AddWithValue("@EmpID", EmpID);
                Cm.Parameters.AddWithValue("@CustomerID", CustomerID);

                DataSet ds = objClass.CommonFunctionForSelect(Cm);
                if (ds.Tables.Count > 0)
                {
                    List<DALDaysValidate> CallData = ds.Tables[0].AsEnumerable().Select
                     (x => new DALDaysValidate
                     {
                         EMPDID = x.Field<int>("EMPDID"),
                         EmpID = x.Field<int>("EmpID"),
                         CustomerID = x.Field<decimal>("CustomerID"),
                         EmpGroupDesc = x.Field<String>("EmpGroupDesc"),
                         CustomerDesc = x.Field<String>("CustomerDesc"),
                         Days = x.Field<int>("Days"),
                         CreatedDate = x.Field<String>("CreatedDate"),
                         CreatedBy = x.Field<String>("CreatedBy"),
                         UpdatedBy = x.Field<String>("UpdatedBy"),
                         UpdatedDate = x.Field<String>("UpdatedDate"),

                     }).ToList();
                    result.Add(CallData);
                }
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<DicData> GetDealerCurrHierarchy(string prefixText, string EmpID)
    {
        List<DicData> result = new List<DicData>();

        try
        {
            List<string> items = new List<string>();
            prefixText = !string.IsNullOrEmpty(prefixText) ? prefixText : "*";
            int UserID = Int32.TryParse(EmpID, out UserID) && UserID > 0 ? UserID : Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

            Cm.Parameters.AddWithValue("@Type", "Dealer");
            Cm.Parameters.AddWithValue("@UserID", UserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@Prefix", prefixText);
            Cm.Parameters.AddWithValue("@Count", 0);
            Cm.Parameters.AddWithValue("@StateID", 0);
            Cm.Parameters.AddWithValue("@CityID", 0);
            Cm.Parameters.AddWithValue("@PlantID", 0);
            Cm.Parameters.AddWithValue("@SSID", 0);
            Cm.Parameters.AddWithValue("@DistID", 0);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            return ds.Tables[0].AsEnumerable()
                        .Select(r => new DicData { Text = r.Field<string>("Data"), Value = 0 })
                        .ToList();
        }
        catch (Exception ex)
        {

        }

        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData()
    {
        List<dynamic> result = new List<dynamic>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetEmpDALDaysInfo";
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            List<DALDaysValidate> CallData = ds.Tables[0].AsEnumerable().Select
             (x => new DALDaysValidate
             {
                 EMPDID = x.Field<int>("EMPDID"),
                 EmpID = x.Field<int>("EmpID"),
                 CustomerID = x.Field<decimal>("CustomerID"),
                 EmpGroupDesc = x.Field<String>("EmpGroupDesc"),
                 CustomerDesc = x.Field<String>("CustomerDesc"),
                 Days = x.Field<int>("Days"),
                 CreatedDate = x.Field<String>("CreatedDate"),
                 CreatedBy = x.Field<String>("CreatedBy"),
                 UpdatedBy = x.Field<String>("UpdatedBy"),
                 UpdatedDate = x.Field<String>("UpdatedDate"),

             }).ToList();

            result.Add(CallData);
        }
        return result;
    }

    protected void btnCancelClick(object sender, EventArgs e)
    {
        Response.Redirect("EmployeeDALDays.aspx");
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputCustomer)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var CustData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputCustomer.ToString());
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);

                ctx.EMPDs.ToList().ForEach(x => x.Active = false);
                foreach (var row in CustData)
                {
                    int TotalDays = Int32.TryParse(Convert.ToString(row["TDays"]), out TotalDays) ? TotalDays : 0;
                    string EmpDesc = Convert.ToString(row["EmpCode"]);
                    if (TotalDays < 0)
                    {
                        return "WARNING=Please select proper DAL process Days for : " + EmpDesc;
                    }
                    int EmpID = Int32.TryParse(Convert.ToString(row["EmpID"]), out EmpID) ? EmpID : 0;
                    decimal CustomerID = decimal.TryParse(Convert.ToString(row["CustomerID"]), out CustomerID) ? CustomerID : 0;
                    int EmpGroupID = Int32.TryParse(Convert.ToString(row["EmpGroupID"]), out EmpGroupID) ? EmpGroupID : 0;

                    EMPD objEMPD = null;
                    int EmpdID = Int32.TryParse(Convert.ToString(row["EmpdID"]), out EmpdID) ? EmpdID : 0;
                    if (EmpID > 0 || CustomerID > 0)
                    {
                        if (EmpdID == 0 && Convert.ToString(row["IsChange"]) == "1")
                        {
                            objEMPD = new EMPD();
                            objEMPD.CreatedDate = DateTime.Now;
                            objEMPD.CreatedBy = UserID;
                            objEMPD.UpdatedBy = UserID;
                            objEMPD.UpdatedDate = DateTime.Now;
                            ctx.EMPDs.Add(objEMPD);
                        }
                        if (objEMPD == null)
                        {
                            objEMPD = ctx.EMPDs.Where(x => x.EMPDID == EmpdID).FirstOrDefault();
                        }
                        if (objEMPD != null)
                        {
                            objEMPD.EmpID = EmpID;
                            objEMPD.CustomerID = CustomerID;
                            objEMPD.ParentID = 1000010000000000;
                            objEMPD.Days = TotalDays;
                            if (Convert.ToString(row["IsChange"]) == "1")
                            {
                                objEMPD.UpdatedBy = UserID;
                                objEMPD.UpdatedDate = DateTime.Now;
                            }
                            objEMPD.Active = true;
                        }
                        ctx.SaveChanges();
                    }
                }
            }
            return "SUCCESS=DAL process days is submitted successfully";
        }
        catch (Exception ex)
        {
            return "ERROR=Error in data saving process: " + Common.GetString(ex);
        }
    }
}
