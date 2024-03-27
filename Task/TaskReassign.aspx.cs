using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Task_TaskReassign : System.Web.UI.Page
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

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            if (Request.QueryString["TaskID"] != null || Request.QueryString["Col"] != null)
            {
                hdnTaskID.Value = Request.QueryString["TaskID"].ToString();

                using (DDMSEntities ctx = new DDMSEntities())
                {
                    Int32 TaskID = Int32.TryParse(Request.QueryString["TaskID"].ToString(), out TaskID) ? TaskID : 0;
                    if (Request.QueryString["Col"] == "0")
                    {
                        var ReasonList = ctx.OTRSNs.AsEnumerable().Where(x => x.ReasonType == "P").Select(x => new { x.TaskReasonID, x.TaskReasonName }).ToList();

                        ddlReason.DataSource = ReasonList;
                        ddlReason.DataValueField = "TaskReasonID";
                        ddlReason.DataTextField = "TaskReasonName";
                        ddlReason.DataBind();

                        var TaskDetail = ctx.OTASKs.Where(x => x.TaskID == TaskID).Select(x => new { x.DueDate, x.DueTime, x.AssignEmpID });
                        string Date = TaskDetail.FirstOrDefault().DueDate.ToString("dd/MM/yyyy");
                        if (Convert.ToDateTime(Date) >= DateTime.Now.Date)
                        {
                            txtDate.Text = TaskDetail.FirstOrDefault().DueDate.ToString("dd/MM/yyyy");
                            txtTime.Text = TaskDetail.FirstOrDefault().DueTime.ToString(@"hh\:mm");
                        }
                        else
                        {
                            txtDate.Text = DateTime.Now.Date.ToString("dd/MM/yyyy");
                            txtTime.Text = DateTime.Now.TimeOfDay.ToString(@"hh\:mm");
                        }

                        int Empid = Convert.ToInt32(TaskDetail.FirstOrDefault().AssignEmpID.ToString());
                        AutoEmp.Text = ctx.OEMPs.Where(x => x.EmpID == Empid).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).FirstOrDefault();
                        ddlEmpList_SelectedIndexChanged(AutoEmp, e);

                        divTaskAssign.Visible = true;
                    }
                    else if (Request.QueryString["Col"] == "14")
                    {
                        gvHistory.DataSource = null;
                        gvHistory.DataBind();

                        var TaskDetail = ctx.OTASKs.Where(x => x.TaskID == TaskID).Select(x => new { x.TaskName, x.TaskCode, x.OTTY.TaskTypeName });
                        txtTaskNo.Text = TaskDetail.FirstOrDefault().TaskCode;
                        txtName.Text = TaskDetail.FirstOrDefault().TaskName;
                        txtType.Text = TaskDetail.FirstOrDefault().TaskTypeName;

                        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                        SqlCommand Cm = new SqlCommand();
                        Cm.Parameters.Clear();
                        Cm.CommandType = CommandType.StoredProcedure;
                        Cm.CommandText = "MECH_GetTaskHistoryDetail";
                        Cm.Parameters.AddWithValue("@ParentID", ParentID);
                        Cm.Parameters.AddWithValue("@TaskID", TaskID);

                        DataSet ds = objClass.CommonFunctionForSelect(Cm);
                        if (ds.Tables.Count > 0)
                        {
                            if (ds.Tables[0].Rows.Count > 0)
                            {
                                gvHistory.DataSource = ds.Tables[0];
                                gvHistory.DataBind();
                            }
                        }
                        divTaskHistory.Visible = true;
                    }
                }
            }
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

            List<string> Employee = new List<string>();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                Employee = ctx.OEMPs.Where(x => x.Active && x.ParentID == ParentID).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).ToList();

                result.Add(Employee);
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR#" + "" + Common.GetString(ex));
        }
        return result;
    }

    #endregion

    #region EventChange

    protected void ddlEmpList_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            gvData.DataSource = null;
            gvData.DataBind();
            Int32 EmpiD = Convert.ToInt32(AutoEmp.Text.Split("-".ToArray()).Last());
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "MECH_GetEmpTaskDetail";
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@UserID", EmpiD);
            Cm.Parameters.AddWithValue("@Date", Convert.ToDateTime(txtDate.Text));

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0)
            {
                gvData.DataSource = ds.Tables[0];
                gvData.DataBind();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    #region PreRender

    protected void gvData_PreRender(object sender, EventArgs e)
    {
        if (gvData.Rows.Count > 0)
        {
            gvData.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvData.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvHistory_PreRender(object sender, EventArgs e)
    {
        if (gvHistory.Rows.Count > 0)
        {
            gvHistory.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvHistory.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region ButtonClick

    protected void btnAssign_Click(object sender, EventArgs e)
    {
        Int32 TaskID = 0;
        if (!String.IsNullOrEmpty(hdnTaskID.Value) && Int32.TryParse(hdnTaskID.Value, out TaskID) && TaskID > 0)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ctx.OTASKs.Any(x => x.TaskID == TaskID && (x.TaskStatusID != 8 || !x.IsCompleted)))
                {
                    Int32 EmpID = 0;
                    if (!string.IsNullOrEmpty(AutoEmp.Text) && Int32.TryParse(AutoEmp.Text.Split("-".ToArray()).Last(), out EmpID) && EmpID > 0)
                    {
                        var objOTASK = ctx.OTASKs.FirstOrDefault(x => x.TaskID == TaskID);
                        objOTASK.AssignEmpID = Convert.ToInt32(AutoEmp.Text.Split("-".ToArray()).Last());
                        objOTASK.DueDate = Convert.ToDateTime(txtDate.Text);
                        objOTASK.DueTime = TimeSpan.Parse(txtTime.Text);
                        objOTASK.TaskStatusID = 5; //Changes done as Milan bhai said
                        objOTASK.IsCompleted = false;
                        objOTASK.TaskCreatedFromID = 2;
                        objOTASK.UpdatedDate = DateTime.Now;
                        objOTASK.UpdatedBy = UserID;

                        TASK1 objTASK1 = new TASK1();
                        objTASK1.TaskID = objOTASK.TaskID;
                        objTASK1.TaskStatusID = 5;
                        objTASK1.LevelNo = objOTASK.TASK1.OrderByDescending(x => x.LevelNo).Select(x => x.LevelNo).DefaultIfEmpty(0).FirstOrDefault() + 1;
                        objTASK1.CustomerID = objOTASK.CustomerID;
                        objTASK1.FromEmpID = UserID;
                        objTASK1.ToEmpID = objOTASK.AssignEmpID;
                        objTASK1.TaskCreatedFromID = objOTASK.TaskCreatedFromID;
                        objTASK1.ReasonID = Convert.ToInt32(ddlReason.SelectedValue);
                        objTASK1.Remarks = txtRemarks.Text;
                        objTASK1.Createdby = UserID;
                        objTASK1.CreatedDate = DateTime.Now.Date;
                        objTASK1.CreatedTime = DateTime.Now.TimeOfDay;
                        ctx.TASK1.Add(objTASK1);
                        ctx.SaveChanges();

                        var CustData = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == objOTASK.CustomerID);
                        if (objOTASK != null) //Notification
                        {
                            string body = "Re-Assignment Task # " + objOTASK.TaskCode + " # " + objOTASK.TaskName +
                                " created from DMS for Serial Number # " + objOTASK.OAST.SerialNumber + " for Date & Time " +
                                Common.DateTimeConvert(objOTASK.DueDate) + " : " + DateTime.Today.Add(objOTASK.DueTime).ToString("hh:mm tt") + " for Customer "
                                + CustData.CustomerCode + " # " + CustData.CustomerName;
                            string title = "Re-Assignment Task # " + objOTASK.TaskCode;

                            Thread t = new Thread(() => { Service.SendNotificationFlow(5003, objOTASK.AssignEmpID, 1000010000000000, body, title, 0); });
                            t.Name = Guid.NewGuid().ToString();
                            t.Start();
                        }

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "size", "alert('Process Completed.'); parent.$.colorbox.close();", true);
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Select Assign Employee!',3);", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('This Task is with In-Process or Resolved Status!',3);", true);
                }
            }
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('TaskID Not Found!',3);", true);
        }
    }

    #endregion
}