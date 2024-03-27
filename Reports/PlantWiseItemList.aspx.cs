using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_PlantWiseItemList : System.Web.UI.Page
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

    #region Pageload

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnGenerat);
        scriptManager.RegisterPostBackControl(this.btnExport);
    }

    private void ClearAllInputs()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivision.DataSource = Division;
            ddlDivision.DataBind();
            txtGroup.Text = txtPlant.Text = txtSubGroup.Text = "";
        }
    }
    #endregion

    #region ButtonClick

    protected void ifmData_Load(object sender, EventArgs e)
    {

    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Int32 PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
        Int32 GroupID = Int32.TryParse(txtGroup.Text.Split("-".ToArray()).Last().Trim(), out GroupID) ? GroupID : 0;
        Int32 SubGroup = Int32.TryParse(txtSubGroup.Text.Split("-".ToArray()).Last().Trim(), out SubGroup) ? SubGroup : 0;

        if (PlantID != 0)
            ifmData.Attributes.Add("src", "../Reports/ViewReport.aspx?PlantWiseItemListPlantID=" + PlantID + "&PlantWiseItemListGroupID=" + GroupID + "&PlantWiseItemListSubGroupID=" + SubGroup + "&PlantWiseItemListDivisionID=" + ddlDivision.SelectedValue + "&PlantWiseItemListActive=" + ddlActive.SelectedValue);
        else
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "PlantWiseItemList";
            Cm.Parameters.AddWithValue("@ITEMGROUPID", GroupID);
            Cm.Parameters.AddWithValue("@ITEMSUBGROUPID", SubGroup);
            Cm.Parameters.AddWithValue("@ACTIVE", ddlActive.SelectedValue);
            Cm.Parameters.AddWithValue("@DIVISIONID", ddlDivision.SelectedValue);
            Cm.Parameters.AddWithValue("@Plant", PlantID);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();

            var plant = txtPlant.Text.Split();

            writer.WriteLine("Plant wise Material Listing ,");
            writer.WriteLine("Division ," + ddlDivision.SelectedItem.ToString());
            writer.WriteLine("Plant ," + (PlantID != 0 ? plant[0].Trim() + " - " + plant[1].Trim() : "All Plant"));
            writer.WriteLine("Item Group ," + (GroupID != 0 ? txtGroup.Text.Split('-')[0].ToString() : "All Group"));
            writer.WriteLine("Item Sub-Group ," + (SubGroup != 0 ? txtSubGroup.Text.Split('-')[0].ToString() : "All Sub-Group"));
            writer.WriteLine("Active ," + ddlActive.SelectedItem.ToString());
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

            string filepath = "PlantWiseItemList_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv";
            Response.AddHeader("content-disposition", "attachment;filename=" + filepath);
            Response.Output.Write(writer.ToString());
            Response.Flush();
            Response.End();
            objClass.CloseConnection();
        }
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Int32 PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
        Int32 GroupID = Int32.TryParse(txtGroup.Text.Split("-".ToArray()).Last().Trim(), out GroupID) ? GroupID : 0;
        Int32 SubGroup = Int32.TryParse(txtSubGroup.Text.Split("-".ToArray()).Last().Trim(), out SubGroup) ? SubGroup : 0;
        if (PlantID != 0)
            ifmData.Attributes.Add("src", "../Reports/ViewReport.aspx?PlantWiseItemListPlantID=" + PlantID + "&PlantWiseItemListGroupID=" + GroupID + "&PlantWiseItemListSubGroupID=" + SubGroup + "&PlantWiseItemListDivisionID=" + ddlDivision.SelectedValue + "&PlantWiseItemListActive=" + ddlActive.SelectedValue + "&Export=1");
        else
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "PlantWiseItemList";
            Cm.Parameters.AddWithValue("@ITEMGROUPID", GroupID);
            Cm.Parameters.AddWithValue("@ITEMSUBGROUPID", SubGroup);
            Cm.Parameters.AddWithValue("@ACTIVE", ddlActive.SelectedValue);
            Cm.Parameters.AddWithValue("@DIVISIONID", ddlDivision.SelectedValue);
            Cm.Parameters.AddWithValue("@Plant", PlantID);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();

            var plant = txtPlant.Text.Split();

            writer.WriteLine("Plant wise Material Listing ,");
            writer.WriteLine("Plant ," + (PlantID != 0 ? plant[0].Trim() + " - " + plant[1].Trim() : "All Plant"));
            writer.WriteLine("Division ," + ddlDivision.SelectedItem.ToString());
            writer.WriteLine("Item Group ," + (GroupID != 0 ? txtGroup.Text.Split('-')[0].ToString() : "All Group"));
            writer.WriteLine("Item Sub-Group ," + (SubGroup != 0 ? txtSubGroup.Text.Split('-')[0].ToString() : "All Sub-Group"));
            writer.WriteLine("Active ," + ddlActive.SelectedItem.ToString());
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

            string filepath = "PlantWiseItemList_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv";
            Response.AddHeader("content-disposition", "attachment;filename=" + filepath);
            Response.Output.Write(writer.ToString());
            Response.Flush();
            Response.End();
            objClass.CloseConnection();
        }
    }

    #endregion

}