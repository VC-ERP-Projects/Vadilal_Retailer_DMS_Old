using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_QPSCommonReport : System.Web.UI.Page
{

    #region Declaration

    string CustomerCode, CustomerIDs;
    Decimal DecNum;
    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType, UserName;


    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null && Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
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



    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Division = ctx.ODIVs.Where(x => x.Active).ToList();
                ddlDivision.DataSource = Division;
                ddlDivision.DataBind();
                ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
                txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
            }
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnGenerat);
    }

    #endregion

    #region GriedView Events

    protected void gvQPSCommon_PreRender(object sender, EventArgs e)
    {
        if (gvQPSCommon.Rows.Count > 0)
        {
            gvQPSCommon.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvQPSCommon.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region Button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            //lblInfoNoMessage.Text = "";
            Decimal DistributorID = 0;
            if (CustType == 1)
                DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            else
                DistributorID = ParentID;
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }
            int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;

            if (RegionID == 0 && PlantID == 0 && SSID == 0 && DistributorID == 0 && DealerID == 0 && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                return;
            }

            Int32 QPSSchemeID = Int32.TryParse(txtQPSCode.Text.Split("-".ToArray()).First().Trim(), out QPSSchemeID) ? QPSSchemeID : 0;
            Int32 ItemID = Int32.TryParse(txtItem.Text.Split("-".ToArray()).First().Trim(), out ItemID) ? ItemID : 0;
            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);

            Decimal CompanyFrom = Decimal.TryParse(txtCpnyContriFrom.Value, out CompanyFrom) ? CompanyFrom : 0;
            Decimal CompanyTo = Decimal.TryParse(txtCpnyContriTo.Value, out CompanyTo) ? CompanyTo : 100;
            Decimal DistFrom = Decimal.TryParse(txtDistContriFrom.Value, out DistFrom) ? DistFrom : 0;
            Decimal DistTo = Decimal.TryParse(txtDistContriTo.Value, out DistTo) ? DistTo : 100;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "QPSCOMMON";
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DivisionID", ddlDivision.SelectedValue);
            Cm.Parameters.AddWithValue("@RegionID", RegionID);
            Cm.Parameters.AddWithValue("@PlantID", PlantID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@QPSSchemeID", QPSSchemeID);
            Cm.Parameters.AddWithValue("@CompanyContriFrom", CompanyFrom);
            Cm.Parameters.AddWithValue("@CompanyContriTo", CompanyTo);
            Cm.Parameters.AddWithValue("@DistributionContriFrom", DistFrom);
            Cm.Parameters.AddWithValue("@DistributionContriTo", DistTo);
            Cm.Parameters.AddWithValue("@SchemeProductID", ItemID);
            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@SaleBy", ddlSaleBy.SelectedValue);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();

            DataTable dt = objClass.CommonFunctionForSelect(Cm).Tables[0];
            if (dt.Rows.Count > 0)
            {

                DataRow dr = dt.NewRow();
                dr.SetField<string>("InvoiceQty", dt.Compute("sum(InvoiceQty)", "").ToString());
                dr.SetField<string>("InvoiceAmount", dt.Compute("sum(InvoiceAmount)", "").ToString());
                dr.SetField<string>("QPSQty", dt.Compute("sum(QPSQty)", "").ToString());
                dr.SetField<string>("SalesAmount", dt.Compute("sum(SalesAmount)", "").ToString());
                dr.SetField<string>("TotalDiscount", dt.Compute("sum(TotalDiscount)", "").ToString());
                dr.SetField<string>("CompanyContriAmount", dt.Compute("sum(CompanyContriAmount)", "").ToString());
                dr.SetField<string>("DistriContAmount", dt.Compute("sum(DistriContAmount)", "").ToString());
                dt.Rows.Add(dr);
                dt.AcceptChanges();

                DataTableReader reader = dt.CreateDataReader();
                StringWriter writer = new StringWriter();

                writer.WriteLine("QPS Product Sales Report ,");
                writer.WriteLine("Invoice From Date ," + txtFromDate.Text + ",");
                writer.WriteLine("Invoice To Date ," + txtToDate.Text);
                writer.WriteLine("Region ," + (RegionID != 0 ? txtRegion.Text.Split('-')[1].ToString() : "All Region"));
              //  writer.WriteLine("Plant ," + (PlantID != 0 ? txtPlant.Text.Split('-')[0].ToString() + "," + txtPlant.Text.Split('-')[1].ToString() : "All Plant"));
                if (ddlSaleBy.SelectedValue == "4")
                    writer.WriteLine("Super Stockist ," + (SSID != 0 ? txtSSDistCode.Text.Split('-')[0].ToString() + "," + txtSSDistCode.Text.Split('-')[1].ToString() : "All Super Stockist"));
                writer.WriteLine("Distributor ," + (DistributorID != 0 ? txtDistCode.Text.Split('-')[0].ToString() + "," + txtDistCode.Text.Split('-')[1].ToString() : "All Distributors"));
                if (ddlSaleBy.SelectedValue == "2")
                    writer.WriteLine("Dealer ," + (DealerID != 0 ? txtDealerCode.Text.Split('-')[0].ToString() + "," + txtDealerCode.Text.Split('-')[1].ToString() : "All Dealer"));

                writer.WriteLine("QPS Scheme ," + (QPSSchemeID != 0 ? txtQPSCode.Text.Split('-')[1].ToString() + "," + txtQPSCode.Text.Split('-')[2].ToString() : "All QPS Scheme"));
                writer.WriteLine("Scheme Product ," + (ItemID != 0 ? txtItem.Text.Split('-')[1].ToString() + "," + txtItem.Text.Split('-')[2].ToString() : "All Scheme Product"));
             //   writer.WriteLine("Company Contribution % between ," + CompanyFrom + "," + "To ," + CompanyTo);
             //   writer.WriteLine("Distribuotor Contribution % between ," + DistFrom + "," + "To ," + DistTo);
                writer.WriteLine("Division ," + ddlDivision.SelectedItem.Text);
                writer.WriteLine("Employee ," + (SUserID != 0 ? txtCode.Text.Split('-')[0].ToString() + "," + txtCode.Text.Split('-')[1].ToString() : ""));
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

                string filepath = "QPSProductSales_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv";
                Response.AddHeader("content-disposition", "attachment;filename=" + filepath);
                Response.Output.Write(writer.ToString());
                Response.Flush();
                Response.End();
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No data found.',3);", true);
                return;
                //lblInfoNoMessage.Text = "No data found.";
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion


}