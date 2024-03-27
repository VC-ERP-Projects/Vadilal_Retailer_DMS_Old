<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="Receipt.aspx.cs" Inherits="Purchase_Receipt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script type="text/javascript">

        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();

            if (IsValid && Number($('.txtTTotalQty').val()) <= 0) {
                ModelMsg('Select at least one quantity.', 3);
                IsValid = false;
            }
            return IsValid;
        }

        function ChangeQuantity(txt) {

            var EnterQty = 0;
            if (txt != undefined) {
                var Container = $(txt).parent().parent();
                var Data = new Array();

                if (Container.find('.lblUnitID').text() != null)
                    Data = Container.find('.lblUnitID').text().split(',');

                if ($(txt).val() == "" || isNaN(parseInt($(txt).val()))) {
                    $(txt).val("0"); EnterQty = 0;
                }
                else
                    EnterQty = $(txt).val();

                if (Data.length == 4) {
                    //Container.find('.lblPrice').val(Number(Data[1]).toFixed(2));
                    Container.find('.lblSubTotal').val((Number(Container.find('.hdnPrice').val()) * EnterQty).toFixed(2));
                    Container.find('.lblTax').val((EnterQty * Number(Data[2])).toFixed(2));
                    Container.find('.lblTotalPrice').val((Number(Container.find('.lblSubTotal').val()) + Number(Container.find('.lblTax').val())).toFixed(2));
                }
            }

            var main = $('.gvItem');
            var AllRows = $(main).find('tbody').find('tr');
            var AvailQty = 0, RequestQty = 0, DisptchQty = 0, Gross = 0, Discount = 0, RecieptQty = 0, DiffirenceQty = 0, TotalQty = 0, SubTotal = 0, Tax = 0, TotalPrice = 0;
            for (var i = 0; i < AllRows.length; i++) {

                if (txt == undefined) {

                    var Data = new Array();

                    EnterQty = $(AllRows[i]).find('.txtRecieptQty').val();
                    $(AllRows[i]).find('.txtRecieptQty').val(EnterQty);

                    if ($(AllRows[i]).find('.lblUnitID').text() != null)
                        Data = $(AllRows[i]).find('.lblUnitID').text().split(',');

                    if (Data.length == 4) {
                        //$(AllRows[i]).find('.lblPrice').val(Number(Data[1]).toFixed(2));
                        $(AllRows[i]).find('.lblSubTotal').val((Number($(AllRows[i]).find('.hdnPrice').val()) * EnterQty).toFixed(2));
                        $(AllRows[i]).find('.lblTax').val((EnterQty * Number(Data[2])).toFixed(2));
                        $(AllRows[i]).find('.lblTotalPrice').val((Number($(AllRows[i]).find('.lblSubTotal').val()) + Number($(AllRows[i]).find('.lblTax').val())).toFixed(2));
                    }
                }
                RequestQty += Number($(AllRows[i]).find('.txtRequestQty').val());
                RecieptQty += Number($(AllRows[i]).find('.txtRecieptQty').val());
                Gross += Number($(AllRows[i]).find('.txtGross').val());
                Discount += Number($(AllRows[i]).find('.lblDiscount').val());
                SubTotal += Number($(AllRows[i]).find('.lblSubTotal').val());
                Tax += Number($(AllRows[i]).find('.lblTax').val());
                TotalPrice += Number($(AllRows[i]).find('.lblTotalPrice').val());
            }
            var FooterContainer = $(main).find('.table-header-gradient');

            FooterContainer.find('.txtTAvailQty').val(AvailQty);
            FooterContainer.find('.txtTRequestQty').val(RequestQty);
            FooterContainer.find('.txtTRecieptQty').val(RecieptQty);
            FooterContainer.find('.txtTGross').val(Gross.toFixed(2));
            FooterContainer.find('.lblTDiscount').val(Discount.toFixed(2));
            FooterContainer.find('.lblTSubTotal').val(SubTotal.toFixed(2));
            FooterContainer.find('.lblTTax').val(Tax.toFixed(2));
            FooterContainer.find('.lblTPrice').val(TotalPrice.toFixed(2));

            isNaN(SubTotal) ? SubTotal = 0 : 0;
            isNaN(Tax) ? Tax = 0 : 0;
            isNaN(Discount) ? Discount = 0 : 0;
            isNaN(TotalPrice) ? TotalPrice = 0 : 0;

            $('.txtBillAmount').val(SubTotal.toFixed(2));
            $('.txtTax').val(Tax.toFixed(2));
            $('.txtDiscount').val(Discount.toFixed(2));
            $('.txtTotal').val(TotalPrice.toFixed(2));

            summary();
        }

        function summary() {

            var Total = Number($('.lblTSubTotal').val()) + Number($('.lblTTax').val());

            $('.txtRounding').val(Number(Math.round(Total) - Total).toFixed(2));

            $('.txtTotal').val(Number(Total + Number($('.txtRounding').val())).toFixed(2));

            $('.txtPending').val(Number(Number($('.txtTotal').val()) - Number($('.txtPaid').val())).toFixed(2));
        }
        function twidth() {
            $('.tdiv').css('max-height', (innerHeight - 369) + "px");
        }
        window.onresize = twidth;

        function Relaod() {
            $(".gvItem").tableHeadFixer('49vh');

            if (innerWidth > 1360) {
                $(".gvItem").css('width', '100%');
                $(".gvItem").css('max-width', '100%');
            } else {
                if ($(".gvItem > tbody tr:first td").text() != 'No Item Found.') {
                    $(".gvItem").css('width', '140%');
                    $(".gvItem").css('max-width', '140%');
                }
            }

            //twidth();
            $(".txtSearch").keyup(function () {
                var word = this.value;
                $(".gvItem > tbody tr").each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();
                });
            });
        }

    </script>
    <style>
        .lblPrice, .txtRequestQty, .txtRecieptQty, .txtGross, .lblDiscount, .lblSubTotal, .lblTax, .lblTotalPrice, .txtTRequestQty, .txtTRecieptQty, .txtTGross, .lblTDiscount, .lblTSubTotal, .lblTTax, .lblTPrice {
            height: 21px;
            padding: 6px 5px;
            font-size: 12px;
            text-align: right;
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            padding: 4px;
            font-size: 11px;
        }

        .lblRight {
            text-align: right;
        }

        .table {
            margin-bottom: 0;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Invoice No" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" TabIndex="3" ID="txtDocNo" OnTextChanged="txtDocNo_TextChanged" AutoPostBack="true" CssClass="form-control" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDocNumber" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetReceiptInwardNo" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDocNo">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Invoice Date" ID="lblInvoiceDate" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtInvoiceDate" TabIndex="9" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblDivision" Text="Division" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" TabIndex="4" ID="txtDivision" CssClass="form-control" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-4" style="display: none;">
                    <div class="input-group form-group">
                        <asp:Label Text="Invoice No" ID="lblBillNumber" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" TabIndex="4" ID="txtBillNumber" CssClass="form-control" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Indent No" ID="lblIndentNo" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" TabIndex="4" ID="txtIndentNo" CssClass="form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group" style="display: none">
                        <asp:Label Text="Indent Date" ID="lblIndentDate" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtIndentDate" TabIndex="9" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Receipt Date" ID="lblReceiptDate" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtReceiptDate" TabIndex="9" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="PO No" ID="lblPONo" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" TabIndex="4" ID="txtPONo" CssClass="form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="PO Date" ID="lblPODate" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtPODate" TabIndex="9" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-4" style="display: none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lblwarehouse" Text="Warehouse" CssClass="input-group-addon" runat="server"></asp:Label>
                        <asp:DropDownList runat="server" TabIndex="5" ID="ddlWhs" DataValueField="WhsID" DataTextField="WhsName" CssClass="form-control">
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-8">
                    <asp:Button Text="Submit" CssClass="btn btn-default" runat="server" TabIndex="20" ID="btnSubmit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
                    <asp:Button Text="Cancel" ID="btnCancel" CssClass="btn btn-default" TabIndex="21" OnClick="btnCancel_Click" runat="server" UseSubmitBehavior="false" CausesValidation="false" />
                </div>
                <div class="col-lg-4">
                    <asp:TextBox runat="server" placeholder="Search here" TabIndex="7" CssClass="txtSearch form-control" />
                </div>
            </div>
            <div style="overflow-x: auto; overflow-y: auto; margin-top: 1%;" class="tdiv">
                <asp:GridView runat="server" ID="gvItem" CssClass="gvItem HighLightRowColor2 table tbl" ShowFooter="true" Style="font-size: 12px;" ShowHeader="true" AutoGenerateColumns="false" OnPreRender="gvItems_PreRender" OnRowDataBound="gvItem_RowDataBound" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                    <Columns>
                        <asp:TemplateField HeaderText="Sr." HeaderStyle-Width="3px" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <%#Container.DataItemIndex+1 %>
                            </ItemTemplate>
                            <HeaderStyle Width="2%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Item Code">
                            <ItemTemplate>
                                <asp:Label ID="txtItemCd" runat="server" Text='<%# Eval("ItemCode") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="8%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Item Name">
                            <ItemTemplate>
                                <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex %>' Style="display: none;"></asp:Label>
                                <asp:Label ID="lblItemID" runat="server" Text='<%# Eval("ItemID") %>' Style="display: none;"></asp:Label>
                                <asp:Label ID="txtItemCode" runat="server" Text='<%# Eval("ItemName") %>'></asp:Label>
                                <asp:Label ID="lblTaxID" runat="server" Text='<%# Eval("TaxID") %>' Style="display: none;"></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="20%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Unit">
                            <ItemTemplate>
                                <asp:Label ID="lblUnitID" CssClass="lblUnitID" runat="server" Style="display: none;" />
                                <asp:Label Text='<%# Eval("UnitName") %>' ID="lblUnit" runat="server" />
                            </ItemTemplate>
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Rate" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:TextBox ID="lblPrice" CssClass="lblPrice form-control" Enabled="false" runat="server" Text='<%# Eval("UnitPrice","{0:0.00}") %>'></asp:TextBox>
                                <input type="hidden" id="hdnAvailQty" class="hdnAvailQty" runat="server" value='<%# Eval("AvailQty","{0:0.00}") %>' />
                                <input type="hidden" id="hdnPrice" class="hdnPrice" runat="server" value='<%# Eval("Price","{0:0.00}") %>' />
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:Label runat="server" Text="Total" />
                            </FooterTemplate>
                            <FooterStyle CssClass="lblRight" />
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="PO Qty" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:TextBox ID="txtRequestQty" CssClass="txtRequestQty form-control" Enabled="false" runat="server" Text='<%# Eval("OrderQuantity","{0:0}") %>' onchange="ChangeQuantity(this);" onkeyup="enter(this);" onkeypress="return isNumberKey(event);" onpaste="return false;" data-bv-stringlength="false" MaxLength="12" onBlur="ResetColor()" onFocus="ChangeColor()" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="txtTRequestQty" CssClass="txtTRequestQty form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="5%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Receipt Qty" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:TextBox ID="txtRecieptQty" CssClass="txtRecieptQty form-control" runat="server" Enabled="false" Text='<%# Eval("Quantity","{0:0}") %>' onchange="ChangeQuantity(this);" onkeyup="enter(this);" onkeypress="return isNumberKey(event);" onpaste="return false;" data-bv-stringlength="false" MaxLength="12" onBlur="ResetColor()" onFocus="ChangeColor()" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="txtTRecieptQty" CssClass="txtTRecieptQty form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="5%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Gross Amt" HeaderStyle-CssClass="lblRight">
                            <ItemTemplate>
                                <asp:TextBox ID="txtGross" CssClass="txtGross form-control" runat="server" Enabled="false" Text='<%# (Convert.ToDecimal(Eval("UnitPrice")) * Convert.ToDecimal(Eval("Quantity"))).ToString("0.00") %>' onchange="ChangeQuantity(this);" onkeyup="enter(this);" onkeypress="return isNumberKey(event);" onpaste="return false;" data-bv-stringlength="false" MaxLength="12" onBlur="ResetColor()" onFocus="ChangeColor()" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="txtTGross" CssClass="txtTGross form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Discount" HeaderStyle-CssClass="lblRight">
                            <ItemTemplate>
                                <asp:TextBox ID="lblDiscount" CssClass="lblDiscount form-control" Enabled="false" runat="server" Text='<%# Eval("Discount","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="lblTDiscount" CssClass="lblTDiscount form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="SubTotal" HeaderStyle-CssClass="lblRight">
                            <ItemTemplate>
                                <asp:TextBox ID="lblSubTotal" CssClass="lblSubTotal form-control" Enabled="false" runat="server" Text='<%# Eval("SubTotal","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="lblTSubTotal" CssClass="lblTSubTotal form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="GST" HeaderStyle-CssClass="lblRight">
                            <ItemTemplate>
                                <asp:TextBox ID="lblTax" CssClass="lblTax form-control" runat="server" Enabled="false" Text='<%# Eval("Tax","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="lblTTax" CssClass="lblTTax form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Net Amount" HeaderStyle-CssClass="lblRight">
                            <ItemTemplate>
                                <asp:TextBox ID="lblTotalPrice" CssClass="lblTotalPrice form-control" Enabled="false" runat="server" Text='<%# Eval("Total","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="lblTPrice" CssClass="lblTPrice form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="6%" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
            <div class="row">
                <div class="col-lg-4" style="display: none;">
                    <div class="input-group form-group" style="display: none">
                        <asp:Label Text="Inward Date" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtDate" TabIndex="8" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label Text="Bill Date" ID="lblBillDate" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtBillDate" TabIndex="9" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label Text="Receive Date" ID="lblReceiveDate" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtReceiveDate" TabIndex="10" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" />
                    </div>
                    <div class="input-group form-group" style="display: none">
                        <asp:Label Text="Paid To" ID="lblPaidTo" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtPaidTo" TabIndex="11" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4" style="display: none;">
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label Text="Discount" ID="lblDiscount" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtDiscount" TabIndex="16" CssClass="txtDiscount form-control" Enabled="false" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" onchange="summary();" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label Text="Bill Amount" ID="lblBillAmount" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtBillAmount" TabIndex="12" CssClass="txtBillAmount form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label Text="Tax" ID="lblTax" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtTax" TabIndex="13" CssClass="txtTax form-control" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-8 _textArea">
                    <div class="input-group form-group">
                        <asp:Label Text="Notes" ID="lblNotes" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtNotes" TabIndex="19" TextMode="MultiLine" CssClass="form-control" Style="resize: none;" />
                    </div>
                </div>
                  <div class="col-lg-1">
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label Text="Rounding" ID="lblRounding" CssClass="input-group-addon lblRight" runat="server" />
                        <asp:TextBox runat="server" ID="txtRounding" TabIndex="14" CssClass="txtRounding form-control lblRight" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" onchange="summary();" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Net Amount" ID="lblTotal" runat="server" CssClass="input-group-addon lblRight" />
                        <asp:TextBox runat="server" ID="txtTotal" TabIndex="15" CssClass="txtTotal form-control lblRight" Enabled="false" />
                    </div>
                    <div class="input-group form-group" style="display: none">
                        <asp:Label Text="Paid" ID="lblPaid" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtPaid" TabIndex="17" CssClass="txtPaid form-control" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" onchange="summary();" />
                    </div>
                    <div class="input-group form-group" style="display: none">
                        <asp:Label Text="Pending" ID="lblPending" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtPending" TabIndex="18" CssClass="txtPending form-control" Enabled="false" />
                    </div>
                </div>
            </div>

        </div>
    </div>
</asp:Content>

