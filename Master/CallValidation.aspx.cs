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
public class CallValidate
{
    public int CallValidationID { get; set; }
    public int EmpGroupId { get; set; }
    public int EmpID { get; set; }
    public String EmpGroupDesc { get; set; }
    public int PRCall { get; set; }
    public int NPRCall { get; set; }
    public int TotalCall { get; set; }
    public String CreatedDate { get; set; }
    public string CreatedBy { get; set; }
    public string CreatedIPAddress { get; set; }
    public String UpdatedDate { get; set; }
    public string UpdatedBy { get; set; }
    public string UpdateIPAddress { get; set; }

}

public partial class Call_Validation : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;


    public List<CallValidate> CallValLIST
    {
        get { return ViewState["CallValidation"] as List<CallValidate>; }
        set { ViewState["CallValidation"] = value; }
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
            CallValLIST = new List<CallValidate>();
            LoadData();
        }
    }

    protected void gvCallValidation_RowDataBound(object sender, GridViewRowEventArgs e)
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
    public static List<dynamic> LoadCustomerByType(string prefixText)
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
    public static List<dynamic> GetCustomerDetail(int EmpID)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            if (EmpID > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    OEMP objOEMP = ctx.OEMPs.FirstOrDefault(x => x.EmpID == EmpID);
                    if (objOEMP != null)
                    {
                        OCVE objOCVE = ctx.OCVEs.FirstOrDefault(x => x.EmpID == objOEMP.EmpID && x.Active);
                        var CustData = new
                        {
                            EmpID = objOCVE != null ? objOCVE.EmpID : objOEMP.EmpID,
                            //ProdCall = objOCVE != null ? objOCVE.PRCall : 0,
                            //NonProdCall = objOCVE != null ? objOCVE.NPRCall : 0,
                            TotalCall = objOCVE != null ? objOCVE.TotalCall : 0,
                            CreatedDate = objOCVE != null ? objOCVE.CreatedDate.ToString("dd/MM/yyyy HH:mm") : "",
                            CreatedBy = objOCVE != null ? ctx.OEMPs.Where(x => x.EmpID == objOCVE.CreatedBy).Select(x => x.EmpCode + " - " + x.Name).DefaultIfEmpty("").FirstOrDefault() : "",
                            CreatedIPAddress = objOCVE != null ? string.IsNullOrEmpty(objOCVE.CreatedIPAddress) ? "" : objOCVE.CreatedIPAddress : "",
                            UpdatedBy = objOCVE != null ? ctx.OEMPs.Where(x => x.EmpID == objOCVE.UpdatedBy).Select(x => x.EmpCode + " - " + x.Name).DefaultIfEmpty("").FirstOrDefault() : "",
                            UpdatedDate = objOCVE != null ? objOCVE.UpdatedDate.ToString("dd/MM/yyyy HH:mm") : "",
                            UpdateIPAddress = objOCVE != null ? string.IsNullOrEmpty(objOCVE.UpdateIPAddress) ? "" : objOCVE.UpdateIPAddress : ""
                        };
                        result.Add(CustData);

                    }
                    else
                        result.Add("ERROR=" + "" + "Employee not found.");
                }
            }
            else
                result.Add("ERROR=" + "" + "Please select proper employee.");
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
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
        Cm.CommandText = "GetCallValidationInfo";
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            List<CallValidate> CallData = ds.Tables[0].AsEnumerable().Select
             (x => new CallValidate
             {
                 CallValidationID = x.Field<int>("CallValidationID"),
                 EmpGroupId = x.Field<int>("EmpGroupId"),
                 EmpID = x.Field<int>("EmpID"),
                 EmpGroupDesc = x.Field<String>("EmpGroupDesc"),
                 //PRCall = x.Field<int>("PRCall"),
                 //NPRCall = x.Field<int>("NPRCall"),
                 TotalCall = x.Field<int>("TotalCall"),
                 CreatedDate = x.Field<String>("CreatedDate"),
                 CreatedBy = x.Field<String>("CreatedBy"),
                 CreatedIPAddress = x.Field<String>("CreatedIPAddress"),
                 UpdatedBy = x.Field<String>("UpdatedBy"),
                 UpdatedDate = x.Field<String>("UpdatedDate"),
                 UpdateIPAddress = x.Field<String>("UpdateIPAddress")

             }).ToList();

            result.Add(CallData);
        }
        return result;
    }

    protected void btnCancelClick(object sender, EventArgs e)
    {
        Response.Redirect("CallValidation.aspx");
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputCustomer, string IPAddress)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var CustData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputCustomer.ToString());
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                string IPAdd = IPAddress;
                if (IPAdd == "undefined")
                    IPAdd = "";
                if (IPAdd.Length > 15)
                    IPAdd = IPAdd.Substring(0, 15);
                ctx.OCVEs.ToList().ForEach(x => x.Active = false);
                foreach (var row in CustData)
                {
                    //int PRCall = Int32.TryParse(Convert.ToString(row["ProdCall"]), out PRCall) ? PRCall : 0;
                    //int NPRCall = Int32.TryParse(Convert.ToString(row["NonProdCall"]), out NPRCall) ? NPRCall : 0;
                    int TotalCall = Int32.TryParse(Convert.ToString(row["TCall"]), out TotalCall) ? TotalCall : 0;
                    int EmpID = Int32.TryParse(Convert.ToString(row["EmpID"]), out EmpID) ? EmpID : 0;
                    int EmpGroupID = Int32.TryParse(Convert.ToString(row["EmpGroupID"]), out EmpGroupID) ? EmpGroupID : 0;

                    OCVE objOCVE = null;
                    int CallValidationID = Int32.TryParse(Convert.ToString(row["CallValID"]), out CallValidationID) ? CallValidationID : 0;
                    if (CallValidationID == 0 && Convert.ToString(row["IsChange"]) == "1")
                    {
                        objOCVE = new OCVE();
                        objOCVE.CreatedDate = DateTime.Now;
                        objOCVE.CreatedBy = UserID;
                        objOCVE.CreatedIPAddress = IPAdd;
                        objOCVE.UpdatedBy = UserID;
                        objOCVE.UpdatedDate = DateTime.Now;
                        objOCVE.UpdateIPAddress = IPAdd;
                        ctx.OCVEs.Add(objOCVE);
                    }
                    if (objOCVE == null)
                    {
                        objOCVE = ctx.OCVEs.Where(x => x.CallValidationID == CallValidationID).FirstOrDefault();
                    }
                    if (objOCVE != null)
                    {
                        objOCVE.EmpGroupId = EmpGroupID;
                        objOCVE.EmpID = EmpID;
                        objOCVE.PRCall = 0;//PRCall;
                        objOCVE.NPRCall = 0;//NPRCall;
                        objOCVE.ParentID = 1000010000000000;
                        objOCVE.TotalCall = TotalCall;
                        if (Convert.ToString(row["IsChange"]) == "1")
                        {
                            objOCVE.UpdatedBy = UserID;
                            objOCVE.UpdatedDate = DateTime.Now;
                            objOCVE.UpdateIPAddress = IPAdd;
                        }
                        objOCVE.Active = true;
                    }
                }
                ctx.SaveChanges();
            }
            return "SUCCESS=Call restriction is submitted successfully";
        }
        catch (Exception ex)
        {
            return "ERROR=Error in data saving process: " + Common.GetString(ex);
        }
    }
}
