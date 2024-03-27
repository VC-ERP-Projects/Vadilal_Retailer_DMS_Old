<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="VendorMasterReport.aspx.cs" Inherits="Reports_VendorMasterReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsActive" runat="server" TabIndex="1"  Checked="true" CssClass="form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="5" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp<asp:Button Text="Export To Excel" ID="btnExport" TabIndex="6" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsItem" runat="server" Text="Is Item" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsItem" runat="server" TabIndex="2" Checked="true" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsParent" runat="server" Text="Is Parent" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsParent" runat="server" TabIndex="3" CssClass="form-control" Checked="true" />
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="4" CssClass="form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
            </div>
            <iframe id="ifmVendor" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmVendor_Load"></iframe>
        </div>
    </div>

</asp:Content>

