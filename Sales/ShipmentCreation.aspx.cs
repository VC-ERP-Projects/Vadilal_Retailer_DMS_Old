using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.Objects;
using System.Xml.Linq;
using System.Net;
using System.IO;
using System.Data.SqlClient;
using System.Data;
using System.Web.UI.HtmlControls;

public partial class Reports_ShipmentCreation : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID, CustomerID;
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

    public static void TransferCreateCSV(string filePath, DataTable dt, DataRow[] drs)
    {
        StreamWriter sw = null;
        int iColCount = dt.Columns.Count;
        if (!File.Exists(filePath))
        {
            sw = new StreamWriter(filePath, false);

            for (int i = 0; i < iColCount; i++)
            {
                sw.Write(dt.Columns[i]);
                if (i < iColCount - 1)
                {
                    sw.Write(",");
                }
            }
            sw.Write(sw.NewLine);
        }
        else
            sw = new StreamWriter(filePath, true);

        foreach (DataRow dr in drs)
        {
            for (int i = 0; i < iColCount; i++)
            {
                if (!Convert.IsDBNull(dr[i]))
                {
                    sw.Write(dr[i].ToString());
                }
                if (i < iColCount - 1)
                {
                    sw.Write(",");
                }
            }
            sw.Write(sw.NewLine);
        }
        sw.Close();
    }

    public void ClearAllInput()
    {
        txtVehicle.Text = "";
        acetxtVehicle.ContextKey = Convert.ToString(CustType == 4 ? 1000010000000000 : ParentID);
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtStartDateTime.Text = DateTime.Now.ToString("dd/MM/yyyy hh:mm");
        gvShipment.DataSource = null;
        gvShipment.DataBind();
    }

    private void TraceService(string content)
    {
        FileStream fs = new FileStream(Server.MapPath("~/Document/ShipmentFTPFiles/Log.txt"), FileMode.OpenOrCreate, FileAccess.Write);
        StreamWriter sw = new StreamWriter(fs);
        sw.BaseStream.Seek(0, SeekOrigin.End);
        sw.WriteLine(content);
        sw.Close();
    }

    #endregion

    #region Page Load
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInput();
        }
    }
    #endregion

    #region button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                decimal VehicleParentID = CustType == 4 ? 1000010000000000 : ParentID;

                Int32 ChkSelRowCount = (from GridViewRow msgRow in gvShipment.Rows
                                        where ((HtmlInputCheckBox)msgRow.FindControl("chkcheck")).Checked
                                        select msgRow).Count();

                if (ChkSelRowCount > 0)
                {

                    if (!string.IsNullOrEmpty(txtVehicle.Text) && ctx.OVCLs.Any(x => x.VehicleNumber.ToLower().Trim() == txtVehicle.Text.ToLower().Trim()
                        && x.ParentID == VehicleParentID && x.Active))
                    {
                        OVCL objOVCL = ctx.OVCLs.FirstOrDefault(x => x.VehicleNumber.ToLower().Trim() == txtVehicle.Text.ToLower().Trim() && x.ParentID == VehicleParentID && x.Active);

                        OSPM objOSPM = new OSPM();
                        objOSPM.ShippingID = ctx.GetKey("OSPM", "ShippingID", "", ParentID, 0).FirstOrDefault().Value;
                        objOSPM.ParentID = ParentID;
                        objOSPM.ShipmentNo = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID).CustomerCode + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss");
                        objOSPM.VehicleID = objOVCL.VehicleID;
                        objOSPM.CreatedBy = UserID;
                        objOSPM.CreatedDate = DateTime.Now;
                        objOSPM.UpdatedBy = UserID;
                        objOSPM.UpdatedDate = DateTime.Now;
                        objOSPM.IsFTPUpload = false;
                        ctx.OSPMs.Add(objOSPM);

                        foreach (GridViewRow item in gvShipment.Rows)
                        {
                            Int32 SaleID = 0;
                            HiddenField hdnSaleID = (HiddenField)item.FindControl("hdnSaleID");
                            HtmlInputCheckBox chkIsChecked = (HtmlInputCheckBox)item.FindControl("chkcheck");

                            SaleID = Int32.TryParse(hdnSaleID.Value, out SaleID) ? SaleID : 0;
                            if (SaleID > 0 && chkIsChecked.Checked)
                            {
                                OPOS objOPOS = ctx.OPOS.FirstOrDefault(x => x.SaleID == SaleID && x.ParentID == ParentID);
                                if (objOPOS != null)
                                {
                                    objOPOS.ShippingID = objOSPM.ShippingID;
                                }
                            }
                        }

                        ctx.SaveChanges();

                        using (WebClient ftpClient = new WebClient())
                        {
                            var FTPLINK = ctx.OSETs.FirstOrDefault(x => x.KeyName == "FTPLINK").Value;
                            var FTPUserName = ctx.OSETs.FirstOrDefault(x => x.KeyName == "FTPUserName").Value;
                            var FTPPassword = ctx.OSETs.FirstOrDefault(x => x.KeyName == "FTPPassword").Value;

                            ftpClient.Credentials = new System.Net.NetworkCredential(FTPUserName, FTPPassword);
                            FtpWebRequest ftpRequest = (FtpWebRequest)WebRequest.Create(FTPLINK);
                            ftpRequest.Credentials = new NetworkCredential(FTPUserName, FTPPassword);
                            ftpRequest.Method = WebRequestMethods.Ftp.UploadFile;

                            List<OSPM> objSendOSPM = ctx.OSPMs.Where(x => x.ParentID == ParentID && !x.IsFTPUpload).ToList();

                            foreach (OSPM item in objSendOSPM)
                            {
                                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                                SqlCommand cm = new SqlCommand();
                                cm.CommandType = System.Data.CommandType.StoredProcedure;
                                cm.CommandText = "GetShipmentDetailForFTP";
                                cm.Parameters.AddWithValue("@ShippingID", item.ShippingID);
                                cm.Parameters.AddWithValue("@ParentID", item.ParentID);
                                cm.Parameters.AddWithValue("@VehicleParentID", VehicleParentID);
                                DataSet Ds = objClass.CommonFunctionForSelect(cm);
                                if (Ds != null && Ds.Tables[0] != null && Ds.Tables[0].Rows.Count > 0)
                                {
                                    DataTable dt = Ds.Tables[0];
                                    try
                                    {
                                        TransferCreateCSV(Server.MapPath("~/Document/ShipmentFTPFiles/") + item.ShipmentNo + ".csv", dt, dt.Select());

                                        ftpClient.UploadFile(FTPLINK + "/ShipmentFTPFiles/" + item.ShipmentNo + ".csv", ftpRequest.Method, Server.MapPath("~/Document/ShipmentFTPFiles/") + item.ShipmentNo + ".csv");

                                        item.IsFTPUpload = true;
                                    }
                                    catch (Exception ex)
                                    {
                                        TraceService("Ftp Upload Throw exception " + Common.GetString(ex) + "for ShippingID : " + item.ShippingID.ToString() + " & ShipNo : " + item.ShipmentNo);
                                    }
                                    finally
                                    {
                                        if (File.Exists(Server.MapPath("~/Document/ShipmentFTPFiles/") + item.ShipmentNo + ".csv"))
                                        {
                                            File.Delete(Server.MapPath("~/Document/ShipmentFTPFiles/") + item.ShipmentNo + ".csv");
                                        }
                                    }
                                }
                            }

                            ctx.SaveChanges();
                        }

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsgs", "ModelMsg('Shipment added sucessfully.',1);", true);
                        ClearAllInput();
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsgs", "ModelMsg('Select Proper Vehicle.',3);", true);
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsgs", "ModelMsg('Please select atlease one row.',3);", true);

            }
        }
        catch (Exception ex)
        {
            TraceService("Main exception" + Common.GetString(ex));
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsgs", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }

    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                DateTime FromDate = Convert.ToDateTime(txtFromDate.Text);
                DateTime ToDate = Convert.ToDateTime(txtToDate.Text);
                Decimal VehicleParentID = CustType == 4 ? 1000010000000000 : ParentID;

                if (!string.IsNullOrEmpty(txtVehicle.Text) && ctx.OVCLs.Any(x => x.VehicleNumber.ToLower().Trim() == txtVehicle.Text.ToLower().Trim()
                    && x.ParentID == VehicleParentID && x.Active))
                {
                    Int32 VehicleID = ctx.OVCLs.FirstOrDefault(x => x.VehicleNumber.ToLower().Trim() == txtVehicle.Text.ToLower().Trim() && x.ParentID == VehicleParentID && x.Active).VehicleID;

                    var SearchData = (from x in ctx.OPOS
                                      where x.ParentID == ParentID && EntityFunctions.TruncateTime(x.Date) >= EntityFunctions.TruncateTime(FromDate)
                                      && EntityFunctions.TruncateTime(x.Date) <= EntityFunctions.TruncateTime(ToDate) && x.ShippingID == null
                                      && x.VehicleID.HasValue && x.VehicleID == VehicleID
                                      && !ctx.OVCLs.Any(y => y.VehicleID == x.VehicleID && y.ParentID == VehicleParentID && y.VehicleNumber.ToLower().Contains("self lift"))
                                      select new
                                      {
                                          x.SaleID,
                                          x.InvoiceNumber,
                                          x.Date,
                                          Qty = x.POS1.Where(z => z.IsDeleted == false).Sum(y => y.TotalQty),
                                          x.Total,
                                          CustomerCode = x.OCRD != null ? x.OCRD.CustomerCode : "",
                                          CustomerName = x.OCRD != null ? x.OCRD.CustomerName : "",
                                          City = x.OCRD != null && x.OCRD.CRD1.Any(z => !z.IsDeleted) ? x.OCRD.CRD1.FirstOrDefault(z => !z.IsDeleted).OCTY.CityName : "",
                                          VehicleNumber = ctx.OVCLs.Any(m => m.VehicleID == x.VehicleID && m.ParentID == VehicleParentID) ? ctx.OVCLs.FirstOrDefault(m => m.VehicleID == x.VehicleID && m.ParentID == VehicleParentID).VehicleNumber : ""
                                      }).OrderBy(x => x.Date).ThenBy(x => x.InvoiceNumber).ToList();

                    if (SearchData != null)
                    {
                        gvShipment.DataSource = SearchData;
                        gvShipment.DataBind();
                    }
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsgs", "ModelMsg('Select Proper Vehicle.',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsgs", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}