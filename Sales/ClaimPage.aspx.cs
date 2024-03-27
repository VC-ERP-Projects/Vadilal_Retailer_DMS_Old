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

public partial class Sales_ClaimPage : System.Web.UI.Page
{
    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData()
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

            List<string> Customer = new List<string>();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                Customer = ctx.OCRDs.Where(x => x.Active && (x.CustomerID == ParentID || x.ParentID == ParentID) && !x.IsTemp).Select(x =>
                    x.CustomerCode + " # " + x.CustomerName.Replace("#", "") + " # " + x.CRD1.FirstOrDefault().OCTY.CityName).ToList();

                result.Add(Customer);
            }

        }
        catch (Exception ex)
        {
            result.Add("ERROR#" + "" + Common.GetString(ex));
        }
        return result;
    }

    [WebMethod]
    public static string GetCustomerByCode(string Code)
    {
        string result = "";

        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                result = ctx.OCRDs.Where(x => x.Active && x.CustomerCode == Code && !x.IsTemp).Select(x =>
                   x.CustomerCode + " # " + x.CustomerName.Replace("#", "") + " # " + x.CRD1.FirstOrDefault().OCTY.CityName).FirstOrDefault();

                if (result == null)
                    result = "";

                return result;
            }
        }
        catch (Exception ex)
        {
            return "";
        }
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

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string tabledata_machine, string postdata)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);

                Decimal DecNum = 0;

                var TableData = JsonConvert.DeserializeObject<dynamic>(tabledata_machine.ToString());
                if (TableData.Count == 0)
                {
                    return "ERROR=No Item Level Record Found.";
                }
                var PostData = JsonConvert.DeserializeObject<dynamic>(postdata.ToString());

                OMCLM objOMCLM = new OMCLM();

                objOMCLM.MClaimID = ctx.GetKey("OMCLM", "MClaimID", "", ParentID, 0).FirstOrDefault().Value;
                objOMCLM.ParentID = ParentID;
                if (Convert.ToString(PostData["txtDocumentDate"]) == "")
                {
                    return "ERROR=Enter Document Date.";
                }
                DateTime dt;
                if (!Common.DateTimeConvert(Convert.ToString(PostData["txtDocumentDate"]), out dt))
                {
                    return "ERROR=Enter Propet Document Date.";
                }
                objOMCLM.Date = dt;

                objOMCLM.VehicleNo = Convert.ToString(PostData["txtVehicleNo"]);
                objOMCLM.TransporterName = Convert.ToString(PostData["txtTransporterName"]);

                objOMCLM.LRNo = Convert.ToString(PostData["txtLRNo"]);
                if (Convert.ToString(PostData["txtLRDate"]) != "")
                {
                    if (!Common.DateTimeConvert(Convert.ToString(PostData["txtLRDate"]), out dt))
                    {
                        return "ERROR=Enter Propet Document Date.";
                    }
                    objOMCLM.LRDate = dt;
                }

                objOMCLM.ChallanNo = Convert.ToString(PostData["txtChallanNo"]);
                if (Convert.ToString(PostData["txtChallanDate"]) != "")
                {
                    if (!Common.DateTimeConvert(Convert.ToString(PostData["txtChallanDate"]), out dt))
                    {
                        return "ERROR=Enter Propet Challan Date Date.";
                    }
                    objOMCLM.ChallanDate = dt;
                }
                objOMCLM.Amount = Decimal.TryParse(Convert.ToString(PostData["txtAmount"]), out DecNum) ? DecNum : 0;
                objOMCLM.CreatedDate = DateTime.Now;
                objOMCLM.CreatedBy = UserID;
                ctx.OMCLMs.Add(objOMCLM);

                int Count = ctx.GetKey("MCLM1", "MCLMID", "", ParentID, 0).FirstOrDefault().Value;
                foreach (var item in TableData)
                {
                    if (Convert.ToString(item["MachineNo"]) == "")
                    {
                        return "ERROR=Enter Proper Machine No.";
                    }
                    else if (Convert.ToString(item["FromDealer"]) == "")
                    {
                        return "ERROR=Enter Proper From Dealer.";
                    }
                    else if (Convert.ToString(item["ToDealer"]) == "")
                    {
                        return "ERROR=Enter Proper To Dealer.";
                    }
                    string FromDealer = Convert.ToString(item["FromDealer"]);
                    string ToDealer = Convert.ToString(item["ToDealer"]);

                    if (!ctx.OCRDs.Any(x => x.CustomerCode == FromDealer && !x.IsTemp && (x.CustomerID == ParentID || x.ParentID == ParentID) && x.Active))
                    {
                        return "ERROR=Enter Proper From Dealer.";
                    }
                    else if (!ctx.OCRDs.Any(x => x.CustomerCode == ToDealer && !x.IsTemp && x.Active))
                    {
                        return "ERROR=Enter Proper To Dealer.";
                    }
                    if (!Decimal.TryParse(Convert.ToString(item["NetValue"]), out DecNum) || DecNum == 0)
                    {
                        return "ERROR=Enter Proper Net Amount.";
                    }

                    MCLM1 objMCLM1 = new MCLM1();

                    objMCLM1.MCLMID = Count++;
                    objMCLM1.AssetCode = Convert.ToString(item["MachineNo"]);
                    objMCLM1.FromDealerID = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == FromDealer && (x.CustomerID == ParentID || x.ParentID == ParentID) && x.Active).CustomerID;
                    objMCLM1.ToDealerID = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == ToDealer && !x.IsTemp && x.Active).CustomerID;
                    objMCLM1.Amount = DecNum;

                    objOMCLM.MCLM1.Add(objMCLM1);
                }
                ctx.SaveChanges();

                return "SUCCESS=Claim Inserted Successfully: Machine Claim No # " + objOMCLM.MClaimID.ToString();
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }
}