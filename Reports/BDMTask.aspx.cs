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

public partial class Reports_BDMTask : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType, UserName;

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
                UserName = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + "," + x.Name).FirstOrDefault().ToString();
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                var UserType = Session["UserType"].ToString();
                int menuid = ctx.OMNUs.FirstOrDefault(x => x.PageName == pagename && (UserType == "b" ? true : x.MenuType == UserType)).MenuID;
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.MenuID == menuid && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    AuthType = Auth.AuthorizationType;
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

    public void ClearAllInputes()
    {
        txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var MachineType = ctx.OASTies.Where(x => x.Active).ToList();
            ddlMachineType.DataTextField = "AssetTypeName";
            ddlMachineType.DataValueField = "AssetTypeID";
            ddlMachineType.DataSource = MachineType;
            ddlMachineType.DataBind();
            ddlMachineType.Items.Insert(0, new ListItem("---Select---", "0"));

            var ProbType = ctx.OPLMs.Where(x => x.Active).ToList();
            ddlBDMType.DataTextField = "ProbemName";
            ddlBDMType.DataValueField = "ProblemID";
            ddlBDMType.DataSource = ProbType;
            ddlBDMType.DataBind();
            ddlBDMType.Items.Insert(0, new ListItem("---Select---", "0"));
        }
    }

    protected void ddlMachineType_SelectedIndexChanged(object sender, EventArgs e)
    {
        var TaskID = Convert.ToInt32(ddlMachineType.SelectedValue);
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var location = ctx.OTTies.Where(x => x.Active && x.TaskTypeID == TaskID).ToList();
            ddlMachineType.DataSource = location;
            ddlMachineType.DataBind();
            ddlMachineType.Items.Insert(0, new ListItem("---Select---", "0"));
        }
    }
    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputes();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnGenerat);
    }
    #endregion

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            if (Session["UserID"] != null && Session["ParentID"] != null &&
            Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
            {
                Int32.TryParse(Session["UserID"].ToString(), out UserID);
                Decimal.TryParse(Session["ParentID"].ToString(), out ParentID);
            }
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            Int32 MechEmpID = Int32.TryParse(txtMechEmp.Text.Split("-".ToArray()).Last().Trim(), out MechEmpID) ? MechEmpID : 0;

            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Int32 CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Int32 MachineType = Int32.TryParse(Convert.ToString(ddlMachineType.SelectedValue), out MachineType) ? MachineType : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "MECH_BDMTaskList_Report";

            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@MachineType", MachineType);
            Cm.Parameters.AddWithValue("@TaskFromDate", StartDate);
            Cm.Parameters.AddWithValue("@TaskToDate", EndDate);
            Cm.Parameters.AddWithValue("@Location", txtlocation.Text);
            Cm.Parameters.AddWithValue("@CityID", CityID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@MechanicID", MechEmpID);
            Cm.Parameters.AddWithValue("@ProblemID", ddlBDMType.SelectedValue);
            Cm.Parameters.AddWithValue("@AssetSerial", txtAssetSerialNo.Text);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();

            writer.WriteLine("Break Down Maintanance Report");
            writer.WriteLine("Complain Book Date From ," + StartDate + "," + "To ," + EndDate);
            writer.WriteLine("Employee/Mechanic," + (!string.IsNullOrEmpty(txtCode.Text) ? txtCode.Text.Split('-')[0].ToString() + "-" + txtCode.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("RSD Location," + (!string.IsNullOrEmpty(txtlocation.Text) ? txtlocation.Text : "All"));
            writer.WriteLine("Customer," + (!string.IsNullOrEmpty(txtDealerCode.Text) ? txtDealerCode.Text.Split('-')[0].ToString() + "-" + txtDealerCode.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("Machine Type," + (ddlMachineType.SelectedValue != "0" ? ddlMachineType.SelectedItem.Text : "All"));
            writer.WriteLine("Asset Serial Number," + (!string.IsNullOrEmpty(txtAssetSerialNo.Text) ? txtAssetSerialNo.Text : "All"));
            writer.WriteLine("Break Down Type," + (ddlBDMType.SelectedIndex > 0 ? ddlBDMType.SelectedItem.Text : "All"));

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

            Response.AddHeader("content-disposition", "attachment; filename=DataExport_Break_Down_Maintanance_Report" + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
            Response.ContentType = "application/txt";
            Response.Write(writer.ToString());
            Response.Flush();
            Response.End();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
}