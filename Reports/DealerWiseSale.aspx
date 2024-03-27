<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DealerWiseSale.aspx.cs" Inherits="Reports_DealerWiseSale" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/MultiSelect_DropDown/bootstrap-multiselect.css" rel="stylesheet" />
    <script src="../Scripts/MultiSelect_DropDown/bootstrap-multiselect.js"></script>
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
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                },
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
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                },
                onSelect: function (selected) {
                    $('.frommindate').datepicker("option", "maxDate", selected);
                }
            });

            $("#btnImport").bind("click", function () {
                var regex = /^([a-zA-Z0-9\s_\\.\-:])+(.csv|.txt)$/;
                if (regex.test($("#fileUpload").val().toLowerCase())) {
                    if (typeof (FileReader) != "undefined") {
                        var reader = new FileReader();
                        reader.onload = function (e) {
                            var rows = e.target.result.split("\n");
                            var row = ""
                            for (var i = 1; i < rows.length; i++) {
                                var cells = rows[i].split(",");
                                for (var j = 0; j < cells.length; j++) {
                                    row += cells[j] + ','
                                }
                            }
                            $(".hdnCustCode").val(row);
                        }
                        reader.readAsText($("#fileUpload")[0].files[0]);
                        ModelMsg("Uploaded Succesfully", 1);
                    } else {
                        ModelMsg("This browser does not support HTML5.", 3);
                    }
                } else {
                    ModelMsg("Please upload a valid csv file.", 3);
                }
            });
        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            if ($('.txtCustCode').val() != undefined) {
                var key = $('.txtCustCode').val().split('-').pop();
                if (key != undefined)
                    sender.set_contextKey(key);
            }
        }

        function _btnCheck() {
            if ($("#fileUpload").val() != "" && $(".hdnCustCode").val() == "") {
                ModelMsg("Please click upload button.", 3);
                event.preventDefault();
            }
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function autoCompleteMatGroup_OnClientPopulating(sender, args) {
            var key = $('.txtGroup').val().split('-')[0];
            sender.set_contextKey(key);
        }

        function autoCompleteMatName_OnClientPopulating(sender, args) {
            var key = $('.txtSubGroup').val().split('-')[0];
            sender.set_contextKey(key);
        }

        function download() {
            window.open("../Document/CSV Formats/DealerWiseSale.csv");
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
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="tomindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlDivision" TabIndex="1" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromDistSSPlantState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Report Option" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlReport" runat="server" CssClass="ddlReport form-control" TabIndex="5">
                            <asp:ListItem Text="Selected Dealer + Distributor + Invoice + Item wise Despatch Report" Value="1" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Selected Dealer + Distributor + Invoice wise Despatch Report" Value="2"></asp:ListItem>
                            <asp:ListItem Text="Selected Dealer + Distributor wise Despatch Report" Value="3"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblGroupName" runat="server" Text='Item Group' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtGroup" TabIndex="16" CssClass="txtGroup form-control" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtItemGroupID" runat="server" ServiceMethod="GetItemGroup" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtGroup" UseContextKey="True"></asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSubGroupName" runat="server" Text='Item Subgroup' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSubGroup" runat="server" TabIndex="17" Style="background-color: rgb(250, 255, 189);" CssClass="txtSubGroup form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtItemSubGroupID" runat="server" ServiceMethod="GetSubGroupItem" ServicePath="../Service.asmx" OnClientPopulating="autoCompleteMatGroup_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSubGroup" UseContextKey="True"></asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Item" ID="lblItem" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtItem" CssClass="txtItem form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="9" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtItem" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetItemWithID" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteMatName_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtItem">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="7" CssClass="btn btn-default" OnClick="btnGenerat_Click" OnClientClick="return _btnCheck();" />
                        &nbsp
                    <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="8" CssClass="btn btn-default" OnClientClick="return _btnCheck();" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Upload File" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                        <input type="file" id="fileUpload" class="form-control" />
                        <input type="button" id="btnImport" value="Upload" />&nbsp
                        <input type="text" hidden="hidden" runat="server" value="" name="hdnCustCode" id="hdnCustCode" class="hdnCustCode" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnDownload" runat="server" Text="Download Format" CssClass="btn btn-default" OnClientClick="download(); return false;" />
                    </div>
                </div>
            </div>
            <div class="col-lg-4">
                <span style="color: red; font-weight: bold">Upload Only CSV Dealer Code File.</span>
            </div>
            <iframe id="ifmDealerSale" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmDealerSale_Load"></iframe>
        </div>

    </div>
</asp:Content>

