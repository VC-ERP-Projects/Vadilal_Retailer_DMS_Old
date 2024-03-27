<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PlantDetailsReport.aspx.cs" Inherits="Reports_PlantDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <script type="text/javascript">
        function _btnCheck() {
            if (!$('.masterForm').data('bootstrapValidator').isValid())
                $('.masteForm').bootstrapValidator('validate');
            return $('.masterForm').data('bootstrapValidator').isValid();
        }
        function _btnPanelCheck() {
            if (!$('.panelForm').data('bootstrapValidator').isValid())
                $('.panelForm').bootstrapValidator('validate');
            return $('.panelForm').data('bootstrapValidator').isValid();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
    <div class="panel">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <%--<asp:Label ID="lblIsActive" runat="server" Text="Is Avtive" CssClass="input-group-addon"></asp:Label>--%>
                        <%--<asp:CheckBox ID="chkIsActive" runat="server" TabIndex="1" Checked="true" CssClass="form-control" Visible="false" />--%>    
                     </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="3" CssClass="btn btn-default" OnClick="btnGenerat_Click" OnClientClick="return _btnCheck();"/>&nbsp
                        <asp:Button ID="btnExport" runat="server" Text="Export To Excel" TabIndex="4" CssClass="btn btn-default" OnClick="btnExport_Click"/>
                    </div>
                </div>
                <div class="col-lg-4">
                    <%--<div class="input-group form-group" id="divCustomer" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="2" CssClass="form-control" autocomplete="off" data-bv-notempty="true" data-bv-notempty-message="Field is Required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx" UseContextKey="true"
                            ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>--%>
                </div>
         </div>
            <iframe id="ifmPlantDtl" style="width:100%" class="embed-responsive-item" runat="server" onload="ifmPlantDtl_Load"></iframe>
        </div>
    </div>
</asp:Content>

