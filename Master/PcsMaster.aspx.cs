using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using System.Data.SqlClient;
using System.Data;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Configuration;

[Serializable]
public class PurSaleItem
{
    public int ItemMapID { get; set; }
    public string PurItem { get; set; }
    public int PurchaseItemID { get; set; }
    public string SaleItem { get; set; }
    public int SaleItemID { get; set; }
    public decimal MapQty { get; set; }
    public String CreatedDate { get; set; }
    public string CreatedBy { get; set; }
    public String UpdatedDate { get; set; }
    public string UpdatedBy { get; set; }
}
public partial class Master_PcsMaster : System.Web.UI.Page
{
    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
    #endregion

    #region HelperMethod

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                int CustType = Convert.ToInt32(Session["Type"]);
                Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);
                LogoURL = Common.GetLogo(ParentID);
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

                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
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

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }
    private void ClearAllInputs()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivision.DataSource = Division;
            ddlDivision.DataBind();
            ddlDivision.ClearSelection();
            ddlDivision.SelectedValue = "5";
        }
    }

    #endregion

    #region AjaxMethods

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadItemByDivision(int DivisionID)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            List<string> items = new List<string>();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                items = (from c in ctx.OITMs
                         where (DivisionID == 0 || c.OGITMs.Any(x => x.DivisionlID == DivisionID && x.ItemID == c.ItemID)) && c.Active
                         orderby c.ItemName
                         select c.ItemCode + " - " + c.ItemName + " - " + SqlFunctions.StringConvert((double)c.ItemID).Trim()).ToList();
                result.Add(items);
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
    public static List<dynamic> LoadData(int DivisionID)
    {
        List<dynamic> result = new List<dynamic>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetPurSaleItemDataMaster";
        Cm.Parameters.AddWithValue("@DivisionID", DivisionID);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            List<PurSaleItem> PurSaleItemData = ds.Tables[0].AsEnumerable().Select
             (x => new PurSaleItem
             {
                 ItemMapID = x.Field<int>("ItemMapID"),
                 PurchaseItemID = x.Field<int>("PurchaseItemID"),
                 PurItem = x.Field<String>("PurItem"),
                 SaleItem = x.Field<String>("SaleItem"),
                 SaleItemID = x.Field<int>("SaleItemID"),
                 MapQty = x.Field<decimal>("MapQty"),
                 CreatedDate = x.Field<String>("CreatedDate"),
                 CreatedBy = x.Field<String>("CreatedBy"),
                 UpdatedBy = x.Field<String>("UpdatedBy"),
                 UpdatedDate = x.Field<String>("UpdatedDate"),
             }).ToList();

            result.Add(PurSaleItemData);
        }
        return result;
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputItem, int DivisionID)
    {
        //List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int count = 0;
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var ItemData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputItem.ToString());

                var Items = (from c in ctx.OITMs
                             join i in ctx.ITM5 on c.ItemID equals i.PurchaseItemID
                             where (c.OGITMs.Any(x => x.DivisionlID == DivisionID && x.ItemID == c.ItemID))
                             select i
                            ).ToList();

                Items.ToList().ForEach(u => u.IsActive = false);

                foreach (var item in ItemData)
                {
                    int ItemMapID = int.TryParse(Convert.ToString(item["ItemMapID"]), out ItemMapID) ? ItemMapID : 0;

                    int PurchaseItemID = int.TryParse(Convert.ToString(item["PurchaseItemID"]), out PurchaseItemID) ? PurchaseItemID : 0;
                    Decimal MapQty = Decimal.TryParse(Convert.ToString(item["MapQty"]), out MapQty) ? MapQty : 0;
                    int SaleItemID = int.TryParse(Convert.ToString(item["SaleItemID"]), out SaleItemID) ? SaleItemID : 0;
                    if (PurchaseItemID > 0 && SaleItemID > 0 && MapQty > 0)
                    {
                        count++;
                        ITM5 objITM5 = ctx.ITM5.FirstOrDefault(x => x.ItemMapID == ItemMapID);
                        if (objITM5 == null && Convert.ToString(item["IsChange"]) == "1")
                        {
                            objITM5 = new ITM5();
                            objITM5.CreatedDate = DateTime.Now;
                            objITM5.CreatedBy = UserID;
                            objITM5.UnitID = 2;
                            ctx.ITM5.Add(objITM5);
                        }
                        if (Convert.ToString(item["IsChange"]) == "1")
                        {
                            objITM5.PurchaseItemID = PurchaseItemID;
                            objITM5.SaleItemID = SaleItemID;
                            objITM5.MapQty = MapQty;
                            objITM5.UpdatedBy = UserID;
                            objITM5.UpdatedDate = DateTime.Now;
                        }
                        objITM5.IsActive = true;
                    }
                }
                if (count == 0)
                {
                    return "WARNING=Please enter atleast one record";
                }

                ctx.SaveChanges();
                return "SUCCESS=Items Added Successfully";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }

    #endregion

    #region Button Events

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport(int DivisionID)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            if (DivisionID > 0)
            {
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand CM = new SqlCommand();
                CM.CommandType = System.Data.CommandType.StoredProcedure;
                CM.CommandText = "ReportPurSaleItemDataMaster";
                CM.Parameters.AddWithValue("@DivisionID", DivisionID);
                DataSet DS = objClass.CommonFunctionForSelect(CM);

                DataTable dt;
                if (DS.Tables[0] != null && DS.Tables[0].Rows.Count > 0)
                {
                    dt = DS.Tables[0];
                    result.Add(JsonConvert.SerializeObject(dt));
                }
            }
            else
                result.Add("ERROR=Division Not Found.");
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    #endregion
}