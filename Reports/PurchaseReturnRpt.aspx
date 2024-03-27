<%@ Page Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PurchaseReturnRpt.aspx.cs" Inherits="Reports_PurchaseReturn" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblItemGroup" runat="server" Text="Item Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlItemGroup" runat="server" TabIndex="2" CssClass="form-control" DataTextField="ItemGroupName" DataValueField="ItemGroupID"></asp:DropDownList>
                    </div>
                    <div class="input-group form-group" id="divCustomer" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="3" CssClass="form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="true" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>

                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" TabIndex="8" Text="Go" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp
                     <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="9" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" TabIndex="4" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblItem" runat="server" Text="Item Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtItemName" TabIndex="5" runat="server" CssClass="form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtItemName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetMaterial" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="true" CompletionSetCount="1" TargetControlID="txtItemName">
                        </asp:AutoCompleteExtender>
                    </div>

                </div>
                <div class="input-group form-group">
                    <asp:Label ID="type" runat="server" Text="Type" CssClass="input-group-addon"></asp:Label>
                    <asp:DropDownList runat="server" ID="ddlType" TabIndex="6" CssClass="form-control">
                        <asp:ListItem Value="0">--Select--</asp:ListItem>
                        <asp:ListItem Value="3">PurchaseReturn</asp:ListItem>
                        <asp:ListItem Value="4">PurchaseReturnAgainBill</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="input-group form-group">
                    <asp:Label ID="lblreason" runat="server" Text="Reason" CssClass="input-group-addon"></asp:Label>
                    <asp:DropDownList runat="server" ID="ddlReason" TabIndex="7" CssClass="form-control" DataTextField="ReasonName" DataValueField="ReasonID">
                    </asp:DropDownList>
                </div>
            </div>

        </div>
        <iframe id="ifmPurchaseReturn" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmPurchaseReturn_Load"></iframe>
    </div>
</asp:Content>

