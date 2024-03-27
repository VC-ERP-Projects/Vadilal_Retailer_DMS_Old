<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PurchaseBillPayment.aspx.cs" Inherits="Reports_PurchaseBillPayment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Payment Detail" ID="lblPymtDetail" CssClass="input-group-addon" runat="server" />
                        <asp:CheckBox runat="server" ID="chkPymtDetail" TabIndex="2" CssClass="form-control"></asp:CheckBox>
                    </div>

                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="6" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp
                        <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="7" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Vendor" ID="lblVendor" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" TabIndex="4" CssClass="form-control" ID="ddlVendor" DataValueField="VendorID" DataTextField="VendorName">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Payment Mode" ID="lblPaymentMode" CssClass="input-group-addon" runat="server" />
                        <asp:DropDownList runat="server" ID="ddlMode" TabIndex="5" DataValueField="Key" CssClass="form-control" DataTextField="Value">
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
        </div>
        <iframe id="ifmPurchaseBillPymt" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmPurchaseBillPymt_Load"></iframe>
    </div>
</asp:Content>

