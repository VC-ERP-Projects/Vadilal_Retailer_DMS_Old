<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="AssetComplaintReg.aspx.cs" Inherits="Task_AssetComplaintReg" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="../Scripts/timepick/jquery.plugin.min.js"></script>
    <script src="../Scripts/timepick/jquery.timeentry.min.js"></script>

    <script type="text/javascript">

        $(document).ready(function () {
            $('.hdnTab1Btn').val('0');
            $('#tab2').addClass('hide');
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function Relaod() {

            $('.txtDueTime').timeEntry({ show24Hours: true, spinnerImage: '' });

            $('.unEditbl').attr('disabled', true);

            var dt = new Date();
            var date = String(dt.getDate()).padStart(2, '0') + '/' + String(dt.getMonth() + 1).padStart(2, '0') + '/' + dt.getFullYear();
            var time = '';
            if (date == $('.tillDate').val() || $('.tillDate').val() == '')
                time = dt.getHours() + ":" + dt.getMinutes();
            $('.txtDueTime').timeEntry('destroy');
            $('.txtDueTime').timeEntry({ show24Hours: true, spinnerImage: '', minTime: time });

            $('.tillDate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(),
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                    time = '';
                    if (date == $('.tillDate').val()) {
                        time = ("0" + dt.getHours()).slice(-2) + ":" + ("0" + dt.getMinutes()).slice(-2);
                        $('.txtDueTime').val(time);
                    }
                    $('.txtDueTime').timeEntry('destroy');
                    $('.txtDueTime').timeEntry({ show24Hours: true, spinnerImage: '', minTime: time });
                }
            });

            $(".tillDate").on("change", function () {
                time = '';
                if (date == $('.tillDate').val()) {
                    time = ("0" + dt.getHours()).slice(-2) + ":" + ("0" + dt.getMinutes()).slice(-2);
                    $('.txtDueTime').val(time);
                }
                $('.txtDueTime').timeEntry('destroy');
                $('.txtDueTime').timeEntry({ show24Hours: true, spinnerImage: '', minTime: time });
            });

            if ($('.hdnTab1Btn').val() == "0" || ($('.hdnTab1Btn').val() == "2" && $(".txtRemarks").val() == ""))
                $('#tab2').addClass('hide');

            var selectedTab = $("#<%=hfTab.ClientID%>");
            var tabId = selectedTab.val() != "" ? selectedTab.val() : "tabs-1";
            if ($('.hdnTab1Btn').val() == "2" && $(".txtRemarks").val() == "") {
                $('#tab2').addClass('hide');
                activeTab("tabs-1");
                ModelMsg("In Case Of Conflict Remarks are mandatory.", 3);
                event.preventDefault();
                return;
            }
            $('#divTabs a[href="#' + tabId + '"]').tab('show');
            $("#divTabs a").click(function () {
                selectedTab.val($(this).attr("href").substring(1));
            });
        }

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function onCityAutoCompleteSelected(sender, e) {
            __doPostBack(sender.get_element().name, null);
        }

        function ChangeToVari(btn) {
            if ($(".txtAssetSerialNo").val() == "") {
                ModelMsg("Please Search for Asset.", 3);
                event.preventDefault();
                return;
            }

            if (btn == "2" && $(".txtRemarks").val().trim() == "") {
                ModelMsg("In Case Of Conflict, Remarks are mandatory.", 3);
                event.preventDefault();
                return;
            }

            $('#tab2').removeClass('hide');
            activeTab("tabs-2");
        }

        function activeTab(tab) {
            $('.nav-tabs a[href="#' + tab + '"]').tab('show');
        };

        function _btnSubmitCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }
        function _btnCheck() {

            if ($(".txtAssetSerialNo").val() == "") {
                ModelMsg("Please Search for Asset.", 3);
                event.preventDefault();
                return;
            }

            if ($(".txtTaskName").val() == "") {
                ModelMsg("Task Name is mandatory!", 3);
                event.preventDefault();
                return;
            }

            if ($('.hdnTab1Btn').val() == "2" && ($(".txtRemarks").val() == "" || $(".txtProbRemark").val() == "")) {
                $('#tab2').addClass('hide');
                //activeTab("tabs-1");
                ModelMsg("In Case Of Conflict, both Remarks are mandatory.", 3);
                event.preventDefault();
                return;
            }
            _btnSubmitCheck();
        }

    </script>
    <style type="text/css">
        .input-group-addon {
            font-size: small;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body ComplaintForm">
            <div class="_masterForm">
                <div class="row">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <input type="hidden" id="hdnTab1Btn" runat="server" class="hdnTab1Btn" />
                            <%--0 = NoVal, 1 = Confirm, 2 = Conflict--%>
                            <asp:HiddenField ID="hfTab" runat="server" />
                            <asp:Label ID="lblAssetSerialNo" runat="server" Text="Asset Sr. No" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtAssetSerialNo" CssClass="txtAssetSerialNo form-control" runat="server" autocomplete="off" Style="background-color: rgb(250, 255, 189);" AutoPostBack="true" OnTextChanged="btnGo_Click"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtAssetSerialNo" runat="server" ServicePath="../Service.asmx"
                                UseContextKey="true" ServiceMethod="GetAssetSerialNo" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtAssetSerialNo">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Button ID="btnGo" CssClass="btn btn-default" runat="server" Text="GO" OnClick="btnGo_Click" />
                        </div>
                    </div>
                </div>
                <div id="divTabs">
                    <ul id="tabs" class="nav nav-tabs" role="tablist">
                        <li class="active" id="tab1"><a href="#tabs-1" role="tab" data-toggle="tab">Verification</a></li>
                        <li id="tab2"><a href="#tabs-2" role="tab" data-toggle="tab">Registration</a></li>
                    </ul>
                </div>
                <div id="myTabContent" class="tab-content">
                    <div id="tabs-1" class="tab-pane active">
                        <div class="row">
                            <div class="col-lg-6">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblAssetNo" runat="server" Text="Asset Sr. No" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtAssetNo" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblAssetCode" runat="server" Text="Asset Code" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtAssetCode" runat="server" CssClass="txtAssetCode unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblIdentifier" runat="server" Text="Equipment" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtIdentifier" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblModelNo" runat="server" Text="Model No - Type" CssClass="input-group-addon"></asp:Label>
                                    <table width="100%">
                                        <tr>
                                            <td width="50%">
                                                <asp:TextBox ID="txtModelNo" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                            </td>
                                            <td width="50%">
                                                <asp:TextBox ID="txtType" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                            </td>
                                        </tr>
                                    </table>

                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblRSDLoc" runat="server" Text="RSD Location" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtRSDLocation" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSize" runat="server" Text="Size In Ltrs." CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSize" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblBrand" runat="server" Text="Brand" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtBrand" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label Text="Assign Employee" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox ID="ddlEmpVerList" runat="server" CssClass="ddlEmpVerList form-control" disabled></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCustCode" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCustCode" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCustGrp" runat="server" Text="Customer Group" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCustGrp" runat="server" Rows="2" CssClass="unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCustomerAdd" runat="server" Text="Customer Address 1" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCustAdd" runat="server" Rows="2" CssClass="txtCustAdd unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCustomerAdd2" runat="server" Text="Customer Address 2" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCustAdd2" runat="server" Rows="2" CssClass="txtCustAdd2 unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblLocation" runat="server" Text="Area" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtLocation" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblContactP" runat="server" Text="Contact Person" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtContactP" runat="server" Rows="2" CssClass="txtContactP unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblLocationCity" runat="server" Text="City" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCity" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblStateRSDLocation" runat="server" Text="State" CssClass="unEditbl input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtState" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPhone1" runat="server" Text="Primary & Second. No" CssClass="input-group-addon"></asp:Label>
                                    <table width="100%">
                                        <tr>
                                            <td width="50%">
                                                <asp:TextBox ID="txtPhone1" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                            </td>
                                            <td width="50%">
                                                <asp:TextBox ID="txtPhone2" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblEmail" runat="server" Text="Email Address" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-12">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblRemarks" runat="server" Text="Remarks" CssClass="lbl_desc input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtRemarks" Rows="2" TextMode="MultiLine" runat="server" CssClass="txtRemarks form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-12">
                                <div class="input-group form-group">
                                    <asp:Button ID="btnConfirm" CssClass="btn btn-default" runat="server" Text="Confirm" OnClick="btnConfirm_Click" OnClientClick="return ChangeToVari(1);" />
                                    &nbsp;&nbsp;
                                    <asp:Button ID="btnConflict" CssClass="btn btn-default" runat="server" Text="Conflict" OnClick="btnConflict_Click" OnClientClick="return ChangeToVari(2);" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="tabs-2" class="tab-pane">
                        <div class="row">
                            <div class="col-lg-6">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblTaskType" runat="server" Text="Task Type" CssClass="input-group-addon"></asp:Label>
                                    <table width="100%">
                                        <tr>
                                            <td width="40%">
                                                <asp:TextBox ID="txtTaskType" runat="server" CssClass="form-control" Enabled="false"></asp:TextBox>
                                            </td>
                                            <td width="60%">
                                                <asp:TextBox ID="txtTaskDate" runat="server" CssClass="form-control" Enabled="false"></asp:TextBox>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCityFlag" runat="server" Text="City Flag" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList ID="ddlCityFlag" runat="server" CssClass="ddlCityFlag form-control" OnSelectedIndexChanged="ddlCityFlag_SelectedIndexChanged" AutoPostBack="true" data-bv-notempty="true" data-bv-notempty-message="Field is required">
                                        <asp:ListItem Value="" Text="---Select---"></asp:ListItem>
                                        <asp:ListItem Value="1" Text="In-City"></asp:ListItem>
                                        <asp:ListItem Value="0" Text="Out-City"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblProbType" runat="server" Text="Problem Type" CssClass="input-group-addon"></asp:Label>
                                    <table width="100%">
                                        <tr>
                                            <td width="40%">
                                                <asp:DropDownList ID="ddlProbType" runat="server" CssClass="ddlProbType form-control" DataTextField="ProbemName" AutoPostBack="true" data-bv-notempty="true" data-bv-notempty-message="Field is required"
                                                    DataValueField="ProblemID" AppendDataBoundItems="true" OnSelectedIndexChanged="ddlProbType_SelectedIndexChanged">
                                                </asp:DropDownList>
                                            </td>
                                            <td width="30%">
                                                <asp:TextBox runat="server" ID="txtDueDate" onkeyup="return ValidateDate(this);" CssClass="tillDate form-control" />
                                            </td>
                                            <td width="30%">
                                                <asp:TextBox runat="server" ID="txtDueTime" CssClass="txtDueTime form-control" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblTaskName" runat="server" Text="Task Name" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtTaskName" runat="server" disabled CssClass="txtTaskName form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblProbRemark" runat="server" Text="Problem Remarks" CssClass="lbl_desc input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtProbRemark" Rows="2" TextMode="MultiLine" runat="server" CssClass="txtProbRemark form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblUnderWrnty" runat="server" Text="Warranty Details" CssClass="input-group-addon"></asp:Label>
                                    <table width="100%">
                                        <tr>
                                            <td width="50%">
                                                <asp:DropDownList ID="ddlUnderWrnty" runat="server" CssClass="form-control" disabled>
                                                    <asp:ListItem Value="0" Text="No" Selected="True"></asp:ListItem>
                                                    <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                            <td width="50%">
                                                <asp:TextBox ID="txtWrntyDate" runat="server" CssClass="unEditbl form-control"></asp:TextBox>
                                            </td>
                                        </tr>
                                    </table>

                                </div>
                                <div class="input-group form-group">
                                    <asp:Button ID="btnSubmit" CssClass="btn btn-default" ValidationGroup="RouteCode" runat="server" Text="Submit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
                                    &nbsp;&nbsp;
                                    <asp:Button ID="btnCancel" CssClass="btn btn-default" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
                                </div>
                            </div>
                            <div class="col-lg-6" id="divConfirm" runat="server">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblInCustCode" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtInCustCode" runat="server" OnTextChanged="txtInCustCode_TextChanged" CssClass="form-control" Style="background-color: rgb(250, 255, 189);" AutoPostBack="true"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                                        UseContextKey="true" ServiceMethod="GetCustomerByAllTypeWithoutTemp" ContextKey="" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtInCustCode">
                                    </asp:AutoCompleteExtender>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblInCustGrp" runat="server" Text="Customer Group" CssClass="lbl_desc input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtInCustGrp" runat="server" Rows="2" CssClass="txtInCustGrp unEditbl form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblInCustAdd" runat="server" Text="Customer Address 1" CssClass="lbl_desc input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtInCustAdd" runat="server" Rows="2" CssClass="txtInCustAdd form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblInCustAdd2" runat="server" Text="Customer Address 2" CssClass="lbl_desc input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtInCustAdd2" runat="server" Rows="2" CssClass="txtInCustAdd2 form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblInLocation" runat="server" Text="Area" CssClass="lbl_desc input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtInLocation" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblInContactP" runat="server" Text="Contact Person" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtInContactP" runat="server" Rows="2" CssClass="txtInContactP form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblInCity" runat="server" Text="City" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtInCity" runat="server" CssClass="form-control" OnTextChanged="txtInCity_TextChanged" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtCityName" runat="server" ServicePath="~/Service.asmx"
                                        UseContextKey="true" ServiceMethod="GetCitys" MinimumPrefixLength="1" CompletionInterval="10" OnClientItemSelected="onCityAutoCompleteSelected"
                                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtInCity">
                                    </asp:AutoCompleteExtender>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblInState" runat="server" Text="State" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtInState" runat="server" CssClass="form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtStateName" runat="server" ServicePath="../Service.asmx"
                                        UseContextKey="true" ServiceMethod="GetStates" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtInState">
                                    </asp:AutoCompleteExtender>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblInPhone1" runat="server" Text="Primary & Second. No" CssClass="input-group-addon"></asp:Label>
                                    <table width="100%">
                                        <tr>
                                            <td width="50%">
                                                <asp:TextBox ID="txtInPhone1" runat="server" CssClass="form-control"></asp:TextBox>
                                            </td>
                                            <td width="50%">
                                                <asp:TextBox ID="txtInPhone2" runat="server" CssClass="form-control"></asp:TextBox>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblInEmail" runat="server" Text="Email Address" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtInEmail" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label Text="Assign Employee" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox ID="ddlEmpList" runat="server" CssClass="ddlEmpList form-control" disabled></asp:TextBox>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

