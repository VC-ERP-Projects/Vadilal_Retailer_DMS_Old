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
using System.Configuration;

public partial class Master_CustomerTypeWisePricing : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
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
                CustType = Convert.ToInt32(Session["Type"]);
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

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData()
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            int UserID = Convert.ToInt16(HttpContext.Current.Session["UserID"]);

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Distributors = ctx.OCRDs.Where(x => x.Active && x.CGRP.CustGroupName == "D001" && x.Type == 2).OrderBy(x => x.CustomerName).Select(x => x.CustomerCode + " - " + x.CustomerName).ToList();
                var Dealers = (from c in ctx.OCRDs
                               join d in ctx.OCRDs on new { c.ParentID } equals new { ParentID = d.CustomerID }
                               where d.CGRP.CustGroupName == "D001" && c.Type == 3 && c.Active && d.Active
                               select c.CustomerCode + " - " + c.CustomerName).ToList();

                result.Add(Distributors);
                result.Add(Dealers);
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR#" + "" + Common.GetString(ex));
        }
        return result;
    }

    private void ClearAllInputs()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivision.DataSource = Division;
            ddlDivision.DataBind();
            ddlDivision.ClearSelection();
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

    #endregion

    #region AjaxMethods

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadPriceByCustType(int Division, int CustType, string prefixText)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            List<string> items = new List<string>();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();

                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "GetCustomerTypeWisePriceGroup";
                Cm.Parameters.AddWithValue("@DivisionID", Division);
                Cm.Parameters.AddWithValue("@CustType", CustType);
                Cm.Parameters.AddWithValue("@Prefix", prefixText);

                DataSet DS = objClass.CommonFunctionForSelect(Cm);
                dynamic Data = "";
                if (DS.Tables[0] != null && DS.Tables[0].Rows.Count > 0)
                {
                    Data = DS.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
                    result.Add(Data);
                }
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
    public static List<dynamic> GetPriceGroupDetail(string PriceGroupID, int DivisionID)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            if (!string.IsNullOrEmpty(PriceGroupID))
            {
                int PriceID = int.TryParse(PriceGroupID, out PriceID) ? PriceID : 0;
                if (PriceID > 0)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        OIPL objOIPL = ctx.OIPLs.FirstOrDefault(x => x.PriceListID == PriceID);
                        if (objOIPL != null)
                        {
                            IPL2 objIPL2 = ctx.IPL2.FirstOrDefault(x => x.PriceListID == objOIPL.PriceListID && x.DivisionID == DivisionID);

                            var PriceGroupData = new
                            {
                                PriceListID = objOIPL != null ? objOIPL.PriceListID : 0,
                                PriceDesc = objOIPL != null && !string.IsNullOrEmpty(objOIPL.Description) ? objOIPL.Description : "",
                                IsProductSale = objIPL2 != null ? objIPL2.SelectedProductSale : false,
                                IsClaim = objIPL2 != null ? objIPL2.OnlineClaim : false,
                                LastUpdateBy = objIPL2 != null ? ctx.OEMPs.Where(x => x.EmpID == objIPL2.UpdatedBy).Select(x => x.EmpCode + " - " + x.Name).FirstOrDefault() : "",
                                LastUpdateDate = objIPL2 != null ? objIPL2.UpdatedDate.ToString("dd/MM/yyyy HH:mm") : "",
                                IpAddress = objIPL2 != null ? objIPL2.IPAddress : ""
                            };
                            result.Add(PriceGroupData);
                        }
                        else
                            result.Add("ERROR=" + "" + "Customer not found.");
                    }

                }
                else
                {
                    result.Add("ERROR=" + "" + "Please select proper price group.");
                }
            }
            else
                result.Add("ERROR=" + "" + "Please select proper price group.");
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }

        return result;
    }

    #endregion

    #region Button Events

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport(string strCustType, string strDivision)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            Int32 CustType = Int32.TryParse(strCustType, out CustType) ? CustType : 0;
            Int32 Division = Int32.TryParse(strDivision, out Division) ? Division : 0;

            if (CustType > 0)
            {
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();

                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "GetCustTypeWisePriceGroupHistory";
                Cm.Parameters.AddWithValue("@DivisionID", Division);
                Cm.Parameters.AddWithValue("@CustType", CustType);

                DataSet DS = objClass.CommonFunctionForSelect(Cm);

                DataTable dt;
                if (DS.Tables[0] != null && DS.Tables[0].Rows.Count > 0)
                {
                    dt = DS.Tables[0];
                    result.Add(JsonConvert.SerializeObject(dt));
                }
            }
            else
                result.Add("ERROR=Customer Type Not Found.");
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }

        return result;

    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputPriceGroupList, int Division, int CustType)
    {
        //List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var PriceGroupListData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputPriceGroupList.ToString());

                foreach (var item in PriceGroupListData)
                {
                    int PriceListID = int.TryParse(Convert.ToString(item["PriceListID"]), out PriceListID) ? PriceListID : 0;

                    if (PriceListID > 0)
                    {
                        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                        SqlCommand Cm = new SqlCommand();

                        Cm.Parameters.Clear();
                        Cm.CommandType = CommandType.StoredProcedure;
                        Cm.CommandText = "CustomerTypeWisePriceGroupCheck";
                        Cm.Parameters.AddWithValue("@DivisionID", Division);
                        Cm.Parameters.AddWithValue("@CustType", CustType);
                        Cm.Parameters.AddWithValue("@PriceListID", PriceListID);

                        DataSet DS = objClass.CommonFunctionForSelect(Cm);
                        dynamic Data = "";
                        if (DS.Tables[0] != null && DS.Tables[0].Rows.Count > 0)
                        {
                            bool IsProdSale = Convert.ToBoolean(Convert.ToString(item["IsProdSale"]));
                            bool IsClaim = Convert.ToBoolean(Convert.ToString(item["IsClaim"]));
                            string IPAddress = Convert.ToString(item["IPAddress"]);

                            IPL2 objIPL2 = ctx.IPL2.FirstOrDefault(x => x.PriceListID == PriceListID);
                            if (objIPL2 == null)
                            {
                                objIPL2 = new IPL2()
                                {
                                    PriceListID = PriceListID,

                                    CreatedBy = UserID,
                                    CreatedDate = DateTime.Now
                                };
                                ctx.IPL2.Add(objIPL2);
                            }
                            objIPL2.SelectedProductSale = IsProdSale;
                            objIPL2.DivisionID = Division;
                            objIPL2.CustType = CustType;
                            objIPL2.OnlineClaim = IsClaim;
                            objIPL2.IPAddress = IPAddress;
                            objIPL2.UpdatedBy = UserID;
                            objIPL2.UpdatedDate = DateTime.Now;
                        }
                    }
                    else
                    {
                        return "ERROR=Please select proper pricing group";
                    }
                }
                ctx.SaveChanges();

                return "SUCCESS=Price List Added Successfully";
            }
        }
        catch (Exception ex)
        {

            return "ERROR=Record saving process Error.: " + Common.GetString(ex);

        }
    }

    #endregion

}