<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="InventoryUpdate.aspx.cs" Inherits="Inventory_InventoryUpdate" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script type="text/javascript">
         
        function download() {
            window.open("../Document/CSV Formats/OpeningStock-INV UpdateFormat.csv");
        }

        $(function () {
            //  $(".gvItem").tableHeadFixer('55vh');
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

            return IsValid;
        }

        function Relaod() {

            // var table = $('.gvItem').DataTable();
            var aryJSONColTable = [];
            aryJSONColTable.push({ "width": "30px", "aTargets": 0 });
            aryJSONColTable.push({ "width": "150px", "aTargets": 1 });
            aryJSONColTable.push({ "width": "30px", "aTargets": 2 });
            aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 3 });
            aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 4 });
            aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 5 });
            aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 6 });
           /* aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 7 });//"sClass": "dtbodyLeft",*/
            //aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 8 });
            //aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 9 });
            //aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 10 });

            $('.gvItem').DataTable({
                bFilter: false,
                scrollCollapse: true,
                "sExtends": "collection",
                scrollX: true,
                scrollY: '50vh',
                responsive: true,
                "bPaginate": false,
                ordering: false,
                "bInfo": false,
                "autoWidth": false,
                destroy: true,
                "aoColumnDefs": aryJSONColTable,
            });

            $('.dataTables_scrollFoot').css('overflow', 'auto');
            $($.fn.dataTable.tables(true)).DataTable().columns.adjust();


            $(".txtSearch").keyup(function () {
                var word = this.value;
                $(".gvItem > tbody tr").each(function () {
                    var itmdata = $(this).find(".txtItem").val();

                    if (($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0) || (itmdata.toUpperCase().indexOf(word.toUpperCase()) >= 0))
                        $(this).show();
                    else
                        $(this).hide();
                });
            });

            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });


            $(document).on('keyup', '.txtItem', function () {

                var txtId = $(this).attr("id");
                var col1 = txtId.replace("body_gvItem_txtItem_", '');
                
                var DistID = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : '<%=ParentID%>';
                var key = DistID + '#';

                $('.gvItem').find('.lblItemID').each(function () {
                    key += $(this).text() + ",";
                });

                key = key.substring(0, key.length - 1);

                //  sender.set_contextKey(key);

                $('#' + txtId).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'InventoryUpdate.aspx/GetActiveMaterialByPlant',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','contextKey':'" + key + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#' + txtId),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    minLength: 1
                });
            });
        }

        function Checkvalidation() {
            if (Number(Container.find('.txtEnterQty').val() == 0)) {
                ModelMsg('Update Quantity must be a greater than Zero', 3);
                return false;
            }
            return true;
        }

        function CheckItemVal(txt) {
            var Container = $(txt).parent().parent();

            var txtval = Container.find('.txtItem').val().trim();
            if (txtval == "-" || txtval == " - " || txtval == "") {
                Container.find('.txtItem').val('');
            }
        }

        function ChangeQuantity(txt) {
            var EnterQty = 0;
            if (txt != undefined) {

                if ($(txt).val() == "" || isNaN(parseInt($(txt).val()))) {
                    $(txt).val("0");
                }
                var Container = $(txt).parent().parent();
                var Data = Container.find('.ddlUnit').val().split(',');

                EnterQty = Container.find('.txtEnterQty').val();

                if (Data.length == 4) {
                    Container.find('.lblUnitPrice').val(Number(Data[1]).toFixed(2));
                    Container.find('.lblPrice').val(Number(Data[1]).toFixed(2));
                  //  Container.find('.txtTotalQty').val(EnterQty * Number(Data[3]));
                    Container.find('.txtAvailQty').val((Number(Container.find('.hdnAvailQty').val()) / Number(Data[3])));
                    Container.find('.lblTotalPrice').val((Number(Container.find('.lblPrice').val()) * EnterQty).toFixed(2));
                    AddFunction(Container.find('.lblNo').text(), Data[0], Container.find('.ddlUnit option:selected').text().trim(), Container.find('.txtEnterQty').val() == undefined ? 0 : Container.find('.txtEnterQty').val(), Container.find('.txtEnterQty').val() == undefined ? 0 : Container.find('.txtEnterQty').val(), Container.find('.lblPrice').val(), Container.find('.lblTotalPrice').val());
//                    AddFunction(Container.find('.lblNo').text(), Data[0], Container.find('.ddlUnit option:selected').text().trim(), Container.find('.txtEnterQty').val() == undefined ? 0 : Container.find('.txtEnterQty').val(), Container.find('.txtTotalQty').val(), Container.find('.lblPrice').val(), Container.find('.lblTotalPrice').val());
                }
            }
            var main = $('.gvItem');
            var AllRows = $(main).find('tbody').find('tr');
            var AvailQty = 0, RequestQty = 0, DispatchQty = 0, TotalQty = 0, TotalPrice = 0, AllowdUpdateAmt;
            for (var i = 0; i < AllRows.length; i++) {

                if (txt == undefined) {

                    var Data = new Array();

                    if ($(AllRows[i]).find('.lblUnitID').text() != null)
                        Data = $(AllRows[i]).find('.lblUnitID').text().split(',');


                    if ($(AllRows[i]).find('.ddlUnit').val() != null)
                        Data = $(AllRows[i]).find('.ddlUnit').val().split(',');

                    EnterQty = $(AllRows[i]).find('.txtEnterQty').val();

                    if (Data.length == 4) {
                        $(AllRows[i]).find('.lblPrice').val(Number(Data[1]).toFixed(2));
                        $(AllRows[i]).find('.txtTotalQty').val(EnterQty * Number(Data[3]));
                        $(AllRows[i]).find('.txtAvailQty').val((Number($(AllRows[i]).find('.hdnAvailQty').val()) / Number(Data[3])));
                        $(AllRows[i]).find('.lblTotalPrice').val((Number($(AllRows[i]).find('.lblPrice').val()) * EnterQty).toFixed(2));
                    }
                }

                AvailQty += Number($(AllRows[i]).find('.txtAvailQty').val());
                RequestQty += Number($(AllRows[i]).find('.txtEnterQty').val());
                TotalQty += Number($(AllRows[i]).find('.txtTotalQty').val());
                TotalPrice += Number($(AllRows[i]).find('.lblTotalPrice').val());
            }

            var FooterContainer = $(main).find('.table-header-gradient');

            FooterContainer.find('.txtTAvailQty').val(AvailQty);
            FooterContainer.find('.txtTRequestQty').val(RequestQty);
            FooterContainer.find('.txtTTotalQty').val(TotalQty);
            FooterContainer.find('.lblTPrice').val(TotalPrice.toFixed(2));

            $('body').animate({ scrollTop: $(window).width() }, 1000);
        }

        function AddFunction(LineID, UnitID, UnitName, Quantity, TotalQty, UnitPrice, Total) {
            
            $.ajax({
                url: 'InventoryUpdate.aspx/AddRecord',
                type: 'POST',
                contentType: "application/json; charset=utf-8",
                data: "{'LineID':'" + LineID + "','UnitID':'" + UnitID + "','UnitName':'" + UnitName + "','Quantity':'" + Quantity + "','TotalQty':'" + TotalQty + "','UnitPrice':'" + UnitPrice + "','Total':'" + Total + "'}",
                dataType: "json",
                success: function (data) {
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    ModelMsg('Something is wrong...', 3);
                }
            });
        }

        function autoCompleteMat_OnClientPopulating(sender, args) {

            var DistID = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : '<%=ParentID%>';
            var key = DistID + '#';

            $('.gvItem').find('.lblItemID').each(function () {
                key += $(this).text() + ",";
            });

            key = key.substring(0, key.length - 1);

            sender.set_contextKey(key);
        }

        function CheckWareHouse() {
            var ddlWhs = $("[id*=ddlWhs]");
            var wareHouse = ddlWhs.find("option:selected").text();

            if (wareHouse == undefined || wareHouse == "") {
                ModelMsg("Please select Proper WareHouse", 3);
                event.preventDefault();
                return false;
            }
        }

    </script>
    <style type="text/css">
        .body {
            overflow: hidden !important;
            overflow-x: hidden !important;
        }

        .txtAvailQty, .txtTAvailQty, .lblPrice, .txtEnterQty, .txtTRequestQty, .txtTotalQty, .txtTTotalQty, .lblTotalPrice, .lblTPrice {
            text-align: right !important;
        }

        .input-group-addon {
            font-size: 1.1rem !important;
            font-weight: bold;
            text-align: right;
        }

        .search {
            background-color: lightyellow !important;
        }

        .CompletionListClass {
            font-size: 10px !important;
        }

        #page-content-wrapper {
            overflow: hidden;
        }

        .form-control {
            padding: 6px 4px !important;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        .dataTables_scrollBody {
            overflow-x: hidden !important;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        table.dataTable thead th.dtbodySrNo {
            padding: 5px 10px !important;
        }

        .dtbodyRight {
            text-align: right !important;
            padding-right: 5px !important;
        }

        .dtbodyCenter {
            text-align: center !important;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        .table > tfoot > tr > th {
            height: 25px !important;
        }

        .lblTTax, .lblTPrice, .txtTRequestQty, .lblTSubTotal, .txtTotalAvailQty, .txtAlreadyreturnQty, .txtTotalInvoiceQty {
            background: linear-gradient(to bottom, rgba(245,246,246,1) 0%,rgba(219,220,226,1) 3%,rgba(184,186,198,1) 59%,rgba(221,223,227,1) 100%,rgba(245,246,246,1) 100%);
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            /*padding-left: 4px !important;*/
            /*padding: 0px 0 0 4px !important;*/
            padding: 0px;
            vertical-align: middle !important;
            font-size: 11px !important;
            /*white-space: nowrap;*/
            /*overflow-x: scroll;*/
        }

        .tdleftalign {
            margin-left: 2px !important;
        }

        .tdrightalign {
            margin-right: 2px !important;
        }

        .CustName {
            /*overflow: auto;*/
            white-space: nowrap;
            overflow-x: scroll;
            padding-left: 4px !important;
        }

            .CustName::-webkit-scrollbar {
                display: none;
            }
        /*table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td::-webkit-scrollbar {
                display: none;
            }*/

        /* Hide scrollbar for IE, Edge and Firefox */
        .CustName {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }

        .lblPrice, .txtAvailQty, .txtEnterQty, .txtTotalQty, .lblSubTotal, .txtTTotalQty, .lblTSubTotal, .lblTax, .lblTTax, .lblTotalPrice, .lblTPrice, .txtTRequestQty, .txtTotalReturn, .txtInvQty,
        .txtTotalAvailQty, .txtAlreadyreturnQty, .txtTotalInvoiceQty {
            font-size: 11px !important;
            height: 25px !important;
            text-align: right !important;
        }

        .input-group form-group, .datepick, .txtCustomer, .txtItem, .lblBillToPartyCode, .txtBill {
            height: 25px !important;
            /*font-weight: bold;*/
            font-size: 10px !important;
        }

        .ui-autocomplete {
            font-size: 10px !important;
        }

        .txtTotalQty, .txtTTotalQty {
            display: none;
        }

        @media (min-width: 768px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .container {
                width: 1073px;
            }
        }

        @media (min-width: 992px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .dataTables_scrollHead {
                width: 1000px !important;
            }

            .dataTables_scrollBody {
                width: 1000px !important;
            }

            .dataTables_scrollFoot {
                width: 1020px !important;
            }

            .dataTables_scrollFootInner {
                width: 1020px !important;
            }
        }

        .form-control {
            display: block;
            width: 100%;
            height: 28px;
            padding: 6px 12px;
            font-size: 11px;
            line-height: 1.42857143;
            color: #555;
            background-color: #fff;
            background-image: none;
            border: 1px solid #ccc;
            border-radius: 4px;
            -webkit-box-shadow: inset 0 1px 1px rgb(0 0 0 / 8%);
            box-shadow: inset 0 1px 1px rgb(0 0 0 / 8%);
            -webkit-transition: border-color ease-in-out .15s, -webkit-box-shadow ease-in-out .15s;
            -o-transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
            transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
        }
        .txtItem, .ddlUnit, .txtAvailQty, .lblPrice, .txtEnterQty, .lblTotalPrice {
            height:22px !important;
        }
        .ddlUnit {
            padding :3px 4px !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Date" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtDate" Enabled="false" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" />
                        <input type="hidden" runat="server" id="hdnRemainingUpdateAmt" class="hdnRemainingUpdateAmt" />
                    </div>
                </div>
                <div class="col-lg-4" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor/SS" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="4" OnTextChanged="txtCustCode_TextChanged" AutoPostBack="true" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetALLCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode" ContextKey="2,4">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button Text="Submit" runat="server" CssClass="btn btn-default" TabIndex="6" ID="btnSubmit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
                        <asp:Button Text="Cancel" ID="btnCancel" CssClass="btn btn-default" TabIndex="7" OnClick="btnCancel_Click" runat="server" UseSubmitBehavior="false" CausesValidation="false" />
                    </div>
                </div>
                <div class="col-lg-4" style="display: none;">

                    <div class="input-group form-group">
                        <asp:Label ID="lblwarehouse" Text="Warehouse" CssClass="input-group-addon" runat="server"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlWhs" TabIndex="3" DataValueField="WhsID" DataTextField="WhsName" CssClass="form-control"
                            AutoPostBack="True" OnSelectedIndexChanged="ddlWhs_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <div class="row" style="display: none;">
                <div class="col-lg-12 _textArea">
                    <div class="input-group form-group">
                        <asp:Label Text="Notes" ID="lblNotes" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtNotes" TabIndex="4" TextMode="MultiLine" CssClass="form-control" Style="resize: none;" />
                    </div>
                </div>
            </div>
            <div class="row">

                <div class="col-lg-5">
                    <div class="input-group form-group">
                        <asp:Label ID="lblExcel" Text="Stock Upload" CssClass="input-group-addon" runat="server"></asp:Label>
                        <asp:FileUpload ID="flCSVUpload" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Button ID="btnUpload" runat="server" Text="Upload File" CssClass="btn btn-default" OnClientClick="CheckWareHouse();" OnClick="btnUpload_Click" />
                        <asp:Button ID="btnDownload" runat="server" Text="Download Format" CssClass="btn btn-default" OnClientClick="download(); return false;" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <asp:TextBox runat="server" placeholder="Search here" ID="txtSearch" TabIndex="5" CssClass="txtSearch form-control" Visible="false" />
    <br />
    <asp:GridView runat="server" ID="gvItem" CssClass="gvItem HighLightRowColor2 table" ShowFooter="true" ShowHeader="true" AutoGenerateColumns="false" OnPreRender="gvItems_PreRender" OnRowDataBound="gvItem_RowDataBound" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient">
        <Columns>
            <asp:TemplateField HeaderText="Sr." HeaderStyle-CssClass="dtbodyCenter">
                <ItemTemplate>
                    <asp:Label ID="lblNoNew" CssClass="lblNoNew" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                </ItemTemplate>
                <ItemStyle HorizontalAlign="Center" />
                <HeaderStyle Width="2%" />

            </asp:TemplateField>
            <asp:TemplateField HeaderText="Item Name" HeaderStyle-HorizontalAlign="Left">
                <ItemTemplate>
                    <asp:Label ID="lblNo" CssClass="lblNo" runat="server" Text='<%# Container.DataItemIndex %>' Style="display: none;"></asp:Label>
                    <asp:Label ID="lblItemID" CssClass="lblItemID" runat="server" Text='<%# Eval("ItemID") %>' Style="display: none;"></asp:Label>
                    <asp:TextBox runat="server" ID="txtItem" OnTextChanged="txtItem_TextChanged" AutoPostBack="true" CssClass="txtItem form-control" Style="background-color: rgb(250, 255, 189);" Text='<%# String.Format("{0} - {1}", Eval("ItemCode"),Eval("ItemName"))  %>' onfocus="CheckItemVal(this);" />
                    <%-- <asp:AutoCompleteExtender OnClientShown="resetPosition"  CompletionListCssClass="CompletionListClass" ID="acettxtItem" runat="server" ServicePath="../WebService.asmx" OnClientPopulating="autoCompleteMat_OnClientPopulating" UseContextKey="true" ServiceMethod="GetActiveMaterialByPlant" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="true" CompletionSetCount="1" TargetControlID="txtItem">
                    </asp:AutoCompleteExtender>--%>
                </ItemTemplate>
                <HeaderStyle Width="25%" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Unit">
                <ItemTemplate>
                    <asp:Label Text='<%# Eval("UnitID") %>' ID="lblUnitID" CssClass="lblUnitID" runat="server" Style="display: none;" />
                    <asp:Label Text='<%# Eval("UnitName") %>' ID="lblUnit" runat="server" Visible="false" />
                    <asp:DropDownList runat="server" ID="ddlUnit" CssClass="ddlUnit form-control" DataValueField="Value" DataTextField="Key" onchange="ChangeQuantity(this);">
                    </asp:DropDownList>
                </ItemTemplate>
                <HeaderStyle Width="10%" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Available Stock" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                <ItemTemplate>
                    <input type="hidden" id="hdnAvailQty" class="hdnAvailQty" runat="server" value='<%# Eval("AvailQty","{0:0}") %>' />
                    <asp:TextBox ID="txtAvailQty" CssClass="txtAvailQty form-control" Enabled="false" runat="server" Text='<%# Eval("AvailQty","{0:0}") %>'></asp:TextBox>
                </ItemTemplate>
                <HeaderStyle Width="15%" />
                <FooterTemplate>
                    <asp:TextBox ID="txtTAvailQty" CssClass="txtTAvailQty form-control" Enabled="false" runat="server"></asp:TextBox>
                </FooterTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Purchase Rate" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                <ItemTemplate>
                    <asp:TextBox ID="lblPrice" Enabled="false" CssClass="lblPrice form-control" runat="server" Text='<%# Eval("UnitPrice","{0:0.00}") %>' onchange="ChangeQuantity(this);" onkeyup="enter(this);" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" MaxLength="12"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Update Qty" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                <ItemTemplate>
                    <asp:TextBox ID="txtEnterQty" CssClass="txtEnterQty form-control" on="select(this);" Text='<%# Eval("Quantity","{0:0}") %>' runat="server" onchange="ChangeQuantity(this);" onkeyup="enter(this);" onkeypress="return isNumberKey(event);" onpaste="return false;" data-bv-stringlength="false" MaxLength="12" onBlur="SetQtyDataBlur(this);" onfocus="SetQtyDataFocus(this);" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:TextBox ID="txtTRequestQty" CssClass="txtTRequestQty form-control" Enabled="false" runat="server"></asp:TextBox>
                </FooterTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="New Stock Qty" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false">
                <ItemTemplate>
                    <asp:TextBox ID="txtTotalQty" Text='<%# Eval("TotalQty","{0:0}") %>' CssClass="txtTotalQty form-control" runat="server" Enabled="false"></asp:TextBox>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:TextBox ID="txtTTotalQty" CssClass="txtTTotalQty form-control" Enabled="false" runat="server"></asp:TextBox>
                </FooterTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="New Stock Amount" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right">
                <ItemTemplate>
                    <asp:TextBox ID="lblTotalPrice" CssClass="lblTotalPrice form-control" Enabled="false" runat="server" Text='<%# Eval("Total","{0:0.00}") %>'></asp:TextBox>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:TextBox ID="lblTPrice" CssClass="lblTPrice form-control" Enabled="false" runat="server"></asp:TextBox>
                </FooterTemplate>
                <HeaderStyle Width="10%" />
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <br />
    <div class="row">
        <div id="divMissData" class="col-lg-12" runat="server">
            <div style="overflow-x: auto">
                <asp:GridView ID="gvMissdata" runat="server" CssClass="table table-bordered table-responsive" AutoGenerateColumns="true">
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

