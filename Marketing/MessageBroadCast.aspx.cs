using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Data.Objects.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Marketing_MessageBroadCast : System.Web.UI.Page
{
    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #region Helper Method


    public void ClearAllInputs()
    {
       
        //using (DDMSEntities ctx = new DDMSEntities())
        //{
        //    var EmpG = ctx.OGRPs.Where(x => x.Active && x.ParentID == ParentID).Select(x => new { EmpGroupName = x.EmpGroupName + " # " + x.EmpGroupDesc, x.EmpGroupID }).ToList();
        //    ddlEGroup.DataSource = EmpG;
        //    ddlEGroup.DataBind();
        //    ddlEGroup.Items.Insert(0, new ListItem("---Select---", "0"));
        //    ddlEGroup.SelectedValue = "0";

        //}

        txtRegion.Text = "";
       

        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ClearAllInputs();", true);
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
                            var unit = xml.Descendants("message_broadcast");
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

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        
        if (!IsPostBack)
        {
            ClearAllInputs();
            // txtSubject.Focus();
        }
    }

    #endregion

    

    //public void FillGrid(Decimal CustID)
    //{
    //    using (DDMSEntities ctx = new DDMSEntities())
    //    {
    //        Int32 EGID = 0;
    //        RMNU GRPs = new RMNU();
    //        Int32 RegionID = 0, EmpIID = 0;
    //        if (txtRegion.Text.Trim() != "")
    //        {
    //            RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
    //            OCST obj = ctx.OCSTs.Where(x => x.StateID == RegionID).FirstOrDefault();
    //            if (obj == null)
    //            {
    //                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper region.',3);", true);
    //                return;
    //            }
    //        }

    //        //  if (Int32.TryParse(ddlEGroup.SelectedValue, out EGID) && EGID > 0)
    //        //  {
    //        GRPs = ctx.RMNUs.Where(x => x.EmpGroupId == EGID && x.RegionId == RegionID && x.EmployeeId == EmpIID && x.IsActive == true).FirstOrDefault();




    //        //}
    //    }
    //}

    #region TextChanged



    [WebMethod(EnableSession = true)]
    public static List<dynamic> GetMessageDetailByID(string MessageID)
    {
        Decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"].ToString());

        List<dynamic> result = new List<dynamic>();
        try
        {
            Int32 MsgID = Int32.TryParse(MessageID, out MsgID) ? MsgID : 0;
            if (MsgID > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (ctx.OMSGs.Any(x => x.MessageID == MsgID))
                    {
                        OMSG objOMSG = ctx.OMSGs.Include("MSG1").FirstOrDefault(x => x.ParentID == ParentID && x.MessageID == MsgID);
                        var HeaderData = new
                        {
                            MessageID = objOMSG.MessageID,
                            Subject = objOMSG.Subject,
                            CreatedTime = objOMSG.CreatedDate.ToString("dd/MM/yyyy HH:mm"),
                            UpdatedTime = objOMSG.UpdatedDate.ToString("dd/MM/yyyy HH:mm"),
                            CreatedBy = ctx.OEMPs.Where(z => z.ParentID == ParentID && z.EmpID == objOMSG.CreatedBy).Select(z => z.EmpCode + " # " + z.Name).FirstOrDefault(),
                            UpdatedBy = ctx.OEMPs.Where(z => z.ParentID == ParentID && z.EmpID == objOMSG.UpdatedBy).Select(z => z.EmpCode + " # " + z.Name).FirstOrDefault(),
                            Body = objOMSG.MessageBody,
                            AppliFrom = objOMSG.ApplicableFromDate.Value.ToString("dd/MM/yyyy"),
                            AppliTo = objOMSG.ApplicableToDate.Value.ToString("dd/MM/yyyy"),
                            AppliFor = objOMSG.ApplicableFor,
                            IsActive = objOMSG.Active,
                            ImageUpload = string.IsNullOrEmpty(objOMSG.ImageUpload) ? "" : "/Document/MsgBroadcastUpload/" + objOMSG.ImageUpload
                        };

                        result.Add(HeaderData);

                        if (objOMSG.MSG1.Count() > 0)
                        {
                            foreach (var item in objOMSG.MSG1)
                            {
                                var ItemData = new
                                {
                                    AppliFor = item.ApplicableFor,

                                    RegionID = item.RegionID != null && item.RegionID > 0 ? item.RegionID : 0,
                                    Region = item.RegionID != null && item.RegionID > 0 ? ctx.OCSTs.Where(y => y.StateID == item.RegionID).Select(x => x.GSTStateCode + "#" + x.StateName).FirstOrDefault() : "",

                                    heirarchyEmpID = item.HierarchyEmpID != null && item.HierarchyEmpID > 0 ? item.HierarchyEmpID : 0,
                                    heirarchyEmp = item.HierarchyEmpID != null && item.HierarchyEmpID > 0 ? ctx.OEMPs.Where(y => y.EmpID == item.HierarchyEmpID && y.ParentID == ParentID).Select(x => x.EmpCode + "#" + x.Name).FirstOrDefault() : "",

                                    EmpCustGroupID = item.GroupID != null && item.GroupID > 0 ? item.GroupID : 0,
                                    EmpCustGroup = item.ApplicableFor != null && item.GroupID != null && item.GroupID > 0 ?
                                                    (item.ApplicableFor == "E" || item.ApplicableFor == "F" ? ctx.OGRPs.Where(m => m.EmpGroupID == item.GroupID).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).FirstOrDefault() :
                                                    ctx.CGRPs.Where(m => m.CustGroupID == item.GroupID).Select(x => x.CustGroupName + " # " + x.CustGroupDesc).FirstOrDefault()) : "",

                                    EmpCustID = item.UserID != null && item.UserID > 0 ? item.UserID : 0,
                                    EmpCustName = item.ApplicableFor != null && item.UserID != null && item.UserID > 0 ?
                                                    (item.ApplicableFor == "C" ? ctx.OCRDs.Where(y => y.CustomerID == item.UserID).Select(x => x.CustomerCode + "#" + x.CustomerName).FirstOrDefault() :
                                                     ctx.OEMPs.Where(y => y.EmpID == item.UserID && y.ParentID == ParentID).Select(x => x.EmpCode + "#" + x.Name).FirstOrDefault()) : "",

                                    UserType = item.UserType,
                                    IsInclude = item.IsInclude ? "True" : "False"
                                };


                                result.Add(ItemData);
                            }
                        }
                    }
                    else
                    {
                        result.Add("ERROR=No Message Detail found.");
                    }
                }
            }
            else
            {
                result.Add("ERROR=Please select proper Message.");
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }

        return result;
    }

    [WebMethod]
    public static Int32 GetCustGroupID(string CustGroupName)
    {
        Int32 CustGroupID = 0;

        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (ctx.CGRPs.Any(x => x.CustGroupName == CustGroupName))
                CustGroupID = ctx.CGRPs.FirstOrDefault(x => x.CustGroupName == CustGroupName).CustGroupID;
        }

        return CustGroupID;
    }

    [WebMethod]
    public static Int32 GetEmpGroupID(string EmpGroupName)
    {
        Int32 EmpGroupID = 0;

        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (ctx.OGRPs.Any(x => x.EmpGroupName == EmpGroupName))
                EmpGroupID = ctx.OGRPs.FirstOrDefault(x => x.EmpGroupName == EmpGroupName).EmpGroupID;
        }

        return EmpGroupID;
    }

    #endregion

    #region Button Click

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputMaterial, string hidJsonInputHeader)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                DateTime dt;

                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);

                if (ParentID == 0 || UserID == 0)
                {
                    return "ERROR=Your session time out is expire.";
                }
                var DetailData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());
                var HeaderData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputHeader.ToString());

                bool IsAddMode = HeaderData["IsAddMode"];
                Int32 MessageID = Int32.TryParse(Convert.ToString(HeaderData["MessageID"]), out MessageID) ? MessageID : 0;
                string Subject = Convert.ToString(HeaderData["Subject"]);
                string ApplicableFor = Convert.ToString(HeaderData["ApplicableFor"]);
                string FromDate = Convert.ToString(HeaderData["ApplicableFrom"]);
                string ToDate = Convert.ToString(HeaderData["ApplicableTo"]);
                string MessageBody = Convert.ToString(HeaderData["MessageBody"]);
                bool IsActive = Convert.ToBoolean(Convert.ToString(HeaderData["IsActive"]));


                ///// Validate Data
                if (!IsAddMode && MessageID == 0)
                {
                    return "ERROR=Please select message brodcast.";
                }
                if (string.IsNullOrEmpty(Subject))
                {
                    return "ERROR=Please enter Subject for message brodcast.";
                }
                else if (Subject.Length > 200)
                {
                    return "ERROR=Please enter Subject character under 200 for message brodcast.";
                }
                else if (string.IsNullOrEmpty(ApplicableFor))
                {
                    return "ERROR=Please enter ApplicableFor for message brodcast.";
                }
                else if (!DateTime.TryParse(FromDate, out dt))
                {
                    return "ERROR=Please select fromdate for message brodcast.";
                }
                else if (!DateTime.TryParse(ToDate, out dt))
                {
                    return "ERROR=Please select todate for message brodcast.";
                }
                //else if (string.IsNullOrEmpty(MessageBody))
                //{
                //    return "ERROR=Please type message body for message brodcast.";
                //}
                //else if (!string.IsNullOrEmpty(MessageBody) && MessageBody.Length > 500)
                //{
                //    return "ERROR=Please enter message body character under 500 for message brodcast.";
                //}
                if (ctx.OMSGs.Any(x => x.Subject.ToLower() == Subject.Trim().ToLower() && x.MessageID != MessageID && x.ParentID == ParentID))
                {
                    return "ERROR= Same subject name is not allowed!";
                }

                if (((Newtonsoft.Json.Linq.JContainer)(DetailData)).Count == 0 && ApplicableFor != "D")
                {
                    return "ERROR=No Configuration found. Please refresh the page & try agian.";
                }

                foreach (var data in DetailData)
                {
                    if (!string.IsNullOrEmpty(Convert.ToString(data["RegionID"])))
                    {
                        Int32 RegionID = 0;
                        if (Int32.TryParse(Convert.ToString(data["RegionID"]), out RegionID) && RegionID > 0 && !ctx.OCSTs.Any(x => x.StateID == RegionID))
                            return "ERROR=Please select proper region.";
                    }

                    if (!string.IsNullOrEmpty(Convert.ToString(data["EmpID"])))
                    {
                        Int32 EmpID = 0;
                        if (Int32.TryParse(Convert.ToString(data["EmpID"]), out EmpID) && EmpID > 0 && !ctx.OEMPs.Any(x => x.EmpID == EmpID && x.ParentID == ParentID))
                            return "ERROR=Please select proper employee.";
                    }

                    if (!string.IsNullOrEmpty(Convert.ToString(data["EmpGroupID"])))
                    {
                        Int32 EmpGroupID = 0;
                        if (Int32.TryParse(Convert.ToString(data["EmpGroupID"]), out EmpGroupID) && EmpGroupID > 0 && !ctx.OGRPs.Any(x => x.EmpGroupID == EmpGroupID && x.ParentID == ParentID))
                            return "ERROR=Please select proper Employee Group.";
                    }

                    if (!string.IsNullOrEmpty(Convert.ToString(data["HrEmpID"])))
                    {
                        Int32 HrEmpID = 0;
                        if (Int32.TryParse(Convert.ToString(data["HrEmpID"]), out HrEmpID) && HrEmpID > 0 && !ctx.OEMPs.Any(x => x.EmpID == HrEmpID && x.ParentID == ParentID))
                            return "ERROR=Please select proper Hierarchy Employee.";
                    }

                    if (!string.IsNullOrEmpty(Convert.ToString(data["CustGroupID"])))
                    {
                        Int32 CustGroupID = 0;
                        if (Int32.TryParse(Convert.ToString(data["CustGroupID"]), out CustGroupID) && CustGroupID > 0 && !ctx.CGRPs.Any(x => x.CustGroupID == CustGroupID))
                            return "ERROR=Please select proper Customer Group.";
                    }

                    if (!string.IsNullOrEmpty(Convert.ToString(data["SSID"])))
                    {
                        Decimal SSID = 0;
                        if (Decimal.TryParse(Convert.ToString(data["SSID"]), out SSID) && SSID > 0 && !ctx.OCRDs.Any(x => x.CustomerID == SSID && x.Type == 4))
                            return "ERROR=Please select proper SS.";
                    }

                    if (!string.IsNullOrEmpty(Convert.ToString(data["DistriID"])))
                    {
                        Decimal DistriID = 0;
                        if (Decimal.TryParse(Convert.ToString(data["DistriID"]), out DistriID) && DistriID > 0 && !ctx.OCRDs.Any(x => x.CustomerID == DistriID && x.Type == 2))
                            return "ERROR=Please select proper Distributor.";
                    }

                    string IsInclude = Convert.ToString(data["IsInclude"]);
                    if ((string.IsNullOrEmpty(IsInclude) || !new string[] { "true", "false" }.Contains(IsInclude.Trim().ToLower())))
                        return "ERROR=Please select proper Is Include.";
                }


                ////////////////// Save Data

                OMSG objOMSG = ctx.OMSGs.FirstOrDefault(x => x.MessageID == MessageID && x.ParentID == ParentID);
                if (objOMSG == null)
                {
                    objOMSG = new OMSG();
                    objOMSG.MessageID = ctx.GetKey("OMSG", "MessageID", "", ParentID, 0).FirstOrDefault().Value;
                    objOMSG.ParentID = ParentID;
                    objOMSG.MessageDate = DateTime.Now;
                    objOMSG.MessageTime = DateTime.Now.TimeOfDay;
                    objOMSG.CreatedDate = DateTime.Now;
                    objOMSG.CreatedBy = UserID;
                    ctx.OMSGs.Add(objOMSG);
                }
                objOMSG.Subject = Subject;
                objOMSG.ApplicableFor = ApplicableFor;
                objOMSG.MessageBody = MessageBody.ToString().Replace("&gt;", ">").Replace("&lt;", "<").Replace("&quot;", "'");
                objOMSG.ApplicableFromDate = Convert.ToDateTime(FromDate);
                objOMSG.ApplicableToDate = Convert.ToDateTime(ToDate);
                objOMSG.UpdatedBy = UserID;
                objOMSG.UpdatedDate = DateTime.Now;
                objOMSG.Active = IsActive;

                int Count = ctx.GetKey("MSG1", "MSG1ID", "", ParentID, 0).FirstOrDefault().Value;
                Int32 IntNum = 0;
                Decimal DecNum = 0;

                if (!IsAddMode && objOMSG.MSG1 != null && objOMSG.MSG1.Count() > 0)
                {
                    objOMSG.MSG1.ToList().ForEach(x => ctx.MSG1.Remove(x));
                }

                foreach (var data in DetailData)
                {
                    MSG1 objMSG1 = new MSG1();
                    objMSG1.MSG1ID = Count++;
                    objMSG1.ParentID = ParentID;
                    objMSG1.ApplicableFor = objOMSG.ApplicableFor;

                    if (Decimal.TryParse(Convert.ToString(data["DistriID"]), out DecNum) && DecNum > 0 && objMSG1.ApplicableFor == "C")
                    {
                        objMSG1.UserID = DecNum;
                        objMSG1.UserType = 2;
                    }
                    else if (Decimal.TryParse(Convert.ToString(data["SSID"]), out DecNum) && DecNum > 0 && objMSG1.ApplicableFor == "C")
                    {
                        objMSG1.UserID = DecNum;
                        objMSG1.UserType = 4;
                    }
                    else if (Int32.TryParse(Convert.ToString(data["EmpID"]), out IntNum) && IntNum > 0 && objMSG1.ApplicableFor == "E")
                    {
                        objMSG1.UserID = IntNum;
                        objMSG1.UserType = 1;
                    }
                    else if (Int32.TryParse(Convert.ToString(data["EmpID"]), out IntNum) && IntNum > 0 && objMSG1.ApplicableFor == "F")
                    {
                        objMSG1.UserID = IntNum;
                        objMSG1.UserType = 1;
                    }
                    else if (Int32.TryParse(Convert.ToString(data["EmpGroupID"]), out IntNum) && IntNum > 0 && objMSG1.ApplicableFor == "E")
                        objMSG1.GroupID = IntNum;
                    else if (Int32.TryParse(Convert.ToString(data["CustGroupID"]), out IntNum) && IntNum > 0 && objMSG1.ApplicableFor == "C")
                        objMSG1.GroupID = IntNum;
                    else if (Int32.TryParse(Convert.ToString(data["EmpGroupID"]), out IntNum) && IntNum > 0 && objMSG1.ApplicableFor == "F")
                        objMSG1.GroupID = IntNum;
                    else if (Int32.TryParse(Convert.ToString(data["HrEmpID"]), out IntNum) && IntNum > 0)
                        objMSG1.HierarchyEmpID = IntNum;
                    else if (Int32.TryParse(Convert.ToString(data["RegionID"]), out IntNum) && IntNum > 0)
                        objMSG1.RegionID = IntNum;

                    objMSG1.IsInclude = Convert.ToBoolean(Convert.ToString(data["IsInclude"]));

                    objOMSG.MSG1.Add(objMSG1);
                }

                ctx.SaveChanges();

                return "SUCCESS= Message Saved SuccessFully, Your Message Code:" + objOMSG.MessageID + "";
            }

        }
        catch (DbEntityValidationException ex)
        {
            var error = ex.EntityValidationErrors.First().ValidationErrors.First();
            return "ERROR= EntityValidation. Something is worng: " + error.ErrorMessage.ToString();
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }


    #endregion




}
