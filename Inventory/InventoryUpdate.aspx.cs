using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Validation;
using System.IO;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Inventory_InventoryUpdate : System.Web.UI.Page
{
    #region Property

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    public class InvUpdateClass
    {
        public string Text { get; set; }
        public string Value { get; set; }
    }
    private List<ItemData> BindList
    {
        get { return this.Session["RET1"] as List<ItemData>; }
        set { this.Session["RET1"] = value; }
    }

    private List<DisData> ORSNs
    {
        get { return this.ViewState["DisData"] as List<DisData>; }
        set { this.ViewState["DisData"] = value; }
    }

    private List<NewItemData> NewList
    {
        get { return this.Session["NewItemDatas"] as List<NewItemData>; }
        set { this.Session["NewItemDatas"] = value; }
    }

    #endregion

    #region Helper Method
    [WebMethod(EnableSession = true)]
    public static Boolean AddRecord(int LineID, int UnitID, string UnitName, Int32 Quantity, Int32 TotalQty, Decimal UnitPrice, Decimal Total)
    {
        Boolean RetVal = false;
        try
        {
            List<ItemData> RET1s = HttpContext.Current.Session["RET1"] as List<ItemData>;
            if (RET1s == null) RET1s = new List<ItemData>();
            var objRET1 = RET1s[LineID];
            if (objRET1 != null)
            {
                objRET1.UnitID = UnitID;
                objRET1.UnitName = UnitName;
                objRET1.Quantity = Quantity;
                objRET1.TotalQty = TotalQty;
                objRET1.UnitPrice = UnitPrice;
                objRET1.Total = Total;
            }
            HttpContext.Current.Session["RET1"] = RET1s;

            RetVal = true;
        }
        catch (Exception)
        {
            RetVal = true;
        }
        return RetVal;
    }

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
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
        else
        {
            Response.Redirect("~/Login.aspx");
        }

    }

    public void ClearAllInputs()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            //For Reset User & Parent
        }
        txtDate.Text = Common.DateTimeConvert(DateTime.Now);
        var DayCloseData = ctx.CheckDayClose(Common.DateTimeConvert(txtDate.Text), ParentID).FirstOrDefault();
        if (!String.IsNullOrEmpty(DayCloseData))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + DayCloseData + "',3);", true);
            btnUpload.Visible = btnSubmit.Visible = false;
            return;
        }
        else
        {
            btnUpload.Visible = btnSubmit.Visible = true;
        }

        txtDistCode.Text = txtNotes.Text = "";

        var Data = ctx.OWHS.Where(x => x.ParentID == ParentID && x.Active).ToList();
        ddlWhs.DataSource = Data;
        ddlWhs.DataBind();
        NewList = new List<NewItemData>();
        BindList = new List<ItemData>();
        BindList.Add(new ItemData());
        gvItem.DataSource = BindList;
        gvItem.DataBind();

        gvMissdata.DataSource = null;
        gvMissdata.DataBind();

        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);

    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (CustType != 1)
        {
            divDistributor.Attributes.Add("style", "display: none");
        }
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(btnUpload);
    }

    #endregion

    #region Button Click

    protected void ddlWhs_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("InventoryUpdate.aspx");
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (CustType == 1 && String.IsNullOrEmpty(txtDistCode.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper Distributor/SS.',3); ChangeQuantity();", true);
                return;
            }
            if (BindList.Count <= 1)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select item.',3); ChangeQuantity();", true);
                return;
            }
            if (CustType == 1 && Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out ParentID) && ParentID == 1000010000000000)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper Distributor/SS.',3); ChangeQuantity();", true);
                return;
            }

            INRT objINRT = new INRT();
            objINRT.INRTID = ctx.GetKey("INRT", "INRTID", "", ParentID, 0).FirstOrDefault().Value;

            objINRT.ParentID = ParentID;
            objINRT.CustomerID = ParentID;
            objINRT.Notes = txtNotes.Text;
            objINRT.WhsID = Convert.ToInt32(ddlWhs.SelectedValue);
            objINRT.DocumentDate = Common.DateTimeConvert(txtDate.Text).Add(DateTime.Now.TimeOfDay);
            objINRT.CreatedDate = DateTime.Now;
            objINRT.CreatedBy = UserID;
            objINRT.UpdatedDate = DateTime.Now;
            objINRT.UpdatedBy = UserID;
            objINRT.TotalItemAmt = BindList.Sum(x => x.Total);
            objINRT.Status = CustType == 1 ? "C" : "D";

            if (ctx.INRTs.Any(x => x.ParentID == ParentID && x.DocumentType == "O") || ctx.OMIDs.Any(x => x.ParentID == ParentID && new int[] { 3, 4 }.Contains(x.InwardType)))
                objINRT.DocumentType = "U";
            else
                objINRT.DocumentType = "O";

            ctx.INRTs.Add(objINRT);

            int Count = ctx.GetKey("NRT1", "NRT1ID", "", ParentID, null).FirstOrDefault().Value;
            int CountM = ctx.GetKey("ITM2", "StockID", "", ParentID, null).FirstOrDefault().Value;

            foreach (var item in BindList)
            {
                Decimal Diffqty = 0;

                if (item.ItemID > 0)
                {
                    ITM2 objITM2 = ctx.ITM2.FirstOrDefault(x => x.ItemID == item.ItemID && x.WhsID == objINRT.WhsID && x.ParentID == ParentID);

                    if (objITM2 == null && item.TotalQty >= 0)
                    {
                        objITM2 = new ITM2();
                        objITM2.StockID = CountM++;
                        objITM2.ParentID = ParentID;
                        objITM2.WhsID = objINRT.WhsID;
                        objITM2.ItemID = item.ItemID;
                        //objITM2.PPrice = item.UnitPrice;
                        ctx.ITM2.Add(objITM2);

                        Diffqty = (objITM2.TotalPacket - item.TotalQty) * -1;
                    }
                    else
                    {
                        Diffqty = (objITM2.TotalPacket - item.TotalQty) * -1;

                        //if ((objITM2.TotalPacket + Diffqty) == 0)
                        //    objITM2.PPrice = ((objITM2.TotalPacket * objITM2.PPrice) + (item.UnitPrice * Diffqty)) / 1;
                        //else
                        //    objITM2.PPrice = ((objITM2.TotalPacket * objITM2.PPrice) + (item.UnitPrice * Diffqty)) / (objITM2.TotalPacket + Diffqty);
                    }
                    objITM2.PPrice = item.UnitPrice;

                    // We update inventory same as qty enter by user in quantity.
                    // current avail qty & updated qty diffrnace store in total qty
                    objITM2.TotalPacket = item.TotalQty;

                    NRT1 objNRT1 = new NRT1();
                    objNRT1.NRT1ID = Count++;
                    objNRT1.ItemID = item.ItemID;
                    objNRT1.UnitID = item.UnitID;
                    objNRT1.AvalQty = item.AvailQty;
                    objNRT1.Qty = item.TotalQty;
                    objNRT1.TotalQty = Diffqty;
                    objNRT1.Price = item.UnitPrice;
                    objNRT1.Total = item.Total;
                    objNRT1.TranType = objINRT.DocumentType;

                    objINRT.NRT1.Add(objNRT1);
                }
            }
            if (objINRT.DocumentDate.Date != DateTime.Now.Date)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('DayClose is missing, please refresh page or do dayclose',3);", true);
                return;
            }
            ctx.SaveChanges();

            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record Inserted Successfully',1);", true);
            ClearAllInputs();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    #endregion

    #region GridView Events

    protected void gvItems_PreRender(object sender, EventArgs e)
    {
        if (gvItem.Rows.Count > 0)
        {
            gvItem.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvItem.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvItem_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            ItemData Data = e.Row.DataItem as ItemData;
            if (Data.ItemID > 0)
            {
                DropDownList ddlUnit = (DropDownList)e.Row.FindControl("ddlUnit");
                foreach (NewItemData item in NewList.Where(x => x.ItemID == Data.ItemID).ToList())
                {
                    ddlUnit.Items.Add(new ListItem(item.Unitname, item.UnitID + "," + item.UnitPrice + "," + item.PriceTax + "," + item.Quantity));
                }
                ddlUnit.SelectedIndex = ddlUnit.Items.IndexOf(ddlUnit.Items.FindByText(Data.UnitName));
            }
        }
    }

    #endregion

    #region TextBoxEvents

    protected void txtCustCode_TextChanged(object sender, EventArgs e)
    {
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        if (DistributorID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Distributor/SS.',3);", true);
            return;
        }
        txtDate.Text = Common.DateTimeConvert(DateTime.Now);
        var DayCloseData = ctx.CheckDayClose(Common.DateTimeConvert(txtDate.Text), DistributorID).FirstOrDefault();
        if (!String.IsNullOrEmpty(DayCloseData))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + DayCloseData + "',3);", true);
            btnUpload.Visible = btnSubmit.Visible = false;
            return;
        }
        else
        {
            btnUpload.Visible = btnSubmit.Visible = true;
        }
        var Data = ctx.OWHS.Where(x => x.ParentID == DistributorID && x.Active).ToList();
        if (Data.Count == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Default warehouse found.',3);", true);
            btnUpload.Visible = btnSubmit.Visible = false;
            return;
        }
        ddlWhs.DataSource = Data;
        ddlWhs.DataBind();
    }

    protected void txtItem_TextChanged(object sender, EventArgs e)
    {
        int WhsID, PriceID = 0;
        if (Int32.TryParse(ddlWhs.SelectedValue, out WhsID) && WhsID > 0)
        {
            TextBox txt = (TextBox)sender;
            GridViewRow row = (GridViewRow)txt.NamingContainer;

            if (!String.IsNullOrEmpty(txt.Text))
            {
                var word = txt.Text.Split("-".ToArray());
                if (word.Length > 1)
                {
                    var ItemCode = word.First().Trim();
                    int ItemID = ctx.OITMs.Where(x => x.ItemCode == ItemCode && x.Active).Select(x => x.ItemID).DefaultIfEmpty(0).FirstOrDefault();
                    if (ItemID > 0)
                    {
                        int DivisionID = ctx.OGITMs.FirstOrDefault(x => x.ItemID == ItemID && x.DivisionlID.HasValue).DivisionlID.Value;
                        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
                        if (CustType == 1 && ParentID == 1000010000000000)
                        {
                            if (DistributorID > 0)
                            {
                                PriceID = ctx.OGCRDs.Where(x => x.CustomerID == DistributorID && x.DivisionlID == DivisionID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Distributor/SS.',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            PriceID = ctx.OGCRDs.Where(x => x.CustomerID == ParentID && x.DivisionlID == DivisionID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();
                        }
                        var NewID = DistributorID > 0 ? DistributorID : ParentID;

                        var Data = ctx.PurchaseItem(NewID, PriceID, 0, ItemID, 0, WhsID).ToList();
                        if (Data.Count > 0)
                        {
                            if (NewList == null)
                                NewList = new List<NewItemData>();

                            if (BindList[row.RowIndex].ItemID > 0)
                            {
                                NewList.RemoveAll(x => x.ItemID == BindList[row.RowIndex].ItemID);
                                NewList.AddRange((from x in Data
                                                  select new NewItemData
                                                  {
                                                      ItemID = x.ItemID,
                                                      UnitID = x.UnitID,
                                                      Unitname = x.Unitname,
                                                      UnitPrice = x.UnitPrice,
                                                      PriceTax = x.Tax,
                                                      Quantity = Convert.ToInt32(x.Quantity)
                                                  }).ToList());

                                ItemData tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.ItemCode, y.AvailQty, y.TaxID }).ToList()
                                                    select new ItemData
                                                    {
                                                        ItemID = x.Key.ItemID,
                                                        ItemCode = x.Key.ItemCode,
                                                        ItemName = x.Key.ItemName,
                                                        AvailQty = Convert.ToInt32(x.Key.AvailQty),
                                                        TaxID = x.Key.TaxID
                                                    }).FirstOrDefault();

                                BindList[row.RowIndex] = tmpList;
                            }
                            else
                            {
                                NewList.RemoveAll(x => x.ItemID == BindList[row.RowIndex].ItemID);
                                NewList.AddRange((from x in Data
                                                  select new NewItemData
                                                  {
                                                      ItemID = x.ItemID,
                                                      UnitID = x.UnitID,
                                                      Unitname = x.Unitname,
                                                      UnitPrice = x.UnitPrice,
                                                      PriceTax = x.Tax,
                                                      Quantity = Convert.ToInt32(x.Quantity)
                                                  }).ToList());

                                List<ItemData> tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.ItemCode, y.AvailQty, y.TaxID }).ToList()
                                                          select new ItemData
                                                          {
                                                              ItemID = x.Key.ItemID,
                                                              ItemCode = x.Key.ItemCode,
                                                              ItemName = x.Key.ItemName,
                                                              AvailQty = Convert.ToInt32(x.Key.AvailQty),
                                                              TaxID = x.Key.TaxID
                                                          }).ToList();


                                BindList.RemoveAt(BindList.Count - 1);
                                BindList.AddRange(tmpList);
                                BindList.Add(new ItemData());
                            }
                            gvItem.DataSource = BindList;
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please contact Marketing Department to resolve this issue.',3); ChangeQuantity();", true);
                            txt.Text = "";
                            return;
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Item is not found.',3); ChangeQuantity();", true);
                        txt.Text = "";
                        return;
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Item.',3); ChangeQuantity();", true);
                    txt.Text = "";
                    return;
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
            }
            else
            {
                if (BindList.Count - 1 != row.RowIndex)
                {
                    BindList.RemoveAt(row.RowIndex);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
                }
            }
            gvItem.DataSource = BindList;
            gvItem.DataBind();
            TextBox txtQty = (TextBox)row.FindControl("txtEnterQty");
            txtQty.Focus();
        }
    }

    [WebMethod(EnableSession = true)]
    public static List<InvUpdateClass> GetActiveMaterialByPlant(string prefixText,  string contextKey)
    {
        List<InvUpdateClass> StrMat = new List<InvUpdateClass>();
        List<int> ItemIDs = new List<int>();
        Decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

        if (!string.IsNullOrEmpty(contextKey) && contextKey.Split("#".ToArray()).Length == 2)
        {
            var itms = contextKey.Split("#".ToArray());

            ParentID = Decimal.TryParse(itms[0], out ParentID) ? ParentID : 0;

            var stritem = itms[1].Trim();
            if (!String.IsNullOrEmpty(stritem))
            {
                stritem.Split(",".ToArray()).ToList().ForEach(x => ItemIDs.Add(Convert.ToInt32(x)));
            }
        }

        using (var ctx = new DDMSEntities())
        {
            List<int> PlantIDs = ctx.OGCRDs.Where(y => y.PlantID.HasValue && y.DivisionlID.HasValue && y.CustomerID == ParentID).Select(x => x.PlantID.Value).Distinct().ToList();

            if (prefixText == "*")
            {
                StrMat = (from c in ctx.OITMs.Where(x => x.Active && !(ItemIDs.Contains(x.ItemID)) && (x.OGITMs.Any(s => s.PlantID.HasValue && PlantIDs.Contains(s.PlantID.Value) && s.Active)))
                          select new InvUpdateClass
                          {
                              Text = c.ItemCode + " - " + c.ItemName,
                              Value = c.ItemCode
                          }).Take(20).ToList();
            }
            else
            {
                StrMat = (from c in ctx.OITMs.Where(x => x.Active && !(ItemIDs.Contains(x.ItemID)) &&
                      (x.ItemCode.Contains(prefixText) || x.ItemName.Contains(prefixText))
                      && (x.OGITMs.Any(s => s.PlantID.HasValue && PlantIDs.Contains(s.PlantID.Value) && s.Active)))
                          select new InvUpdateClass
                          {
                              Text = c.ItemCode + " - " + c.ItemName,
                              Value = c.ItemCode
                              //Select(x => x.ItemCode + " - " + x.ItemName).Take(20).ToList();
                          }).Take(20).ToList();
                //Select(x => x.ItemCode + " - " + x.ItemName).Take(20).ToList();
            }

            return StrMat;
        }
    }
    #endregion

    #region CSVUPLOAD

    public static void TransferCSVToTable(string filePath, DataTable dt)
    {
        string[] csvRows = System.IO.File.ReadAllLines(filePath);
        string[] fields = null;
        bool head = true;
        foreach (string csvRow in csvRows)
        {
            if (head)
            {
                if (dt.Columns.Count == 0)
                {
                    fields = csvRow.Split(',');
                    foreach (string column in fields)
                    {
                        DataColumn datecolumn = new DataColumn(column);
                        datecolumn.AllowDBNull = true;
                        dt.Columns.Add(datecolumn);
                    }
                }
                head = false;
            }
            else
            {
                fields = csvRow.Split(',');
                DataRow row = dt.NewRow();
                row.ItemArray = new object[fields.Length];
                row.ItemArray = fields;
                dt.Rows.Add(row);
            }
        }
    }

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        DataTable missdata = new DataTable();
        missdata.Columns.Add("Material Code");
        missdata.Columns.Add("Material Name");
        missdata.Columns.Add("ErrorMsg");

        try
        {
            if (flCSVUpload.HasFile)
            {
                decimal DecNum = 0;
                DataTable dtItems = new DataTable();
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flCSVUpload.PostedFile.FileName));
                flCSVUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flCSVUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    TransferCSVToTable(fileName, dtItems);
                    if (dtItems != null && dtItems.Rows != null && dtItems.Rows.Count > 0)
                    {
                        int ItemCount = dtItems.AsEnumerable().Select(r => new { ItemCode = r.Field<string>("ItemCode") }).GroupBy(x => x.ItemCode).
                            Where(grp => grp.Count() > 1).Count();

                        if (ItemCount > 0)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Dublicate item found in File',3);", true);
                            return;
                        }

                        bool IsError = false;

                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            IsError = false;
                            int WareHouseID = Convert.ToInt32(ddlWhs.SelectedValue);


                            if (CustType == 1 && Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out ParentID) && ParentID == 1000010000000000)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper Distributor/SS.',3);", true);
                                return;
                            }

                            int INRTID = ctx.GetKey("INRT", "INRTID", "", ParentID, 0).FirstOrDefault().Value;
                            int Count = ctx.GetKey("NRT1", "NRT1ID", "", ParentID, null).FirstOrDefault().Value;
                            int CountM = ctx.GetKey("ITM2", "StockID", "", ParentID, null).FirstOrDefault().Value;

                            INRT objINRT = new INRT();
                            objINRT.INRTID = INRTID++;
                            objINRT.ParentID = ParentID;
                            objINRT.CustomerID = ParentID;

                            if (ctx.INRTs.Any(x => x.ParentID == ParentID && x.DocumentType == "O") || ctx.OMIDs.Any(x => x.ParentID == ParentID && new int[] { 3, 4 }.Contains(x.InwardType)))
                                objINRT.DocumentType = "U";
                            else
                                objINRT.DocumentType = "O";

                            objINRT.WhsID = WareHouseID;
                            objINRT.DocumentDate = Common.DateTimeConvert(txtDate.Text).Add(DateTime.Now.TimeOfDay);
                            objINRT.CreatedDate = DateTime.Now;
                            objINRT.CreatedBy = UserID;
                            objINRT.UpdatedDate = DateTime.Now;
                            objINRT.UpdatedBy = UserID;

                            ctx.INRTs.Add(objINRT);

                            NRT1 objNRT1 = null;
                            ITM2 objITM2 = null;
                            string ItemCode = "", ItemName = "";
                            Decimal Quantity = 0;
                            OITM objOITM = null;

                            Decimal AvalQty = 0;

                            for (int i = 0; i < dtItems.Rows.Count; i++)
                            {
                                try
                                {
                                    ItemCode = dtItems.Rows[i]["ItemCode"].ToString();
                                    ItemName = dtItems.Rows[i]["ItemName"].ToString();
                                    Quantity = Decimal.TryParse(dtItems.Rows[i]["Quantity"].ToString(), out DecNum) ? DecNum : 0;
                                    AvalQty = 0;

                                    objOITM = ctx.OITMs.FirstOrDefault(x => x.ItemCode == ItemCode);

                                    if (objOITM != null && Quantity >= 0)
                                    {

                                        Decimal Diffqty = 0;
                                        objITM2 = ctx.ITM2.FirstOrDefault(x => x.ItemID == objOITM.ItemID && x.WhsID == objINRT.WhsID && x.ParentID == ParentID);

                                        int DivisionID = ctx.OGITMs.FirstOrDefault(x => x.ItemID == objOITM.ItemID && x.DivisionlID.HasValue).DivisionlID.Value;
                                        int PriceID = ctx.OGCRDs.Where(x => x.CustomerID == ParentID && x.DivisionlID == DivisionID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

                                        var Data = ctx.PurchaseItem(ParentID, PriceID, 0, objOITM.ItemID, 0, objINRT.WhsID).FirstOrDefault();
                                        if (Data != null)
                                        {
                                            if (objITM2 == null)
                                            {
                                                objITM2 = new ITM2();
                                                objITM2.StockID = CountM++;
                                                objITM2.ParentID = ParentID;
                                                objITM2.WhsID = objINRT.WhsID;
                                                objITM2.ItemID = objOITM.ItemID;
                                                //objITM2.PPrice = Data.UnitPrice;
                                                ctx.ITM2.Add(objITM2);
                                            }
                                            objITM2.PPrice = Data.UnitPrice;
                                            Diffqty = (objITM2.TotalPacket - Quantity) * -1;

                                            //if ((objITM2.TotalPacket + Diffqty) == 0)
                                            //    objITM2.PPrice = ((objITM2.TotalPacket * objITM2.PPrice) + (Data.UnitPrice * Diffqty)) / 1;
                                            //else
                                            //    objITM2.PPrice = ((objITM2.TotalPacket * objITM2.PPrice) + (Data.UnitPrice * Diffqty)) / (objITM2.TotalPacket + Diffqty);
                                        }
                                        else
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["Material Code"] = ItemCode;
                                            missdr["Material Name"] = ItemName;
                                            missdr["ErrorMsg"] = "No Price Found.";
                                            missdata.Rows.Add(missdr);
                                            IsError = true;
                                        }

                                        AvalQty = objITM2.TotalPacket;

                                        objITM2.TotalPacket = Quantity;

                                        objNRT1 = new NRT1();
                                        objNRT1.NRT1ID = Count++;
                                        objNRT1.ItemID = objOITM.ItemID;
                                        objNRT1.UnitID = ctx.ITM1.FirstOrDefault(x => x.ItemID == objOITM.ItemID && x.IsBaseUnit == true).UnitID;
                                        objNRT1.AvalQty = AvalQty;
                                        objNRT1.Qty = Quantity;
                                        objNRT1.TotalQty = Diffqty;
                                        objNRT1.Price = Data.UnitPrice;
                                        objNRT1.Total = Data.UnitPrice * Quantity;
                                        objNRT1.TranType = objINRT.DocumentType;
                                        objINRT.NRT1.Add(objNRT1);

                                    }
                                    else
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Material Code"] = ItemCode;
                                        missdr["Material Name"] = ItemName;
                                        missdr["ErrorMsg"] = "Item Code Not Found or Quantity is in Minus";
                                        missdata.Rows.Add(missdr);
                                        IsError = true;
                                    }
                                }
                                catch (DbEntityValidationException ex)
                                {
                                    var error = ex.EntityValidationErrors.First().ValidationErrors.First();

                                    DataRow missdr = missdata.NewRow();
                                    missdr["Material Code"] = ItemCode;
                                    missdr["Material Name"] = ItemName;
                                    missdr["ErrorMsg"] = error.ErrorMessage.Replace("'", "");
                                    missdata.Rows.Add(missdr);
                                    IsError = true;
                                }
                                catch (Exception ex)
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Material Code"] = ItemCode;
                                    missdr["Material Name"] = ItemName;
                                    missdr["ErrorMsg"] = Common.GetString(ex);
                                    missdata.Rows.Add(missdr);
                                    IsError = true;
                                }
                            }

                            if (IsError == false)
                            {
                                ctx.SaveChanges();
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('File upload successfully.',1);", true);
                                ClearAllInputs();

                                divMissData.Attributes.Add("style", "display: none");
                            }
                            else
                            {
                                gvMissdata.DataSource = missdata;
                                gvMissdata.DataBind();
                            }



                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('No record found.',2);", true);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Upload only CSV file format.',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload file.',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}