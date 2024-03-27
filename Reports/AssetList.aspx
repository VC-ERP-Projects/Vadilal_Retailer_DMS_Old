<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="AssetList.aspx.cs" Inherits="Reports_AssetList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }
    </script>
    <style>
        .ifmAsset {
            height: 470px !important;
            width: 100%;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblAssetCode" runat="server" Text='Asset Serial No' CssClass="input-group-addon"></asp:Label>
                        <%--OnTextChanged="txtAssetCode_TextChanged" AutoPostBack="true"--%>
                        <asp:TextBox ID="txtAssetCode" CssClass="txtAssetCode form-control" runat="server" TabIndex="1" Style="background-color: rgb(250, 255, 189);" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtName" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetActiveOAST" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtAssetCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" style="float: left;">
                        <asp:Button ID="btnGenerat" runat="server" Text="GO" CssClass="btn btn-default"  TabIndex="2" OnClick="btnGenerat_Click" OnClientClick="return _btnCheck();" />&nbsp
                        <asp:Button Text="Export To Excel" ID="btnExport" CssClass="btn btn-default"  TabIndex="3" runat="server" OnClick="btnExport_Click" OnClientClick="return _btnCheck();" />
                    </div>
                </div>
            </div>
            <iframe id="ifmAsset" class="ifmAsset embed-responsive-item" runat="server" onload="ifmAsset_Load"></iframe>
        </div>
    </div>
</asp:Content>

