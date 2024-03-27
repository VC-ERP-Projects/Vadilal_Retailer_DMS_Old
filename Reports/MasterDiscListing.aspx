<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="MasterDiscListing.aspx.cs" Inherits="Reports_MasterDiscListing" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var ParentID = '<% = ParentID%>';
        var CustType = '<% = CustType%>';

        $(function () {

            $(".allownumericwithdecimal").keydown(function (e) {
                // Allow: backspace, delete, tab, escape, enter
                if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 86, 67]) !== -1 ||
                    // Allow: Ctrl+A, Command+A
                    ((e.keyCode == 65 || e.keyCode == 86 || e.keyCode == 67) && (e.ctrlKey === true || e.metaKey === true)) ||
                    // Allow: home, end, left, right, down, up
                    (e.keyCode >= 35 && e.keyCode <= 40)) {
                    // let it happen, don't do anything

                    var myval = $(this).val();
                    if (myval != "") {
                        if (isNaN(myval)) {
                            $(this).val('');
                            e.preventDefault();
                            return false;
                        }
                    }

                    return;
                }
                // Ensure that it is a number and stop the keypress
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Reload();
        }

        function Reload() {

            $('.frommindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                onSelect: function (selected) {
                    $('.tomindate').datepicker("option", "minDate", selected);
                }
            });

            $('.tomindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //"maxDate": '<%=DateTime.Now %>',
                //minDate: new Date(2017, 6, 1),
                onSelect: function (selected) {
                    $('.frommindate').datepicker("option", "maxDate", selected);
                }
            });

            var autoComplete = $find("DealerCode");
            if (autoComplete != undefined) {
                if ($('.ddlReportFor').val() == 1) {
                    $('.lbldealer').text("Dealer");
                    autoComplete.set_serviceMethod("GetNotFOWDealerofDist");
                }
                else if ($('.ddlReportFor').val() == 2) {
                    $('.lbldealer').text("FOW");
                    autoComplete.set_serviceMethod("GetFOWDealerofDist");
                }
                else {
                    $('.lbldealer').text("Dealer/FOW");
                    autoComplete.set_serviceMethod("GetDealerofDist");
                }
            }

            $('.ddlReportFor').change(function () {
                var autoComplete = $find("DealerCode");
                if (autoComplete != undefined) {
                    if ($('.ddlReportFor').val() == 1) {
                        $('.lbldealer').text("Dealer");
                        $('.txtDealerCode').val("");
                        autoComplete.set_serviceMethod("GetNotFOWDealerofDist");
                    }
                    else if ($('.ddlReportFor').val() == 2) {
                        $('.lbldealer').text("FOW");
                        $('.txtDealerCode').val("");
                        autoComplete.set_serviceMethod("GetFOWDealerofDist");
                    }
                    else {
                        $('.lbldealer').text("Dealer/FOW");
                        $('.txtDealerCode').val("");
                        autoComplete.set_serviceMethod("GetDealerofDist");
                    }
                }
            });
        }

        function _btnCheck() {
            var IsValid = true;
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var Region = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            sender.set_contextKey(Region + "-0-0-0-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            if ($('.txtCustCode').val() != undefined) {
                var key = $('.txtCustCode').val().split('-').pop();
                if (key != undefined)
                    sender.set_contextKey(key);
            }
            else {
                sender.set_contextKey(ParentID);
            }
        }

        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtPlant").val('');
                $(".txtRegion").val('');
                $(".txtSSDistCode").val('');
                $(".txtCustCode").val('');
                $(".txtDealerCode").val('');
            }
        }

        function ClearOtherDistConfig() {
            if ($(".txtCustCode").length > 0) {
                $(".txtDealerCode").val('');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="4"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtRegionId" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" CssClass="lbldealer input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode" BehaviorID="DealerCode" ServiceMethod="GetDealerofDist">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblDivision" Text="Division" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" TabIndex="11" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                    <%--    <div class="input-group form-group">--%>
                    <asp:Label ID="lblCpnyContriTo" runat="server" Visible="false" Text='Comp. Contri % To' CssClass="input-group-addon"></asp:Label>
                    <input id="txtCpnyContriTo" tabindex="10" visible="false" runat="server" name="txtCpnyContriTo" class="txtCpnyContriTo form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />
                    <%-- </div>

                    <div class="input-group form-group">--%>
                    <asp:Label ID="lblDistContriTo" runat="server" Visible="false" Text='Dist. Contri % To' CssClass="input-group-addon"></asp:Label>
                    <input id="txtDistContriTo" tabindex="13" runat="server" visible="false" name="txtDistContriTo" class="txtDistContriTo form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />
                    <%--</div>--%>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="tomindate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group" id="divDistributor" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" OnChange="ClearOtherDistConfig()" runat="server" CssClass="txtCustCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);" TabIndex="5"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblstatus" runat="server" Text="Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlDistStatus" CssClass="ddlDistStatus form-control" TabIndex="8">
                            <asp:ListItem Text="Both" Value="2" Selected="True" />
                            <asp:ListItem Text="Active" Value="1" />
                            <asp:ListItem Text="In-Active" Value="0" />
                        </asp:DropDownList>
                    </div>

                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" CssClass="btn btn-default" TabIndex="14" OnClick="btnGenerat_Click" />
                        &nbsp
                        <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="15" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" OnChange="ClearOtherConfig()" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblReportFor" Text="Report For" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlReportFor" CssClass="ddlReportFor form-control" TabIndex="6">
                            <asp:ListItem Text="Both" Value="0" Selected="True" />
                            <asp:ListItem Text="Dealer" Value="1" />
                            <asp:ListItem Text="FOW" Value="2" />
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="Label1" Text="Gross Sales Period" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlSalesPeriod" CssClass="ddlSalesPeriod form-control" TabIndex="9">
                            <asp:ListItem Value="1">Yearly</asp:ListItem>
                            <asp:ListItem Value="2">Discount Period</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <%-- <div class="input-group form-group">--%>
                    <asp:Label ID="lblCpnyContriFrom" runat="server" Visible="false" Text='Comp. Contri % From' CssClass="input-group-addon"></asp:Label>
                    <input id="txtCpnyContriFrom" tabindex="9" visible="false" runat="server" name="txtCpnyContriFrom" class="txtCpnyContriFrom form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />

                    <%--</div>
                    <div class="input-group form-group">--%>
                    <asp:Label ID="lblDistContriFrom" runat="server" Visible="false" Text='Dist. Contri % From' CssClass="input-group-addon"></asp:Label>
                    <input id="txtDistContriFrom" tabindex="12" runat="server" visible="false" name="txtDistContriFrom" class="txtDistContriFrom form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />
                    <%--</div>--%>
                </div>
            </div>
        </div>
        <iframe id="ifmDataReq" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmDataReq_Load"></iframe>
    </div>
</asp:Content>

