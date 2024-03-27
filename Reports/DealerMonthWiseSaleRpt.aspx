<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DealerMonthWiseSaleRpt.aspx.cs" Inherits="Reports_DealerMonthWiseSaleRpt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var ParentID = <% = ParentID%>;
        var CustType = '<% =CustType%>';

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + "0" + "-" + ss + "-" + EmpID);
        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
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
            sender.set_contextKey(reg + "-0-" + "0" + "-" + ss + "-" + dist + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-" + "0" + "-" + EmpID);
        }

        function acettxtCity_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            
            sender.set_contextKey(reg + "-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        function ChangeReportFor(SelType) {
            if ($('.ddlSaleBy').val() == "4") {
                $('.lblRegion').text('SuperStockist Region');
                $('.lblCity').text('Distributor City');
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlSaleBy').val() == "2") {
                $('.lblRegion').text('Distributor Region');
                $('.lblCity').text('Dealer City');
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
            }
        }

        $(function () {
            ReLoadFn();
            ChangeReportFor('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
            ChangeReportFor('1');
        }
        function ReLoadFn() {

            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });

            //$('.ddlSaleBy').change(function () {
            //    if($('.ddlSaleBy').val() == 2)
            //    {
            //        $('.txtSSDistCode').val('');
            //        $('#body_divSS').hide();
            //        $('#body_divDealer').show();
            //    }
            //    else 
            //    {
            //        $('.txtDealerCode').val('');
            //        $('#body_divSS').show();
            //        $('#body_divDealer').hide();
            //    }
            //}).change();
        }

        function ChangeState()
        {
            $('.txtCity').val('');
        }

    </script>
    <style type="text/css">
        .ui-datepicker-calendar {
            display: none;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Month" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromMonth" TabIndex="1" runat="server" MaxLength="7" CssClass="onlymonth form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Month" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToMonth" TabIndex="2" runat="server" MaxLength="7" CssClass="onlymonth form-control"></asp:TextBox>
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
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Sale By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlSaleBy" CssClass="ddlSaleBy form-control" TabIndex="4" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Distributor Region' CssClass="lblRegion input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="5"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesStoreHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="autoCompleteState_OnClientPopulating"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Distributor City" ID="lblCity" runat="server" CssClass="lblCity input-group-addon" autocomplete="off" />
                        <asp:TextBox runat="server" ID="txtCity" CssClass="txtCity form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="6" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtCity" runat="server"
                            OnClientPopulating="acettxtCity_OnClientPopulating" ServicePath="../Service.asmx" UseContextKey="true" ServiceMethod="GetCitysCurrHierarchy" MinimumPrefixLength="1"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCity">
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
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
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
                        <asp:DropDownList runat="server" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID" TabIndex="10">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="11" CssClass="btn btn-default" Style="display: none;" OnClick="btnGenerat_Click" />
                        <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="12" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
                <div class="col-lg-12">
                    <span style="color: red; font-weight: bold">Report Processed only 12 Month.</span>
                </div>
                <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvSalevsDispatch" runat="server" CssClass="gvSalevsDispatch table tbl" Style="font-size: 11px;" AutoGenerateColumns="true"
                        OnPreRender="gvSalevsDispatch_PreRender" HeaderStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
            <iframe hidden="hidden" id="ifmDealerMnthSale" style="height: 100%; width: 100%" class="embed-responsive-item" runat="server" onload="ifmDealerMnthSale_Load"></iframe>
        </div>
    </div>
</asp:Content>

