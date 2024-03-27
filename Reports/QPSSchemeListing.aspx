<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="QPSSchemeListing.aspx.cs" Inherits="Reports_QPSSchemeListing" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
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
                //minDate: new Date(2017, 6, 1),
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
            var autoComplete = $find("LvlInput");
            if ($('.ddlSchemeLvl').val() == 1) {
                $('.txtLvlInput').prop("disabled", false);
                autoComplete.set_serviceMethod("GetStates");
            }
            else if ($('.ddlSchemeLvl').val() == 2) {
                $('.txtLvlInput').prop("disabled", false);
                autoComplete.set_serviceMethod("GetPlants");
            }
            else if ($('.ddlSchemeLvl').val() == 3) {
                $('.txtLvlInput').prop("disabled", false);
                autoComplete.set_serviceMethod("GetDistFromSSPlantState");
            }
            else if ($('.ddlSchemeLvl').val() == 4) {
                $('.txtLvlInput').prop("disabled", false);
                autoComplete.set_serviceMethod("GetDealerFromDistSSPlantState");
            }

            $('.ddlSchemeLvl').change(function () {
                var autoComplete = $find("LvlInput");
                $('.txtLvlInput').val("");

                if (autoComplete != undefined) {
                    if ($('.ddlSchemeLvl').val() == 1) {
                        $('.txtLvlInput').prop("disabled", false);
                        autoComplete.set_serviceMethod("GetStates");
                    }
                    else if ($('.ddlSchemeLvl').val() == 2) {
                        $('.txtLvlInput').prop("disabled", false);
                        autoComplete.set_serviceMethod("GetPlants");
                    }
                    else if ($('.ddlSchemeLvl').val() == 3) {
                        $('.txtLvlInput').prop("disabled", false);
                        autoComplete.set_serviceMethod("GetDistFromSSPlantState");
                    }
                    else if ($('.ddlSchemeLvl').val() == 4) {
                        $('.txtLvlInput').prop("disabled", false);
                        autoComplete.set_serviceMethod("GetDealerFromDistSSPlantState");
                    }
                }
            });

            $('.ddlDateOption').change(function () {
                if ($('.ddlDateOption').val() == 1) {
                    $('#divBtwnDate').hide();
                    $('#divFromTo').show();
                }
                else if ($('.ddlDateOption').val() == 2) {
                    $('#divBtwnDate').show();
                    $('#divFromTo').hide();
                }
            }).change();
        }

    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Scheme Code" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtCode" CssClass="form-control" Style="background-color: rgb(250, 255, 189);" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtCode" runat="server" ServiceMethod="GetQPSScheme"
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode" UseContextKey="True"
                            Enabled="true">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Item Code & Name" runat="server" CssClass="input-group-addon" />
                        <asp:Label ID="lblItemID" CssClass="lblItemID" runat="server" Text='<%# Eval("ItemID") %>' Style="display: none;"></asp:Label>
                        <asp:TextBox runat="server" ID="txtItem" CssClass="txtItem form-control" Style="background-color: rgb(250, 255, 189);" Text='<%# String.Format("{0} - {1}", Eval("ItemCode"),Eval("ItemName")) %>' />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtItem" runat="server" ServicePath="../WebService.asmx" UseContextKey="true" ServiceMethod="GetQPSSchemeItem" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtItem">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblCpnyContriFrom" runat="server" Text='Comp. Contri % From' CssClass="input-group-addon"></asp:Label>
                        <input id="txtCpnyContriFrom" runat="server" name="txtCpnyContriFrom" class="txtCpnyContriFrom form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />
                        <%--<asp:TextBox ID="txtCpnyContriFrom" CssClass="allownumericwithdecimal form-control" runat="server" placeholder="0.0"></asp:TextBox>--%>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblDistContriFrom" runat="server" Text='Dist. Contri % From' CssClass="input-group-addon"></asp:Label>
                        <input id="txtDistContriFrom" runat="server" name="txtDistContriFrom" class="txtDistContriFrom form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />
                        <%--<asp:TextBox ID="txtDistContriFrom" CssClass="allownumericwithdecimal  form-control" runat="server" placeholder="0.0"></asp:TextBox>--%>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp
                        <asp:Button Text="Export To Excel" ID="btnExport" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSchemeLvl" Text="Scheme Level" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlSchemeLvl" CssClass="ddlSchemeLvl form-control">
                            <asp:ListItem Text="All" Value="0" Selected="True" />
                            <asp:ListItem Text="Region" Value="1" />
                            <asp:ListItem Text="Plant" Value="2" />
                            <asp:ListItem Text="Distributor" Value="3" />
                            <asp:ListItem Text="Dealer" Value="4" />
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblLevelInput" runat="server" Text="Level" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtLvlInput" runat="server" CssClass="txtLvlInput form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtLvlInput" BehaviorID="LvlInput">
                        </asp:AutoCompleteExtender>
                    </div>

                    <div class="input-group form-group">
                        <asp:Label ID="lblCpnyContriTo" runat="server" Text='Comp. Contri % To' CssClass="input-group-addon"></asp:Label>
                        <input id="txtCpnyContriTo" runat="server" name="txtCpnyContriTo" class="txtCpnyContriTo form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />
                        <%--<asp:TextBox ID="txtCpnyContriTo" CssClass="txtCpnyContriTo form-control allownumericwithdecimal" runat="server" placeholder="100.0"></asp:TextBox>--%>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblDistContriTo" runat="server" Text='Dist. Contri % To' CssClass="input-group-addon"></asp:Label>
                        <input id="txtDistContriTo" runat="server" name="txtDistContriTo" class="txtDistContriTo form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />
                        <%--<asp:TextBox ID="txtDistContriTo" CssClass="txtDistContriTo form-control allownumericwithdecimal" runat="server" placeholder="100.0"></asp:TextBox>--%>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsDetail" runat="server" Text="Is Detail" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsDetail" TabIndex="4" Checked="true" runat="server" CssClass="chkIsDetail form-control" />
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblDateOption" Text="Option" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlDateOption" CssClass="ddlDateOption form-control">
                            <asp:ListItem Text="Scheme Period" Value="1" Selected="True" />
                            <asp:ListItem Text="Between Date" Value="2" />
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group" id="divBtwnDate">
                        <asp:Label ID="lblBtwnDate" runat="server" Text="Between Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtBtwnDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                    </div>
                    <div id="divFromTo">
                        <div class="input-group form-group" id="divFromDate" runat="server">
                            <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group" id="divToDate" runat="server">
                            <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="tomindate form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblLowerLimit" runat="server" Text='Lower Limit' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtLowerLimit" CssClass="txtLowerLimit form-control allownumericwithdecimal" runat="server" placeholder="0.0"></asp:TextBox>
                    </div>
                    <%--<div class="input-group form-group">
                        <asp:Label runat="server" ID="lblDivision" Text="Division" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>--%>
                </div>
            </div>
        </div>
        <iframe id="ifmDataReq" style="width: 100%" class="embed-responsive-item" runat="server" ></iframe>
    </div>
</asp:Content>

