using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_RegDistDealerListing : System.Web.UI.Page
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
        if (CustType == 1)
        {
            divDistributor.Visible = true;
        }
        else
        {
            divDistributor.Visible = false;
            divDistributor.Style.Add("Display", "none");
        }
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            if (CustType == 2)
            {
                divRegion.Attributes.Add("style", "display:none;");
                divEmpCode.Attributes.Add("style", "display:none;");
                txtDistCode.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnGenerat);
    }

    #endregion

    #region Button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Int32 DistRegionID = Int32.TryParse(txtDistRegion.Text.Split("-".ToArray()).Last().Trim(), out DistRegionID) ? DistRegionID : 0;
        Int32 DealRegionID = Int32.TryParse(txtDealRegion.Text.Split("-".ToArray()).Last().Trim(), out DealRegionID) ? DealRegionID : 0;

        if (SUserID == 0 && DistributorID == 0 && DealRegionID == 0 && DistRegionID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            return;
        }

        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "DealerList";
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@EmpID", UserID);
        Cm.Parameters.AddWithValue("@SUserID", SUserID);
        Cm.Parameters.AddWithValue("@DistRegionID", DistRegionID);
        Cm.Parameters.AddWithValue("@DistSAPStatus", ddlSAPDistStatus.SelectedValue);
        Cm.Parameters.AddWithValue("@DistDMSStatus", ddlDMSDistStatus.SelectedValue);
        Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
        Cm.Parameters.AddWithValue("@CustRegionID", DealRegionID);
        Cm.Parameters.AddWithValue("@CustSAPStatus", ddlSAPDealStatus.SelectedValue);
        Cm.Parameters.AddWithValue("@CustDMSStatus", ddlDMSDealerStatus.SelectedValue);

        Response.Clear();
        Response.Buffer = true;
        Response.ClearContent();
        IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
        StringWriter writer = new StringWriter();

        writer.WriteLine("Region + Distributor wise Dealer Listing ,");
        writer.WriteLine("Distributor Region ," + (DistRegionID != 0 ? txtDistRegion.Text.Split('-')[1].ToString() : "All Region"));
        writer.WriteLine("Distributor SAP Status ," + ddlSAPDistStatus.SelectedItem.Text);
        writer.WriteLine("Distributor DMS Status ," + ddlDMSDistStatus.SelectedItem.Text);
        writer.WriteLine("Distributor ," + (DistributorID != 0 ? txtDistCode.Text.Split('-')[0].ToString() + "," + txtDistCode.Text.Split('-')[1].ToString() : "All Distributors"));
        writer.WriteLine("Dealer Region ," + (DealRegionID != 0 ? txtDealRegion.Text.Split('-')[1].ToString() : "All Region"));
        writer.WriteLine("Dealer SAP Status ," + ddlSAPDealStatus.SelectedItem.Text);
        writer.WriteLine("Dealer DMS Status ," + ddlDMSDealerStatus.SelectedItem.Text);
        writer.WriteLine("Employee ," + (SUserID != 0 ? txtCode.Text.Split('-')[0].ToString() + "," + txtCode.Text.Split('-')[1].ToString() : ""));
        writer.WriteLine("User ," + hdnUserName.Value);
        writer.WriteLine("Created On ," + DateTime.Now.ToString("dd-MMM-yy HH:mm"));

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

        Response.AddHeader("content-disposition", "attachment; filename=RegDistDealerListing" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
        Response.ContentType = "application/txt";
        Response.Write(writer.ToString());
        Response.Flush();
        Response.End();
    }

    protected void gvRegDistDealer_PreRender(object sender, EventArgs e)
    {
        if (gvRegDistDealer.Rows.Count > 0)
        {
            gvRegDistDealer.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvRegDistDealer.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

}