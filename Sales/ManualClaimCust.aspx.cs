using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Objects;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Sales_ManualClaimCust : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    [Serializable]
    public class Person
    {
        public int ReasonID { get; set; }
        public string ReasonName { get; set; }
    }
    [Serializable]
    public class RootObject
    {
        public List<Person> ReasonIDs { get; set; }
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

    public void ClearAllInputs()
    {
        txtDate.Text = DateTime.Now.AddMonths(-1).ToString("MM/yyyy");
        txtDistCode.Text = txtSSDistCode.Text = "";
        divDistributor.Visible = divSS.Visible = false;

        if (CustType == 2)
        {
            divDistributor.Visible = true;
            txtDistCode.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }
        if (CustType == 4)
        {
            divSS.Visible = true;
            txtSSDistCode.Enabled = false;

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
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
        }
    }

    #endregion

    #region ButtonClick

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetItemDetails()
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                List<Person> reasonList = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new Person { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), ReasonID = x.ReasonID }).OrderBy(x => x.ReasonName).ToList();

                if (reasonList.Count > 0)
                    result.Add(reasonList);
                else
                    result.Add("ERROR=" + "" + "No reason code availalble");
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
    public static string SaveData(string hidJsonInputData, int IsAnyRowDeleted, string ClaimDate, string IPAdd)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (!string.IsNullOrEmpty(ClaimDate))
                {
                    int count = 0;

                    if (IPAdd == "undefined")
                        IPAdd = "";
                    if (IPAdd.Length > 15)
                        IPAdd = IPAdd = IPAdd.Substring(0, 15);

                    int UserID = Int32.TryParse(HttpContext.Current.Session["UserID"].ToString(), out UserID) ? UserID : 0;
                    Decimal ParentID = Decimal.TryParse(HttpContext.Current.Session["ParentID"].ToString(), out ParentID) ? ParentID : 0;
                    if (ParentID == 0)
                    {
                        return "WARNING=Customer Entry Not found. please refresh and try again";
                    }
                    var CustomerListData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputData.ToString());
                    DateTime ClaimFromdate = Convert.ToDateTime(ClaimDate);
                    DateTime ClaimTodate = new DateTime(ClaimFromdate.Year, ClaimFromdate.Month, DateTime.DaysInMonth(ClaimFromdate.Year, ClaimFromdate.Month));

                    string serverPath = HttpContext.Current.Server.MapPath("~/Document/ManualClaimImg/");
                    if (!Directory.Exists(serverPath))
                        Directory.CreateDirectory(serverPath);

                    var result = JsonConvert.DeserializeObject<List<Person>>(hidJsonInputData.ToString());
                    var ReasonIDCount = result.Select(p => p.ReasonID).ToList().Distinct();

                    if (result.Count() != ReasonIDCount.Count())
                    {
                        return "WARNING=Reason code should not be same for multiple row";
                    }
                    Decimal cparentid = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID).ParentID;
                    int OCLMPID = ctx.GetKey("OCLMP", "ParentClaimID", "", ParentID, 0).FirstOrDefault().Value;
                    int OCLMID = ctx.GetKey("OCLM", "ClaimID", "", ParentID, 0).FirstOrDefault().Value;
                    int OCLMCLDID = ctx.GetKey("OCLMCLD", "ClaimChildID", "", cparentid, 0).FirstOrDefault().Value;

                    foreach (var item in CustomerListData)
                    {
                        count++;
                        int ReasonID = int.TryParse(Convert.ToString(item["ReasonID"]), out ReasonID) ? ReasonID : 0;
                        decimal ClaimAmt = decimal.TryParse(Convert.ToString(item["ClaimAmt"]), out ClaimAmt) ? ClaimAmt : 0;

                        var dict = JsonConvert.DeserializeObject<dynamic>(Convert.ToString(item["ImageList"]));
                        if (dict != null)
                        {
                            bool imageAvail = false;
                            List<string> imageList = new List<string>();
                            foreach (var Image in dict)
                            {
                                string FileExt = Path.GetExtension(Image.FileName); ///need to debug
                                string fileName = Path.Combine(Guid.NewGuid().ToString("N")) + FileExt;
                                byte[] FileBytesPhotoIn = Convert.FromBase64String(Convert.ToString(Image));
                                FileStream file = File.Create(Path.Combine(serverPath, fileName));
                                file.Write(FileBytesPhotoIn, 0, FileBytesPhotoIn.Length);
                                file.Close();
                                imageList.Add(fileName);
                                imageAvail = true;
                            }
                            if (ReasonID > 0)
                            {
                                if (ClaimAmt > 0)
                                {
                                    if (imageAvail)
                                    {
                                        var ReasonData = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonID);

                                        if (ctx.OCLMPs.Any(x => x.SchemeType == ReasonData.ReasonDesc && EntityFunctions.TruncateTime(x.FromDate) == EntityFunctions.TruncateTime(ClaimFromdate)
                                            && EntityFunctions.TruncateTime(x.ToDate) == EntityFunctions.TruncateTime(ClaimTodate) && x.ParentID == ParentID && (!x.OCLMs.Any(z => z.Status == 6))))
                                        {
                                            return "WARNING=Same Claim is already exists of " + ReasonData.ReasonName + " # " + (ReasonData.Active ? "ACTIVE" : "INACTIVE") + " ,so you can not process same claim again";
                                        }
                                        if (!ctx.OCRDs.Any(x => x.CustomerID == cparentid))
                                        {
                                            return "WARNING=Parent Entry Not found. please refresh and try again";
                                        }

                                        OCLMP objOCLMP = new OCLMP();
                                        objOCLMP.ParentClaimID = OCLMPID++;
                                        objOCLMP.ParentID = ParentID;
                                        objOCLMP.SchemeType = ReasonData.ReasonDesc;
                                        objOCLMP.CreatedDate = DateTime.Now;
                                        objOCLMP.FromDate = ClaimFromdate;
                                        objOCLMP.ToDate = ClaimTodate;
                                        objOCLMP.CreatedBy = UserID;
                                        objOCLMP.IsSAP = true;
                                        objOCLMP.CreatedIPAddress = IPAdd;
                                        objOCLMP.ClaimImage = imageList.Count > 0 ? string.Join(",", imageList) : "";
                                        objOCLMP.ClaimRemarks = Convert.ToString(item["Remarks"]);

                                        if (ctx.OCRDs.FirstOrDefault(x => x.CustomerID == cparentid).Type == 4)// Process for Dist of SS
                                        {
                                            objOCLMP.IsSAP = false;
                                        }
                                        ctx.OCLMPs.Add(objOCLMP);

                                        OCLM objOCLM = new OCLM();
                                        objOCLM.ClaimID = OCLMID++;
                                        objOCLM.ParentID = ParentID;
                                        objOCLM.Status = 1;
                                        objOCLM.SAPReasonItemCode = ReasonData.SAPReasonItemCode;
                                        objOCLM.TotalQty = 0;
                                        objOCLM.SchemeID = 0;
                                        objOCLM.SchemeType = ReasonData.ReasonDesc;
                                        objOCLM.SchemeAmount = ClaimAmt;
                                        objOCLM.CompanyCont = ClaimAmt;
                                        objOCLM.DistCont = 0;
                                        objOCLM.DistContTax = 0;
                                        objOCLM.TotalCompanyCont = ClaimAmt;
                                        objOCLM.Deduction = 0;
                                        objOCLM.DeductionRemarks = "";
                                        objOCLM.ApprovedAmount = 0;
                                        objOCLM.Total = 0;
                                        objOCLM.TotalPurchase = 0;
                                        objOCLM.IsAuto = false;
                                        objOCLM.SAPDocNo = "";
                                        objOCLMP.OCLMs.Add(objOCLM);

                                        if (objOCLMP.IsSAP == false)
                                        {
                                            OCLMCLD objOCLMCLD = new OCLMCLD();
                                            objOCLMCLD.ClaimChildID = OCLMCLDID++;
                                            objOCLMCLD.ParentID = cparentid;
                                            objOCLMCLD.DocNo = DateTime.Now.ToString("yyMMdd") + objOCLMCLD.ClaimChildID.ToString("D7");
                                            objOCLMCLD.CustomerID = objOCLMP.ParentID;
                                            objOCLMCLD.ParentClaimID = objOCLMP.ParentClaimID;
                                            objOCLMCLD.FromDate = objOCLMP.FromDate;
                                            objOCLMCLD.ToDate = objOCLMP.ToDate;
                                            objOCLMCLD.ClaimDate = objOCLMP.CreatedDate;
                                            objOCLMCLD.SchemeAmount = objOCLM.SchemeAmount;
                                            objOCLMCLD.Deduction = 0;
                                            objOCLMCLD.ApprovedAmount = objOCLM.SchemeAmount;
                                            objOCLMCLD.DeductionRemarks = null;
                                            objOCLMCLD.ReasonCode = objOCLM.SAPReasonItemCode;
                                            objOCLMCLD.IsAuto = true;
                                            objOCLMCLD.TotalSale = objOCLM.Total;
                                            objOCLMCLD.SchemeSale = objOCLM.TotalPurchase;
                                            objOCLMCLD.CreatedDate = DateTime.Now;
                                            objOCLMCLD.CreatedBy = UserID;
                                            objOCLMCLD.UpdatedDate = DateTime.Now;
                                            objOCLMCLD.UpdatedBy = UserID;
                                            objOCLMCLD.Status = 1;
                                            ctx.OCLMCLDs.Add(objOCLMCLD);
                                        }
                                    }
                                    else
                                    {
                                        return "WARNING=Please select proper Image at row :" + count;
                                    }
                                }
                                else
                                {
                                    return "WARNING=Claim Amount must be greater than ZERO at row :" + count;
                                }
                            }
                            else
                            {
                                return "WARNING=Please select proper reason code at row :" + count;
                            }
                        }
                        else
                        {
                            return "WARNING=Image is compulsory so Please select proper image at row :" + count;
                        }
                    }

                    if (count == 0 && IsAnyRowDeleted == 0)
                    {
                        return "WARNING=Please enter atleast one record";
                    }
                }
                else
                {
                    return "WARNING=Please select proper Month";
                }
                ctx.SaveChanges();
                return "SUCCESS=Record submitted successfully";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is wrong: " + Common.GetString(ex);
        }
    }
    #endregion
}