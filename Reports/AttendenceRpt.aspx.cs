﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_AttendenceRpt : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;

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

                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
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
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var EmpG = ctx.OGRPs.Where(x => x.Active && x.ParentID == ParentID).ToList();
            ddlEGroup.DataSource = EmpG;
            ddlEGroup.DataBind();
            ddlEGroup.Items.Insert(0, new ListItem("---Select---", "0"));
        }
        txtCode.Text = "";
        txtCode.Style.Add("background-color", "rgb(250, 255, 189);");
        txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
        gvattendence.DataSource = null;
        gvattendence.DataBind();
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

    #region Griedview Events

    protected void gvattendence_Prerender(object sender, EventArgs e)
    {
        if (gvattendence.Rows.Count > 0)
        {
            gvattendence.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvattendence.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region Button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            int GRPID = Convert.ToInt32(ddlEGroup.SelectedValue);
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : UserID;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetAttendenceStatus";

            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@FromDate", Common.DateTimeConvert(txtFromDate.Text));
            Cm.Parameters.AddWithValue("@ToDate", Common.DateTimeConvert(txtToDate.Text));
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@GroupID", GRPID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables[0].Rows.Count > 7000)
            {
                IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
                StringWriter writer = new StringWriter();
                writer.WriteLine("Employee Wise Daily Activity Report");
                writer.WriteLine("From Date ," + txtFromDate.Text + ", To Date ," + txtToDate.Text);
                writer.WriteLine("Employee Group ," + (ddlEGroup.SelectedValue == "0" ? "All" : ddlEGroup.SelectedItem.ToString()));
                writer.WriteLine("Employee ," + ((txtCode.Text.Split('-').Length > 2) ? txtCode.Text.Split('-')[0].ToString() + "-" + txtCode.Text.Split('-')[1].ToString() : (txtCode.Text.Split('-').Length > 0 && txtCode.Text != "" && SUserID > 0) ? txtCode.Text : "All"));
                writer.WriteLine("Run Date/Time  ,'" + DateTime.Now.ToString("dd-MMM-yy HH:mm"));
                do
                {
                    writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetName).ToList()));
                    int count = 0;
                    while (reader.Read())
                    {
                        writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetValue).ToList()));
                        if (++count % 100 == 0)
                        {
                            writer.Flush();
                        }
                    }
                }
                while (reader.NextResult());

                Response.AddHeader("content-disposition", "attachment; filename=Emp_Daily_Activity_Report_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
                Response.ContentType = "application/txt";
                Response.Write(writer.ToString());
                Response.Flush();
                Response.End();
            }
            else
            {
                gvattendence.DataSource = ds.Tables[0];
                //gvattendence.DataSource = objClass.CommonFunctionForSelectDR(Cm);
                gvattendence.DataBind();
            }
            //gvattendence.DataSource = objClass.CommonFunctionForSelectDR(Cm);
            //gvattendence.DataBind();

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }

    }

    #endregion
}