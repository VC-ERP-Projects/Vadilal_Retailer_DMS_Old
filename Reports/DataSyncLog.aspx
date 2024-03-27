<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DataSyncLog.aspx.cs" Inherits="Reports_DataSyncLog" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" onfocus="this.blur();" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button Text="Export Customer" ID="btnCustomer" CssClass="btn btn-default" runat="server" OnClick="btnCustomerExport_Click" />
                        <asp:Button Text="Export Item" ID="btnItem" CssClass="btn btn-default" runat="server" OnClick="btnItemExport_Click" />
                        <asp:Button Text="Export Sales" ID="btnExport" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" onfocus="this.blur();" CssClass="todate form-control"></asp:TextBox>
                    </div>

                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblState" runat="server" Text="Region" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtState" runat="server" CssClass="form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetStateNames" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtState">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

