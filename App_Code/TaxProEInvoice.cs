using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for TaxProEInvoice
/// </summary>
public class TaxProEInvoice
{
    public TaxProEInvoice()
    {
        TranDtls = new TranDtls();
        DocDtls = new DocDtls();
        SellerDtls = new SellerDtls();
        BuyerDtls = new BuyerDtls();
        //DispDtls = new DispDtls();
       // ShipDtls = new ShipDtls();
        ItemList = new List<ItemList>();
        ValDtls = new ValDtls();
       // ExpDtls = new ExpDtls();
        PrecDocDtls = new PrecDocDtls();
        //EwbDtls = new EwbDtls();
    }
    public string Version { get; set; }
    public TranDtls TranDtls { get; set; }
    public DocDtls DocDtls { get; set; }
    public SellerDtls SellerDtls { get; set; }
    public BuyerDtls BuyerDtls { get; set; }
   // public DispDtls DispDtls { get; set; }
   // public ShipDtls ShipDtls { get; set; }
    public PrecDocDtls PrecDocDtls { get; set; }
  //  public EwbDtls EwbDtls { get; set; }
    public List<ItemList> ItemList { get; set; }
    public ValDtls ValDtls { get; set; }
    //public string PayDtls { get; set; }
  //  public string RefDtls { get; set; }
    public string ContrDtls { get; set; }
 //   public string AddlDocDtls { get; set; }
  //  public ExpDtls ExpDtls { get; set; }
}
public class PrecDocDtls
{
    public string InvNo { get; set; }
    public string InvDt { get; set; }
}
public class TranDtls
{
    public string TaxSch { get; set; }
    public string SupTyp { get; set; }
    public string RegRev { get; set; }
    public string EcmGstin { get; set; }
    public string IgstOnIntra { get; set; }
}
public class DocDtls
{
    public string Typ { get; set; }
    public string No { get; set; }
    public string Dt { get; set; }
}
public class ExpDtls
{
    public string RefClm { get; set; }
    public string ShipBNo { get; set; }
    public string ShipBDt { get; set; }
}
public class SellerDtls
{
    public string Gstin { get; set; }
    public string LglNm { get; set; }
    public string TrdNm { get; set; }
    public string Addr1 { get; set; }
    public string Addr2 { get; set; }
    public string Loc { get; set; }
    public int Pin { get; set; }
    // public string State { get; set; }
    public string Stcd { get; set; }
    public string Ph { get; set; }
    public string Em { get; set; }

}
public class BuyerDtls
{
    public string Gstin { get; set; }
    public string LglNm { get; set; }
    public string TrdNm { get; set; }
    public string Pos { get; set; }
    public string Addr1 { get; set; }
    public string Addr2 { get; set; }
    public string Loc { get; set; }
    public int Pin { get; set; }
    //  public string State { get; set; }
    public string Stcd { get; set; }
    public string Ph { get; set; }
    public string Em { get; set; }
}
public class DispDtls
{
    public string Nm { get; set; }
    public string Addr1 { get; set; }
    public string Addr2 { get; set; }
    public string Loc { get; set; }
    public int Pin { get; set; }
    public string Stcd { get; set; }
}
public class ShipDtls
{
    public string Gstin { get; set; }
    public string LglNm { get; set; }
    public string TrdNm { get; set; }
    public string Addr1 { get; set; }
    public string Addr2 { get; set; }
    public string Loc { get; set; }
    public int Pin { get; set; }
    public string Stcd { get; set; }
}
public class ValDtls
{
    public double AssVal { get; set; }
    public double CgstVal { get; set; }
    public double SgstVal { get; set; }
    public double IgstVal { get; set; }
    public double CesVal { get; set; }
    public double StCesVal { get; set; }
    public double OthChrg { get; set; }
    public double RndOffAmt { get; set; }
    public double TotInvVal { get; set; }
    public double Item_Taxable_Value  { get; set; }

}

public class EwbDtls
{
    public string TransId { get; set; }
    public string TransName { get; set; }
    public int Distance { get; set; }
    public string TransDocNo { get; set; }
    public string TransDocDt { get; set; }
    public string VehNo { get; set; }
    public string VehType { get; set; }
    public string TransMode { get; set; }

}
public class ItemList
{

    public string SlNo { get; set; }
    public string PrdDesc { get; set; }
    public string IsServc { get; set; }
    public string HsnCd { get; set; }
    public string Barcde { get; set; }
    //public string BchDtls { get; set; }
    public double Qty { get; set; }
    public int FreeQty { get; set; }
    public string Unit { get; set; }
    public double UnitPrice { get; set; }
    public double TotAmt { get; set; }
    public double Discount { get; set; }
   // public int PreTaxVal { get; set; }
    public double AssAmt { get; set; }
    public double GstRt { get; set; }
    public double IgstAmt { get; set; }
    public double CgstAmt { get; set; }
    public double SgstAmt { get; set; }
    public double CesRt { get; set; }
    public double CesAmt { get; set; }
    public double CesNonAdvlAmt { get; set; }
    public double StateCesRt { get; set; }
    public double StateCesAmt { get; set; }
    public double StateCesNonAdvlAmt { get; set; }
    public double OthChrg { get; set; }
    public double TotItemVal { get; set; }
    public string PrdSlNo { get; set; }
    public string BchDtls { get; set; }
    public string AttribDtls { get; set; }
}
public class EIvoiceCancelAPI
{
    public string Irn { get; set; }
    public string CnlRsn { get; set; }
    public string CnlRem { get; set; }
}
