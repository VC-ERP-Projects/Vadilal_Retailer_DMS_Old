using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_TempCustomerCompeititor : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
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

    private void ClearAllInputs()
    {
        txtCreatedOn.Text =
        txtCode.Text = txtEmpName.Text = txtdistributor.Text = txtBeatCodeName.Text = txtBrand.Text = txtAddress1.Text = txtAddress2.Text = txtCity.Text
        = txtContactPerson.Text = txtcreatedby.Text = txtEmailID.Text = txtlatitude.Text = txtIstemp.Text = txtlongitude.Text =
        txtOName.Text = txtpincode.Text = txtpincode.Text = txtRegion.Text = txtTempcode.Text = txtMobileNo.Text = txtLocation.Text = txtactive.Text = "";

        img1.Visible = img2.Visible = img3.Visible = img4.Visible = false;


        if (ddlOption.SelectedValue == "2")
        {
            divactive.Visible = true;
            lblIsTemp.Text = "Is Competitor ?";
            divaddress2.Visible = true;
            lbltempCode.Text = "Competitor Code";
            divbrand.Visible = false;
            txtdistributor.Enabled = true;
            txtdistributor.Style.Add("background-color", "rgb(250, 255, 189)");
        }
        else
        {
            divactive.Visible = false;
            lblIsTemp.Text = "Is Temp Customer?";
            divaddress2.Visible = false;
            lbltempCode.Text = "Temporary Code";
            divbrand.Visible = true;
            //txtdistributor.Enabled = false;
            //txtdistributor.Style.Remove("background-color");

        }
    }
    #endregion

    #region Page Load
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Textbox Change Event

    protected void txtCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Decimal CompetitorID = Decimal.TryParse(txtCode.Text.Split('-').Last(), out CompetitorID) ? CompetitorID : 0;
                if (CompetitorID > 0 && txtCode.Text.Split("-".ToArray()).Length == 3) // if get 3 array in txtcode textbox then get value
                {
                    if (CompetitorID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper " + ddlOption.SelectedItem.Text + ".',3);", true);
                        return;
                    }
                    img1.Visible = img2.Visible = img3.Visible = img4.Visible = false;


                    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                    SqlCommand Cm = new SqlCommand();
                    Cm.Parameters.Clear();
                    Cm.CommandType = CommandType.StoredProcedure;
                    Cm.CommandText = "GetCompetitorDetails";
                    Cm.Parameters.AddWithValue("@CompetitorID", CompetitorID);
                    Cm.Parameters.AddWithValue("@CustType", ddlOption.SelectedValue);
                    DataSet ds = objClass.CommonFunctionForSelect(Cm);

                    if (ds.Tables[0].Rows.Count > 0)
                    {

                        DataTable dt = ds.Tables[0];

                        txtCode.Text = txtCode.Text + " ";
                        txtOName.Text = dt.Rows[0]["OutletName"].ToString();
                        txtContactPerson.Text = dt.Rows[0]["ContactPerson"].ToString();
                        txtEmailID.Text = dt.Rows[0]["Email"].ToString();
                        txtMobileNo.Text = dt.Rows[0]["Phone"].ToString();
                        txtAddress1.Text = dt.Rows[0]["ADDRESS1"].ToString();
                        txtAddress2.Text = dt.Rows[0]["ADDRESS2"].ToString();
                        txtLocation.Text = dt.Rows[0]["Location"].ToString();
                        txtpincode.Text = dt.Rows[0]["Zipcode"].ToString();
                        txtCity.Text = dt.Rows[0]["CityName"].ToString();
                        txtRegion.Text = dt.Rows[0]["StateName"].ToString();
                        if (ddlOption.SelectedValue == "1")
                        {
                            txtBrand.Text = dt.Rows[0]["Brand"].ToString();
                        }
                        txtdistributor.Text = dt.Rows[0]["Distributor"].ToString();
                        txtBeatCodeName.Text = dt.Rows[0]["Beat Name"].ToString();
                        txtCreatedOn.Text = dt.Rows[0]["Created On"].ToString();
                        txtcreatedby.Text = dt.Rows[0]["Created By"].ToString();
                        txtlatitude.Text = dt.Rows[0]["Latitude"].ToString();
                        txtlongitude.Text = dt.Rows[0]["Longitude"].ToString();
                        if (ddlOption.SelectedValue == "2")
                        {
                            txtIstemp.Text = dt.Rows[0]["IsCompetitor"].ToString();
                            txtTempcode.Text = dt.Rows[0]["CompetitorCode"].ToString();
                            if ((dt.Rows[0]["IsCompetitor"].ToString() == "N"))
                            {
                                divtempcode.Visible = false;
                            }
                            else
                            {
                                divtempcode.Visible = true;
                            }

                            txtactive.Text = dt.Rows[0]["Active Status"].ToString();
                        }
                        else
                        {
                            txtIstemp.Text = dt.Rows[0]["IsTemp"].ToString();
                            txtTempcode.Text = dt.Rows[0]["Temporary Code"].ToString();

                            if (dt.Rows[0]["IsTemp"].ToString() == "N")
                            {
                                divtempcode.Visible = false;
                            }
                            else
                            {
                                divtempcode.Visible = true;
                            }

                            DataTable dtimage = ds.Tables[1];
                            if (dtimage.Rows.Count > 0)
                            {
                                if (dtimage.Rows[0]["Image1"] != null && !string.IsNullOrEmpty(dtimage.Rows[0]["Image1"].ToString()))
                                {
                                    img1.HRef = dtimage.Rows[0]["Image1"].ToString();
                                    img1.Visible = true;
                                }
                                if (dtimage.Rows[0]["Image2"] != null && !string.IsNullOrEmpty(dtimage.Rows[0]["Image2"].ToString()))
                                {
                                    img2.HRef = dtimage.Rows[0]["Image2"].ToString();
                                    img2.Visible = true;
                                }
                                if (dtimage.Rows[0]["Image3"] != null && !string.IsNullOrEmpty(dtimage.Rows[0]["Image3"].ToString()))
                                {
                                    img3.HRef = dtimage.Rows[0]["Image3"].ToString();
                                    img3.Visible = true;
                                }
                                if (dtimage.Rows[0]["Image4"] != null && !string.IsNullOrEmpty(dtimage.Rows[0]["Image4"].ToString()))
                                {
                                    img4.HRef = dtimage.Rows[0]["Image4"].ToString();
                                    img4.Visible = true;
                                }
                            }
                        }
                    }
                }
                else
                {
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void ddlOption_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlOption.SelectedItem.Value == "1")
            acettxtroute.ServiceMethod = "GetCompetitorRouteByEmpID";
        else //temp cust
            acettxtroute.ServiceMethod = "GetRouteByEmpID";

        ClearAllInputs();
    }
    #endregion

    #region Submit button click

    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int StateID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last(), out StateID) ? StateID : 0;
                int CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last(), out CityID) ? CityID : 0;
                int RouteID = Int32.TryParse(txtBeatCodeName.Text.Split("-".ToArray()).Last(), out RouteID) ? RouteID : 0;
                decimal DistributorID = decimal.TryParse(txtdistributor.Text.Split("-".ToArray()).Last(), out DistributorID) ? DistributorID : 0;
                if (StateID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper state name.',3);", true);
                    return;
                }
                if (CityID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper city name.',3);", true);
                    return;
                }
                if (RouteID == 0 && !string.IsNullOrEmpty(txtBeatCodeName.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper beat name.',3);", true);
                    return;
                }
                if (DistributorID == 0 && !string.IsNullOrEmpty(txtdistributor.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper distributor name.',3);", true);
                    return;
                }

                if (RouteID > 0 && !string.IsNullOrEmpty(txtBeatCodeName.Text))
                {
                    if ((ddlOption.SelectedItem.Value == "1" && !ctx.OCRUTs.Any(x => x.CompRouteID == RouteID)) || (ddlOption.SelectedItem.Value == "2" && !ctx.ORUTs.Any(x => x.RouteID == RouteID)))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper beat name.',3);", true);
                        return;
                    }
                }
                if (DistributorID > 0 && !string.IsNullOrEmpty(txtdistributor.Text) && !ctx.OCRDs.Any(x => x.CustomerID == DistributorID))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper distributor name.',3);", true);
                    return;
                }


                string hdnBrandID = "";

                if (ddlOption.SelectedValue == "1")
                {
                    if (!string.IsNullOrEmpty(txtBrand.Text))
                    {
                        if (txtBrand.Text.Contains(","))
                        {
                            var brandList = txtBrand.Text.Trim().Split(",".ToArray()).ToList();

                            List<string> brandID = new List<string>();

                            foreach (var brand in brandList)
                            {
                                if (!string.IsNullOrEmpty(brand))
                                {
                                    if (ctx.OBRNDs.Any(x => x.BrandName == brand))
                                    {
                                        string BrandID = ctx.OBRNDs.FirstOrDefault(x => x.BrandName == brand).BrandID.ToString();
                                        brandID.Add(BrandID);
                                    }
                                    else
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper Brand : " + brand + ".',3);", true);
                                        return;
                                    }
                                }
                            }
                            if (brandID != null && brandID.Count > 0)
                            {
                                hdnBrandID = String.Join(",", brandID.Distinct().ToArray());
                            }
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper brand.',3);", true);
                            return;
                        }
                    }
                    var CompID = Convert.ToInt32(txtCode.Text.Split("-".ToArray()).Last());
                    if (CompID > 0)
                    {
                        OCOMP objOCOMP = ctx.OCOMPs.FirstOrDefault(x => x.OCOMPID == CompID);
                        if (RouteID > 0 && objOCOMP != null)
                        {
                            if (ctx.CRUT1.Count(x => x.OCOMPID == CompID) > 0)
                            {
                                ctx.CRUT1.Where(x => x.OCOMPID == CompID).ToList().ForEach(x => { x.Active = false; });
                            }

                            CRUT1 objCRUT1 = objOCOMP.CRUT1.FirstOrDefault(x => x.CompRouteID == RouteID);

                            if (objCRUT1 == null)
                            {
                                objCRUT1 = new CRUT1();
                                objCRUT1.CRUT1ID = ctx.GetKey("CRUT1", "CRUT1ID", "", ParentID, 0).FirstOrDefault().Value;
                                objCRUT1.ParentID = ParentID;
                                objCRUT1.CompRouteID = RouteID;
                                objCRUT1.OCOMPID = objOCOMP.OCOMPID;
                                ctx.CRUT1.Add(objCRUT1);
                            }
                            objCRUT1.Active = true;
                            objCRUT1.IsDeleted = false;
                        }
                        if (objOCOMP != null)
                        {
                            objOCOMP.CustomerName = txtOName.Text;
                            objOCOMP.ContactPerson = txtContactPerson.Text;
                            objOCOMP.Email = txtEmailID.Text;
                            objOCOMP.Phone = txtMobileNo.Text;
                            objOCOMP.Address1 = txtAddress1.Text;
                            objOCOMP.Address2 = txtAddress2.Text;
                            objOCOMP.Location = txtLocation.Text;
                            objOCOMP.Zipcode = txtpincode.Text;
                            objOCOMP.StateID = StateID;
                            objOCOMP.CityID = CityID;
                            objOCOMP.BrandID = hdnBrandID;
                            objOCOMP.ParentID = DistributorID;
                            objOCOMP.RouteID = RouteID;
                            objOCOMP.UpdatedBy = UserID;
                            objOCOMP.UpdatedDate = DateTime.Now;
                        }

                        OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CompetitorID == CompID && x.IsTemp);
                        if (objOCRD != null)
                        {
                            CRD1 objCRD1 = ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.BranchID == 1);
                            if (objCRD1 != null)
                            {
                                objCRD1.Address1 = txtAddress1.Text;
                                objCRD1.Address2 = txtAddress2.Text;
                                objCRD1.Location = txtLocation.Text;
                                objCRD1.ZipCode = txtpincode.Text;
                                objCRD1.ContactPerson = txtContactPerson.Text;
                                objCRD1.PhoneNumber = txtMobileNo.Text;
                                objCRD1.StateID = StateID;
                                objCRD1.CityID = CityID;
                            }
                            objOCRD.ParentID = DistributorID;
                            objOCRD.CustomerName = txtOName.Text;
                            objOCRD.EMail1 = txtEmailID.Text;
                            objOCRD.Phone = txtMobileNo.Text;
                            objOCRD.UpdatedBy = UserID;
                            objOCRD.UpdatedDate = DateTime.Now;

                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper " + ddlOption.SelectedItem.Text + ".',3);", true);
                        return;
                    }
                }
                else
                {
                    var CustomerID = Convert.ToInt64(txtCode.Text.Split("-".ToArray()).Last());
                    if (CustomerID > 0)
                    {
                        OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID && x.IsTemp);
                        if (objOCRD != null)
                        {
                            objOCRD.ParentID = DistributorID;
                            objOCRD.CustomerName = txtOName.Text;
                            objOCRD.EMail1 = txtEmailID.Text;
                            objOCRD.Phone = txtMobileNo.Text;
                            objOCRD.UpdatedBy = UserID;
                            objOCRD.UpdatedDate = DateTime.Now;
                        }
                        CRD1 objCRD1 = ctx.CRD1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.BranchID == 1);
                        if (objCRD1 != null)
                        {
                            objCRD1.Address1 = txtAddress1.Text;
                            objCRD1.Address2 = txtAddress2.Text;
                            objCRD1.ZipCode = txtpincode.Text;
                            objCRD1.ContactPerson = txtContactPerson.Text;
                            objCRD1.PhoneNumber = txtMobileNo.Text;
                            objCRD1.StateID = StateID;
                            objCRD1.CityID = CityID;
                            objCRD1.Location = txtLocation.Text;
                        }
                        if (RouteID > 0)
                        {
                            if (ctx.RUT1.Count(x => x.CustomerID == CustomerID) > 0)
                            {
                                ctx.RUT1.Where(x => x.CustomerID == CustomerID).ToList().ForEach(x => { x.Active = false; });
                            }

                            RUT1 objRUT1 = objOCRD.RUT1.FirstOrDefault(x => x.RouteID == RouteID);

                            if (objRUT1 == null)
                            {
                                objRUT1 = new RUT1();
                                objRUT1.RUT1ID = ctx.GetKey("RUT1", "RUT1ID", "", ParentID, 0).FirstOrDefault().Value;
                                objRUT1.ParentID = ParentID;
                                objRUT1.RouteID = RouteID;
                                objRUT1.CustomerID = CustomerID;
                                objRUT1.BranchID = 1;

                                ctx.RUT1.Add(objRUT1);
                            }

                            objRUT1.Active = true;
                            objRUT1.IsDeleted = false;
                        }

                        OCOMP objOCOMP = ctx.OCOMPs.FirstOrDefault(x => x.OCOMPID == objOCRD.CompetitorID);
                        if (objOCOMP != null)
                        {
                            objOCOMP.CustomerName = txtOName.Text;
                            objOCOMP.ContactPerson = txtContactPerson.Text;
                            objOCOMP.Email = txtEmailID.Text;
                            objOCOMP.Phone = txtMobileNo.Text;
                            objOCOMP.Address1 = txtAddress1.Text;
                            objOCOMP.Address2 = txtAddress2.Text;
                            objOCOMP.Location = txtLocation.Text;
                            objOCOMP.Zipcode = txtpincode.Text;
                            objOCOMP.StateID = StateID;
                            objOCOMP.CityID = CityID;
                            objOCOMP.RouteID = RouteID;
                            objOCOMP.UpdatedBy = UserID;
                            objOCOMP.UpdatedDate = DateTime.Now;
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper " + ddlOption.SelectedItem.Text + ".',3);", true);
                        return;
                    }
                }
                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + txtCode.Text + "',1);", true);
                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    #endregion
}


