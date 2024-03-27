<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="POConfirm.aspx.cs" Inherits="Purchase_POConfirm" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">

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

            var Request = 0;

            if (txt != undefined) {
                var Container = $(txt).parent().parent();
                var Data = new Array();

                if ($(txt).val() == "" || isNaN(parseInt($(txt).val()))) {
                    $(txt).val("0"); Request = 0;
                }
                else {

                    Request = $(txt).val();
                }

                if (Container.find('.lblUnitID').text() != null)
                    Data = Container.find('.lblUnitID').text().split(',');

                if (Data.length == 4) {
                    Container.find('.lblPrice').val(Number(Data[1]).toFixed(2));
                    Container.find('.txtTotalQty').val(Request * Number(Data[3]));
                    Container.find('.lblSubTotal').val((Number(Container.find('.lblPrice').val()) * Request).toFixed(2));
                    Container.find('.lblTax').val((Request * Number(Data[2])).toFixed(2));
                    Container.find('.lblTotalPrice').val((Number(Container.find('.lblSubTotal').val()) + Number(Container.find('.lblTax').val())).toFixed(2));
                }
            }

            var main = $('.gvItem');
            var AllRows = $(main).find('tbody').find('tr');
            var AvailQty = 0, RequestQty = 0, TotalQty = 0, SubTotal = 0, Tax = 0, TotalPrice = 0;
            for (var i = 0; i < AllRows.length; i++) {

                if (txt == undefined) {

                    var Data = new Array();
                    Request = $(AllRows[i]).find('.txtRequestQty').val()

                    if ($(AllRows[i]).find('.lblUnitID').text() != null)
                        Data = $(AllRows[i]).find('.lblUnitID').text().split(',');


                    if (Data.length == 4) {
                        $(AllRows[i]).find('.lblPrice').val(Number(Data[1]).toFixed(2));
                        $(AllRows[i]).find('.txtTotalQty').val(Request * Number(Data[3]));
                        $(AllRows[i]).find('.lblSubTotal').val((Number($(AllRows[i]).find('.lblPrice').val()) * Request).toFixed(2));
                        $(AllRows[i]).find('.lblTax').val((Request * Number(Data[2])).toFixed(2));
                        $(AllRows[i]).find('.lblTotalPrice').val((Number($(AllRows[i]).find('.lblSubTotal').val()) + Number($(AllRows[i]).find('.lblTax').val())).toFixed(2));
                    }
                }
                AvailQty += Number($(AllRows[i]).find('.txtAvailQty').val());
                RequestQty += Number($(AllRows[i]).find('.txtRequestQty').val());
                TotalQty += Number($(AllRows[i]).find('.txtTotalQty').val());
                SubTotal += Number($(AllRows[i]).find('.lblSubTotal').val());
                Tax += Number($(AllRows[i]).find('.lblTax').val());
                TotalPrice += Number($(AllRows[i]).find('.lblTotalPrice').val());
            }
            var FooterContainer = $(main).find('.table-header-gradient');

            FooterContainer.find('.txtTAvailQty').val(AvailQty);
            FooterContainer.find('.txtTRequestQty').val(RequestQty);
            FooterContainer.find('.txtTTotalQty').val(TotalQty);
            FooterContainer.find('.lblTSubTotal').val(SubTotal.toFixed(2));
            FooterContainer.find('.lblTTax').val(Tax.toFixed(2));
            FooterContainer.find('.lblTPrice').val(TotalPrice.toFixed(2));

            isNaN(SubTotal) ? SubTotal = 0 : 0;
            isNaN(Tax) ? Tax = 0 : 0;
            isNaN(TotalPrice) ? TotalPrice = 0 : 0;

            $('.txtBillAmount').val(SubTotal.toFixed(2));
            $('.txtTax').val(Tax.toFixed(2));
            $('.txtTotal').val(TotalPrice.toFixed(2));

            summary();
        }

        function summary() {
            $('.txtTotal').val(Number(Number($('.txtBillAmount').val()) - Number($('.txtDiscount').val()) + Number($('.txtTax').val())).toFixed(2));
            $('.txtRounding').val(Number(($('.txtTotal').val()) - Math.round(Number($('.txtTotal').val()))).toFixed(2));

            $('.txtTotal').val(Number(Number($('.txtTotal').val()) - Number($('.txtRounding').val())).toFixed(2));
            $('.txtPending').val(Number(Number($('.txtTotal').val()) - Number($('.txtPaid').val())).toFixed(2));
        }
        function twidth() {
            $('.tdiv').css('max-height', (innerHeight - 100) + "px");
        }
        window.onresize = twidth;

        function Relaod() {
            if (innerWidth > 1360) {
                $(".gvItem").css('width', '100%');
                $(".gvItem").css('max-width', '100%');
            } else {
                if ($(".gvItem > tbody tr:first td").text() != 'No Item Found.') {
                    $(".gvItem").css('width', '140%');
                    $(".gvItem").css('max-width', '140%');
                }
            }


            twidth();
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

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Distributor" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox ID="txtdealer" runat="server" TabIndex="11" CssClass="form-control" autocomplete="off" OnTextChanged="ddlVendor_SelectedIndexChanged" AutoPostBack="true"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtdealer" runat="server" ServicePath="~/WebService.asmx" UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtdealer"></asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Document No" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" TabIndex="3" ID="txtDocNo" OnTextChanged="txtDocNo_TextChanged" AutoPostBack="true" CssClass="form-control" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDocNumber" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetInwardNo" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDocNo">
                        </asp:AutoCompleteExtender>
                    </div>

                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Inward Date" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtDate" TabIndex="7" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" />
                    </div>
                </div>
            </div>
            <asp:TextBox runat="server" placeholder="Search here" TabIndex="6" CssClass="txtSearch form-control" />
            <div style="overflow-x: auto; overflow-y: auto" class="tdiv">
                <asp:GridView runat="server" ID="gvItem" CssClass="gvItem HighLightRowColor2 table tbl" ShowFooter="true" ShowHeader="true" AutoGenerateColumns="false" OnPreRender="gvItems_PreRender" OnRowDataBound="gvItem_RowDataBound" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                    <Columns>
                        <asp:TemplateField HeaderText="Item Code">
                            <ItemTemplate>
                                <asp:Label ID="txtItemCd" runat="server" Text='<%# Eval("OITM.ItemCode") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="10%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Item Name">
                            <ItemTemplate>
                                <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex %>' Style="display: none;"></asp:Label>
                                <asp:Label ID="lblItemID" runat="server" Text='<%# Eval("ItemID") %>' Style="display: none;"></asp:Label>
                                <asp:Label ID="txtItemCode" runat="server" Text='<%# Eval("OITM.ItemName") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="20%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Unit">
                            <ItemTemplate>
                                <asp:Label ID="lblUnitID" CssClass="lblUnitID" runat="server" Style="display: none;" />
                                <asp:Label Text='<%# Eval("OUNT.UnitName") %>' ID="lblUnit" runat="server" />
                            </ItemTemplate>
                            <HeaderStyle Width="15%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Price">
                            <ItemTemplate>
                                <asp:TextBox ID="lblPrice" CssClass="lblPrice form-control" Enabled="false" runat="server" Text='<%# Eval("Price","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <HeaderStyle Width="13%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Available">
                            <ItemTemplate>
                                <asp:TextBox ID="txtAvailQty" CssClass="txtAvailQty form-control" Enabled="false" runat="server" Text='<%# Eval("AvailableQty","{0:0}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="txtTAvailQty" CssClass="txtTAvailQty form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="13%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Request">
                            <ItemTemplate>
                                <asp:TextBox ID="txtRequestQty" CssClass="txtRequestQty form-control" runat="server" Text='<%# Eval("RequestQty","{0:0}") %>' onchange="ChangeQuantity(this);" onkeyup="enter(this);" onkeypress="return isNumberKey(event);" onpaste="return false;" data-bv-stringlength="false" MaxLength="12" onBlur="ResetColor()" onFocus="ChangeColor()" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="txtTRequestQty" CssClass="txtTRequestQty form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="13%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Total Qty">
                            <ItemTemplate>
                                <asp:TextBox ID="txtTotalQty" CssClass="txtTotalQty form-control" Enabled="false" runat="server" Text='<%# Eval("TotalQty") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="txtTTotalQty" CssClass="txtTTotalQty form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="13%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="SubTotal">
                            <ItemTemplate>
                                <asp:TextBox ID="lblSubTotal" CssClass="lblSubTotal form-control" Enabled="false" runat="server" Text='<%# Eval("SubTotal","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="lblTSubTotal" CssClass="lblTSubTotal form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="17%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Tax">
                            <ItemTemplate>
                                <asp:TextBox ID="lblTax" CssClass="lblTax form-control" runat="server" Enabled="false" Text='<%# Eval("Tax","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="lblTTax" CssClass="lblTTax form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="17%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Total Price">
                            <ItemTemplate>
                                <asp:TextBox ID="lblTotalPrice" CssClass="lblTotalPrice form-control" Enabled="false" runat="server" Text='<%# Eval("Total","{0:0.00}") %>'></asp:TextBox>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:TextBox ID="lblTPrice" CssClass="lblTPrice form-control" Enabled="false" runat="server"></asp:TextBox>
                            </FooterTemplate>
                            <HeaderStyle Width="18%" />
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>
            </div>
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Invoice Number" ID="lblBillNumber" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" TabIndex="4" ID="txtBillNumber" CssClass="form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Sub Total" ID="lblBillAmount" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" TabIndex="11" ID="txtBillAmount" CssClass="txtBillAmount form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Tax" ID="lblTax" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtTax" TabIndex="12" CssClass="txtTax form-control" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Total" ID="lblTotal" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtTotal" TabIndex="14" CssClass="txtTotal form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Rounding" ID="lblRounding" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtRounding" TabIndex="13" CssClass="txtRounding form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Discount" ID="lblDiscount" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtDiscount" TabIndex="15" CssClass="txtDiscount form-control" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" onchange="summary();" />
                    </div>

                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Paid" ID="lblPaid" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtPaid" TabIndex="16" CssClass="txtPaid form-control" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" onchange="summary();" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Pending" ID="lblPending" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtPending" TabIndex="17" CssClass="txtPending form-control" Enabled="false" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Paid To" ID="lblPaidTo" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtPaidTo" TabIndex="10" CssClass="form-control" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12 _textArea">
                    <div class="input-group form-group">
                        <asp:Label Text="Notes" ID="lblNotes" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtNotes" TabIndex="18" TextMode="MultiLine" CssClass="form-control" Style="resize: none;" />
                    </div>
                </div>
            </div>
            <br />
            <asp:Button Text="Submit" CssClass="btn btn-default" runat="server" TabIndex="19" ID="btnSubmit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
            <asp:Button Text="Cancel" ID="btnCancel" CssClass="btn btn-default" TabIndex="20" OnClick="btnCancel_Click" runat="server" UseSubmitBehavior="false" CausesValidation="false" />
        </div>
    </div>
</asp:Content>

