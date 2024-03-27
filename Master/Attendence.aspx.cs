using System;
using System.Collections.Generic;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading;


public partial class Master_Attendence : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;

    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {

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
        if (!IsPostBack)
        {
            if (Request.QueryString["EmpCode"] != null && Request.QueryString["Date"] != null)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    string EmpCode = Request.QueryString["EmpCode"].ToString();
                    DateTime Date = Common.DateTimeConvert(Request.QueryString["Date"].ToString());

                    if (ctx.OEMPs.Any(x => x.ParentID == ParentID && x.EmpCode == EmpCode))
                    {
                        ddlToTimeType.SelectedValue = "2";
                        var EmpID = ctx.OEMPs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpCode == EmpCode).EmpID;

                        OENT objOENT = ctx.OENTs.FirstOrDefault(x => x.EmpID == EmpID && x.ParentID == ParentID &&
                            EntityFunctions.TruncateTime(x.InDate) == EntityFunctions.TruncateTime(Date));

                        txtStartDate.Text = Common.DateTimeConvert(Date);
                        txtEndDate.Text = Common.DateTimeConvert(Date);
                        txtFromDate.Text = Common.DateTimeConvert(Date);
                        txtToDate.Text = Common.DateTimeConvert(Date);

                        if (objOENT != null)
                        {
                            txtStartTime.Text = objOENT.InDate.TimeOfDay.ToString();
                            InTIme.SelectedValue = objOENT.InCity ? "1" : "0";
                            if (objOENT.OutDate.HasValue)
                            {
                                txtEndTime.Text = objOENT.OutDate.Value.TimeOfDay.ToString();
                                OutTime.SelectedValue = objOENT.OutCity.Value ? "1" : "0";
                            }
                        }
                        var code = ctx.OEMPs.Where(x => x.EmpID == EmpID && x.ParentID == ParentID).Select(x => new { x.EmpCode, x.Name, x.ManagerID }).FirstOrDefault();
                        txtEmpCode.Text = code.Name;
                        var manager = ctx.OEMPs.Where(x => x.EmpID == code.ManagerID && x.ParentID == ParentID).Select(x => new { x.EmpCode, x.Name, x.ManagerID }).FirstOrDefault();
                        txtManager.Text = manager == null ? "" : manager.Name;

                        var LeaveID = (from a in ctx.OLVTies
                                       join b in ctx.OLVBLs.Where(x => x.ParentID == ParentID && x.EmpID == EmpID) on a.LeaveTypeID equals b.LeaveTypeID into f
                                       from dpem in f.DefaultIfEmpty()
                                       select new
                                       {
                                           a.LeaveTypeID,
                                           Leave = a.LeaveName + " # " + (dpem != null ? SqlFunctions.StringConvert(dpem.LeaveBalance).Trim() : "0")
                                       }).ToList();

                        ddlLeaveType.DataSource = LeaveID;
                        ddlLeaveType.DataValueField = "LeaveTypeID";
                        ddlLeaveType.DataTextField = "Leave";
                        ddlLeaveType.DataBind();
                        ddlLeaveType.Items.Insert(0, new ListItem("---Select---", "0"));
                    }
                    else
                    {
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "ModelMsg('Emplyoee Code is not Proper.',3);", true);
                    }
                }
            }
        }
    }

    protected void btnDayEventSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                string EmpCode = Request.QueryString["EmpCode"].ToString();
                DateTime Date = Common.DateTimeConvert(Request.QueryString["Date"].ToString());

                if (ctx.OEMPs.Any(x => x.ParentID == ParentID && x.EmpCode == EmpCode))
                {
                    var EmpID = ctx.OEMPs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpCode == EmpCode).EmpID;

                    OENT objOENT = ctx.OENTs.FirstOrDefault(x => x.EmpID == EmpID && x.ParentID == ParentID &&
                        EntityFunctions.TruncateTime(x.InDate) == EntityFunctions.TruncateTime(Date));

                    if (objOENT == null)
                    {
                        objOENT = new OENT();
                        objOENT.EntryID = ctx.GetKey("OENT", "EntryID", "", ParentID, 0).FirstOrDefault().Value;
                        objOENT.ParentID = ParentID;
                        objOENT.EmpID = EmpID;
                        objOENT.InLat = "-1";
                        objOENT.InLong = "-1";
                        objOENT.InCItyName = "";
                        objOENT.DeviceID = "-1";
                        objOENT.CreatedDate = DateTime.Now;
                        objOENT.UpdatedDate = DateTime.Now;
                        ctx.OENTs.Add(objOENT);

                        List<OENT> objOENTs = ctx.OENTs.Where(x => x.ParentID == ParentID && x.EmpID == EmpID && !x.OutDate.HasValue).ToList();
                        foreach (OENT item in objOENTs)
                        {
                            item.OutDate = new DateTime(item.InDate.Year, item.InDate.Month, item.InDate.Day, 23, 59, 59);
                            item.OutLat = "-1";
                            item.OutLong = "-1";
                            item.OutCity = false;
                        }

                        List<OCSE> objOCSEs = ctx.OCSEs.Where(x => x.EmpID == EmpID && x.ParentID == ParentID && x.EndDate == null).ToList();
                        foreach (OCSE item in objOCSEs)
                        {
                            item.EndDate = new DateTime(item.StartDate.Year, item.StartDate.Month, item.StartDate.Day, 23, 50, 00);
                            item.EndTime = new TimeSpan(23, 50, 00);
                            item.EndLat = "-1";
                            item.EndLong = "-1";
                            item.UpdatedDate = DateTime.Now;
                            item.UpdatedBy = EmpID;
                        }

                    }
                    TimeSpan ts;
                    if (!TimeSpan.TryParseExact(txtStartTime.Text, "g", CultureInfo.CurrentCulture, out ts))
                    {
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('Start Time is not Proper.');", true);
                        return;
                    }
                    objOENT.InDate = Date.Add(ts);
                    objOENT.InCity = InTIme.SelectedValue == "1" ? true : false;
                    TimeSpan outTs;
                    if (txtEndTime.Text == "")
                    {
                        objOENT.OutDate = null;
                        objOENT.OutLat = "-1";
                        objOENT.OutLong = "-1";
                        objOENT.OutCity = null;
                        objOENT.OutCItyName = "";
                    }
                    else if (TimeSpan.TryParseExact(txtEndTime.Text, "g", CultureInfo.CurrentCulture, out outTs))
                    {
                        objOENT.OutDate = Date.Add(outTs);
                        objOENT.OutLat = "-1";
                        objOENT.OutLong = "-1";
                        objOENT.OutCity = OutTime.SelectedValue == "1" ? true : false;
                        objOENT.OutCItyName = "";
                    }
                    else
                    {
                        this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('End Time is not Proper.');", true);
                        return;
                    }

                    ctx.SaveChanges();

                    this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('Record Submitted Successfully.'); parent.$.colorbox.close();", true);
                }
                else
                {
                    this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('Emplyoee Code is not Proper.');", true);
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnLeaveSubmit_Click(object sender, EventArgs e)
    {
        Int32 EmpID = 0;
        string EmpCode = Request.QueryString["EmpCode"].ToString();
        DateTime Date = Common.DateTimeConvert(Request.QueryString["Date"].ToString());

        using (DDMSEntities ctx = new DDMSEntities())
        {
            Int32 IntNum = 0;
            Decimal DecNum = 0;
            DateTime Fromdate = DateTime.Now;
            DateTime Todate = DateTime.Now;

            EmpID = ctx.OEMPs.FirstOrDefault(x => x.EmpCode == EmpCode && x.ParentID == ParentID).EmpID;
            if (!string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtToDate.Text))
            {
                Fromdate = Convert.ToDateTime(txtFromDate.Text);
                Todate = Convert.ToDateTime(txtToDate.Text);
            }
            else
            {
                this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('Enter Proper Date.');", true);
                return;
            }
            if (ddlLeaveType.SelectedValue == "0")
            {
                this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('Select Leave Type.');", true);
                return;
            }
            Int32 LeaveTypeID = Int32.TryParse(Convert.ToString(ddlLeaveType.SelectedValue), out IntNum) ? IntNum : 0;
            Decimal NoOFDays = Decimal.TryParse(Convert.ToString(hdnNoOfDays.Value), out DecNum) ? DecNum : 0;

            int ManagerID = 0;
            if (ctx.OEMPs.FirstOrDefault(x => x.EmpID == EmpID && x.ParentID == ParentID).ManagerID.HasValue)
            {
                ManagerID = ctx.OEMPs.FirstOrDefault(x => x.EmpID == EmpID && x.ParentID == ParentID).ManagerID.Value;
            }
            OLVBL objOLVBL = ctx.OLVBLs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpID == EmpID && x.LeaveTypeID == LeaveTypeID);

            for (var dt = Fromdate; dt <= Todate; dt = dt.AddDays(1))
            {
                if (ctx.OLVRQs.Any(x => x.EmpID == EmpID && x.FromDate <= dt && x.ToDate >= dt && (x.FromLeaveMode == ddlFromTimeType.SelectedValue || x.ToLeaveMode == ddlToTimeType.SelectedValue) && x.Status != 3))
                {
                    this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('Leave Request Already Exist for : " + dt.ToShortDateString().ToString() + ".');", true);
                    return;
                }
            }

            if (objOLVBL != null && objOLVBL.LeaveBalance >= NoOFDays)
            {
                OLVRQ objOLVRQ = new OLVRQ();
                objOLVRQ.LeaveReqID = ctx.GetKey("OLVRQ", "LeaveReqID", "", ParentID, 0).FirstOrDefault().Value;
                objOLVRQ.EmpID = EmpID;
                objOLVRQ.ParentID = ParentID;
                objOLVRQ.ManagerID = ManagerID;
                objOLVRQ.LeaveTypeID = Int32.TryParse(Convert.ToString(ddlLeaveType.SelectedValue), out IntNum) ? IntNum : 0;
                objOLVRQ.ApplicationType = "Regular";
                objOLVRQ.NoOfDays = NoOFDays;
                objOLVRQ.FromDate = Fromdate;
                objOLVRQ.ToDate = Todate;
                objOLVRQ.FromLeaveMode = ddlFromTimeType.SelectedValue;
                objOLVRQ.ToLeaveMode = ddlToTimeType.SelectedValue;
                objOLVRQ.Reason = txtRemarks.Text;
                objOLVRQ.CreatedDate = DateTime.Now;
                objOLVRQ.CreatedBy = UserID;
                objOLVRQ.UpdatedDate = DateTime.Now;
                objOLVRQ.UpdatedBy = UserID;
                objOLVRQ.Status = 1;

                if (ctx.OAWRKs.Any(x => x.RequestTypeMenuID == 9114 && x.Status == 2 && x.Active))
                {
                    OAWRK objOAWRK = ctx.OAWRKs.Where(x => x.RequestTypeMenuID == 9114 && x.Status == 2 && x.Active).OrderBy(x => x.LevelNo).FirstOrDefault();
                    if (objOAWRK.IsManager)
                    {
                        //if next requester manager tick then go to immediate manager
                        objOLVRQ.NextManagerID = ctx.OEMPs.FirstOrDefault(x => x.EmpID == EmpID && x.ParentID == ParentID).ManagerID.Value;
                        objOLVRQ.LevelNo = objOAWRK.LevelNo;
                    }
                    else
                    {
                        objOLVRQ.NextManagerID = Convert.ToInt32(objOAWRK.UserID);
                        objOLVRQ.LevelNo = objOAWRK.LevelNo;
                    }
                }
                else
                {
                    //if no app work found then insert next managetid by default
                    objOLVRQ.NextManagerID = ctx.OEMPs.FirstOrDefault(x => x.EmpID == EmpID && x.ParentID == ParentID).ManagerID.Value;
                }
                objOLVBL.LeaveBalance -= NoOFDays;
                objOLVBL.UpdatedDate = DateTime.Now;
                objOLVBL.UpdatedBy = UserID;
                ctx.OLVRQs.Add(objOLVRQ);
                ctx.SaveChanges();

                this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('Record Submitted Successfully.'); parent.$.colorbox.close();", true);

                var EmpData = ctx.OEMPs.Where(x => x.EmpID == EmpID && x.ParentID == ParentID).Select(x => new { x.EmpCode, x.Name, EmpGroupID = x.EmpGroupID.Value }).FirstOrDefault();
                OMNUR objOMNU = ctx.OMNURs.FirstOrDefault(x => x.MenuID == 9114 && x.EmpGroupID == EmpData.EmpGroupID);
                if (objOMNU != null && objOMNU.Notification)
                {
                    string body = "New Leave request is generated by " + EmpData.EmpCode + " # " + EmpData.Name + " On " + objOLVRQ.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                    string title = objOMNU.OMNU.MenuName;

                    Thread t = new Thread(() => { Service.SendNotificationFlow(9114, EmpID, ParentID, body, title, 0); });
                    t.Name = Guid.NewGuid().ToString();
                    t.Start();
                }
            }
            else
            {
                this.ClientScript.RegisterStartupScript(this.GetType(), "", "alert('Not enough Leave Balance For Employee.');", true);
                return;
            }
        }
    }
}