<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ReceiptJE.aspx.cs" Inherits="Finance_ReceiptJE" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        function download() {
            window.open("../Document/CSV Formats/InComingPaymnet.csv");
        }

        function CheckMain(chk) {

            if (chk == undefined) {
                if ($('.chkSelect').length == $('.chkSelect:checked').length)
                    $('.chkMain').prop('checked', true);
                else
                    $('.chkMain').prop('checked', false);
            }
            else {
                if ($(chk).is(':checked')) {
                    $('.chkSelect').prop('checked', true);
                }
                else {
                    $('.chkSelect').prop('checked', false);
                }
            }
        }

        function ChangePayMode(ddl) {

            var Container = $(ddl).parent().parent();

            Container.find('.txtDocName').val("");
            Container.find('.txtDocNo').val("");

            if ($(ddl).val() == "1") {
                Container.find('.txtDocName').prop('disabled', true);
                Container.find('.txtDocNo').prop('disabled', true);
            }
            else if ($(ddl).val() == "2") {
                Container.find('.txtDocName').prop('disabled', false);
                Container.find('.txtDocNo').prop('disabled', false);
            }
            else if ($(ddl).val() == "3") {
                Container.find('.txtDocName').prop('disabled', false);
                Container.find('.txtDocNo').prop('disabled', false);
            }
            else if ($(ddl).val() == "4") {
                Container.find('.txtDocName').prop('disabled', false);
                Container.find('.txtDocNo').prop('disabled', false);
            }
            else if ($(ddl).val() == "5") {
                Container.find('.txtDocName').prop('disabled', true);
                Container.find('.txtDocNo').prop('disabled', false);
            }
        }

        function HideShowDIV(ddl) {

            $('.gvVendor').find('tr').each(function () {
                $(this).find('.txtDocNo').val('');
                $(this).find('.txtDocName').val('');
                $(this).find('.ddlMode').prop('disabled', false);
                $(this).find('.ddlMode').val('1');
            });

            $('.txtBankName').val('');
            $('.txtDocumentNo').val('');
            $('.txtTotalAmount').val('');
            $('.ddlPayMode').val('1');

            var val = ddl.value;
            if (val == "1") {
                $("#divPayOption").hide();
            }
            else {
                $("#divPayOption").show();
                $('.txtBankName').prop('disabled', true);
                $('.txtDocumentNo').prop('disabled', true);
                $('.txtTotalAmount').focus();
                $('.txtTotalAmount').val('');

                $('.gvVendor').find('tr').each(function () {
                    $(this).find('.ddlMode').prop('disabled', true);
                    $(this).find('.txtDocNo').prop('disabled', true);
                    $(this).find('.txtDocName').prop('disabled', true);
                });

            }
        }

        function ChangePaymentMode(ddl) {

            $('.txtBankName').val('');
            $('.txtDocumentNo').val('');

            if (ddl.value == "1") {
                $('.txtBankName').prop('disabled', true);
                $('.txtDocumentNo').prop('disabled', true);
                $('.txtTotalAmount').focus();
            }
            else if (ddl.value == "2") {
                $('.txtBankName').prop('disabled', false);
                $('.txtDocumentNo').prop('disabled', false);
                $('.txtBankName').focus();
            }
            else if (ddl.value == "3") {
                $('.txtBankName').prop('disabled', false);
                $('.txtDocumentNo').prop('disabled', false);
                $('.txtBankName').focus();
            }
            else if (ddl.value == "4") {
                $('.txtBankName').prop('disabled', false);
                $('.txtDocumentNo').prop('disabled', false);
                $('.txtBankName').focus();
            }
            else if (ddl.value == "5") {
                $('.txtBankName').prop('disabled', true);
                $('.txtDocumentNo').prop('disabled', false);
                $('.txtDocumentNo').focus();
            }

            $('.gvVendor').find('tr').each(function () {
                $(this).find('.ddlMode').val($(ddl).val());
            });
        }

        function _btnCheck() {
            validateCheckBoxes();
            ValidateAmount();
            ValidateGridRowItems();

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();

            return IsValid;
        }

        function _btnCheck2() {

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();

            return IsValid;
        }

        function validateCheckBoxes() {

            var isValid = false;

            var gridView = document.getElementById('<%= gvVendor.ClientID %>');

            for (var i = 1; i < gridView.rows.length; i++) {

                var inputs = gridView.rows[i].getElementsByTagName('input');

                if (inputs != null) {
                    if (inputs[0].type == "checkbox") {
                        if (inputs[0].checked) {
                            isValid = true;
                            return true;
                        }
                    }
                }
            }

            ModelMsg(" Please select atleast one record", 3);
            event.preventDefault();
            return false;
        }

        function ValidateAmount() {
            var main = $('.gvVendor');
            var FooterContainer = $(main).find('.table-header-gradient');
            var totAmount = parseFloat(FooterContainer.find('.lblSubTotal').val());

            var ddl = $('.ddlPayOption').val();

            if (ddl == "2") {

                var selOpt = $('.ddlPayMode').val();
                var bnk = $('.txtBankName').val().trim();
                var doc = $('.txtDocumentNo').val().trim();

                if (selOpt == "2" || selOpt == "3" || selOpt == "4") {
                    if (bnk == "" || doc == "") {
                        ModelMsg("Please enter Bank Name & Document No.", 3);
                        event.preventDefault();
                        return false;
                    }
                }
                if (selOpt == "5") {
                    if (doc == "") {
                        ModelMsg("Please enter Document No.", 3);
                        event.preventDefault();
                        return false;
                    }
                }

                if ($('.txtTotalAmount').val().trim() != "") {
                    var genAmount = parseFloat($('.txtTotalAmount').val());
                    if (totAmount != genAmount) {
                        ModelMsg("Total Amount and GridView total must be equal.", 3);
                        event.preventDefault();
                        return false;
                    }
                }
                else {
                    ModelMsg("Please enter Amount.", 3);
                    $('.txtTotalAmount').focus();
                    event.preventDefault();
                    return false;
                }
            }
        }

        function ChangeQuantity(txt) {

            var main = $('.gvVendor');
            var AllRows = $(main).find('tbody').find('tr');
            if (txt != undefined) {

                var amt = $(txt).val();
                var pending = $(txt).parent().parent().find('.txtBalance').val();

                if (parseFloat(amt) > parseFloat(pending)) {
                    ModelMsg("Entered Amount is more than Pending Amount in Row", 3);
                    $(txt).val('');
                    ChangeQuantity(txt);
                    return false;
                }
            }
            var SubTotal = 0, TotalAmount = 0, TotalPending = 0;
            for (var i = 0; i < AllRows.length; i++) {


                $(AllRows[i]).find('.txtBalance').val(
                   Number(Number($(AllRows[i]).find('.lblTotalAmount').text()) - Number($(AllRows[i]).find('.txtAmount').val()) - Number($(AllRows[i]).find('.lblPaidAmount').text()) - Number($(AllRows[i]).find('.lblMasterCN').text())).toFixed(2));

                TotalAmount += Number($(AllRows[i]).find('.lblTotalAmount').text());
                SubTotal += Number($(AllRows[i]).find('.txtAmount').val());
                TotalPending += Number($(AllRows[i]).find('.txtBalance').val());

            }
            var FooterContainer = $(main).find('.table-header-gradient');
            FooterContainer.find('.lblTotBillAmount').text(TotalAmount.toFixed(2));
            FooterContainer.find('.lblSubTotal').val(SubTotal.toFixed(2));
            FooterContainer.find('.lblTotBalance').text(TotalPending.toFixed(2));
        }

        function ValidateGridRowItems() {
            var ddl = $('.ddlPayOption').val();

            if (ddl == "1") {

                var selOpt = "";
                var bnk = "";
                var doc = "";
                var cnt = 0;
                var amt = 0;
                var pending = 0;

                $('.gvVendor').find('tr').each(function () {
                    selOpt = $(this).find('.ddlMode').val();
                    doc = $(this).find('.txtDocNo').val();
                    bnk = $(this).find('.txtDocName').val();
                    amt = $(this).find('.txtAmount').val();
                    pending = $(this).find('.txtBalance').text();

                    if (cnt != 0) {
                        if ($(this).find('.chkSelect').is(':checked')) {
                            if (selOpt == "2" || selOpt == "3" || selOpt == "4") {
                                if (bnk == "" || doc == "") {
                                    ModelMsg("Please enter Bank Name & Document No. in Row = " + cnt, 3);
                                    event.preventDefault();
                                    return false;
                                }
                            }
                            if (selOpt == "5") {
                                if (doc == "") {
                                    ModelMsg("Please enter Document No. in Row = " + cnt, 3);
                                    event.preventDefault();
                                    return false;
                                }
                            }

                            if (amt == "") {
                                ModelMsg("Please enter Amount in Row = " + cnt, 3);
                                event.preventDefault();
                                return false;
                            }

                            if (parseFloat(amt) > parseFloat(pending)) {
                                ModelMsg("Entered Amount is more than Pending Amount in Row = " + cnt, 3);
                                event.preventDefault();
                                return false;
                            }
                        }
                    }
                    cnt++;
                });
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFdate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control" ClientIDMode="Static"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnSearch" CssClass="btn btn-default" runat="server" Text="Search Records" OnClientClick="return _btnCheck2();" OnClick="btnSearch_Click" />
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblTdate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtTodate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control" ClientIDMode="Static"></asp:TextBox>
                    </div>

                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Customer" ID="lblCustomer" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" TabIndex="4" ID="txtCustomer" CssClass="form-control txtCustomer" MaxLength="50" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACECustomer" runat="server" ServicePath="~/WebService.asmx" ContextKey="0"
                            UseContextKey="true" ServiceMethod="GetActiveCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustomer">
                        </asp:AutoCompleteExtender>
                    </div>

                </div>
            </div>

        </div>
    </div>
    <div class="row">
        <div class="col-lg-4">
            <div class="input-group form-group">
                <asp:Label ID="lblJENo" runat="server" Text="Doc Date" CssClass="input-group-addon"></asp:Label>
                <asp:TextBox ID="txtJEDate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control"></asp:TextBox>
            </div>
            <div class="input-group form-group">
                <asp:Label ID="lblCsv" Text="Outstanding Upload" CssClass="input-group-addon" runat="server"></asp:Label>
                <asp:FileUpload ID="flCSVUpload" runat="server" CssClass="form-control" />
            </div>
        </div>
        <div class="col-lg-4">
            <div class="input-group form-group">
                <asp:Label ID="lblPaymentType" runat="server" Text="Payment Type" CssClass="input-group-addon"></asp:Label>
                <asp:DropDownList runat="server" CssClass="ddlPayOption form-control" ID="ddlPayOption" onchange="HideShowDIV(this);">
                    <asp:ListItem Text="Individual" Value="1" />
                    <asp:ListItem Text="Bulk Payment" Value="2" />
                </asp:DropDownList>
            </div>
            <div class="input-group form-group">
                <asp:Button ID="btnUpload" runat="server" Text="Upload File" CssClass="btn btn-default" OnClientClick="CheckWareHouse();" OnClick="btnUpload_Click" />
                &nbsp; &nbsp; 
                <asp:Button ID="btnDownload" runat="server" Text="Download Format" CssClass="btn btn-default" OnClientClick="download(); return false;" />
            </div>
        </div>
        <div class="col-lg-4">
            <div class="input-group form-group">
                <asp:Label ID="lblNotes" runat="server" Text="Notes" CssClass="input-group-addon"></asp:Label>
                <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-1"></div>
        <div class="col-lg-10">
            <div id="divPayOption" style="display: none;">
                <div class="row">
                    <table class="table" border="1">
                        <tr class="table-header-gradient">
                            <th>Payment Mode</th>
                            <th>Bank Name</th>
                            <th>Document No.</th>
                            <th>Amount</th>
                        </tr>
                        <tr>
                            <td>
                                <asp:DropDownList runat="server" ID="ddlPayMode" DataValueField="Key" CssClass="ddlPayMode form-control" DataTextField="Value" onchange="ChangePaymentMode(this);">
                                </asp:DropDownList></td>
                            <td>
                                <asp:TextBox ID="txtBankName" runat="server" CssClass="txtBankName form-control"></asp:TextBox></td>
                            <td>
                                <asp:TextBox ID="txtDocumentNo" runat="server" CssClass="txtDocumentNo form-control"></asp:TextBox></td>
                            <td>
                                <asp:TextBox ID="txtTotalAmount" runat="server" CssClass="txtTotalAmount form-control" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;"></asp:TextBox></td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-lg-1"></div>
    </div>
    <div class="row">
        <asp:GridView runat="server" ID="gvVendor" CssClass="gvVendor HighLightRowColor2 table" ShowHeader="true" ShowFooter="true" AutoGenerateColumns="false"
            HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Record Found" OnRowDataBound="gvVendor_RowDataBound" OnPreRender="gvVendor_PreRender"
            FooterStyle-CssClass="table-header-gradient">
            <Columns>
                <asp:TemplateField HeaderText="Check">
                    <HeaderTemplate>
                        <input type="checkbox" name="chkMain" id="chkMain" class="chkMain" runat="server" onchange="CheckMain(this);" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <input type="checkbox" name="chkSelect" id="chkSelect" class="chkSelect" runat="server" onchange="CheckMain();" />
                    </ItemTemplate>
                    <HeaderStyle Width="3%" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Invoice No">
                    <ItemTemplate>
                        <asp:Label ID="lblBillNumber" runat="server" Text='<%# Eval("InvoiceNumber") %>'></asp:Label>
                    </ItemTemplate>
                    <HeaderStyle Width="8%" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Date">
                    <ItemTemplate>
                        <asp:Label ID="lblDate" runat="server" Text='<%# Eval("Date","{0:dd/MM/yyyy}") %>'></asp:Label>
                        <asp:Label ID="lblSaleID" runat="server" Text='<%# Eval("SaleID") %>' Visible="false"></asp:Label>
                    </ItemTemplate>
                    <HeaderStyle Width="7%" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Customer">
                    <ItemTemplate>
                        <asp:Label ID="lblCust" runat="server" Text='<%# Eval("CustomerName") %>'></asp:Label>
                    </ItemTemplate>
                    <HeaderStyle Width="20%" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Total">
                    <ItemTemplate>
                        <asp:Label ID="lblTotalAmount" CssClass="lblTotalAmount" runat="server" Text='<%# Eval("Total","{0:0.00}") %>'></asp:Label>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Label ID="lblTotBillAmount" CssClass="lblTotBillAmount" Enabled="false" runat="server"></asp:Label>
                    </FooterTemplate>
                    <HeaderStyle Width="8%" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Paid">
                    <ItemTemplate>
                        <asp:Label ID="lblPaidAmount" CssClass="lblPaidAmount" runat="server" Text='<%# Eval("Paid","{0:0.00}") %>'></asp:Label>
                    </ItemTemplate>
                    <HeaderStyle Width="8%" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Master CN">
                    <ItemTemplate>
                        <asp:Label ID="lblMasterCN" CssClass="lblMasterCN" runat="server" Text='<%# Eval("MasterCN","{0:0.00}") %>'></asp:Label>
                        <input type="hidden" runat="server" id="hdnCreditNoteID" value='<%# Eval("CreditNoteID") %>' />
                    </ItemTemplate>
                    <HeaderStyle Width="8%" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Type">
                    <ItemTemplate>
                        <asp:DropDownList runat="server" ID="ddlMode" DataValueField="Key" CssClass="ddlMode form-control" DataTextField="Value" onchange="ChangePayMode(this);">
                        </asp:DropDownList>
                    </ItemTemplate>
                    <HeaderStyle Width="10%" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Doc Name">
                    <ItemTemplate>
                        <asp:TextBox ID="txtDocName" runat="server" CssClass="txtDocName form-control" Enabled="false"></asp:TextBox>
                    </ItemTemplate>
                    <HeaderStyle Width="10%" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Doc No">
                    <ItemTemplate>
                        <asp:TextBox ID="txtDocNo" runat="server" CssClass="txtDocNo form-control" onkeypress="return isNumberKeyWithStar(event);" onpaste="return false;" Enabled="false" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceCreditNote" runat="server" ServicePath="../WebService.asmx"
                            ServiceMethod="GetCreditNoteNo" MinimumPrefixLength="1" CompletionInterval="10" ContextKey='<%# Eval("CustomerID") %>'
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDocNo" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </ItemTemplate>
                    <HeaderStyle Width="10%" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Amount">
                    <ItemTemplate>
                        <asp:TextBox ID="txtAmount" runat="server" onchange="ChangeQuantity(this);" CssClass="txtAmount form-control" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:TextBox ID="lblSubTotal" CssClass="lblSubTotal form-control" Enabled="false" runat="server" Text="0"></asp:TextBox>
                    </FooterTemplate>
                    <HeaderStyle Width="8%" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Pending">
                    <ItemTemplate>
                        <asp:TextBox ID="txtBalance" Enabled="false" runat="server" CssClass="txtBalance form-control" Text='<%# Eval("Pending","{0:0.00}") %>' onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Label ID="lblTotBalance" CssClass="lblTotBalance" Enabled="false" runat="server"></asp:Label>
                    </FooterTemplate>
                    <HeaderStyle Width="8%" />
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
    <div class="row">
        <div id="divMissData" class="col-lg-12" runat="server">
            <div style="overflow-x: auto">
                <asp:GridView ID="gvMissdata" runat="server" CssClass="table table-bordered table-responsive" AutoGenerateColumns="true">
                </asp:GridView>
            </div>
        </div>
    </div>
    <asp:Button ID="btnSubmit" CssClass="btn btn-default" runat="server" Text="Submit" OnClientClick="_btnCheck()" OnClick="btnSubmit_Click" />
    <asp:Button ID="btnCancel" CssClass="btn btn-default" CausesValidation="false" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
</asp:Content>

