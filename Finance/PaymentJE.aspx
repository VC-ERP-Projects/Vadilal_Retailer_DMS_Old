<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PaymentJE.aspx.cs" Inherits="Finance_PaymentJE" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">


        function ClearPr(txt) {
            var main = $('.gvVendor');
            var AllRows = $(main).find('tbody').find('tr');

            for (var i = 0; i < AllRows.length; i++) {
                $(AllRows[i]).find('[id *= ' + txt + ']').val('');
            }
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

        function ChangeQuantity(txt) {

            var main = $('.gvVendor');
            var AllRows = $(main).find('tbody').find('tr');
            if (txt != undefined) {

                var amt = $(txt).val();
                var pending = $(txt).parent().parent().find('.txtBalance').val();

                if (parseFloat(amt) > parseFloat(pending)) {
                    ModelMsg("Entered Amount is more than Pending Amount in Row", 3);
                    $(txt).val('');
                    return false;
                }
            }
            var SubTotal = 0, TotalPending = 0;
            for (var i = 0; i < AllRows.length; i++) {


                $(AllRows[i]).find('.txtBalance').val(Number($(AllRows[i]).find('.lblTotalAmount').val()) - Number($(AllRows[i]).find('.lblPaidAmount').val())
                    - Number($(AllRows[i]).find('.txtAmount').val()));

                SubTotal += Number($(AllRows[i]).find('.txtAmount').val());
                TotalPending += Number($(AllRows[i]).find('.txtBalance').val());



            }
            var FooterContainer = $(main).find('.table-header-gradient');
            FooterContainer.find('.lblSubTotal').val(SubTotal.toFixed(2));
            FooterContainer.find('.lblTotBalance').text(TotalPending.toFixed(2));

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
            var ddlVen = $('.ddlVendor').val();
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
                if (ddlVen == "0") {
                    ModelMsg(" Please select any Vendor first.", 3);
                    ddl.value = "1";
                    event.preventDefault();
                    return false;
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
                    pending = $(this).find('.txtBalance').val();

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
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="row _masterForm">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblFdate" runat="server" Text="Inv From Date" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtFromDate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblTdate" runat="server" Text="Inv To Date" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtTodate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Vendor" ID="lblVendor" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox runat="server" TabIndex="4" ID="txtVendor" CssClass="form-control txtVendor" MaxLength="50" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEVendor" runat="server" ServicePath="~/WebService.asmx" ContextKey="0"
                                    UseContextKey="true" ServiceMethod="GetActiveVendor" MinimumPrefixLength="1" CompletionInterval="10"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtVendor">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                    </div>

                    <asp:Button ID="btnSearch" CssClass="btn btn-default" runat="server" Text="Search Records" OnClientClick="_btnCheck2();" OnClick="btnSearch_Click" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblJENo" runat="server" Text="JE No. - Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtJEDate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control"></asp:TextBox>
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
                </div>
                <div class="col-lg-4 _textArea">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNotes" runat="server" Text="Notes" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
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
        </div>
    </div>

    <asp:GridView runat="server" ID="gvVendor" CssClass="gvVendor HighLightRowColor2 table" ShowHeader="true" ShowFooter="true" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Record Found" OnRowDataBound="gvVendor_RowDataBound" OnPreRender="gvVendor_PreRender" FooterStyle-CssClass="table-header-gradient">
        <Columns>

            <asp:TemplateField HeaderText="Check" ItemStyle-Width="10%">
                <HeaderTemplate>
                    <input type="checkbox" name="chkMain" id="chkMain" class="chkMain" runat="server" onchange="CheckMain(this);" />
                </HeaderTemplate>
                <ItemTemplate>
                    <input type="checkbox" name="chkSelect" id="chkSelect" class="chkSelect" runat="server" onchange="CheckMain();" />
                </ItemTemplate>
                <ItemStyle Width="8%" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Date">
                <ItemTemplate>
                    <asp:Label ID="lblDate" runat="server" Text='<%# Eval("InvocieDate","{0:dd/MM/yyyy}") %>'></asp:Label>
                    <asp:Label ID="lblInwardID" runat="server" Text='<%# Eval("InwardID") %>' Visible="false"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
             <asp:TemplateField HeaderText="Vendor" Visible="false">
                <ItemTemplate>
                    <asp:Label ID="lblVName" runat="server" Text=""></asp:Label>
                    <asp:Label ID="lblVendorID" runat="server" Text='<%# Eval("VendorID") %>' Visible="false"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Invoice Number">
                <ItemTemplate>
                    <asp:Label ID="lblBillNumber" runat="server" Text='<%# Eval("BillNumber") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
             <asp:TemplateField HeaderText="GST Inv Number">
                <ItemTemplate>
                    <asp:Label ID="lblGSTINVNo" runat="server" Text='<%# Eval("GSTInvNo") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Bill Amount">
                <ItemTemplate>
                    <asp:TextBox ID="lblTotalAmount" CssClass="lblTotalAmount form-control" runat="server" Text='<%# Eval("Total","{0:0.00}") %>' Enabled="false"></asp:TextBox>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:TextBox ID="lblTotBillAmount" CssClass="lblTotBillAmount form-control" Enabled="false" runat="server"></asp:TextBox>
                </FooterTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Paid Amount">
                <ItemTemplate>
                    <asp:TextBox ID="lblPaidAmount" CssClass="lblPaidAmount form-control" runat="server" Text='<%# Eval("Paid","{0:0.00}") %>' Enabled="false"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Type">
                <ItemTemplate>
                    <asp:DropDownList runat="server" ID="ddlMode" DataValueField="Key" CssClass="ddlMode form-control" DataTextField="Value" onchange="ChangePayMode(this);">
                    </asp:DropDownList>
                </ItemTemplate>
                <ItemStyle Width="15%" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Bank Name">
                <ItemTemplate>
                    <asp:TextBox ID="txtDocName" runat="server" CssClass="txtDocName form-control" Enabled="false"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Document No">
                <ItemTemplate>
                    <asp:TextBox ID="txtDocNo" runat="server" CssClass="txtDocNo form-control" onkeypress="return isNumberKeyWithStar(event);" onpaste="return false;" Enabled="false" />
                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceCreditNote" runat="server" ServicePath="../WebService.asmx"
                        ServiceMethod="GetCreditNoteNo" MinimumPrefixLength="1" CompletionInterval="10"
                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDocNo" UseContextKey="True">
                    </asp:AutoCompleteExtender>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Amount">
                <ItemTemplate>
                    <asp:TextBox ID="txtAmount" runat="server" onchange="ChangeQuantity(this);" CssClass="txtAmount form-control" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                </ItemTemplate>
                <FooterTemplate>
                    <asp:TextBox ID="lblSubTotal" CssClass="lblSubTotal form-control" Enabled="false" runat="server" Text="0"></asp:TextBox>
                </FooterTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Pending">
                <ItemTemplate>
                    <asp:TextBox ID="txtBalance" Enabled="false" runat="server" CssClass="txtBalance form-control" Text='<%# Eval("Pending","{0:0.00}") %>' onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblTotBalance" CssClass="lblTotBalance" Enabled="false" runat="server"></asp:Label>
                </FooterTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <asp:Button ID="btnSubmit" CssClass="btn btn-default" runat="server" Text="Submit" OnClientClick="_btnCheck()" OnClick="btnSubmit_Click" />
    <asp:Button ID="btnCancel" CssClass="btn btn-default" CausesValidation="false" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
</asp:Content>

