using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_AssetUtilization : System.Web.UI.Page
{

    #region Property

    protected int UserID;
    public int CustType;
    public decimal ParentID;
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

                    UserName = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + "," + x.Name).FirstOrDefault().ToString();
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

    public void ClearAllInputs()
    {
        // txtDistCode.Text = "";
        txtFromMonth.Text = DateTime.Now.Month.ToString() + '/' + DateTime.Now.Year.ToString();
    }

    #endregion

    #region PageLoad
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Division = ctx.ODIVs.Where(x => x.Active).ToList();
                ddlDivision.DataSource = Division;
                ddlDivision.DataBind();
                ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
                ddlDivision.ClearSelection();
                ddlDivision.SelectedValue = "3";
            }
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnExport);
    }
    #endregion



    protected void btnExport_Click(object sender, EventArgs e)
    {
        DateTime CurMonthDateFrom, CurMonthDateTo, PrevMonthDateFrom, PrevMonthDateTo, SelectedDate;
        SelectedDate = Convert.ToDateTime(txtFromMonth.Text);

        CurMonthDateFrom = new DateTime(SelectedDate.Year, SelectedDate.Month, 1);
        CurMonthDateTo = new DateTime(SelectedDate.Year, SelectedDate.Month, DateTime.DaysInMonth(SelectedDate.Year, SelectedDate.Month));
        PrevMonthDateFrom = new DateTime(CurMonthDateFrom.Year - 1, CurMonthDateFrom.Month, CurMonthDateFrom.Day);
        PrevMonthDateTo = new DateTime(CurMonthDateTo.Year - 1, CurMonthDateTo.Month, DateTime.DaysInMonth(CurMonthDateTo.Year - 1, CurMonthDateTo.Month));


        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
        //Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;



        //if (RegionID == 0 && CityID == 0 && SS == 0 && DistributorID == 0 && DealerID == 0 && SUserID == 0)
        //{
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one parameter.',3);", true);
        //    return;
        //}

        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "AssetUtilization";
            Cm.Parameters.AddWithValue("@ReportOption", ddlReportOption.SelectedValue);
            Cm.Parameters.AddWithValue("@DivisionID", ddlDivision.SelectedValue);
            Cm.Parameters.AddWithValue("@DistRegionID", RegionID);
            Cm.Parameters.AddWithValue("@DistCityID", CityID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@PrevMonthDateFrom", PrevMonthDateFrom);
            Cm.Parameters.AddWithValue("@PrevMonthDateTo", PrevMonthDateTo);
            Cm.Parameters.AddWithValue("@CurMonthDateFrom", CurMonthDateFrom);
            Cm.Parameters.AddWithValue("@CurMonthDateTo", CurMonthDateTo);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();

            StringWriter writer = new StringWriter();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            writer.WriteLine("Asset Utilization	Report,");

            writer.WriteLine("Report Option ," + ddlReportOption.SelectedItem.Text);
            //writer.WriteLine("Division ," + ((ddlDivision.SelectedItem.Value != "0") ? ddlDivision.SelectedItem.Text : "All"));
            if (ddlReportOption.SelectedValue == "1" || ddlReportOption.SelectedValue == "4")
                writer.WriteLine("Employee ," + (SUserID != 0 ? txtCode.Text.Split('-')[0].ToString() + "," + txtCode.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("Region ," + (RegionID != 0 ? txtRegion.Text.Split('-')[1].ToString() : "All"));
            if (ddlReportOption.SelectedValue != "3")
                writer.WriteLine("City ," + (CityID != 0 ? txtCity.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("Month ," + SelectedDate.ToString("MMM-yy") + ",");

            writer.WriteLine("User ," + UserName);
            writer.WriteLine("Created On ," + DateTime.Now);

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

            Response.AddHeader("content-disposition", "attachment; filename=AssetUtilization" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
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