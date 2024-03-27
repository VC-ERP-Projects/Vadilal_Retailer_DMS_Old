<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="StockUpdate.aspx.cs" Inherits="Reports_StockUpdate" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var ParentID = <% = ParentID%>;
        var CustType = '<% =CustType%>';

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey("0" + "-0-" + "0" + "-" + ss + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0" + "-0-" + "0" + "-" + EmpID);
        }

        $(document).ready(function() {
            ChangeReportFor();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ChangeReportFor();
        }

        function ChangeReportFor(ddl) {

            if(CustType == 1 && $('.ddlReportBy').val() == "4")
            {
                $('.txtDistCode').val('');
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style','display:none;');
            }
            else if (CustType == 1 && $('.ddlReportBy').val() == "2")
            {
                $('.txtSSDistCode').val('');
                $('.divSS').attr('style','display:none;');
                $('.divDistributor').removeAttr('style');
            }
        }

        function aceFromdate_OnClientPopulating(sender, args) {
            var Dist = $('.txtDistCode').val();
            var SS = $('.txtSSDistCode').val();
            var RptBy = $('.ddlReportBy').val();
            if(RptBy == 4)
            {
                if (SS != "") {
                    var key = $('.txtSSDistCode').val().split('-').pop();
                    if (key != undefined)
                        sender.set_contextKey(key);
                }
                else {
                    ModelMsg("Please Select SuperStockist First !", 3);
                }
            }
            else{
                if (Dist != "") {
                    var key = $('.txtDistCode').val().split('-').pop();
                    if (key != undefined)
                        sender.set_contextKey(key);
                }
                else {
                    ModelMsg("Please Select Distributor First !", 3);
                }
            }
        }

        function aceTodate_OnClientPopulating(sender, args) {
            var Dist = $('.txtDistCode').val();
            var SS = $('.txtSSDistCode').val();
            var RptBy = $('.ddlReportBy').val();
            if(RptBy == 4)
            {
                if (SS != "") {
                    var key = $('.txtSSDistCode').val().split('-').pop();
                    if (key != undefined)
                        sender.set_contextKey(key);
                }
                else {
                    $('.txtFromDate').val('');
                    $('.txtToDate').val('');
                    ModelMsg("Please Select SuperStockist First !", 3);
                }
            }
            else{
                if (Dist != "") {
                    var key = $('.txtDistCode').val().split('-').pop();
                    if (key != undefined)
                        sender.set_contextKey(key);
                }
                else {
                    $('.txtFromDate').val('');
                    $('.txtToDate').val('');
                    ModelMsg("Please Select Distributor First !", 3);
                }
            }
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            return $('._masterForm').data('bootstrapValidator').isValid();
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Report Option" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlReport" runat="server" CssClass="ddlReport form-control" TabIndex="1">
                            <asp:ListItem Text=" Date + Item wise Inventory Update Report" Value="1" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Date wise Inventory Update Report" Value="2"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" TabIndex="2" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblReportBy" Text="Report For" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlReportBy" TabIndex="3" CssClass="ddlReportBy form-control" OnChange="ChangeReportFor();">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="4" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtFromDate" TabIndex="6" CssClass="txtFromDate form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceFromDate" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetInventoryUpdateDate" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="aceFromdate_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtFromDate">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtToDate" TabIndex="7" CssClass="txtFromDate form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceToDate" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetInventoryUpdateDate" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="aceTodate_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtToDate">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID" TabIndex="8">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Item" ID="lblItem" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtItem" CssClass="txtItem form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="9" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtItem" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetItemWithID" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtItem">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="10" CssClass="btn btn-default" OnClick="btnGenerat_Click" OnClientClick="return _btnCheck();" />
                        &nbsp
                     <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="11" CssClass="btn btn-default" OnClientClick="return _btnCheck();" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>
            <iframe id="ifmStockUpdate" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmStockUpdate_Load"></iframe>
        </div>
    </div>
</asp:Content>

