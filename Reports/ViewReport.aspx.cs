using System;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System.IO;
using System.Web.UI;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Data.EntityClient;

public partial class Reports_ViewReport : System.Web.UI.Page
{
    protected int UserID, Type;
    protected decimal ParentID;
    protected String AuthType;
    public Boolean Export { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!IsPostBack)
            {
                ParentID = Convert.ToDecimal(Session["ParentID"]);
                UserID = Convert.ToInt32(Session["UserID"]);
                Type = Convert.ToInt32(Session["Type"]);

                if (Request.QueryString["Export"] != null)
                    Reports(true);
                else
                    Reports(false);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "alert('" + Common.GetString(ex) + "');", true);
        }
    }

    public void Reports(bool Export)
    {
        ReportDocument myReport = new ReportDocument();

        MemoryStream mem = new MemoryStream();
        try
        {
            ConnectionInfo myConnectionInfo = new ConnectionInfo();
            if (!string.IsNullOrEmpty(Request.QueryString["CustMstActive"])) // Customer Master
            {
                myReport.Load(Server.MapPath("CrystalReports/CustomerMaster.rpt"));
                myReport.SetParameterValue("@Active", Request.QueryString["CustMstActive"].ToString());
                myReport.SetParameterValue("@Type", (Type + 1).ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["EmpMstActive"])) // Employee Master
            {
                myReport.Load(Server.MapPath("CrystalReports/EmployeeMaster.rpt"));
                myReport.SetParameterValue("@Active", Request.QueryString["EmpMstActive"].ToString());
                //myReport.SetParameterValue("@RegionID", Request.QueryString["EmpMstRegionID"].ToString());
                //myReport.SetParameterValue("@SUserID", Request.QueryString["EmpMstSUserID"].ToString());
                //myReport.SetParameterValue("@CustomerID", Request.QueryString["CompCust"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["VclMstActive"])) // Vehicle Master
            {
                myReport.Load(Server.MapPath("CrystalReports/VehicleMaster.rpt"));
                myReport.SetParameterValue("@Active", Request.QueryString["VclMstActive"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["WarMstActive"])) // Warehouse Master
            {
                myReport.Load(Server.MapPath("CrystalReports/WarehouseMaster.rpt"));
                myReport.SetParameterValue("@Active", Request.QueryString["WarMstActive"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["VndMstActive"])) // Vendor Master
            {
                myReport.Load(Server.MapPath("CrystalReports/VendorMaster.rpt"));
                myReport.SetParameterValue("@Active", Request.QueryString["VndMstActive"].ToString());
                myReport.SetParameterValue("@PParentID", Request.QueryString["VndMstIsParent"].ToString());
                myReport.SetParameterValue("@IsItem", Request.QueryString["VndIsItem"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["MatMstStatus"]))  // Item Master
            {
                myReport.Load(Server.MapPath("CrystalReports/MaterialMaster.rpt"));
                myReport.SetParameterValue("@Active", Request.QueryString["MatMstStatus"].ToString());
                myReport.SetParameterValue("@PurchasePriceListID", Request.QueryString["PurchasePricelistID"].ToString());
                myReport.SetParameterValue("@SalePriceListID", Request.QueryString["Salepricelistid"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["WarUtiMstActive"])) // Warehouse Utilization
            {
                myReport.Load(Server.MapPath("CrystalReports/WhsUtilizationReport.rpt"));
                myReport.SetParameterValue("@Active", Request.QueryString["WarUtiMstActive"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["BOMActive"])) // Bill Of Item
            {
                myReport.Load(Server.MapPath("CrystalReports/BillofMaterial.rpt"));
                myReport.SetParameterValue("@Active", Request.QueryString["BOMActive"].ToString());
                myReport.SetParameterValue("@ItemID", Request.QueryString["BOMItemID"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["MatBarcodeStatus"])) // Item Master
            {
                myReport.Load(Server.MapPath("CrystalReports/BarcodeMaterialMaster.rpt"));
                myReport.SetParameterValue("@Active", Request.QueryString["MatBarcodeStatus"].ToString());
                myReport.SetParameterValue("@ItemGroupID", Request.QueryString["MatBarcodeIGID"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["StockStatementWhsID"])) // Stock Statement
            {
                myReport.Load(Server.MapPath("CrystalReports/StockStatement.rpt"));
                myReport.SetParameterValue("@WhsID", Request.QueryString["StockStatementWhsID"].ToString());
                myReport.SetParameterValue("@ItemGroupID", Request.QueryString["StockStatementIGID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["StockStatementSSID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["StockStatementDistID"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["StockStatementRptFor"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["StockStatementSUserID"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["DivisionID"].ToString());

            }
            else if (!string.IsNullOrEmpty(Request.QueryString["StockSummaryWhsID"])) // Stock Summary
            {
                myReport.Load(Server.MapPath("CrystalReports/StockSummary.rpt"));
                myReport.SetParameterValue("@WhsID", Request.QueryString["StockSummaryWhsID"].ToString());
                myReport.SetParameterValue("@ItemGroupID", Request.QueryString["StockSummaryIGID"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["MatCostingFromDate"]) && !string.IsNullOrEmpty(Request.QueryString["MatCostingToDate"])) // Item Costing
            {
                myReport.Load(Server.MapPath("CrystalReports/MaterialCosting.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["MatCostingFromDate"]));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["MatCostingToDate"]));
                myReport.SetParameterValue("@IsWholeSale", Request.QueryString["MatCostingIsWholeSale"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["PLFromDate"]) && !string.IsNullOrEmpty(Request.QueryString["PLToDate"])) // Profit And Loss
            {
                myReport.Load(Server.MapPath("CrystalReports/Profit&Loss.rpt"));

                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["PLFromDate"]));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["PLToDate"]));
                myReport.SetParameterValue("@IsWholeSale", Request.QueryString["PLIsWholeSale"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["TotalSaleSummaryFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["TotalSaleSummaryToDate"])) // Total Sales Summary
            {
                if (Request.QueryString["TotalSaleIsDate"].ToString() == "1")
                {
                    myReport.Load(Server.MapPath("CrystalReports/TotalSales_DateWise.rpt"));
                }
                else
                {
                    myReport.Load(Server.MapPath("CrystalReports/TotalSales_ItemWise.rpt"));
                }
                myReport.SetParameterValue("@IsDate", Request.QueryString["TotalSaleIsDate"].ToString());
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["TotalSaleSummaryFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["TotalSaleSummaryToDate"].ToString()));
                myReport.SetParameterValue("@IsMaterial", Request.QueryString["TotalSaleSummaryIsMaterial"].ToString());
                myReport.SetParameterValue("@ItemGroupID", Request.QueryString["TotSaleItemGroup"].ToString());
                myReport.SetParameterValue("@IsGroup", Request.QueryString["TotalSaleIsGroup"].ToString());
                myReport.SetParameterValue("@ItemID", Request.QueryString["TotalSaleItem"].ToString());
                myReport.SetParameterValue("@SaleBy", Request.QueryString["TotSaleSaleBy"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["TotSaleSSID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["TotSaleDistributorID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["TotSaleCustomerID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["TotSaleSUserID"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["DivisionID"].ToString());

            }
            else if (!String.IsNullOrEmpty(Request.QueryString["TotPurFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["TotPurToDate"])) // Total Purcahse
            {
                myReport.Load(Server.MapPath("CrystalReports/TotalPurchase.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["TotPurFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["TotPurToDate"].ToString()));
                myReport.SetParameterValue("@ItemGroupID", Request.QueryString["TotPurIGID"].ToString());
                myReport.SetParameterValue("@ItemID", Request.QueryString["TotPurItemID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["TotPurSSID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["TotPurDistID"].ToString());
                myReport.SetParameterValue("@PurchaseBy", Request.QueryString["TotPurPurchaseBy"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["TotPurSUserID"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["DivisionID"].ToString());

            }
            else if (!String.IsNullOrEmpty(Request.QueryString["SalesRegisFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["SalesRegisToDate"]))  // Sales Register
            {
                myReport.Load(Server.MapPath("CrystalReports/SalesRegister.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["SalesRegisFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["SalesRegisToDate"].ToString()));
                myReport.SetParameterValue("@OrderType", Request.QueryString["SalesRegisType"].ToString());
                myReport.SetParameterValue("@IsMobile", Request.QueryString["SalesRegisIsMobile"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["SalesContriFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["SalesContriToDate"])) // Sales Contribution 
            {
                myReport.Load(Server.MapPath("CrystalReports/DealerWiseNOSaleRPt.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["SalesContriFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["SalesContriToDate"].ToString()));
                //myReport.SetParameterValue("@PlantID", Request.QueryString["SalesContriPlantID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["SalesContriRegionID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["SalesContriDistributorID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["SalesContriSSID"].ToString());
                myReport.SetParameterValue("@SaleBy", Request.QueryString["SalesContriSaleBy"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["SalesContriSelectedEmpID"].ToString());
                myReport.SetParameterValue("@CustStatus", Request.QueryString["SalesContriCustStatus"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["GoodsDeliAgingFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["GoodsDeliAgingToDate"])) // GoodsDeliveryAging
            {
                myReport.Load(Server.MapPath("CrystalReports/GoodsDeliveryAgingReport.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["GoodsDeliAgingFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["GoodsDeliAgingToDate"].ToString()));
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["PurRegisFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["PurRegisToDate"])) // Purchase Register
            {
                if (Request.QueryString["PurRegisIsMaterail"].ToString() == "1")
                    myReport.Load(Server.MapPath("CrystalReports/PurchaseRegister_ItemWise.rpt"));
                else
                    myReport.Load(Server.MapPath("CrystalReports/PurchaseRegister.rpt"));

                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["PurRegisFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["PurRegisToDate"].ToString()));
                myReport.SetParameterValue("@InwardType", Request.QueryString["PurRegisType"].ToString());
                myReport.SetParameterValue("@IsItem", Request.QueryString["PurRegisIsMaterail"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["TransRegisFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["TransRegisToDate"])) // Transfer Register
            {
                myReport.Load(Server.MapPath("CrystalReports/TransferRegister.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["TransRegisFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["TransRegisToDate"].ToString()));
                myReport.SetParameterValue("@InwardType", Request.QueryString["TransRegisType"].ToString());
                myReport.SetParameterValue("@IsItem", Request.QueryString["TransRegisIsMaterail"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["CWMFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["CWMToDate"])) // Consume/Waste Item
            {
                myReport.Load(Server.MapPath("CrystalReports/ConsumeWasteMaterial.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["CWMFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["CWMToDate"].ToString()));
                myReport.SetParameterValue("@Type", Request.QueryString["CWMType"].ToString());
                myReport.SetParameterValue("@ItemGroupID", Request.QueryString["CWMIGID"].ToString());
                myReport.SetParameterValue("@ReasonID", Request.QueryString["CWMReasonID"].ToString());
                myReport.SetParameterValue("@CustomerID", Request.QueryString["CWMReasonCustomerID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["CWMReasonRegionID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["CWMReasonSUserID"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["MatStatusFromDate"]) && !string.IsNullOrEmpty(Request.QueryString["MatStatusToDate"])) // Item Status
            {
                myReport.Load(Server.MapPath("CrystalReports/MaterialStatus.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["MatStatusFromDate"]));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["MatStatusToDate"]));
                myReport.SetParameterValue("@ItemGroupID", Request.QueryString["MatStatusIGID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["MatStatusSSID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["MatStatusDistID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["MatStatusSUserID"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["MatStatusReportBy"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["DivisionID"].ToString());
                myReport.SetParameterValue("@TranType", Request.QueryString["TranType"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["BillPymtFromDate"]) && !string.IsNullOrEmpty(Request.QueryString["BillPymtToDate"])) // Bill Payment
            {
                myReport.Load(Server.MapPath("CrystalReports/BillPayment.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["BillPymtFromDate"]));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["BillPymtToDate"]));
                myReport.SetParameterValue("@VendorID", Request.QueryString["BillPymtVendorID"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["MatSummaryFromDate"]) && !string.IsNullOrEmpty(Request.QueryString["MatSummaryToDate"])) // Item Summary
            {
                myReport.Load(Server.MapPath("CrystalReports/MaterialSummary.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["MatSummaryFromDate"]));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["MatSummaryToDate"]));
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["SVPMFromDate"]) && !string.IsNullOrEmpty(Request.QueryString["SVPMToDate"])) // Sales V/S Packing Item Consumption 
            {
                myReport.Load(Server.MapPath("CrystalReports/SalesVSPackingConsumption.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["SVPMFromDate"]));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["SVPMToDate"]));
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["CRActive"])) // Customer Register
            {
                myReport.Load(Server.MapPath("CrystalReports/CustomerRegister.rpt"));
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["PONumber"])) // Purchase Order
            {
                myReport.Load(Server.MapPath("CrystalReports/PurchaseOrder.rpt"));
                //myReport.SetParameterValue("@DivisionID", Request.QueryString["DivisionID"].ToString());
                myReport.SetParameterValue("@DocKey", Request.QueryString["PONumber"].ToString());
                myReport.SetParameterValue("@CustParentID", Session["OutletPID"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["PurSummPONumber"])) // Purchase Summary
            {
                myReport.Load(Server.MapPath("CrystalReports/PurchaseSummary.rpt"));
                myReport.SetParameterValue("@DocKey", Request.QueryString["PurSummPONumber"].ToString());
                myReport.SetParameterValue("@ItemGroupID", Request.QueryString["PurSummIGID"].ToString());
                myReport.SetParameterValue("@CustParentID", Session["OutletPID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["CompTotSummFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["CompTotSummToDate"]))  // Company Total Summary
            {
                myReport.Load(Server.MapPath("CrystalReports/CompanyTotalSummary.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["CompTotSummFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["CompTotSummToDate"].ToString()));
                myReport.SetParameterValue("@ItemGroupID", Request.QueryString["CompTotSummIGID"].ToString());
                myReport.SetParameterValue("@CustomerID", Request.QueryString["CompTotSummCustomerID"].ToString());
                myReport.SetParameterValue("@IsAmount", Request.QueryString["CompTotSummIsAmount"].ToString());
                myReport.SetParameterValue("@IsItem", Request.QueryString["CompTotSummIsItem"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["SaleBillPymtFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["SaleBillPymtToDate"])) // Sale Bill Payment
            {
                myReport.Load(Server.MapPath("CrystalReports/SaleBillPayment.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["SaleBillPymtFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["SaleBillPymtToDate"].ToString()));
                myReport.SetParameterValue("@PaymentDetail", Convert.ToInt32(Request.QueryString["SaleBillPymtDetail"]));
                myReport.SetParameterValue("@PaymentMode", Convert.ToInt32(Request.QueryString["SaleBillPymtMode"]));
                myReport.SetParameterValue("@CustomerID", Request.QueryString["SaleBillPymtCust"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["PurBillPymtFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["PurBillPymtToDate"])) // Purchase Bill Payment
            {
                myReport.Load(Server.MapPath("CrystalReports/PurchaseBillPayment.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["PurBillPymtFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["PurBillPymtToDate"].ToString()));
                myReport.SetParameterValue("@PaymentDetail", Convert.ToInt32(Request.QueryString["PurBillPymtDetail"]));
                myReport.SetParameterValue("@PaymentMode", Convert.ToInt32(Request.QueryString["PurBillPymtMode"]));
                myReport.SetParameterValue("@VendorID", Request.QueryString["PurBillPymtVndr"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["SPRFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["SPRToDate"])) // Sales Return
            {
                myReport.Load(Server.MapPath("CrystalReports/SalesReturn.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["SPRFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["SPRToDate"].ToString()));
                myReport.SetParameterValue("@Type", Request.QueryString["SPRType"].ToString());
                myReport.SetParameterValue("@ItemGroupID", Request.QueryString["SPRIGID"].ToString());
                myReport.SetParameterValue("@ItemID", Request.QueryString["SPRItem"].ToString());
                myReport.SetParameterValue("@ReasonId", Request.QueryString["SPRReasonID"].ToString());
                myReport.SetParameterValue("@CustomerWise", Request.QueryString["SPRIsCustomerWise"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["DataSyncLogFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["DataSyncLogToDate"])) // Data Sync Log
            {
                myReport.Load(Server.MapPath("CrystalReports/DataSyncLog.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["DataSyncLogFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["DataSyncLogToDate"].ToString()));
                myReport.SetParameterValue("@CustType", (Type).ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["SalesOrderNo"])) //SalesOrderNo
            {
                //if (Request.QueryString["SalesOrderIsOld"].ToString().ToLower() == "true")
                //{
                //    if (Request.QueryString["SalesOrderPageSize"].ToString() == "A4")
                //    {
                //        myReport.Load(Server.MapPath("CrystalReports/SalesInvoice_A4_BeforeAddPOS3.rpt"));
                //        myReport.SetParameterValue("@SaleID", Request.QueryString["SalesOrderNo"].ToString());
                //    }
                //    else if (Request.QueryString["SalesOrderPageSize"].ToString() == "A5")
                //    {
                //        myReport.Load(Server.MapPath("CrystalReports/SalesInvoice_A5_BeforeAddPOS3.rpt"));
                //        myReport.SetParameterValue("@SaleID", Request.QueryString["SalesOrderNo"].ToString());
                //    }
                //}
                //else
                //{
                //    if (Request.QueryString["SalesOrderPageSize"].ToString() == "A4")
                //    {
                //        myReport.Load(Server.MapPath("CrystalReports/SalesInvoice_A4.rpt"));
                //        myReport.SetParameterValue("@SaleID", Request.QueryString["SalesOrderNo"].ToString());
                //    }
                //    else if (Request.QueryString["SalesOrderPageSize"].ToString() == "A5")
                //    {
                //        myReport.Load(Server.MapPath("CrystalReports/SalesInvoice_A5.rpt"));
                //        myReport.SetParameterValue("@SaleID", Request.QueryString["SalesOrderNo"].ToString());
                //    }
                //}

                if (Request.QueryString["SalesOrderIsOld"].ToString().ToLower() == "0")
                {
                    myReport.Load(Server.MapPath("CrystalReports/SalesInvoice_A4_BeforeAddPOS3.rpt"));
                    myReport.SetParameterValue("@SaleID", Request.QueryString["SalesOrderNo"].ToString());
                }
                else if (Request.QueryString["SalesOrderIsOld"].ToString().ToLower() == "1")
                {
                    myReport.Load(Server.MapPath("CrystalReports/SalesInvoice_A4_WithoutGST.rpt"));
                    myReport.SetParameterValue("@SaleID", Request.QueryString["SalesOrderNo"].ToString());
                }
                else if (Request.QueryString["SalesOrderIsOld"].ToString().ToLower() == "2")
                {
                    myReport.Load(Server.MapPath("CrystalReports/SalesInvoice_A4_Portrait.rpt"));
                    //if (UserID == 11 || UserID == 1576)
                    //{
                    //    myReport.Load(Server.MapPath("CrystalReports/SalesInvoice_A4_Portrait.rpt"));
                    //}
                    //else
                    //{
                    //    myReport.Load(Server.MapPath("CrystalReports/SalesInvoice_A4.rpt"));
                    //}
                    myReport.SetParameterValue("@SaleID", Request.QueryString["SalesOrderNo"].ToString());
                }
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["ReturnNo"]))  //Sales Return
            {
                if (Request.QueryString["ReturnIsOld"].ToString().ToLower() == "false")
                {
                    myReport.Load(Server.MapPath("CrystalReports/SalesReturnInvoice.rpt"));
                    myReport.SetParameterValue("@ReturnID", Request.QueryString["ReturnNo"].ToString());
                }
                else
                {
                    myReport.Load(Server.MapPath("CrystalReports/SalesReturnInvoice_WithoutGST.rpt"));
                    myReport.SetParameterValue("@ReturnID", Request.QueryString["ReturnNo"].ToString());
                }
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["TripReportOrderNo"])) //TripReportOrderNo
            {
                myReport.Load(Server.MapPath("CrystalReports/TripReport.rpt"));
                myReport.SetParameterValue("@SaleID", Request.QueryString["TripReportOrderNo"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["SalesRegisterOrderNo"])) //Sales Register
            {
                myReport.Load(Server.MapPath("CrystalReports/SalesRegister.rpt"));
                myReport.SetParameterValue("@SaleID", Request.QueryString["SalesRegisterOrderNo"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["TCHFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["TCHToDate"])) // Target Commission History
            {
                myReport.Load(Server.MapPath("CrystalReports/TargetCommissionHistory.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["TCHFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["TCHToDate"].ToString()));
                myReport.SetParameterValue("@Type", Request.QueryString["TCHType"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["AMActive"])) //Asset Master
            {
                myReport.Load(Server.MapPath("CrystalReports/AssetMaster.rpt"));
                myReport.SetParameterValue("@ConfirmType", Request.QueryString["AMActive"].ToString());
                myReport.SetParameterValue("@CustomerID", Request.QueryString["AMCust"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["ACCust"])) //Asset Conflict
            {
                myReport.Load(Server.MapPath("CrystalReports/AssetConfict.rpt"));
                myReport.SetParameterValue("@CustomerID", Request.QueryString["ACCust"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["CNFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["CNToDate"])) //Credit Note
            {
                myReport.Load(Server.MapPath("CrystalReports/CreditNote.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["CNFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["CNToDate"].ToString()));
                myReport.SetParameterValue("@Status", Request.QueryString["CNStauts"].ToString());
                myReport.SetParameterValue("@CustomerID", Request.QueryString["CNCustomerID"].ToString());
                myReport.SetParameterValue("@CreditNoteType", Request.QueryString["CNType"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["PRFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["PRToDate"])) //Purchase Return
            {
                myReport.Load(Server.MapPath("CrystalReports/PurchaseReturn.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["PRFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["PRToDate"].ToString()));
                myReport.SetParameterValue("@ItemGroupID", Request.QueryString["PRIGID"].ToString());
                myReport.SetParameterValue("@Type", Request.QueryString["PRType"].ToString());
                myReport.SetParameterValue("@ItemID", Request.QueryString["PRItem"].ToString());
                myReport.SetParameterValue("@ReasonId", Request.QueryString["PRReasonID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["VOFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["VOToDate"])) //Vendor Outstanding
            {
                myReport.Load(Server.MapPath("CrystalReports/VendorOutstanding.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["VOFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["VOToDate"].ToString()));
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["COFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["COToDate"])) //Customer Outstanding
            {
                myReport.Load(Server.MapPath("CrystalReports/CustomerOutstanding.rpt"));
                myReport.SetParameterValue("@FromDt", Common.DateTimeConvert(Request.QueryString["COFromDate"].ToString()));
                myReport.SetParameterValue("@ToDt", Common.DateTimeConvert(Request.QueryString["COToDate"].ToString()));
                myReport.SetParameterValue("@CustomerID", Request.QueryString["COCustomerID"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["TCActive"])) // Target Commission Master
            {
                myReport.Load(Server.MapPath("CrystalReports/TargetCommissionMaster.rpt"));
                myReport.SetParameterValue("@Active", Request.QueryString["TCActive"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["TCIsDetail"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["SchmMstActive"])) // Scheme Master
            {
                myReport.Load(Server.MapPath("CrystalReports/SchemeMaster.rpt"));
                myReport.SetParameterValue("@Active", Request.QueryString["SchmMstActive"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["SchmMstDistributorID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["SchmMstDealerID"].ToString());
                myReport.SetParameterValue("@IsDeatail", Request.QueryString["SchmMstIsDetail"].ToString());
                myReport.SetParameterValue("@Schemetype", Request.QueryString["SchmMstSchemeType"].ToString());
                myReport.SetParameterValue("@PlantID", Request.QueryString["SchmMstPlantID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["SchmMstRegionID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["RAPFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["RAPToDate"])) // Purchase Return Register
            {
                myReport.Load(Server.MapPath("CrystalReports/PurchaseReturnRegister.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["RAPFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["RAPToDate"].ToString()));
                myReport.SetParameterValue("@IsItem", Request.QueryString["RAPIsItem"].ToString());
                myReport.SetParameterValue("@ReturnType", Request.QueryString["RAPReturnType"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["VATCommFromDate"]) && !string.IsNullOrEmpty(Request.QueryString["VATCommToDate"])) // VAT Computation
            {
                myReport.Load(Server.MapPath("CrystalReports/VATComputation.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["VATCommFromDate"]));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["VATCommToDate"]));
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["201AFromDate"]) && !string.IsNullOrEmpty(Request.QueryString["201AToDate"])) // Form 201A
            {
                myReport.Load(Server.MapPath("CrystalReports/Form201A.rpt"));
                myReport.SetParameterValue("@FromDt", Common.DateTimeConvert(Request.QueryString["201AFromDate"]));
                myReport.SetParameterValue("@ToDt", Common.DateTimeConvert(Request.QueryString["201AToDate"]));
                myReport.SetParameterValue("@ReportType", Request.QueryString["201AReportType"].ToString());
                myReport.SetParameterValue("@Tax", Request.QueryString["201ATaxType"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["201BFromDate"]) && !string.IsNullOrEmpty(Request.QueryString["201BToDate"])) // Form 201B
            {
                myReport.Load(Server.MapPath("CrystalReports/Form201B.rpt"));
                myReport.SetParameterValue("@FromDt", Common.DateTimeConvert(Request.QueryString["201BFromDate"]));
                myReport.SetParameterValue("@ToDt", Common.DateTimeConvert(Request.QueryString["201BToDate"]));
                myReport.SetParameterValue("@ReportType", Request.QueryString["201AReportType"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["201CFromDate"]) && !string.IsNullOrEmpty(Request.QueryString["201CToDate"])) // Form 201C
            {
                myReport.Load(Server.MapPath("CrystalReports/Form201C.rpt"));
                myReport.SetParameterValue("@FromDt", Common.DateTimeConvert(Request.QueryString["201CFromDate"]));
                myReport.SetParameterValue("@ToDt", Common.DateTimeConvert(Request.QueryString["201CToDate"]));
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["RASFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["RASToDate"])) // Return Against Sales
            {
                myReport.Load(Server.MapPath("CrystalReports/SalesReturnRegister.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["RASFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["RASToDate"].ToString()));
                myReport.SetParameterValue("@IsItem", Request.QueryString["RASIsItem"].ToString());
                myReport.SetParameterValue("@ReturnType", Request.QueryString["RASReturnType"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["CliFeedbackFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["CliFeedbackToDate"])) //Client FeedBack
            {
                myReport.Load(Server.MapPath("CrystalReports/ClientFeedback.rpt"));
                myReport.SetParameterValue("@FromDt", Common.DateTimeConvert(Request.QueryString["CliFeedbackFromDate"].ToString()));
                myReport.SetParameterValue("@ToDt", Common.DateTimeConvert(Request.QueryString["CliFeedbackToDate"].ToString()));
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["PlntDtlStatus"])) //Plant Details
            {
                myReport.Load(Server.MapPath("CrystalReports/PlantDetails.rpt"));
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["ClaimRegFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["ClaimRegToDate"])) // Claim Register
            {
                myReport.Load(Server.MapPath("CrystalReports/ClaimProcess.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["ClaimRegFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["ClaimRegToDate"].ToString()));
                myReport.SetParameterValue("@ClaimStatus", Request.QueryString["ClaimRegClaimStatus"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["ClaimRegSSID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["ClaimRegDistID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["ClaimRegDealerID"].ToString());
                myReport.SetParameterValue("@ItemDetail", Request.QueryString["ClaimItemDetail"].ToString());
                myReport.SetParameterValue("@Stype", Request.QueryString["Stype"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["SUserID"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["ReportBy"].ToString());
                myReport.SetParameterValue("@IpAddress", Request.QueryString["IpAddress"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["MCClaimRegFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["MCClaimRegToDate"]))// Machine Claim Register
            {
                myReport.Load(Server.MapPath("CrystalReports/MachineTransClaimProcess.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["MCClaimRegFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["MCClaimRegToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["MCClaimRegDistributorID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["MCClaimRegDealerID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["MCClaimRegRegionID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["MCClaimRegSUserID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["MCClaimRegSSID"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["MCClaimRegReportBy"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["IvnWiseItmSaleFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["IvnWiseItmSaleToDate"]))// Invoice Wise Item Sale
            {
                myReport.Load(Server.MapPath("CrystalReports/Invoice_ItemwiseA4.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["IvnWiseItmSaleFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["IvnWiseItmSaleToDate"].ToString()));
                myReport.SetParameterValue("@SSID", Request.QueryString["IvnSSID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["IvnDistributorID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["IvnDealerID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@SaleBy", Request.QueryString["InvSaleBy"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["IvnSUserID"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["DivisionID"].ToString());
                myReport.SetParameterValue("@Version", Request.QueryString["Version"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["DealerWiseCpnFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["DealerWiseCpnToDate"]))// Dealer Wise Coupon Report
            {
                myReport.Load(Server.MapPath("CrystalReports/MachineBifu.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["DealerWiseCpnFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["DealerWiseCpnToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["DealerWiseCpnDistID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["DealerWiseCpnDealerID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["DealerWiseCpnRegionID"].ToString());
                myReport.SetParameterValue("@Schemetype", Request.QueryString["DealerWiseCpnSchemeID"].ToString());
                myReport.SetParameterValue("@PendingConsume", Request.QueryString["DealerWiseCpnPendingConsume"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["DealerWiseCpnSSID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["DealerWiseCpnSUserID"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["DealerWiseCpnReportBy"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["DeaWiseItmSaleFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["DeaWiseItmSaleToDate"]))// Dealer Wise Item Sale
            {
                myReport.Load(Server.MapPath("CrystalReports/Dealer_ItemwiseA4.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["DeaWiseItmSaleFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["DeaWiseItmSaleToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["DistributorID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["DealerID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@SaleBy", Request.QueryString["SaleBy"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["SSID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["SUserID"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["DivisionID"].ToString());

            }
            else if (!String.IsNullOrEmpty(Request.QueryString["DealerWiseDiscBiffFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["DealerWiseDiscBiffToDate"]))// Dealer Wise Item Sale
            {
                myReport.Load(Server.MapPath("CrystalReports/DiscBiffRpt.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["DealerWiseDiscBiffFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["DealerWiseDiscBiffToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["DealerWiseDiscBiffDistID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["DealerWiseDiscBiffDealerID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["DealerWiseDiscBiffSSID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["DealerWiseDiscBiffSUserID"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["DealerWiseDiscBiffReportBy"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["DealerWiseDiscBiffRegionID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["IvnWiseItmSaleReturnFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["IvnWiseItmSaleReturnToDate"]))// Invoice Wise Item Sale Return
            {
                myReport.Load(Server.MapPath("CrystalReports/Invoice_Itemwise_Return.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["IvnWiseItmSaleReturnFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["IvnWiseItmSaleReturnToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["IvnDistributorID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["IvnDealerID"].ToString());
                myReport.SetParameterValue("@Division", Request.QueryString["IvnDivisionID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["ItmWiseIvnPurchaseFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["ItmWiseIvnPurchaseToDate"]))// ItemWise Invoice Purchase
            {
                myReport.Load(Server.MapPath("CrystalReports/Itemwise_InvoiceA4Purchase.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["ItmWiseIvnPurchaseFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["ItmWiseIvnPurchaseToDate"].ToString()));
                myReport.SetParameterValue("@SSID", Request.QueryString["IvnSSID"].ToString());
                myReport.SetParameterValue("@PurchaseBy", Request.QueryString["IvnPurchaseBy"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["IvnDistributorID"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["IvnDivisionID"].ToString());
                myReport.SetParameterValue("@DateType", Request.QueryString["IvnDateOption"].ToString());
                myReport.SetParameterValue("@ItemID", Request.QueryString["IvnItemID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["IvnSUserID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["InvoiceWiseItmPurchaseFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["InvoiceWiseItmPurchaseToDate"]))// Invoice Wise Item Purchase
            {
                myReport.Load(Server.MapPath("CrystalReports/InvoiceWise_ItmPurchase.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["InvoiceWiseItmPurchaseFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["InvoiceWiseItmPurchaseToDate"].ToString()));
                myReport.SetParameterValue("@SSID", Request.QueryString["IvnSSID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["IvnDistributorID"].ToString());
                myReport.SetParameterValue("@PurchaseBy", Request.QueryString["IvnPurchaseBy"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["IvnDivisionID"].ToString());
                myReport.SetParameterValue("@DateType", Request.QueryString["IvnDateOption"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["IvnSUserID"].ToString());
            }

            else if (!String.IsNullOrEmpty(Request.QueryString["InvoiceWiseItmPurchaseReturnFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["InvoiceWiseItmPurchaseReturnToDate"]))// Invoice Wise Item Purchase Return
            {
                myReport.Load(Server.MapPath("CrystalReports/Invoice_ItmWisePurReturn.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["InvoiceWiseItmPurchaseReturnFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["InvoiceWiseItmPurchaseReturnToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["IvnDistributorID"].ToString());
                myReport.SetParameterValue("@Division", Request.QueryString["IvnDivisionID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["InvoiceWisePOFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["InvoiceWisePOToDate"]))// Invoice Wise Po V/s Receipt
            {
                myReport.Load(Server.MapPath("CrystalReports/ItemWise_PO_Vs_Receipt.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["InvoiceWisePOFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["InvoiceWisePOToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["IvnDistributorID"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["IvnDivisionID"].ToString());
                myReport.SetParameterValue("@DateType", Request.QueryString["IvnDateOption"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["IvnSSID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["IvnSUserID"].ToString());
                myReport.SetParameterValue("@PurchaseBy", Request.QueryString["IvnPurchaseBy"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["SalesVSPurchFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["SalesVSPurchToDate"]))// Invoice Wise Item Sale Return
            {
                myReport.Load(Server.MapPath("CrystalReports/SalesVSPurchAmtCompare.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["SalesVSPurchFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["SalesVSPurchToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["SalesVSPurchDistributorID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["SalesVSPurchDealerID"].ToString());
                myReport.SetParameterValue("@Division", Request.QueryString["SalesVSPurchDivisionID"].ToString());
                myReport.SetParameterValue("@GAvsNA", Request.QueryString["SalesVSPurchDiffBtwn"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["BeatEmp"]))// Employee Wise Beat Listing 
            {
                myReport.Load(Server.MapPath("CrystalReports/Emp_beat_Listing.rpt"));
                myReport.SetParameterValue("@BeatEmpID", Request.QueryString["BeatEmp"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@EmpGrpID", Request.QueryString["BeatEmpGrpID"].ToString());
                myReport.SetParameterValue("@Status", Request.QueryString["BeatStatus"].ToString());
                myReport.SetParameterValue("@EmpStatus", Request.QueryString["EmpStatus"].ToString());
                myReport.SetParameterValue("@ReportOption", Request.QueryString["BeatOption"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["SUserID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["EmpBeatSummaryFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["EmpBeatSummaryToDate"]))// Employee Wise Beat Summary 
            {
                myReport.Load(Server.MapPath("CrystalReports/EmpWiseBeatSummary.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["EmpBeatSummaryFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["EmpBeatSummaryToDate"].ToString()));
                myReport.SetParameterValue("@SUserID", Request.QueryString["EmpBeatSummarySUserID"].ToString());
                myReport.SetParameterValue("@EmpGrpID", Request.QueryString["EmpBeatSummaryEmpGrpID"].ToString());
                myReport.SetParameterValue("@BeatType", Request.QueryString["BeatType"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["EmpBeatSummaryRegionID"].ToString());
                myReport.SetParameterValue("@BeatSummaryEMP", Request.QueryString["EmpBeatSummaryEMP"].ToString());
                myReport.SetParameterValue("@DealerType", Request.QueryString["DealerType"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["AssetRequestFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["AssetRequestToDate"]))// AssetRequestReport
            {
                myReport.Load(Server.MapPath("CrystalReports/AssetRequest.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["AssetRequestFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["AssetRequestToDate"].ToString()));
                myReport.SetParameterValue("@SSID", Request.QueryString["AssetRqstSSID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["AssetRqstDistributorID"].ToString());
                myReport.SetParameterValue("@CustomerID", Request.QueryString["AssetRqstDealerID"].ToString());
                myReport.SetParameterValue("@PlantID", Request.QueryString["AssetRqstPlantID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["AssetRqstRegionID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["AssetRqstEmpID"].ToString());
                myReport.SetParameterValue("@Status", Request.QueryString["AssetRqstStatusID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["AssetRqstRptBy"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["ClaimRequestFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["ClaimRequestToDate"]))// ClaimRequestReport
            {
                myReport.Load(Server.MapPath("CrystalReports/ClaimRequest.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["ClaimRequestFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["ClaimRequestToDate"].ToString()));
                myReport.SetParameterValue("@RegionID", Request.QueryString["ClaimRqstRegionID"].ToString());
                myReport.SetParameterValue("@Option", Request.QueryString["ClaimRqstOption"].ToString());
                myReport.SetParameterValue("@ClaimTypeID", Request.QueryString["ClaimRqstClaimTypeID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["ClaimRqstDistributorID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["ClaimRqstSSID"].ToString());
                myReport.SetParameterValue("@PendingBy", Request.QueryString["ClaimRqstManagerID"].ToString());
                myReport.SetParameterValue("@ReportFor", Request.QueryString["ClaimRqstRptForID"].ToString());
                myReport.SetParameterValue("@Status", Request.QueryString["ClaimRqstStatusID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["ClaimRqstReportBy"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["ClaimRqstSUserID"].ToString());

            }
            else if (!String.IsNullOrEmpty(Request.QueryString["AssetStatusRequestFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["AssetStatusRequestToDate"]))// ClaimRequestReport
            {
                myReport.Load(Server.MapPath("CrystalReports/AssetRequestStatus.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["AssetStatusRequestFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["AssetStatusRequestToDate"].ToString()));
                myReport.SetParameterValue("@RegionID", Request.QueryString["AssetStatusRequestRegionID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["AssetStatusRequestDealerID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["AssetStatusRequestSUserID"].ToString());
                myReport.SetParameterValue("@Option", Request.QueryString["Option"].ToString());
                myReport.SetParameterValue("@AssetConditionID", Request.QueryString["AssetStatusRequestAssetConditionID"].ToString());
                myReport.SetParameterValue("@AssetTypeID", Request.QueryString["AssetStatusRequestAssetTypeID"].ToString());
                myReport.SetParameterValue("@AssetSubTypeID", Request.QueryString["AssetStatusRequestAssetSubTypeID"].ToString());
                myReport.SetParameterValue("@AssetSizeID", Request.QueryString["AssetStatusRequestAssetSizeID"].ToString());
                myReport.SetParameterValue("@StatusID", Request.QueryString["AssetStatusRequestAssetStatusID"].ToString());
                myReport.SetParameterValue("@Reason", Request.QueryString["AssetStatusRequestReason"].ToString());



            }
            else if (!String.IsNullOrEmpty(Request.QueryString["DistClaimFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["DistClaimToDate"]))// ClaimRequestReport
            {
                myReport.Load(Server.MapPath("CrystalReports/DistributorClaimReport.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["DistClaimFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["DistClaimToDate"].ToString()));
                myReport.SetParameterValue("@RegionID", Request.QueryString["ClaimRptRegionID"].ToString());

                myReport.SetParameterValue("@DistributorID", Request.QueryString["ClaimRptDistributorID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["ClaimRptSSID"].ToString());
                myReport.SetParameterValue("@PlantID", Request.QueryString["PlantID"].ToString());
                myReport.SetParameterValue("@ReportFor", Request.QueryString["ClaimRpttRptForID"].ToString());
                myReport.SetParameterValue("@ClaimStatus", Request.QueryString["ClaimRptStatusID"].ToString());
                myReport.SetParameterValue("@ClaimType", Request.QueryString["ClaimType"].ToString());
                // myReport.SetParameterValue("@ReportBy", Request.QueryString["ClaimRqstReportBy"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["ClaimRqstSUserID"].ToString());


            }
            else if (!String.IsNullOrEmpty(Request.QueryString["LeaveRequestFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["LeaveRequestToDate"]))// LeaveRequestReport
            {
                myReport.Load(Server.MapPath("CrystalReports/LeaveRequest.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["LeaveRequestFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["LeaveRequestToDate"].ToString()));
                myReport.SetParameterValue("@Emp", Request.QueryString["LeaveRqstEmpID"].ToString());
                myReport.SetParameterValue("@PendingBy", Request.QueryString["LeaveRqstManagerID"].ToString());
                myReport.SetParameterValue("@Status", Request.QueryString["LeaveRqstStatusID"].ToString());
                myReport.SetParameterValue("@LeaveType", Request.QueryString["LeaveTypeID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["EmpLeaveRptFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["EmpLeaveRptToDate"]))//EMP Leave Report
            {
                myReport.Load(Server.MapPath("CrystalReports/EmpLeaveRpt.rpt"));
                myReport.SetParameterValue("@FromDate", Request.QueryString["EmpLeaveRptFromDate"].ToString());
                myReport.SetParameterValue("@ToDate", Request.QueryString["EmpLeaveRptToDate"].ToString());
                myReport.SetParameterValue("@EmpGroupID", Request.QueryString["EmpGroupID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["SUserID"].ToString());
                myReport.SetParameterValue("@IpAddress", Request.QueryString["IpAddress"].ToString());
                myReport.SetParameterValue("@LeaveTypeID", Request.QueryString["LeaveTypeID"].ToString());
                myReport.SetParameterValue("@LeaveRqstStatusID", Request.QueryString["LeaveRqstStatusID"].ToString());

            }
            else if (!String.IsNullOrEmpty(Request.QueryString["ExpenseRequestFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["ExpenseRequestToDate"]))// ExpenseRequestReport
            {
                myReport.Load(Server.MapPath("CrystalReports/ExpenseRequest.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["ExpenseRequestFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["ExpenseRequestToDate"].ToString()));
                myReport.SetParameterValue("@Emp", Request.QueryString["ExpenseRqstEmpID"].ToString());
                myReport.SetParameterValue("@PendingBy", Request.QueryString["ExpenseRqstManagerID"].ToString());
                myReport.SetParameterValue("@Status", Request.QueryString["ExpenseRqstStatusID"].ToString());
                myReport.SetParameterValue("@ExpType", Request.QueryString["ExpenseTypeID"].ToString());
                myReport.SetParameterValue("@ExpMode", Request.QueryString["ExpenseModeID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["TravelRequestFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["TravelRequestToDate"]))// TravelAdvRequestReport
            {
                myReport.Load(Server.MapPath("CrystalReports/TravelRequest.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["TravelRequestFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["TravelRequestToDate"].ToString()));
                myReport.SetParameterValue("@Emp", Request.QueryString["TravelRqstEmpID"].ToString());
                myReport.SetParameterValue("@PendingBy", Request.QueryString["TravelRqstManagerID"].ToString());
                myReport.SetParameterValue("@Status", Request.QueryString["TravelRqstStatusID"].ToString());
                myReport.SetParameterValue("@ExpType", Request.QueryString["TravelTypeID"].ToString());
                myReport.SetParameterValue("@ExpMode", Request.QueryString["TravelModeID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["DistListCustStatus"]))// DistributorListingRpt
            {
                myReport.Load(Server.MapPath("CrystalReports/DistributorListRpt.rpt"));
                myReport.SetParameterValue("@SUserID", Request.QueryString["DistListSUserID"].ToString());
                myReport.SetParameterValue("@CustStatus", Request.QueryString["DistListCustStatus"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["DistListRegionID"].ToString());
                myReport.SetParameterValue("@PlantID", Request.QueryString["DistListPlantID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["DistListSSID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["DealerListCustStatus"]))// DealerListingRpt
            {
                myReport.Load(Server.MapPath("CrystalReports/DealerListRpt.rpt"));
                myReport.SetParameterValue("@CustStatus", Request.QueryString["DealerListCustStatus"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["DealerListDistID"].ToString());
                myReport.SetParameterValue("@CustGroupID", Request.QueryString["DealerListCustGrpID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["DealerListSUserID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["SeconTransFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["SeconTransToDate"])) // SeconTransListingRpt
            {
                myReport.Load(Server.MapPath("CrystalReports/SecTransDiscList.rpt"));
                myReport.SetParameterValue("@SchemeFrom", Common.DateTimeConvert(Request.QueryString["SeconTransFromDate"].ToString()));
                myReport.SetParameterValue("@SchemeTo", Common.DateTimeConvert(Request.QueryString["SeconTransToDate"].ToString()));
                myReport.SetParameterValue("@RegionID", Request.QueryString["SeconTransRegionID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["SeconTransDistID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["SeconTransDealerID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["MasterDiscFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["MasterDiscToDate"])) // MasterDiscListingRpt
            {
                myReport.Load(Server.MapPath("CrystalReports/MasterDiscList.rpt"));
                myReport.SetParameterValue("@SchemeFrom", Common.DateTimeConvert(Request.QueryString["MasterDiscFromDate"].ToString()));
                myReport.SetParameterValue("@SchemeTo", Common.DateTimeConvert(Request.QueryString["MasterDiscToDate"].ToString()));
                myReport.SetParameterValue("@RegionID", Request.QueryString["MasterDiscRegionID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["MasterDiscDistID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["MasterDiscDealerID"].ToString());
                myReport.SetParameterValue("@SchemeStatus", Request.QueryString["MasterDistStatus"].ToString());
                myReport.SetParameterValue("@Division", Request.QueryString["MasterDiscDivision"].ToString());
                myReport.SetParameterValue("@CpnyContriFrom", Request.QueryString["MasterDiscCmpnyFrom"].ToString());
                myReport.SetParameterValue("@CpnyContriTo", Request.QueryString["MasterDiscCmpnyTo"].ToString());
                myReport.SetParameterValue("@DistContriFrom", Request.QueryString["MasterDiscDistFrom"].ToString());
                myReport.SetParameterValue("@DistContriTo", Request.QueryString["MasterDiscDistTo"].ToString());
                myReport.SetParameterValue("@ReportType", Request.QueryString["MasterDiscReportFor"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["MasterDistSUserID"].ToString());
                myReport.SetParameterValue("@SalesPeriod", Request.QueryString["MDisSalesPeriod"].ToString());
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["CustListCUSTID"]))
            {
                myReport.Load(Server.MapPath("CrystalReports/Customer_List.rpt"));
                myReport.SetParameterValue("@CustomerID", Request.QueryString["CustListCUSTID"].ToString());
                myReport.SetParameterValue("@CUSTTYPE", Request.QueryString["CustListCustType"].ToString());
                myReport.SetParameterValue("@DISTCustListDealerDistPW", Server.UrlDecode(Request.QueryString["CustListDealerDistPW"].ToString()));
                myReport.SetParameterValue("@DISTPW", Server.UrlDecode(Request.QueryString["CustListDISTPW"].ToString()));
                myReport.SetParameterValue("@SSPW", Server.UrlDecode(Request.QueryString["CustListSSPW"].ToString()));
               // myReport.SetParameterValue("@DealerPwd", Server.UrlDecode(Request.QueryString["DealerPws"].ToString()));
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["IOUClaimFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["IOUClaimToDate"])) // IOUClaim
            {
                myReport.Load(Server.MapPath("CrystalReports/IOUClaim.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["IOUClaimFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["IOUClaimToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["IOUClaimDist"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["IOUClaimSUserID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["IOUClaimRegionID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["IOUClaimDist"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["DealerMnthSaleFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["DealerMnthSaleToDate"])) // DealerMonthWiseSaleRpt
            {
                myReport.Load(Server.MapPath("CrystalReports/DealerMonthWiseSale.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["DealerMnthSaleFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["DealerMnthSaleToDate"].ToString()));
                myReport.SetParameterValue("@RegionID", Request.QueryString["DealerMnthSaleRegion"].ToString());
                myReport.SetParameterValue("@CityID", Request.QueryString["DealerMnthSaleCity"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["DealerMnthSaleSS"].ToString());
                myReport.SetParameterValue("@SaleBy", Request.QueryString["DealerMnthSaleSaleBy"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["DealerMnthSaleDist"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["DealerMnthSaleDealer"].ToString());
                myReport.SetParameterValue("@Division", Request.QueryString["DealerMnthSaleDivision"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["DealerMnthSaleSUserID"].ToString());
            }

            else if (!String.IsNullOrEmpty(Request.QueryString["GSTDeleteFromdate"]) && !String.IsNullOrEmpty(Request.QueryString["GstDeleteToDate"]))// GST Delete Report
            {
                myReport.Load(Server.MapPath("CrystalReports/GSTFormDelete.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["GSTDeleteFromdate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["GstDeleteToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["GSTDistID"].ToString());
                myReport.SetParameterValue("@Region", Request.QueryString["GSTRegionID"].ToString());

            }
            else if (!String.IsNullOrEmpty(Request.QueryString["QPSSchemeFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["QPSSchemeToDate"])) // QPSSchemeListingRpt
            {
                myReport.Load(Server.MapPath("CrystalReports/QPSSchemeList.rpt"));
                myReport.SetParameterValue("@SchemeFrom", Common.DateTimeConvert(Request.QueryString["QPSSchemeFromDate"].ToString()));
                myReport.SetParameterValue("@SchemeTo", Common.DateTimeConvert(Request.QueryString["QPSSchemeToDate"].ToString()));
                myReport.SetParameterValue("@BtwnDate", Common.DateTimeConvert(Request.QueryString["QPSSchemeBtwnDate"].ToString()));

                myReport.SetParameterValue("@SchemeID", Request.QueryString["QPSSchemeSchemeID"].ToString());
                myReport.SetParameterValue("@ItemID", Request.QueryString["QPSSchemeItmeID"].ToString());
                myReport.SetParameterValue("@SchemeLvl", Request.QueryString["QPSSchemeLvl"].ToString());
                myReport.SetParameterValue("@SchemeLvlOption", Request.QueryString["QPSSchemeLvlInput"].ToString());

                myReport.SetParameterValue("@CpnyContriFrom", Request.QueryString["QPSSchemeCmpnyFrom"].ToString());
                myReport.SetParameterValue("@CpnyContriTo", Request.QueryString["QPSSchemeCmpnyTo"].ToString());
                myReport.SetParameterValue("@DistContriFrom", Request.QueryString["QPSSchemeDistFrom"].ToString());
                myReport.SetParameterValue("@DistContriTo", Request.QueryString["QPSSchemeDistTo"].ToString());
                myReport.SetParameterValue("@DateType", Request.QueryString["QPSSchemeDateOption"].ToString());
                myReport.SetParameterValue("@LowerLimit", Request.QueryString["QPSSchemeLowerLimit"].ToString());
                myReport.SetParameterValue("@Division", Request.QueryString["QPSSchemeDivisionID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["StockUpdateFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["StockUpdateToDate"]))// Stock Update Report
            {
                myReport.Load(Server.MapPath("CrystalReports/StockUpdate.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["StockUpdateFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["StockUpdateToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["StockUpdateDistributor"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["StockUpdateSS"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["StockUpdateDivisionID"].ToString());
                myReport.SetParameterValue("@ItemID", Request.QueryString["StockUpdateItemID"].ToString());
                myReport.SetParameterValue("@ReportType", Request.QueryString["StockUpdateReportOption"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["StockUpdateRptBy"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["StockUpdateSUserID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["DealerSaleFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["DelaerSaleToDate"]))// Deale Wise Sale Report
            {
                myReport.Load(Server.MapPath("CrystalReports/DealerwiseSale.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["DealerSaleFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["DelaerSaleToDate"].ToString()));
                myReport.SetParameterValue("@DealerID", Request.QueryString["DealerSaleDealerCode"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["DealerSaleDivision"].ToString());
                myReport.SetParameterValue("@ItemID", Request.QueryString["DealerSaleItemID"].ToString());
                myReport.SetParameterValue("@ItemGrpID", Request.QueryString["DealerSaleItemGrpID"].ToString());
                myReport.SetParameterValue("@ItemSubGrpID", Request.QueryString["DealerSaleItemSubGrpID"].ToString());
                myReport.SetParameterValue("@ReportType", Request.QueryString["DealerSaleReportoption"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["ClaimBalDetailFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["ClaimBalDetailToDate"])) // Claim Balance Detail Report
            {
                myReport.Load(Server.MapPath("CrystalReports/ClaimBalanceDetail.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["ClaimBalDetailFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["ClaimBalDetailToDate"].ToString()));
                myReport.SetParameterValue("@CustomerID", Request.QueryString["ClaimBalDetailDistID"].ToString());
                myReport.SetParameterValue("@ReportType", Request.QueryString["ClaimBalDetailReportType"].ToString());
                myReport.SetParameterValue("@CustType", Request.QueryString["ClaimBalDetailCustType"].ToString());
                myReport.SetParameterValue("@ReportFor", Request.QueryString["ClaimBalDetailEmpID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["ClaimBalDetailRegionID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["ClaimBalDetailSUserID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["BeatDistributorCode"]))// Beat Master Report
            {
                myReport.Load(Server.MapPath("CrystalReports/DistributorDealerWeeklyBealtPlan.rpt"));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["BeatDistributorCode"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["BeatDealerID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["BeatRegionID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["RegionWiseDistributorID"])) // Region Wise PriceList
            {
                myReport.Load(Server.MapPath("CrystalReports/Price_Master.rpt"));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["RegionWiseDistributorID"].ToString());
                myReport.SetParameterValue("@DivisionID", Request.QueryString["RegionWiseDivisionID"].ToString());
                myReport.SetParameterValue("@PriceType", Request.QueryString["RegionWisePriceType"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["RegionWiseRegionID"].ToString());
                myReport.SetParameterValue("@DealerType", Request.QueryString["RegionWiseDealerType"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["RegionWiseSUserID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["NoVisitFromdate"]) && !String.IsNullOrEmpty(Request.QueryString["NoVisitToDate"])) // Dealer No Visit
            {
                myReport.Load(Server.MapPath("CrystalReports/DealerNoVisit.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["NoVisitFromdate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["NoVisitToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["NoVisitDistID"].ToString());
                myReport.SetParameterValue("@PlantID", Request.QueryString["NoVisitPlantID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["NoVisitRegionID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["NoVisitSSID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["NoVisitSUserID"].ToString());
                myReport.SetParameterValue("@Status", Request.QueryString["Status"].ToString());
                myReport.SetParameterValue("@Type", Request.QueryString["NoVisitType"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["ASCLaimFrom"]) && !String.IsNullOrEmpty(Request.QueryString["ASCLaimTo"])) // As On Claim Status
            {
                myReport.Load(Server.MapPath("CrystalReports/AsOnClaim.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["ASCLaimFrom"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["ASCLaimTo"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["ASClaimDistributorID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["ASClaimSSID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["ASClaimRegionID"].ToString());
                myReport.SetParameterValue("@ClaimType", Request.QueryString["ASClaimType"].ToString());
                myReport.SetParameterValue("@ReportType", Request.QueryString["ASCLaimReportType"].ToString());
                myReport.SetParameterValue("@AsonDate", Common.DateTimeConvert(Request.QueryString["ASOnDate"].ToString()));
                myReport.SetParameterValue("@SUserID", Request.QueryString["AsOnSUserID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["CallDurationEmpID"]) && !String.IsNullOrEmpty(Request.QueryString["CallDurationDate"])) // As On Claim Status
            {
                myReport.Load(Server.MapPath("CrystalReports/CallDuration.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["FromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["CallDurationDate"].ToString()));
                myReport.SetParameterValue("@SUserID", Request.QueryString["CallDurationEmpID"].ToString());
                myReport.SetParameterValue("@CallDurationEMP", Request.QueryString["CallDurationEMP"].ToString());
                myReport.SetParameterValue("@EmpGrpID", Request.QueryString["CallDurationEmpGrp"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["MnthRgnWiseFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["MnthRgnWiseToDate"])) // Dealer No Visit
            {
                myReport.Load(Server.MapPath("CrystalReports/MonthRegionWiseSumm.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["MnthRgnWiseFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["MnthRgnWiseToDate"].ToString()));
                myReport.SetParameterValue("@RegionID", Request.QueryString["MnthRgnWiseRegion"].ToString());
                myReport.SetParameterValue("@Divisional", Request.QueryString["MnthRgnWiseDivisionID"].ToString());
                myReport.SetParameterValue("@ReportOption", Request.QueryString["MnthRgnWiseRptOption"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["MnthRgnWiseSUserID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["SSListCustStatus"]))// SSListingRpt
            {
                myReport.Load(Server.MapPath("CrystalReports/SSListRpt.rpt"));
                myReport.SetParameterValue("@SUserID", Request.QueryString["SSListSUserID"].ToString());
                myReport.SetParameterValue("@CustStatus", Request.QueryString["SSListCustStatus"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["SSListRegionID"].ToString());
                myReport.SetParameterValue("@PlantID", Request.QueryString["SSListPlantID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["InvScanFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["InvScanToDate"]))// InvScanReport
            {
                myReport.Load(Server.MapPath("CrystalReports/InvoiceScanRpt.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["InvScanFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["InvScanToDate"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["InvScanDistributorID"].ToString());
                myReport.SetParameterValue("@CustomerID", Request.QueryString["InvScanDealerID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["InvScanRegionID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["InvScanEmpID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["EmpHomeActivityFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["EmpHomeActivityToDate"]))// EmpHomeActivityReport
            {
                myReport.Load(Server.MapPath("CrystalReports/EmpHomeActivity.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["EmpHomeActivityFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["EmpHomeActivityToDate"].ToString()));
                myReport.SetParameterValue("@SUserID", Request.QueryString["EmpHomeActivitySUserID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["SaleVsClaimFrom"]) && !String.IsNullOrEmpty(Request.QueryString["SaleVsClaimTo"])) // Sales VS Claim
            {
                myReport.Load(Server.MapPath("CrystalReports/ClaimVSSales.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["SaleVsClaimFrom"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["SaleVsClaimTo"].ToString()));
                myReport.SetParameterValue("@DistributorID", Request.QueryString["SaleVsClaimDistributorID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["SaleVsClaimSSID"].ToString());
                myReport.SetParameterValue("@RegionID", Request.QueryString["SaleVsClaimRegionID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["SaleVsClaimSUserID"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["SaleVsClaimReportBy"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["MasterDiscApprovlFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["MasterDiscApprovlToDate"])) // Dealer No Visit
            {
                myReport.Load(Server.MapPath("CrystalReports/MasterDiscountRequest.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["MasterDiscApprovlFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["MasterDiscApprovlToDate"].ToString()));
                myReport.SetParameterValue("@RegionID", Request.QueryString["MasterDiscRegion"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["MasterDiscDist"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["MasterDiscDealer"].ToString());
                myReport.SetParameterValue("@RequestType", Request.QueryString["MasterDiscRequestType"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["MasterDiscSUserID"].ToString());
                myReport.SetParameterValue("@RequestBy", Request.QueryString["MasterDiscRequestBy"].ToString());
                myReport.SetParameterValue("@PendingFrom", Request.QueryString["MasterDiscPendingFrom"].ToString());
                myReport.SetParameterValue("@MasterDiscEMP", Request.QueryString["MasterDiscEMP"].ToString());
                myReport.SetParameterValue("@Division", Request.QueryString["MasterDiscDivisionID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["PlantWiseItemListPlantID"]) && !String.IsNullOrEmpty(Request.QueryString["PlantWiseItemListGroupID"])) // Dealer No Visit
            {
                myReport.Load(Server.MapPath("CrystalReports/PlantWiseItemList.rpt"));
                myReport.SetParameterValue("@Plant", Request.QueryString["PlantWiseItemListPlantID"].ToString());
                myReport.SetParameterValue("@ITEMGROUPID", Request.QueryString["PlantWiseItemListGroupID"].ToString());
                myReport.SetParameterValue("@ITEMSUBGROUPID", Request.QueryString["PlantWiseItemListSubGroupID"].ToString());
                myReport.SetParameterValue("@DIVISIONID", Request.QueryString["PlantWiseItemListDivisionID"].ToString());
                myReport.SetParameterValue("@ACTIVE", Request.QueryString["PlantWiseItemListActive"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["PlantListRegionID"])) // Dealer No Visit
            {
                myReport.Load(Server.MapPath("CrystalReports/PlantList.rpt"));
                myReport.SetParameterValue("@RegionID", Request.QueryString["PlantListRegionID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["ManualClaimFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["ManualClaimToDate"]))// ManualClaimReport
            {
                myReport.Load(Server.MapPath("CrystalReports/ManualClaimList.rpt"));
                myReport.SetParameterValue("@EntryFrom", Common.DateTimeConvert(Request.QueryString["ManualClaimFromDate"].ToString()));
                myReport.SetParameterValue("@EntryTo", Common.DateTimeConvert(Request.QueryString["ManualClaimToDate"].ToString()));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["ManualClaimFromMonth"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["ManualClaimToMonth"].ToString()));
                myReport.SetParameterValue("@RegionID", Request.QueryString["ManualClaimRegionID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["ManualClaimDistributorID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["ManualClaimSSID"].ToString());
                myReport.SetParameterValue("@Option", Request.QueryString["ManualClaimOption"].ToString());
                myReport.SetParameterValue("@ClaimTypeID", Request.QueryString["ManualClaimClaimTypeID"].ToString());
                myReport.SetParameterValue("@Status", Request.QueryString["ManualClaimStatusID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["ManualClaimSUserID"].ToString());
                myReport.SetParameterValue("@StatusText", Request.QueryString["ManualClaimStatus"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["AssetSerialNo"])) // Asset List Display
            {
                myReport.Load(Server.MapPath("CrystalReports/AssetList.rpt"));
                myReport.SetParameterValue("@AssetNo", Request.QueryString["AssetSerialNo"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["GSTDMSStatus"]))// GST COMP Report
            {
                myReport.Load(Server.MapPath("CrystalReports/GSTComp.rpt"));
                myReport.SetParameterValue("@DMSStatus", Request.QueryString["GSTDMSStatus"].ToString());
                myReport.SetParameterValue("@Status", Request.QueryString["Status"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["ReportBy"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["SUserID"].ToString());
                myReport.SetParameterValue("@DistID", Request.QueryString["DistID"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["SSID"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["DIstClaimRegFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["DistClaimRegToDate"])) // Claim Register
            {
                myReport.Load(Server.MapPath("CrystalReports/DistClaimRegister.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["DIstClaimRegFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["DistClaimRegToDate"].ToString()));
                myReport.SetParameterValue("@ClaimStatus", Request.QueryString["ClaimRegClaimStatus"].ToString());
                myReport.SetParameterValue("@SSID", Request.QueryString["ClaimRegSSID"].ToString());
                myReport.SetParameterValue("@DistributorID", Request.QueryString["ClaimRegDistID"].ToString());
                myReport.SetParameterValue("@DealerID", Request.QueryString["ClaimRegDealerID"].ToString());
                myReport.SetParameterValue("@ItemDetail", Request.QueryString["ClaimItemDetail"].ToString());
                myReport.SetParameterValue("@Stype", Request.QueryString["Stype"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["SUserID"].ToString());
                myReport.SetParameterValue("@ReportBy", Request.QueryString["ReportBy"].ToString());
                myReport.SetParameterValue("@IpAddress", Request.QueryString["IpAddress"].ToString());
            }
            else if (!String.IsNullOrEmpty(Request.QueryString["ClaimonHandFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["ClaimonHandToDate"]))// Claim On Hand Report
            {
                myReport.Load(Server.MapPath("CrystalReports/ClaimOnHand.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["ClaimonHandFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["ClaimonHandToDate"].ToString()));
                myReport.SetParameterValue("@RegionID", Request.QueryString["ClaimRqstRegionID"].ToString());
                myReport.SetParameterValue("@Option", Request.QueryString["ClaimRqstOption"].ToString());
                myReport.SetParameterValue("@ClaimTypeID", Request.QueryString["ClaimRqstClaimTypeID"].ToString());
                myReport.SetParameterValue("@PendingFrom", Request.QueryString["ClaimRqstManagerID"].ToString());
                //myReport.SetParameterValue("@ReportFor", Request.QueryString["ClaimRqstRptForID"].ToString());
                myReport.SetParameterValue("@Status", Request.QueryString["ClaimRqstStatusID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
                //myReport.SetParameterValue("@ReportBy", Request.QueryString["ClaimRqstReportBy"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["ClaimRqstSUserID"].ToString());
                myReport.SetParameterValue("@LastProceedBy", Request.QueryString["LastProcedBy"].ToString());
                myReport.SetParameterValue("@LastProceedFromDate", Common.DateTimeConvert(Request.QueryString["LastProceedFromDate"].ToString()));
                myReport.SetParameterValue("@LastProceedToDate", Common.DateTimeConvert(Request.QueryString["LastProceedToDate"].ToString()));

                myReport.SetParameterValue("@IsHierarchy", Request.QueryString["IsHierarchy"].ToString());
                myReport.SetParameterValue("@IsAuto", Request.QueryString["IsAuto"].ToString());

            }
            else if (!String.IsNullOrEmpty(Request.QueryString["ZTableOutstandingFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["ZTableOutstandingToDate"]))// Claim On Hand Report
            {
                myReport.Load(Server.MapPath("CrystalReports/ZTableOutStandingReport.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["ZTableOutstandingFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["ZTableOutstandingToDate"].ToString()));
                myReport.SetParameterValue("@RegionID", Request.QueryString["ZTableOutstandingRegionID"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["ZTableOutstandingSUserID"].ToString());
                myReport.SetParameterValue("@CustomerID", Request.QueryString["ZTableOutstandingDistID"].ToString());
                myReport.SetParameterValue("@IsDetail", Request.QueryString["IsDetail"].ToString());
            }
            //Added by dipali for CustomerFeedBackReport
            else if (!String.IsNullOrEmpty(Request.QueryString["CustFeedBackFromDate"]) && !String.IsNullOrEmpty(Request.QueryString["CustFeedBackToDate"]))  //Customer Feedback report
            {
                myReport.Load(Server.MapPath("CrystalReports/CustomerFeedbackReport.rpt"));
                myReport.SetParameterValue("@FromDate", Common.DateTimeConvert(Request.QueryString["CustFeedBackFromDate"].ToString()));
                myReport.SetParameterValue("@ToDate", Common.DateTimeConvert(Request.QueryString["CustFeedBackToDate"].ToString()));
                myReport.SetParameterValue("@Type", Request.QueryString["CustFeedBackType"].ToString());
                myReport.SetParameterValue("@SUserID", Request.QueryString["CustFeedBackEmployee"].ToString());
            }

            myReport.SetParameterValue("@EmpID", UserID);
            string LogoSRC = "";
            if (Convert.ToString(Request.QueryString["CompCust"]) == "0" || Convert.ToString(Request.QueryString["CompCust"]) == null)
            {
                myReport.SetParameterValue("@ParentID", ParentID);
                LogoSRC = Common.GetLogo(ParentID);
            }
            else
            {
                myReport.SetParameterValue("@ParentID", Request.QueryString["CompCust"].ToString());
                LogoSRC = Common.GetLogo(Convert.ToDecimal(Request.QueryString["CompCust"].ToString()));
            }
            //myReport.SetParameterValue("@LogoImage", Server.MapPath("~/Images/LOGO.jpg"));
            myReport.SetParameterValue("@LogoImage", Server.MapPath("~/Images/CompanyLogo/" + LogoSRC));

            string connectString = System.Configuration.ConfigurationManager.ConnectionStrings["DDMSEntities"].ToString();
            EntityConnectionStringBuilder Builder = new EntityConnectionStringBuilder(connectString);
            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(Builder.ProviderConnectionString);

            Tables myTables = myReport.Database.Tables;
            foreach (CrystalDecisions.CrystalReports.Engine.Table myTable in myTables)
            {
                TableLogOnInfo myTableLogonInfo = myTable.LogOnInfo;
                myConnectionInfo.ServerName = builder.DataSource;
                myConnectionInfo.DatabaseName = builder.InitialCatalog;
                myConnectionInfo.UserID = "sa";
                myConnectionInfo.Password = builder.Password;
                myTableLogonInfo.ConnectionInfo = myConnectionInfo;
                myTable.ApplyLogOnInfo(myTableLogonInfo);
            }

            CrystalReportViewer1.ReportSource = myReport;
            CrystalReportViewer1.RefreshReport();

            if (Export)
            {
                ExportOptions ep = new ExportOptions();
                ep.ExportFormatType = ExportFormatType.ExcelRecord;
                ExcelDataOnlyFormatOptions Options = new ExcelDataOnlyFormatOptions();
                Options.MaintainRelativeObjectPosition = true;
                //Options.ShowGridLines = true;
                //Options.ExcelAreaType = AreaSectionKind.WholeReport;
                ep.ExportFormatOptions = Options;
                myReport.ExportToHttpResponse(ep, Response, true, Path.GetFileNameWithoutExtension(myReport.FileName));
                //myReport.ExportToHttpResponse(CrystalDecisions.Shared.ExportFormatType.Excel, Response, true, Path.GetFileNameWithoutExtension(myReport.FileName));
            }
            else
            {
                //mem = (MemoryStream)myReport.ExportToStream(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat);
                //Response.Clear();
                //Response.Buffer = true;
                //Response.ContentType = "application/pdf";
                //Response.BinaryWrite(mem.ToArray());
                //Response.End();

                ///// Uncomment below code if memorystreme not supported in crystalreport viewer higher version & commnet upper code.

                Stream oStream = null;
                byte[] byteArray = null;
                oStream = myReport.ExportToStream(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat);
                byteArray = new byte[oStream.Length];
                oStream.Read(byteArray, 0, Convert.ToInt32(oStream.Length - 1));

                Response.Clear();
                Response.Buffer = true;
                Response.ContentType = "application/pdf";
                Response.BinaryWrite(byteArray.ToArray());
                Response.End();
            }
        }
        catch (Exception ex)
        {
            try
            {
                if (!string.IsNullOrEmpty(Request.QueryString["CustListCUSTID"]))
                {
                    var FileName = Server.MapPath("~/Document/Log/CustomerParentDisplayReportLog.txt");
                    if (!Common.GetString(ex).Contains("Thread was being aborted"))
                    {
                        TraceService(FileName, Common.GetString(ex));
                        TraceService(FileName, ex.Source);
                        TraceService(FileName, ex.StackTrace);
                        TraceService(FileName, ex.Message);
                    }
                }
            }
            catch (Exception)
            {
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "alert('" + Common.GetString(ex) + "');", true);
        }
        finally
        {
            CrystalReportViewer1.Dispose();
            myReport.Close();
            myReport.Dispose();
            mem.Close();
            mem.Dispose();
            GC.Collect();
        }
    }

    private void TraceService(string path, string content)
    {
        FileStream fs = new FileStream(path, FileMode.OpenOrCreate, FileAccess.Write);
        StreamWriter sw = new StreamWriter(fs);
        sw.BaseStream.Seek(0, SeekOrigin.End);
        sw.WriteLine(content);
        sw.Close();
    }
}