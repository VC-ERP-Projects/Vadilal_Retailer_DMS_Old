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

public partial class Master_CustomerActiveInActive : System.Web.UI.Page
{
    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

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
    }

    #endregion

    #region AjaxMethods

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetCustomerDetail(string CustCode)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            if (!string.IsNullOrEmpty(CustCode))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustCode);
                    if (objOCRD != null)
                    {
                        int Days = DateTime.Now.Subtract(objOCRD.CreatedDate).Days;
                        if (objOCRD.Type == 3 && Days > 30 && objOCRD.IsTemp == true)
                            objOCRD.Active = false;

                        var CustData = new
                        {
                            CustomerID = objOCRD.CustomerID,
                            CustomerCode = objOCRD.CustomerCode,
                            CustomerName = objOCRD.CustomerName,
                            City = objOCRD.CRD1.Any(x => x.IsDeleted == false && x.CityID > 0) ? objOCRD.CRD1.FirstOrDefault(x => x.IsDeleted == false && x.CityID > 0).OCTY.CityName : "",
                            Active = ctx.ACRD1.Any(x => x.CustomerID == objOCRD.CustomerID) ? ctx.ACRD1.Where(x => x.CustomerID == objOCRD.CustomerID).OrderByDescending(x => x.ACRD1ID).FirstOrDefault().Active : false,
                            SAPActive = objOCRD.Active,
                            LastRemarks = ctx.ACRD1.Any(x => x.CustomerID == objOCRD.CustomerID) ? ctx.ACRD1.Where(x => x.CustomerID == objOCRD.CustomerID).OrderByDescending(x => x.ACRD1ID).FirstOrDefault().Remarks : ""
                        };

                        result.Add(CustData);

                    }
                    else
                        result.Add("ERROR=" + "" + "Customer not found.");
                }
            }
            else
                result.Add("ERROR=" + "" + "Please select proper customer.");
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }

        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadCustomerByType(int CustType, string prefixText)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            List<string> items = new List<string>();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (prefixText == "*")
                {
                    items = ctx.OCRDs.Where(x => x.Type == CustType).Select(x => x.CustomerCode + " - " + x.CustomerName).Take(30).ToList();
                }
                else
                {
                    items = ctx.OCRDs.Where(x => x.Type == CustType && (x.CustomerCode.Contains(prefixText) || x.CustomerName.Contains(prefixText))).Select(x => x.CustomerCode + " - " + x.CustomerName).Take(30).ToList();
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
    public static string SaveData(string hidJsonInputCustomer)
    {
        //List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                var CustData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputCustomer.ToString());

                int Count = ctx.GetKey("AOCRD", "AOCRDID", "", null, null).FirstOrDefault().Value;
                int CountM = ctx.GetKey("ACRD1", "ACRD1ID", "", null, null).FirstOrDefault().Value;

                foreach (var item in CustData)
                {
                    Decimal CustomerID = Decimal.TryParse(Convert.ToString(item["CustomerID"]), out CustomerID) ? CustomerID : 0;
                    string Remarks = Convert.ToString(item["Remarks"]);
                    bool IsActive = Convert.ToBoolean(Convert.ToString(item["IsActive"]));
                    string IPAddress = Convert.ToString(item["IPAddress"]);
                    Boolean LastStatus = true;
                    if (CustomerID > 0)
                    {
                        AOCRD objAOCRD = ctx.AOCRDs.FirstOrDefault(x => x.CustomerID == CustomerID);
                        if (objAOCRD != null)
                        {
                            LastStatus = ctx.ACRD1.Where(x => x.AOCRDID == objAOCRD.AOCRDID).OrderByDescending(x => x.ACRD1ID).Select(x => x.Active).FirstOrDefault();
                        }
                        if (LastStatus != IsActive)
                        {
                            if (objAOCRD == null)
                            {
                                objAOCRD = new AOCRD();
                                objAOCRD.AOCRDID = Count++;
                                objAOCRD.CustomerID = CustomerID;
                                objAOCRD.CreatedBy = UserID;
                                objAOCRD.CreatedDate = DateTime.Now;
                                ctx.AOCRDs.Add(objAOCRD);
                            }
                            objAOCRD.Active = IsActive;
                            objAOCRD.Remarks = Remarks;
                            objAOCRD.IPAddress = IPAddress;

                            ACRD1 objACRD1 = new ACRD1();
                            objACRD1.ACRD1ID = CountM++;
                            objACRD1.AOCRDID = objAOCRD.AOCRDID;
                            objACRD1.CustomerID = CustomerID;
                            objACRD1.Active = IsActive;
                            objACRD1.Remarks = Remarks;
                            objACRD1.UpdatedBy = UserID;
                            objACRD1.UpdatedDate = DateTime.Now;
                            objACRD1.IPAddress = IPAddress;
                            objAOCRD.ACRD1.Add(objACRD1);
                        }
                        else
                        {
                            var Cust = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID).CustomerCode;
                            return "WARNING=Last Status and current status is same for Customer : " + Cust;
                        }
                    }
                }

                ctx.SaveChanges();

                return "SUCCESS=Customer Added Successfully";
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
    public static List<dynamic> LoadReport(string strCustType)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            Int32 CType = Int32.TryParse(strCustType, out CType) ? CType : 0;

            if (CType > 0)
            {
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand CM = new SqlCommand();
                CM.CommandType = System.Data.CommandType.StoredProcedure;
                CM.CommandText = "GetCustomerHistory";
                CM.Parameters.AddWithValue("@CustType", CType);
                DataSet DS = objClass.CommonFunctionForSelect(CM);

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

    #endregion

}