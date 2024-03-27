<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DayClose.aspx.cs" Inherits="Sales_DayClose" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(function () {
            Relaod();
            ChangeQuantity();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
            ChangeQuantity();
        }
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }
        function twidth() {
            // $('.tdiv').css('max-height', (innerHeight - 100) + "px");
            // $('.tdiv').css('height', 'auto');
        }
        window.onresize = twidth;
        function Relaod() {
            if ($(".gvItem > tbody tr:first td").text() != 'No Item Found.') {
                $(".gvItem").css('width', '130%');
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
            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });

            $("ul.nav-tabs > li > a").on("shown.bs.tab", function (e) {
                $.cookie("DayClose", $(e.target).attr("href").substr(1));
            });
            $('#tabs a[href="#' + $.cookie("DayClose") + '"]').tab('show');
        }

        function ChangeExpense() {
            var Emain = $('.gvExpense');
            var EAllRows = $(Emain).find('tbody').find('tr');

            var ExpAmount = 0;

            for (var i = 0; i < EAllRows.length; i++) {
                ExpAmount += Number($(EAllRows[i]).find('.txtAmount').val());
            }

            isNaN(ExpAmount) ? ExpAmount = 0 : 0;
            $('.txtMisExp').val(ExpAmount.toFixed(2));

            Summary();
        }

        function Summary() {
            var Container = $('.CashBlock');
            var EnterQty = (Container.find('.txt1000').length > 0 ? Number(Container.find('.txt1000').val()) * 1000 : 0) +
                          (Container.find('.txt500').length > 0 ? Number(Container.find('.txt500').val()) * 500 : 0) +
                          (Container.find('.txt100').length > 0 ? Number(Container.find('.txt100').val()) * 100 : 0) +
                          (Container.find('.txt50').length > 0 ? Number(Container.find('.txt50').val()) * 50 : 0) +
                          (Container.find('.txt20').length > 0 ? Number(Container.find('.txt20').val()) * 20 : 0) +
                          (Container.find('.txt10').length > 0 ? Number(Container.find('.txt10').val()) * 10 : 0) +
                          (Container.find('.txt5').length > 0 ? Number(Container.find('.txt5').val()) * 5 : 0) +
                          (Container.find('.txt2').length > 0 ? Number(Container.find('.txt2').val()) * 2 : 0) +
                          (Container.find('.txt1').length > 0 ? Number(Container.find('.txt1').val()) * 1 : 0) +
                          (Container.find('.txt0').length > 0 ? Number(Container.find('.txt0').val()) : 0);

            $('.txtActualAmount').val(EnterQty);

            $('.txtOtherClosing').val($('.txtSaleOther').val());

            $('.txtCashClosing').val(Number(
              Number($('.txtOpening').val())
              - Number($('.txtPPayment').val())
              + Number($('.txtSaleCash').val())
              + Number($('.txtAdvance').val())
              - Number($('.txtMisExp').val())
              - Number($('.txtPettyCash').val())).toFixed(2));

            
        }

        function ChangeQuantity() {
            var main = $('.gvItem');
            var AllRows = $(main).find('tbody').find('tr');

            var SalesR = 0, Opening = 0, Inward = 0, Dispatch = 0, Return = 0, Consume = 0, Wastage = 0, SaleOrder = 0, GodwonSales = 0, Closing = 0, Sales = 0, GainLoss = 0;

            for (var i = 0; i < AllRows.length; i++) {

                Opening += Number($(AllRows[i]).find('.lblOpening').text());
                Inward += Number($(AllRows[i]).find('.lblInward').text());
                Dispatch += Number($(AllRows[i]).find('.lblDispatch').text());
                Return += Number($(AllRows[i]).find('.lblReturn').text());
                Wastage += Number($(AllRows[i]).find('.lblWastage').text());
                Consume += Number($(AllRows[i]).find('.lblConsume').text());
                SaleOrder += Number($(AllRows[i]).find('.lblSaleOrder').text());
                GodwonSales += Number($(AllRows[i]).find('.lblGodwonSales').text());
                Sales += Number($(AllRows[i]).find('.lblRetailSales').text());
                SalesR += Number($(AllRows[i]).find('.lblSaleReturn').text());
                GainLoss += Number($(AllRows[i]).find('.lblGainLoss').text());
                Closing += Number($(AllRows[i]).find('.lblClosing').text());
            }

            var FooterContainer = $(main).find('.table-header-gradient');

            FooterContainer.find('.lblTOpening').text(Opening.toFixed(2));
            FooterContainer.find('.lblTInward').text(Inward.toFixed(2));
            FooterContainer.find('.lblTDispatch').text(Dispatch.toFixed(2));
            FooterContainer.find('.lblTReturn').text(Return.toFixed(2));
            FooterContainer.find('.lblTWastage').text(Wastage.toFixed(2));
            FooterContainer.find('.lblTConsume').text(Consume.toFixed(2));
            FooterContainer.find('.lblTSaleOrder').text(SaleOrder.toFixed(2));
            FooterContainer.find('.lblTGodwonSales').text(GodwonSales.toFixed(2));
            FooterContainer.find('.lblTOtherSales').text(GodwonSales.toFixed(2));
            FooterContainer.find('.lblTRetailSales').text(Sales.toFixed(2));
            FooterContainer.find('.lblTSaleReturn').text(SalesR.toFixed(2));
            FooterContainer.find('.lblTGainLoss').text(GainLoss.toFixed(2));
            FooterContainer.find('.lblTClosing').text(Closing.toFixed(2));
        }

    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label Text="Date" runat="server" CssClass="input-group-addon" ID="lblDate" />
                        <asp:TextBox runat="server" TabIndex="1" ID="txtDate" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" OnTextChanged="txtDate_TextChanged" AutoPostBack="true"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Button ID="btnSubmit" runat="server" TabIndex="3" Text="Submit" OnClick="btnSubmit_Click" CssClass="btn btn-default" OnClientClick="return _btnCheck();" />&nbsp
                        <asp:Button ID="btnCancel" runat="server" TabIndex="4" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label Text="Is Confirm" runat="server" CssClass="input-group-addon" ID="lblIsConfirm" />
                        <asp:CheckBox ID="chkIsConfirm" TabIndex="2" runat="server" CssClass="form-control" />
                    </div>
                </div>
            </div>
            <ul id="tabs" class="nav nav-tabs" role="tablist">
                <li class="active"><a href="#tabs-1" role="tab" tabindex="5" data-toggle="tab">Item</a></li>
                <li><a href="#tabs-2" tabindex="6" role="tab">Payment</a></li>
                <li><a href="#tabs-3" tabindex="7" role="tab">Expense</a></li>
            </ul>
            <div id="myTabContent" class="tab-content">
                <div id="tabs-1" class="tab-pane active">
                    <asp:TextBox runat="server" placeholder="Search here" ID="txtSearch" CssClass="txtSearch form-control" Style="margin-top: 5px;" />
                    <div style="overflow-y: auto; max-height: 500px;" class="tdiv">
                        <asp:GridView runat="server" Style="max-width: 120%" ID="gvItem" OnPreRender="gvItem_PreRender" CssClass="gvItem FixedTable HighLightRowColor2 table" ShowFooter="true" ShowHeader="true" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                            <Columns>
                                <asp:TemplateField HeaderText="Item Code">
                                    <ItemTemplate>
                                        <asp:Label ID="lblItemCd" runat="server" Text='<%# Eval("ItemCode") %>'></asp:Label>
                                    </ItemTemplate>
                                    <HeaderStyle Width="10%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Item Name">
                                    <ItemTemplate>
                                        <asp:Label ID="lblItemID" runat="server" Text='<%# Eval("ItemID") %>' Visible="false"></asp:Label>
                                        <asp:Label ID="lblItemName" runat="server" Text='<%# Eval("ItemName") %>'></asp:Label>
                                    </ItemTemplate>
                                    <HeaderStyle Width="30%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Unit">
                                    <ItemTemplate>
                                        <asp:Label ID="lblUnitID" runat="server" Text='<%# Eval("UnitID") %>' Visible="false"></asp:Label>
                                        <asp:Label ID="lblUnitName" runat="server" Text='<%# Eval("UnitName") %>'></asp:Label>
                                    </ItemTemplate>
                                    <HeaderStyle Width="5%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Opening">
                                    <ItemTemplate>
                                        <asp:Label ID="lblOpening" CssClass="lblOpening" runat="server" Text='<%# Convert.ToDecimal(Eval("Opening")) != 0 ? Eval("Opening","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTOpening" CssClass="lblTOpening" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Inward">
                                    <ItemTemplate>
                                        <asp:Label ID="lblInward" CssClass="lblInward" runat="server" Text='<%# Convert.ToDecimal(Eval("Inward")) != 0 ? Eval("Inward","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTInward" CssClass="lblTInward" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Delivery">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDispatch" CssClass="lblDispatch" runat="server" Text='<%# Convert.ToDecimal(Eval("Dispatch")) != 0 ? Eval("Dispatch","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTDispatch" CssClass="lblTDispatch" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Purchase Return">
                                    <ItemTemplate>
                                        <asp:Label ID="lblReturn" CssClass="lblReturn" runat="server" Text='<%# Convert.ToDecimal(Eval("PurchaseReturn")) != 0 ? Eval("PurchaseReturn","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTReturn" CssClass="lblTReturn" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Wastage">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWastage" CssClass="lblWastage" runat="server" Text='<%# Convert.ToDecimal(Eval("Wastage")) != 0 ? Eval("Wastage","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTWastage" CssClass="lblTWastage" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Consume">
                                    <ItemTemplate>
                                        <asp:Label ID="lblConsume" CssClass="lblConsume" runat="server" Text='<%# Convert.ToDecimal(Eval("Consume")) != 0 ? Eval("Consume","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTConsume" CssClass="lblTConsume" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Open SO">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSaleOrder" CssClass="lblSaleOrder" runat="server" Text='<%# Convert.ToDecimal(Eval("SaleOrder")) != 0 ? Eval("SaleOrder","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTSaleOrder" CssClass="lblTSaleOrder" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Godwon Sales">
                                    <ItemTemplate>
                                        <asp:Label ID="lblGodwonSales" CssClass="lblGodwonSales" runat="server" Text='<%# Convert.ToDecimal(Eval("DispatchOrder")) != 0 ? Eval("DispatchOrder","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTGodwonSales" CssClass="lblTGodwonSales" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Sales">
                                    <ItemTemplate>
                                        <asp:Label ID="lblRetailSales" CssClass="lblRetailSales" runat="server" Text='<%# Convert.ToDecimal(Eval("Sales")) != 0 ? Eval("Sales","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTRetailSales" CssClass="lblTRetailSales" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Sale Return">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSaleReturn" CssClass="lblSaleReturn" runat="server" Text='<%# Convert.ToDecimal(Eval("SaleReturn")) != 0 ? Eval("SaleReturn","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTSaleReturn" CssClass="lblTSaleReturn" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Gain / Loss">
                                    <ItemTemplate>
                                        <asp:Label ID="lblGainLoss" CssClass="lblGainLoss" runat="server" Text='<%# Convert.ToDecimal(Eval("GainLoss")) != 0 ? Eval("GainLoss","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTGainLoss" CssClass="lblTGainLoss" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Closing">
                                    <ItemTemplate>
                                        <asp:Label ID="lblClosing" CssClass="lblClosing" runat="server" Text='<%# Convert.ToDecimal(Eval("Closing")) != 0 ? Eval("Closing","{0:0.00}") : "" %>' Enabled="false"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTClosing" CssClass="lblTClosing" runat="server" Enabled="false"></asp:Label>
                                    </FooterTemplate>
                                    <HeaderStyle Width="7%" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
                <div id="tabs-2" class="tab-pane">
                    <div class="row">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Opening" runat="server" ForeColor="Green" CssClass="input-group-addon" ID="lblHOpening" />
                                <asp:TextBox runat="server" ID="txtOpening" CssClass="txtOpening form-control" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Purchase" runat="server" CssClass="input-group-addon" ID="lblHPurchase" />
                                <asp:TextBox runat="server" ID="txtPurchase" CssClass="txtPurchase form-control" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Purchase Return" runat="server" CssClass="input-group-addon" ID="Label2" />
                                <asp:TextBox runat="server" ID="txtPurchaseReturn" CssClass="txtPurchaseReturn form-control" onchange="Summary();" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Purchase Payment" ForeColor="Green" runat="server" CssClass="input-group-addon" ID="Label4" />
                                <asp:TextBox runat="server" ID="txtPPayment" CssClass="txtPPayment form-control" onchange="Summary();" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Delivery" runat="server" CssClass="input-group-addon" ID="lblHDispatch" />
                                <asp:TextBox runat="server" ID="txtDispatch" CssClass="txtDispatch form-control" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Transfer" runat="server" CssClass="input-group-addon" ID="lblHTransfer" />
                                <asp:TextBox runat="server" ID="txtTransfer" CssClass="txtTransfer form-control" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Sale Cash" runat="server" ForeColor="Green" CssClass="input-group-addon" ID="lblSaleCash" />
                                <asp:TextBox runat="server" ID="txtSaleCash" CssClass="txtSaleCash form-control" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Sale Other" runat="server" ForeColor="Green" CssClass="input-group-addon" ID="lblSaleOther" />
                                <asp:TextBox runat="server" ID="txtSaleOther" CssClass="txtSaleOther form-control" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Open Sale Order" runat="server" CssClass="input-group-addon" ID="lbltxtOpenSO" />
                                <asp:TextBox runat="server" ID="txtOpenSO" CssClass="txtOpenSO form-control" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Sale Return" runat="server" CssClass="input-group-addon" ID="Label1" />
                                <asp:TextBox runat="server" ID="txtReturn" CssClass="txtReturn form-control" onchange="Summary();" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Advance" runat="server" ForeColor="Green" CssClass="input-group-addon" ID="lblAdvance" />
                                <asp:TextBox runat="server" ID="txtAdvance" CssClass="txtAdvance form-control" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Misc. Expense" runat="server" ForeColor="Green" CssClass="input-group-addon" ID="lblHMisExp" />
                                <asp:TextBox runat="server" ID="txtMisExp" CssClass="txtMisExp form-control" onchange="Summary();" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Consume" runat="server" CssClass="input-group-addon" ID="lblHConsume" />
                                <asp:TextBox runat="server" ID="txtConsume" CssClass="txtConsume form-control" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Wastage" runat="server" CssClass="input-group-addon" ID="lblHWastage" />
                                <asp:TextBox runat="server" ID="txtWastage" CssClass="txtWastage form-control" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Payment" runat="server" ForeColor="Green" CssClass="input-group-addon" ID="Label3" />
                                <asp:TextBox runat="server" ID="txtActualAmount" CssClass="txtActualAmount form-control" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Petty Cash" runat="server" ForeColor="Green" CssClass="input-group-addon" ID="lblHPettyCash" />
                                <asp:TextBox runat="server" ID="txtPettyCash" CssClass="txtPettyCash form-control" onchange="Summary();" onkeypress="return isNumberKeyMinusAmount(event);"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Cash Closing" runat="server" ForeColor="Green" CssClass="input-group-addon" ID="lblHClosing" />
                                <asp:TextBox runat="server" ID="txtCashClosing" CssClass="txtCashClosing form-control" onchange="Summary();" Enabled="false"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Other Closing" runat="server" ForeColor="Green" CssClass="input-group-addon" ID="Label5" />
                                <asp:TextBox runat="server" ID="txtOtherClosing" CssClass="txtOtherClosing form-control" onchange="Summary();" Enabled="false"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-12">
                            <asp:Label runat="server" Text="Currency Bifurcation" Style="font-weight: bold; text-decoration: underline; font-size: 16px"></asp:Label>
                            <table style="width: 100%;" class="CashBlock table">
                                <thead>
                                    <tr class="table-header-gradient">
                                        <th>
                                            <asp:Label ID="lbl1000" runat="server" Text="1000x"></asp:Label>
                                        </th>
                                        <th>
                                            <asp:Label ID="lbl500" runat="server" Text="500x"></asp:Label>
                                        </th>
                                        <th>
                                            <asp:Label ID="lbl100" runat="server" Text="100x"></asp:Label>
                                        </th>
                                        <th>
                                            <asp:Label ID="lbl50" runat="server" Text="50x"></asp:Label>
                                        </th>
                                        <th>
                                            <asp:Label ID="lbl20" runat="server" Text="20x"></asp:Label>
                                        </th>
                                        <th>
                                            <asp:Label ID="lbl10" runat="server" Text="10x"></asp:Label>
                                        </th>
                                        <th>
                                            <asp:Label ID="lbl5" runat="server" Text="5x"></asp:Label>
                                        </th>
                                        <th>
                                            <asp:Label ID="lbl2" runat="server" Text="2x"></asp:Label>
                                        </th>
                                        <th>
                                            <asp:Label ID="lbl1" runat="server" Text="1x"></asp:Label>
                                        </th>
                                        <th>
                                            <asp:Label ID="lblOther" runat="server" Text="Other"></asp:Label>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>
                                            <asp:TextBox runat="server" ID="txt1000" CssClass="form-control txt1000" onkeypress="return isNumberKey(event);" onkeyup="enter(this);" onpaste="return false;" onchange="Summary();" MaxLength="6" />
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txt500" CssClass="form-control txt500" onkeypress="return isNumberKey(event);" onkeyup="enter(this);" onpaste="return false;" onchange="Summary();" MaxLength="6" />
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txt100" CssClass="form-control txt100" onkeypress="return isNumberKey(event);" onkeyup="enter(this);" onpaste="return false;" onchange="Summary();" MaxLength="6" />
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txt50" CssClass="form-control txt50" onkeypress="return isNumberKey(event);" onkeyup="enter(this);" onpaste="return false;" onchange="Summary();" MaxLength="6" />
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txt20" CssClass="form-control txt20" onkeypress="return isNumberKey(event);" onkeyup="enter(this);" onpaste="return false;" onchange="Summary();" MaxLength="6" />
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txt10" CssClass="form-control txt10" onkeypress="return isNumberKey(event);" onkeyup="enter(this);" onpaste="return false;" onchange="Summary();" MaxLength="6" />
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txt5" CssClass="form-control txt5" onkeypress="return isNumberKey(event);" onkeyup="enter(this);" onpaste="return false;" onchange="Summary();" MaxLength="6" />
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txt2" CssClass="form-control txt2" onkeypress="return isNumberKey(event);" onkeyup="enter(this);" onpaste="return false;" onchange="Summary();" MaxLength="6" />
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txt1" CssClass="form-control txt1" onkeypress="return isNumberKey(event);" onkeyup="enter(this);" onpaste="return false;" onchange="Summary();" MaxLength="6" />
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txt0" CssClass="form-control txt0" onkeypress="return isNumberKeyForAmount(event);" onkeyup="enter(this);" onpaste="return false;" onchange="Summary();" MaxLength="6" />
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-12">
                            <div class="input-group form-group">
                                <asp:Label Text="Closing Note" runat="server" CssClass="input-group-addon" ID="lblHClosingNote" />
                                <asp:TextBox runat="server" ID="txtCashClosingNote" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="tabs-3" class="tab-pane">
                    <div class="row">
                        <asp:GridView runat="server" ID="gvExpense" CssClass="gvExpense HighLightRowColor2 table" ShowFooter="true" ShowHeader="true" OnPreRender="gvExpense_PreRender" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" EmptyDataText="No Record Found">
                            <Columns>
                                <asp:TemplateField HeaderText="Expense Name">
                                    <ItemTemplate>
                                        <asp:Label ID="lblExpenseID" runat="server" Text='<%# Eval("ExpenseID") %>' Visible="false"></asp:Label>
                                        <asp:TextBox ID="txtExpName" CssClass="form-control" runat="server" Text='<%# Eval("OEXP.Name") %>' AutoPostBack="true" OnTextChanged="txtExpName_TextChanged"></asp:TextBox>
                                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtName" runat="server" ServiceMethod="GetActiveExpense" ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtExpName" UseContextKey="True">
                                        </asp:AutoCompleteExtender>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Amount">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtAmount" CssClass="txtAmount form-control" runat="server" Text='<%# Eval("Amount","{0:0.00}") %>' AutoPostBack="true" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" OnTextChanged="txtExpName_TextChanged" onchange="ChangeExpense();"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Notes">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtNotes" CssClass="txtNotes form-control" runat="server" Text='<%# Eval("Notes") %>' AutoPostBack="true" OnTextChanged="txtExpName_TextChanged"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
