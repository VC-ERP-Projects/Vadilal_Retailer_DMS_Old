using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_DistributorLastInvoice : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (Session["UserID"] != null && Session["ParentID"] != null &&
              Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
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
                        {

                        }
                    }
                }
            }
            else
            {
                Response.Redirect("~/Login.aspx");
            }
        }
    }

    public void ClearAllInputs()
    {
        txtEffactiveToDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtDistCode.Text = txtRegion.Text = txtPlant.Text = "";
        gvgrid.DataSource = null;
        gvgrid.DataBind();
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (CustType == 1)
        {
            divDistributor.Visible = divPlant.Visible = divRegion.Visible = true;
        }
        else
        {
            divDistributor.Visible = divPlant.Visible = divRegion.Visible = false;
            divDistributor.Style.Add("Display", "none");
            txtPlant.Style.Add("display", "none");
            txtRegion.Style.Add("display", "none");

        }
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Griedview Events

    protected void gvgrid_Prerender(object sender, EventArgs e)
    {
        if (gvgrid.Rows.Count > 0)
        {
            gvgrid.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvgrid.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region Button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                DateTime EffactiveToDate = Convert.ToDateTime(txtEffactiveToDate.Text);


                int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
                int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
                Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
                int SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();
                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;

                Cm.CommandText = "DistributorLastInvoice";
                Cm.Parameters.AddWithValue("@Date", EffactiveToDate);

                if (CustType == 1)
                {
                    Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;

                    //if (PlantID == 0 && RegionID == 0 && DistributorID == 0)
                    //{
                    //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                    //    return;
                    //}

                    Cm.Parameters.AddWithValue("@DistributorID", DistributorID.ToString());
                    Cm.Parameters.AddWithValue("@PlantID", PlantID);
                    Cm.Parameters.AddWithValue("@RegionID", RegionID);
                    Cm.Parameters.AddWithValue("@ParentID", ParentID);
                    Cm.Parameters.AddWithValue("@SUserID", SUserID);
                    Cm.Parameters.AddWithValue("@EmpID", UserID);
                    Cm.Parameters.AddWithValue("@SSID", SSID);
                }
                else
                {
                    Cm.Parameters.AddWithValue("@DistributorID", ParentID.ToString());
                    Cm.Parameters.AddWithValue("@PlantID", "0");
                    Cm.Parameters.AddWithValue("@RegionID", "0");
                    Cm.Parameters.AddWithValue("@ParentID", ParentID);
                    Cm.Parameters.AddWithValue("@SUserID", SUserID);
                    Cm.Parameters.AddWithValue("@EmpID", UserID);
                    Cm.Parameters.AddWithValue("@SSID", SSID);
                }

                DataSet ds = objClass.CommonFunctionForSelect(Cm);
                if (ds.Tables.Count > 0)
                {
                    gvgrid.DataSource = ds.Tables[0];
                    gvgrid.DataBind();
                }

            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }

    }

    #endregion

}