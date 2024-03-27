<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="InvoiceWiseItemSaleReturn.aspx.cs" Inherits="Reports_InvoiceWiseItemSaleReturn" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
     <script type="text/javascript">
         var ParentID = '<% = ParentID%>';

         $(function () {
             Relaod();
             Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
         });

         function EndRequestHandler2(sender, args) {
             Relaod();
         }

         function Relaod() {

             $('.frommindate').datepicker({
                 numberOfMonths: 1,
                 dateFormat: 'dd/mm/yy',
                 changeMonth: true,
                 changeYear: true,
                 minDate: new Date(2017, 6, 1),
                 "maxDate": '<%=DateTime.Now %>',
                 onSelect: function (selected) {
                     $('.tomindate').datepicker("option", "minDate", selected);
                 }
             });


             $('.tomindate').datepicker({
                 numberOfMonths: 1,
                 dateFormat: 'dd/mm/yy',
                 changeMonth: true,
                 changeYear: true,
                "maxDate": '<%=DateTime.Now %>',
                minDate: new Date(2017, 6, 1),
                onSelect: function (selected) {
                    $('.frommindate').datepicker("option", "maxDate", selected);
                }
            });
        }



        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function acetxtCustName_OnClientPopulating(sender, args) {
            if ($('.txtCustCode').val() != undefined) {
                var key = $('.txtCustCode').val().split('-')[2];
                if (key != undefined)
                    sender.set_contextKey(key);
            }
            else {
                sender.set_contextKey(ParentID);
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
     <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="Return From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group" id="divDistributor" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="4" CssClass="txtCustCode form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:TextBox>
                       <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="Return To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="tomindate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group" id="divDealer" runat="server">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtdealer" runat="server" TabIndex="11" CssClass="form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtdealer" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerofDist" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtCustName_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtdealer">
                        </asp:AutoCompleteExtender>
                    </div>

                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <%--<asp:DropDownList ID="ddlDivision" runat="server" CssClass="ddlDivision form-control" >
                            <asp:ListItem Text="All Division" Value="0" Selected="True"/>
                            <asp:ListItem Text="Ice-Cream" Value="3"  />
                            <asp:ListItem Text="Dairy" Value="5" />--%>
                        <asp:DropDownList runat="server" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsDetail" runat="server" Text="Is Detail" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsDetail" TabIndex="4" Checked="true" runat="server" CssClass="chkIsDetail form-control" />
                    </div>
                </div>
                <div class="col-lg-12">
                    <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="6" CssClass="btn btn-default" OnClick="btnGenerat_Click" OnClientClick="return _btnCheck();" />
                    &nbsp
                     <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="7" CssClass="btn btn-default" OnClientClick="return _btnCheck();" runat="server" OnClick="btnExport_Click" />
                </div>
            </div>
            <iframe id="ifmInvoicewiseItemSaleReturn" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmInvoicewiseItemSaleReturn_Load"></iframe>
        </div>
    </div>
</asp:Content>

