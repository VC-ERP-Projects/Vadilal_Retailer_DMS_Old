<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClaimConfiguration.aspx.cs" Inherits="MyAccount_FOWConfiguration" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        function acetxtCustName_OnClientPopulating(sender, args) {
            if ($('.txtCustCode').val() != undefined) {
                var key = $('.txtCustCode').val().split('-')[2];
                if (key != undefined)
                    sender.set_contextKey(key);
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="State" ID="lblState" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtState" TabIndex="1" CssClass="txtState form-control" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtState" runat="server" ServicePath="../WebService.asmx" UseContextKey="true" ServiceMethod="GetStateNames" MinimumPrefixLength="1"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtState">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Percentage" ID="lblPercentage" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtPercentage" TabIndex="1" onkeypress="return isNumberKeyForAmount(event);" CssClass="txtPercentage form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" TabIndex="4" CssClass="btn btn-default" OnClick="btnSearch_Click" />
                        &nbsp;
                        <asp:Button ID="btnReset" runat="server" Text="Reset" TabIndex="5" CssClass="btn btn-default" OnClick="btnReset_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divDistributor" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="2" CssClass="txtCustCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Amount" ID="Label1" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtAmount" onkeypress="return isNumberKeyForAmount(event);" TabIndex="1" CssClass="txtAmount form-control" />
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group" id="divDealer" runat="server">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtdealer" runat="server" TabIndex="3" CssClass="form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtdealer" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetChildCustomer" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtCustName_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtdealer">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView runat="server" ID="gvClaimConfiguration" CssClass="HighLightRowColor2 table tbl" AutoGenerateColumns="true" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" EmptyDataText="No record found.">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

