<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DataExportPurchase.aspx.cs" Inherits="Reports_DataExportPurchase" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        var ParentID = '<% = ParentID%>';
        var CustType = '<% =CustType%>';

        $(function () {
            ChangeReportFor('1');
            ChangePurFrom('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ChangeReportFor('1');
            ChangePurFrom('1');
        }

        function ChangePurFrom(SelType) {
            if (($('.ddlReportBy').val() == "4") || ($('.ddlReportBy').val() == "2") && ($('.ddlPurFrom').val() == "3" || $('.ddlPurFrom').val() == "1")) {
                $('.divInvPlant').removeAttr('style');
            }
            else {
                $('.divInvPlant').attr('style', 'display:none;');
            }

            if (($('.ddlReportBy').val() == "4") || ($('.ddlReportBy').val() == "2") && $('.ddlPurFrom').val() == "2") {
                $('.divSS').removeAttr('style');
            }
            else {
                if (SelType == "2")
                    $('.txtSSDistCode').val('');
                $('.divSS').attr('style', 'display:none;');
            }
        }

        function ChangeReportFor(SelType) {

            if ($('.ddlReportBy').val() == "4") {
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
                $('.divPurFrom').attr('style', 'display:none;');
            }
            else if ($('.ddlReportBy').val() == "2") {
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
                $('.divPurFrom').removeAttr('style');
            }

            if (($('.ddlReportBy').val() == "4") || ($('.ddlReportBy').val() == "2") && ($('.ddlPurFrom').val() == "3" || $('.ddlPurFrom').val() == "1")) {
                $('.divInvPlant').removeAttr('style');
            }
            else {
                $('.divInvPlant').attr('style', 'display:none;');
            }

            if (($('.ddlReportBy').val() == "4") || ($('.ddlReportBy').val() == "2") && $('.ddlPurFrom').val() == "2") {
                $('.divSS').removeAttr('style');
            }
            else {
                if (SelType == "2")
                    $('.txtSSDistCode').val('');
                $('.divSS').attr('style', 'display:none;');
            }
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var plt = $('.txtPlant').is(":visible") ? $('.txtPlant').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + plt + "-" + ss + "-" + EmpID);
        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var plt = $('.txtPlant').is(":visible") ? $('.txtPlant').val().split('-').pop() : "0";
            var ss = "";
            var dist = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            if (CustType == 2)
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : ParentID;
            else
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + plt + "-" + ss + "-" + dist + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var plt = $('.txtPlant').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-" + plt + "-" + EmpID);
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(key + "-0" + "-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        function autoCompleteMatGroup_OnClientPopulating(sender, args) {
            var key = $('.txtGroup').val().split('-')[0];
            sender.set_contextKey(key);
        }

        function autoCompleteMatName_OnClientPopulating(sender, args) {
            var key = $('.txtSubGroup').val().split('-')[0];
            sender.set_contextKey(key);
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row" style="margin-bottom: 0px">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lbltype" Text="Report Option" runat="server" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlType" runat="server" TabIndex="10" CssClass="ddlType form-control">
                            <asp:ListItem Value="4"> Purchase </asp:ListItem>
                            <asp:ListItem Value="5"> Purchase Return </asp:ListItem>
                            <asp:ListItem Value="6"> Purchase & Purchase Return </asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblReportBy" Text="Report Of" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" TabIndex="14" ID="ddlReportBy" CssClass="ddlReportBy form-control" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divPurFrom" id="divPurFrom" runat="server">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblPurFrom" Text="Purchase From" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" TabIndex="12" ID="ddlPurFrom" CssClass="ddlPurFrom form-control" onchange="ChangePurFrom('2');">
                            <asp:ListItem Text="Plant & SuperStockist" Value="3" Selected="True" />
                            <asp:ListItem Text="Plant" Value="1" />
                            <asp:ListItem Text="SuperStockist" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Date Option" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlDateOption" TabIndex="13" runat="server" CssClass="ddlDateOption form-control">
                            <asp:ListItem Text="Receipt Date" Value="2" Selected="True" />
                            <asp:ListItem Text="Invoice Date" Value="1" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleFrom" Text="Sale From" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" TabIndex="4" ID="ddlSaleFrom" CssClass="ddlSaleFrom form-control">
                            <asp:ListItem Text="Both" Value="0" Selected="True" />
                            <asp:ListItem Text="Under Plant" Value="1" />
                            <asp:ListItem Text="Under SuperStockist" Value="4" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="5"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesStoreHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="autoCompleteState_OnClientPopulating"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divPlant" runat="server" style="display: none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control" autocomplete="off" TabIndex="6"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlantsStoreHierarchy"
                            ServicePath="../Service.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divInvPlant" id="divInvPlant" runat="server">
                    <div class="input-group form-group" id="div1" runat="server">
                        <asp:Label ID="lblInvPlant" runat="server" Text='Invoice Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtInvPlant" TabIndex="15" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtInvPlant form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServiceMethod="GetPlants"
                            ServicePath="../Service.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtInvPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlDivision" TabIndex="11" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblGroupName" runat="server" Text='Item Group' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtGroup" TabIndex="16" CssClass="txtGroup form-control" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtItemGroupID" runat="server" ServiceMethod="GetItemGroup" ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtGroup" UseContextKey="True"></asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSubGroupName" runat="server" Text='Item Subgroup' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSubGroup" runat="server" TabIndex="17" Style="background-color: rgb(250, 255, 189);" CssClass="txtSubGroup form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtItemSubGroupID" runat="server" ServiceMethod="GetSubGroupItem" ServicePath="../WebService.asmx" OnClientPopulating="autoCompleteMatGroup_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSubGroup" UseContextKey="True"></asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button Width="291" TabIndex="18" Text="Export-Detail-Data" ID="btnDetailData" OnClick="btnDetailData_Click" CssClass="btnDetailData btn btn-default" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

