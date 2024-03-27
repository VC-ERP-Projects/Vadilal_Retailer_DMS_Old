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

public partial class Master_LeaveApproval : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType, Index;
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
            List<string> Employee = new List<string>();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ctx.OEMPs.Any(x => x.EmpID == UserID && x.ParentID == ParentID && x.IsAdmin))
                    Employee = ctx.OEMPs.Where(x => x.Active && x.ParentID == ParentID).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).ToList();
                else
                    Employee = ctx.EmployeeList(ParentID, UserID).ToList().Select(x => x.EmpCode + " - " + x.EmpName + " - " + x.EmpID.ToString()).ToList();
                result.Add(Employee);
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
        gvApprovalList.DataSource = null;
        gvApprovalList.DataBind();
        AutoEmp.Text = "";
        txtFromDate.Value = txtToDate.Value = Common.DateTimeConvert(DateTime.Now);
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

    #region Button Click

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        try
        {
            var EmpID = 0;
            if (!string.IsNullOrEmpty(AutoEmp.Text) && AutoEmp.Text.Split('-').Length == 3)
                EmpID = (int.TryParse(AutoEmp.Text.Split('-')[2], out EmpID) ? EmpID : 0);
            Int32 ReqType = Int32.TryParse(ddlRequestType.SelectedValue, out ReqType) ? ReqType : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetLeaveApprovelist";
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@UserID", UserID);
            Cm.Parameters.AddWithValue("@FromDate", Common.DateTimeConvert(txtFromDate.Value));
            Cm.Parameters.AddWithValue("@ToDate", Common.DateTimeConvert(txtToDate.Value));
            Cm.Parameters.AddWithValue("@SUserID", EmpID);
            Cm.Parameters.AddWithValue("@Status", ReqType);

            gvApprovalList.DataSource = objClass.CommonFunctionForSelect(Cm);
            gvApprovalList.DataBind();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnApprove_Click(object sender, EventArgs e)
    {
        bool errFound = true;

        using (DDMSEntities ctx = new DDMSEntities())
        {
            List<NotiData> NData = new List<NotiData>();

            foreach (GridViewRow item in gvApprovalList.Rows)
            {
                CheckBox chkCheck = (CheckBox)item.FindControl("chkCheck");
                TextBox txtAppDays = (TextBox)item.FindControl("txtAppDays");
                Decimal AppDay = 0;

                if (chkCheck.Checked && gvApprovalList.Enabled)
                {
                    errFound = false;
                    if (string.IsNullOrEmpty(txtAppDays.Text) || Decimal.TryParse(txtAppDays.Text, out AppDay) && AppDay <= 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter days approved at row no. : " + (item.RowIndex + 1).ToString() + "',3);", true);
                        return;
                    }
                }
            }
            if (errFound == true)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one row!',3);", true);
                return;
            }

            var EmpData = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => new { x.EmpCode, x.Name, EmpGroupID = x.EmpGroupID.Value }).FirstOrDefault();
            foreach (GridViewRow item in gvApprovalList.Rows)
            {
                CheckBox chkCheck = (CheckBox)item.FindControl("chkCheck");
                if (chkCheck.Checked && chkCheck.Enabled)
                {
                    int OLVAPCount = ctx.GetKey("OLVAP", "OLVAPID", "", ParentID, 0).FirstOrDefault().Value;

                    Label lblLeaveReqID = (Label)item.FindControl("lblLeaveReqID");
                    Int32 LeaveReqID = Int32.TryParse(lblLeaveReqID.Text, out LeaveReqID) ? LeaveReqID : 0;

                    Label lblEmpID = (Label)item.FindControl("lblEmpID");
                    Int32 EmpID = Int32.TryParse(lblEmpID.Text, out EmpID) ? EmpID : 0;

                    TextBox txtAppDays = (TextBox)item.FindControl("txtAppDays");
                    Decimal AppDays = Decimal.TryParse(txtAppDays.Text, out AppDays) ? AppDays : 0;

                    TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");

                    OLVRQ objOLVRQ = ctx.OLVRQs.FirstOrDefault(x => x.EmpID == EmpID && x.ParentID == ParentID && x.LeaveReqID == LeaveReqID);
                    OLVBL objOLVBL = ctx.OLVBLs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpID == EmpID && x.LeaveTypeID == objOLVRQ.LeaveTypeID);

                    if (objOLVRQ.NoOfDays >= AppDays)
                    {
                        OLVAP objOLVAP = new OLVAP();
                        objOLVAP.OLVAPID = OLVAPCount++;
                        objOLVAP.LeaveReqID = LeaveReqID;
                        objOLVAP.EmpID = EmpID;
                        objOLVAP.ParentID = ParentID;
                        objOLVAP.ManagerID = objOLVRQ.ManagerID;
                        objOLVAP.LeaveTypeID = objOLVRQ.LeaveTypeID;
                        objOLVAP.NoOfDays = AppDays;
                        objOLVAP.Status = 2;
                        if (objOLVRQ.NextManagerID.HasValue)
                            objOLVRQ.Status = 4;
                        else
                            objOLVRQ.Status = 2;
                        OAWRK objOAWRK = ctx.OAWRKs.Where(x => x.RequestTypeMenuID == 9114 && x.Status == 2 && x.LevelNo > objOLVRQ.LevelNo && x.Active).OrderBy(x => x.LevelNo).FirstOrDefault();
                        if (objOAWRK == null)
                        {
                            //Final and Last Manager
                            objOLVAP.NextManagerID = null;
                            objOLVAP.LevelNo = objOLVRQ.LevelNo;
                            objOLVRQ.NextManagerID = null;
                            objOLVRQ.Status = objOLVAP.Status;
                        }
                        else
                        {
                            if (objOAWRK.IsManager)
                            {
                                if (ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOLVRQ.NextManagerID && x.ParentID == ParentID).ManagerID.HasValue)
                                {
                                    //next requester manager tick then go to immediate manager
                                    int MangerID = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOLVRQ.NextManagerID && x.ParentID == ParentID).ManagerID.Value;
                                    objOLVAP.NextManagerID = MangerID;
                                    objOLVRQ.NextManagerID = MangerID;
                                    objOLVAP.LevelNo = objOLVRQ.LevelNo;
                                    objOLVRQ.LevelNo = objOAWRK.LevelNo;
                                }
                                else
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Next Approval Manager is not found',3);", true);
                                    return;
                                }
                            }
                            else if (objOAWRK.UserID.HasValue)
                            {
                                objOLVAP.NextManagerID = objOAWRK.UserID.Value;
                                objOLVAP.LevelNo = objOLVRQ.LevelNo;
                                objOLVRQ.NextManagerID = objOAWRK.UserID.Value;
                                objOLVRQ.LevelNo = objOAWRK.LevelNo;
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Next Approval Manager is not found',3);", true);
                                return;
                            }
                        }
                        //add Requested bal
                        objOLVBL.LeaveBalance += objOLVRQ.NoOfDays;
                        //minus App Days
                        objOLVBL.LeaveBalance -= AppDays;
                        objOLVBL.UpdatedDate = DateTime.Now;
                        objOLVBL.UpdatedBy = UserID;

                        objOLVAP.Notes = txtRemarks.Text;
                        objOLVAP.CreatedDate = DateTime.Now;
                        objOLVAP.CreatedBy = UserID; objOLVAP.UpdatedDate = DateTime.Now;
                        objOLVAP.UpdatedBy = UserID;
                        ctx.OLVAPs.Add(objOLVAP);

                        var Emp = ctx.OEMPs.Where(x => x.EmpID == objOLVRQ.EmpID && x.ParentID == ParentID).Select(x => new { x.EmpCode, x.Name, EmpGroupID = x.EmpGroupID.Value }).FirstOrDefault();

                        NData.Add(new NotiData(9115, "Leave Approval", "Leave Approved By :" + EmpData.EmpCode + " # " + EmpData.Name + " For Applicant : " + Emp.EmpCode + " # " + Emp.Name + ", From Date : " + Common.DateTimeConvert(objOLVRQ.FromDate) + " To Date :" + Common.DateTimeConvert(objOLVRQ.ToDate) + ", No Of Days : " + objOLVAP.NoOfDays + ", Leave Type : "
                       + ctx.OLVTies.FirstOrDefault(x => x.LeaveTypeID == objOLVAP.LeaveTypeID).LeaveName + ", Reason : " + objOLVAP.Notes + ", Status : Approved", objOLVRQ.CreatedBy, 0));
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Approving Leave Balance can not be more than Requested Leave Balance.',3);", true);
                        return;
                    }

                    ctx.SaveChanges();

                    OMNUR objOMNU = ctx.OMNURs.FirstOrDefault(x => x.MenuID == 9115 && x.EmpGroupID == EmpData.EmpGroupID);
                    if (objOMNU != null && objOMNU.Notification)
                    {
                        foreach (NotiData data in NData)
                        {
                            Thread t = new Thread(() => { Service.SendNotificationFlow(data.MenuID, data.RequestID, UserID, ParentID, data.Body, data.Title, 0); });
                            t.Name = Guid.NewGuid().ToString();
                            t.Start();
                        }
                    }
                }
            }
            ClearAllInputs();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully.',1);", true);
        }
    }

    protected void btnReject_Click(object sender, EventArgs e)
    {
        bool errFound = true;

        using (DDMSEntities ctx = new DDMSEntities())
        {
            List<NotiData> NData = new List<NotiData>();

            foreach (GridViewRow item in gvApprovalList.Rows)
            {
                CheckBox chkCheck = (CheckBox)item.FindControl("chkCheck");
                TextBox txtAppDays = (TextBox)item.FindControl("txtAppDays");
                Int32 AppDay = Int32.TryParse(txtAppDays.Text, out AppDay) ? AppDay : 0;

                if (chkCheck.Checked && gvApprovalList.Enabled)
                {
                    errFound = false;
                }
            }
            if (errFound == true)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one row!',3);", true);
                return;
            }

            var EmpData = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => new { x.EmpCode, x.Name, EmpGroupID = x.EmpGroupID.Value }).FirstOrDefault();
            foreach (GridViewRow item in gvApprovalList.Rows)
            {
                CheckBox chkCheck = (CheckBox)item.FindControl("chkCheck");
                if (chkCheck.Checked && chkCheck.Enabled)
                {
                    int OLVAPCount = ctx.GetKey("OLVAP", "OLVAPID", "", ParentID, 0).FirstOrDefault().Value;

                    Label lblLeaveReqID = (Label)item.FindControl("lblLeaveReqID");
                    Int32 LeaveReqID = Int32.TryParse(lblLeaveReqID.Text, out LeaveReqID) ? LeaveReqID : 0;

                    Label lblEmpID = (Label)item.FindControl("lblEmpID");
                    Int32 EmpID = Int32.TryParse(lblEmpID.Text, out EmpID) ? EmpID : 0;

                    TextBox txtAppDays = (TextBox)item.FindControl("txtAppDays");
                    Int32 AppDays = Int32.TryParse(txtAppDays.Text, out AppDays) ? AppDays : 0;

                    TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");

                    OLVRQ objOLVRQ = ctx.OLVRQs.FirstOrDefault(x => x.EmpID == EmpID && x.ParentID == ParentID && x.LeaveReqID == LeaveReqID);
                    OLVBL objOLVBL = ctx.OLVBLs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpID == EmpID && x.LeaveTypeID == objOLVRQ.LeaveTypeID);

                    Decimal AvalBal = 0;

                    OLVAP objlastappOLVAP = ctx.OLVAPs.Where(x => x.LeaveReqID == objOLVRQ.LeaveReqID && x.ParentID == ParentID).OrderByDescending(x => x.LevelNo).FirstOrDefault();
                    if (objlastappOLVAP != null)
                        AvalBal = objlastappOLVAP.NoOfDays;
                    else
                        AvalBal = objOLVRQ.NoOfDays;

                    objOLVBL.LeaveBalance += AvalBal;
                    objOLVBL.UpdatedDate = DateTime.Now;
                    objOLVBL.UpdatedBy = UserID;

                    objOLVRQ.Status = 3;
                    objOLVRQ.NextManagerID = null;

                    OLVAP objOLVAP = new OLVAP();
                    objOLVAP.OLVAPID = OLVAPCount++;
                    objOLVAP.LeaveReqID = LeaveReqID;
                    objOLVAP.EmpID = EmpID;
                    objOLVAP.ParentID = ParentID;
                    objOLVAP.Status = 3;
                    objOLVAP.NextManagerID = null;
                    objOLVAP.LevelNo = objOLVRQ.LevelNo;
                    objOLVAP.NoOfDays = objOLVRQ.NoOfDays;
                    objOLVAP.ManagerID = objOLVRQ.ManagerID;
                    objOLVAP.LeaveTypeID = objOLVRQ.LeaveTypeID;
                    objOLVAP.Notes = txtRemarks.Text;
                    objOLVAP.CreatedDate = DateTime.Now;
                    objOLVAP.CreatedBy = UserID;
                    objOLVAP.UpdatedDate = DateTime.Now;
                    objOLVAP.UpdatedBy = UserID;
                    ctx.OLVAPs.Add(objOLVAP);

                    var Emp = ctx.OEMPs.Where(x => x.EmpID == objOLVRQ.EmpID && x.ParentID == ParentID).Select(x => new { x.EmpCode, x.Name, EmpGroupID = x.EmpGroupID.Value }).FirstOrDefault();

                    NData.Add(new NotiData(9115, "Leave Reject", "Leave Rejected By :" + EmpData.EmpCode + " # " + EmpData.Name + " For Applicant : " + Emp.EmpCode + " # " + Emp.Name + ", From Date : " + Common.DateTimeConvert(objOLVRQ.FromDate) + " To Date :" + Common.DateTimeConvert(objOLVRQ.ToDate) + ", No Of Days : " + objOLVAP.NoOfDays +
                        ", Leave Type : " + ctx.OLVTies.FirstOrDefault(x => x.LeaveTypeID == objOLVAP.LeaveTypeID).LeaveName + ", Reason : " + objOLVAP.Notes + ", Status : Rejected", objOLVRQ.CreatedBy, 0));

                    ctx.SaveChanges();

                    OMNUR objOMNU = ctx.OMNURs.FirstOrDefault(x => x.MenuID == 9115 && x.EmpGroupID == EmpData.EmpGroupID);
                    if (objOMNU != null && objOMNU.Notification)
                    {
                        foreach (NotiData data in NData)
                        {
                            Thread t = new Thread(() => { Service.SendNotificationFlow(data.MenuID, data.RequestID, UserID, ParentID, data.Body, data.Title, 0); });
                            t.Name = Guid.NewGuid().ToString();
                            t.Start();
                        }
                    }
                }
            }
            ClearAllInputs();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully.',1);", true);
        }
    }

    protected void gvApprovalList_PreRender(object sender, EventArgs e)
    {
        if (gvApprovalList.Rows.Count > 0)
        {
            gvApprovalList.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvApprovalList.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

}