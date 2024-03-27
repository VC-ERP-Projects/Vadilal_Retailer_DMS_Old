using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for EInvoiceClass
/// </summary>
namespace TaxProEInvoiceModel
{
    
        public class EInvoiceClassGST
        {
            public string Status { get; set; }
            public List<Data1> Data { get; set; }
            public string ErrorDetails { get; set; }
            public string InfoDtls { get; set; }
        }
        public class Data1
        {
            public string AckNo { get; set; }
            public string AckDt { get; set; }
            public string Irn { get; set; }
            public string SignedQRCode { get; set; }
            public string EwbNo { get; set; }
            public string EwbDt { get; set; }
            public string EwbValidTill { get; set; }
        }
    
}