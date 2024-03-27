<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="PurchaseOrder.aspx.cs" Inherits="Purchase_PurchaseOrder" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <%-- <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>--%>
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>

    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <style>
        .modal-footer {
            text-align: center !important;
        }

        .req:after {
            content: "*";
            color: red;
        }

        .search {
            background-color: lightyellow;
            height: 24px;
            font-size: 11px;
        }

        .allownumericwithdecimal {
            height: 24px;
        }

        .table#tblItem {
            width: 100%;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
            font-size: 11px !important;
        }

        table#tblItem tbody {
            width: 100%;
        }

        table#tblItem thead tr {
            position: relative;
        }

        table#tblItem tfoot tr {
            position: relative;
        }

        .dataTables_scrollBody {
            overflow-x: hidden !important;
        }

        .dataTables_scroll {
            overflow: hidden;
        }

        table.dataTable thead th.dtbodySrNo {
            padding: 5px 10px !important;
        }

        .dtbodyRight {
            text-align: right !important;
        }

        .dtbodyCenter {
            text-align: center !important;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }


        .border-la {
            float: left;
            width: 100%;
            height: 1px;
            padding-right: 10px;
            background: #000;
        }

        #tbl {
            margin-top: 10px;
        }

        .dataTables_scrollBody {
            max-height: 62vh !important;
        }

        .tdPrice {
            text-align: right;
        }

        .tdSubTotal {
            text-align: right;
        }

        .tdTax {
            text-align: right;
        }

        .tdTotalPrice {
            text-align: right;
        }

        .tdAvailable {
            text-align: right;
        }

        .tdTotalQty {
            text-align: right;
        }

        .lblFootAvailable {
            float: right;
        }

        .lblFootReceipt {
            float: right !important;
        }

        .lblFootTotalQty {
            float: right;
        }

        .lblFootSubTotal {
            float: right !important;
        }

        .lblFootTax {
            float: right !important;
        }

        .lblFootTotalPrice {
            float: right !important;
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            padding: 3px;
            line-height: 1.42857143;
            vertical-align: top;
            border-top: 1px solid #ddd;
        }

        .ui-autocomplete {
            font-size: 11px !important;
        }
    </style>
    <script type="text/javascript">

        $(document).ready(function () {

            $("#tblItem").tableHeadFixer('60vh');
        });


    </script>
    <script type="text/javascript">

        var availableTemplate = [];
        var availableVehicle = [];
        var availableOrderForm = [];
        var availableItems = [];
        var gridItems = [];
        var Units = [];
        $(document).ready(function () {
            $('#CountRowMaterial').val(0);
            $('#txtPaid').on('blur', function (event) {
                summary();
            });
            $("#txtDiscount").on('blur', function (event) {
                CalculateDiscount();

            });

            $("#txtDate").datepicker({
                dateFormat: 'dd/MM/yy',
                changeMonth: true, changeYear: true,
                yearRange: "2000:2090",
                beforeShow: function () {
                    setTimeout(function () {
                        $('.ui-datepicker').css('z-index', 99999999999999);
                    }, 0);
                }
            }).on("change", function (e) { FillData(); });


            $('#txtSearch').on('keyup', function () {
                var word = this.value;
                $('#tblItem > tbody tr').each(function () {

                    var itmdata = $("input[name='AutoMatCodes']", this).val();
                    if (($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0) || (itmdata.toUpperCase().indexOf(word.toUpperCase()) >= 0))
                        $(this).show();
                    else
                        $(this).hide();
                });
            });

            var today = '<%=DateTime.Now.ToShortDateString()%>';

            $('#txtDate').val(today);

            FillData();
            OnDivisionChange(); // Load Item Details according to default selected
            //AddMoreRow();
        });

        function FillData() {
            $.ajax({
                url: 'PurchaseOrder.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ Date: $('#txtDate').val() }),
                async: false,
                contentType: 'application/json; charset=utf-8',
                success: function (result) {

                    if (result.d == "") {
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        event.preventDefault();

                        var today = '<%=DateTime.Now.ToShortDateString()%>';

                        $('#txtDate').val(today);
                        return false;
                    }
                    else {
                        var lstDivision = result.d[1];
                        var WareHouse = result.d[2];
                        var Vehicle = result.d[3];
                        var Template = result.d[4];

                        $("#ddlDivision option[value!='0']").remove();
                        $("#ddlDivision").append('<option  value="0">--Select--</option>');
                        for (var i = 0; i < lstDivision.length; i++) {
                            $("#ddlDivision").append('<option value="' + lstDivision[i]["DivisionlID"] + '">' + lstDivision[i]["DivisionName"] + '</option>');
                        }
                        $("#ddlDivision").val('3');
                        $("#ddlWhs option[value!='0']").remove();

                        for (var i = 0; i < WareHouse.length; i++) {
                            $("#ddlWhs").append('<option value="' + WareHouse[i]["Value"] + '">' + WareHouse[i]["Name"] + '</option>');
                        }

                        for (var i = 0; i < Vehicle.length; i++) {
                            availableVehicle.push(Vehicle[i]);
                        }

                        for (var i = 0; i < Template.length; i++) {
                            availableTemplate.push(Template[i]);
                        }
                        $("#txtVehicle").autocomplete({
                            source: availableVehicle,
                            minLength: 0,
                            scroll: true
                        });
                        $("#txtTemplate").autocomplete({
                            source: availableTemplate,
                            minLength: 0,
                            scroll: true
                        });
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {

                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }

        function summary() {
            var Total = parseFloat($('#txtTotal').val());
            var paid = parseFloat($('#txtPaid').val());
            if (Total != null && paid != null) {
                $('#txtPending').val(parseFloat(Math.round(Total) - paid).toFixed(2));
            }
        }
        function AddMoreRow() {

            $('table#tblItem tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMaterial').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMaterial').val(ind);

            var str = "";
            str = "<tr id='trItem" + ind + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='text' id='AutoMatCodes" + ind + "' name='AutoMatCodes' class='form-control search'  OnDivisionChange /></td>"
                + "<td><select id='ddlUnit" + ind + "' name='ddlUnit' class='form-control' onkeyup='enter(this);' disabled='disabled' style='height: 24px;padding-top: 1px;font-size: 11px;' /></td>"
                + "<td id='tdPrice" + ind + "' class='tdPrice'></td>"
                + "<td id='tdAvailable" + ind + "' class='tdAvailable'></td>"
                + "<td><input type='text' id='txtReciept" + ind + "' name='txtReciept' maxlength='10' value='0' class='form-control allownumericwithdecimal' style='text-align:right;' onfocus='SetQtyDataFocus(this);' onblur='SetQtyDataBlur(this);' /></td>"
                + "<td id='tdTotalQty" + ind + "' class='tdTotalQty'></td>"
                + "<td id='tdSubTotal" + ind + "' class='tdSubTotal'></td>"
                + "<td id='tdTax" + ind + "' class='tdTax'></td>"
                + "<td id='tdTotalPrice" + ind + "' class='tdTotalPrice'></td>"
                + "<td style='display:none'><input type='hidden' id='hdnItemID" + ind + "' name='hdnItemID'/>"
                + "<input type='hidden' id='hdnMainID" + ind + "' name='hdnMainID' value='0' />"
                + "<input type='hidden' id='hdnMaterialPriceTax" + ind + "' name='hdnMaterialPriceTax' value='0' />"
                + "<input type='hidden' id='hdnMaterialUnitPrice" + ind + "' name='hdnMaterialUnitPrice' value='0' />"
                + "<input type='hidden' id='hdnMaterialTaxID" + ind + "' name='hdnMaterialTaxID' value='0' />"

                + "<input type='hidden' id='hdnDiscountSubTotal" + ind + "' name='hdnDiscountSubTotal' value='0' />"
                + "<input type='hidden' id='hdnDiscountPrice" + ind + "' name='hdnDiscountPrice' value='0' />"
                + "<input type='hidden' id='hdnDiscountTax" + ind + "' name='hdnDiscountTax' value='0' />"
                + "<input type='hidden' id='hdnDiscountTotal" + ind + "' name='hdnDiscountTotal' value='0' />"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' />"
                + "<input type='hidden' id='hdnMappingQty" + ind + "' name='hdnMappingQty' value='0' /></td>";

            $('#tblItem > tbody').append(str);

            // serial no update on table grid
            var lineNum = 0;
            $('#tblItem > tbody > tr').each(function (row, tr) {
                lineNum++;
                $(".txtSrNo", this).text(lineNum);
            });

            $('#ddlUnit' + ind).on('change', function () {
                SetUnitPrice(ind);
            });
            $("#AutoMatCodes" + ind).autocomplete({
                source: availableItems,
                minLength: 0,
                scroll: true,
                position: { collision: "flip" }
            });


            $('#AutoMatCodes' + ind).on('autocompleteselect', function (e, ui) {
                GetItemDetailsByCode(ui.item.value, ind);
            });

            $('#AutoMatCodes' + ind).bind("autocompleteselect", function (event, ui) {
                // Remove the element and overwrite the availableItems var
                //availableItems.splice(availableItems.indexOf(ui.item.value), 1);
                // Re-assign the source
                $(this).autocomplete("option", "source", availableItems);
            });


            $('#AutoMatCodes' + ind).on('change keyup', function () {
                if ($('#AutoMatCodes' + ind).val() == "") {
                    ClearMaterialRow(ind);
                }
            });
            $('#AutoMatCodes' + ind).on('blur', function (e, ui) {
                if ($('#AutoMatCodes' + ind).val().trim() != "") {
                    if ($('#AutoMatCodes' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Item", 3);
                        $('#AutoMatCodes' + ind).val("");
                        return;
                    }
                    var txt = $('#AutoMatCodes' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        event.preventDefault();
                        return false;
                    }
                    CheckDuplicateItem($('#AutoMatCodes' + ind).val().trim(), ind);
                }
            });

            $("#txtReciept" + ind).on('change keyup paste', function (event) {
                CalculateSum(ind);
                DisableControls();
            });
            $(function () {
                $("#txtReciept" + ind).keydown(function (event) {
                    if (event.shiftKey == true) {
                        event.preventDefault();
                    }
                    if ((event.keyCode >= 48 && event.keyCode <= 57) || (event.keyCode >= 96 && event.keyCode <= 105) || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 37 || event.keyCode == 39 || event.keyCode == 46 || event.keyCode == 190) {
                    } else {
                        event.preventDefault();
                    }
                    if ($(this).val().indexOf('.') !== -1 && event.keyCode == 190)
                        event.preventDefault();
                });
            });
        }

        function DisableControls() {
            $("#txtBillAmount").prop("disabled", true);
            $("#txtTax").prop("disabled", true);
            $("#txtRounding").prop("disabled", true);
            $("#txtTotal").prop("disabled", true);
            $("#txtPending").prop("disabled", true);
        }
        function CalculateDiscount() {
            var DiscValue = $("#txtDiscount").val();
            if (DiscValue != "") {
                var TotalWithDisc = 0;
                var gtotal = $("#txtTotal").val();

                if (gtotal != "") {
                    TotalWithDisc = (Number(gtotal) - parseFloat(DiscValue)).toFixed(2);
                    $("#txtTotal").val(TotalWithDisc);
                    $("#txtPending").val(TotalWithDisc);
                }
                else {
                    return false;
                }
            }
            else {
                return false;
            }

        }
        function SetUnitPrice(row) {
            CalculateSum(row);
        }
        function Cancel() {
            window.location = "../Purchase/Purchase.aspx";
        }
        function OnDivisionChange() {

            var AutoCompleteItems = [];
            $('#tblItem tbody > tr').remove();
            AddMoreRow();
            CalculateSum();

            var DivisionID = $('#ddlDivision').val();
            if (DivisionID != null) {
                if (DivisionID == 0) {

                    var ind = $('#CountRowMaterial').val();
                    $('#CountRowMaterial').val(ind);

                    $("#AutoMatCodes" + ind).autocomplete({
                        source: AutoCompleteItems,
                        minLength: 0,
                        scroll: true
                    });

                    return false;
                }
                else {
                    $.ajax({
                        url: 'PurchaseOrder.aspx/LoadItemsByDivision',
                        type: 'POST',
                        dataType: 'json',
                        data: JSON.stringify({ DivisionID: DivisionID }),
                        async: false,
                        contentType: 'application/json; charset=utf-8',
                        success: function (result) {
                            if (result.d == "") {
                                availableItems = [];
                                event.preventDefault();
                                // return false;
                            }
                            else if (result.d[0].indexOf("ERROR=") >= 0) {
                                var ErrorMsg = result.d[0].split('=')[1].trim();
                                ModelMsg(ErrorMsg, 3);
                                event.preventDefault();
                                //return false;
                            }
                            else {
                                availableItems = result.d[0];
                            }
                            var ind = $('#CountRowMaterial').val();
                            $('#AutoMatCodes' + ind).autocomplete({
                                source: availableItems,
                                minLength: 0,
                                scroll: true
                            });
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {

                            alert('Something is wrong...' + XMLHttpRequest.responseText);
                            event.preventDefault();
                            return false;
                        }
                    });
                }
            }

        }

        function GetItemDetailsByCode(itemCode, row) {
            var allUnits = [];
            var itemtext = itemCode;
            var Item = itemCode.split("-")[0].trim();

            var ddlWhs = $("select[name='ddlWhs']").val().trim();
            var rowCnt_Material = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblItem  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                var itemCode = $("input[name='AutoMatCodes']", this).val().split("-")[0].trim();
                var LineNum = $("input[name='hdnLineNum']", this).val();
                if (itemCode != "") {
                    if (parseInt(row) != parseInt(LineNum)) {
                        if (Item == itemCode) {
                            cnt = 1;
                            errRow = row;
                            event.preventDefault();
                            return false;
                        }
                    }
                }
                //}

                rowCnt_Material++;
            });

            if (cnt == 1) {
                event.preventDefault();
                return false;
            }

            else {

                $.ajax({
                    url: 'PurchaseOrder.aspx/GetItemDetails',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ txt: itemCode, WhsID: ddlWhs }),

                    success: function (result) {
                        if (result == "") {
                            event.preventDefault();
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoMatCodes']", this).val() == "";
                            event.preventDefault();

                            return false;
                        }
                        else {
                            var units = result.d[0];

                            $("#ddlUnit" + row + " option[value!='0']").remove();

                            for (var i = 0; i < units.length; i++) {
                                $("#ddlUnit" + row).append('<option value="' + units[i].Value + '">' + units[i].Text + '</option>');
                            }

                            var Data = new Array();

                            if ($("#ddlUnit" + row).val() != null)
                                Data = $("#ddlUnit" + row).val().split(',');
                            $('#tdPrice' + row).text(Number(Data[1]).toFixed(2));
                            $('#hdnItemID' + row).val(result.d[1].ItemID);
                            $('#hdnMaterialTaxID' + row).val(result.d[1].TaxID);
                            $('#hdnMaterialUnitPrice' + row).val(Data[1]);
                            $('#hdnMaterialPriceTax' + row).val(Data[2]);

                            $('#hdnDiscountPrice' + row).val(Data[1]);
                            $('#hdnDiscountTax' + row).val(Data[2]);

                            $('#tdAvailable' + row).text(result.d[1].AvailQty);

                            $('#txtReciept' + row).focus();
                            $('#txtReciept' + row).select();

                            CalculateSum();
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        event.preventDefault();
                        return false;
                    }
                });
            }

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
        }
        function CalculateSum(ind) {
            var rowCnt_Material = 1;
            var MainLineTotal = 0;
            var MainTaxTotal = 0;
            var MainSubTotal = 0;
            var MainDiscountTotal = 0;
            var totQTY = 0;
            var ALLQTY = 0;
            var FootAvailable = 0;
            var FootReceipt = 0;
            var FootTotalQty = 0;
            var FootSubTotal = 0;
            var FootTax = 0;
            var FootTotalPrice = 0;

            $('#tblItem  > tbody > tr').each(function (row, tr) {

                if ($("input[name='AutoMatCodes']", this).val() != "" && $("select[name='ddlUnit']", this).val() != null) {
                    var Data = new Array();

                    if ($("select[name='ddlUnit']", this).val().trim() != null)
                        Data = $("select[name='ddlUnit']", this).val().split(',');

                    $(".tdPrice", this).text(Number(Data[1]).toFixed(2));

                    var Price = $(".tdPrice", this).text();
                    if (Price == "") {
                        Price = 0;
                    }

                    var EnterQty = $("input[name='txtReciept']", this).val();
                    if (EnterQty == "") {
                        EnterQty = 0;
                    }

                    var Available = $(".tdAvailable", this).text();
                    if (Available == "") {
                        Available = 0;
                    }


                    $(".tdTotalQty", this).text((EnterQty * Data[3]).toFixed(0));
                    $(".tdTax", this).text((Number(Data[2]) * EnterQty).toFixed(2));

                    $(".tdSubTotal", this).text((Number(Price) * parseFloat(EnterQty)).toFixed(2));
                    $(".tdTotalPrice", this).text((Number($(".tdSubTotal", this).text()) + Number($(".tdTax", this).text())).toFixed(2));


                    if (!$("input[name='txtReciept']", this).is(':disabled')) {
                        $("input[name='hdnDiscountTax']", this).val((Number(Data[2]) * EnterQty).toFixed(2));

                        $("input[name='hdnDiscountSubTotal']", this).val((Number(Price) * parseFloat(EnterQty)).toFixed(2));
                        $("input[name='hdnDiscountTotal']", this).val((Number($(".tdSubTotal", this).text()) + Number($(".tdTax", this).text())).toFixed(2));
                    }


                    FootAvailable = parseFloat(parseFloat(FootAvailable) + parseFloat(Available)).toFixed(0);
                    FootReceipt = parseFloat(parseFloat(FootReceipt) + parseFloat(EnterQty)).toFixed(0);

                    FootTotalQty = parseFloat(parseFloat(FootTotalQty) + parseFloat($(".tdTotalQty", this).text())).toFixed(0);
                    FootSubTotal = parseFloat(parseFloat(FootSubTotal) + parseFloat($(".tdSubTotal", this).text())).toFixed(2);

                    FootTax = parseFloat(parseFloat(FootTax) + parseFloat($(".tdTax", this).text())).toFixed(2);
                    FootTotalPrice = parseFloat(parseFloat(FootTotalPrice) + parseFloat($(".tdTotalPrice", this).text())).toFixed(2);
                }
                else {
                    $("input[name='txtReciept']", this).val("0");
                }
                rowCnt_Material++;
            });

            $("#lblFootAvailable").text(FootAvailable);
            $("#lblFootReceipt").text(FootReceipt);
            $("#lblFootTotalQty").text(FootTotalQty);
            $("#lblFootSubTotal").text(FootSubTotal);
            $("#lblFootTax").text(FootTax);
            $("#lblFootTotalPrice").text(FootTotalPrice);

            $("#txtBillAmount").val(FootSubTotal);
            $("#txtTax").val(FootTax);
            $("#txtTotal").val(FootTotalPrice);
            $("#txtPending").val(FootTotalPrice);
            CalculateSum_General();
        }
        function CalculateSum_General() {

            var SubTotal = $("#txtBillAmount").val();
            if (SubTotal == "") {
                SubTotal = 0;
            }
            var Tax = $("#txtTax").val();
            if (Tax == "") {
                Tax = 0;
            }
            SubTotal = parseFloat(SubTotal) + parseFloat(Tax);

            MainTotal = parseFloat(SubTotal);

            $('#txtRounding').val(Number(Math.round(MainTotal) - MainTotal).toFixed(2));

            MainTotal = Number(MainTotal + Number($('#txtRounding').val())).toFixed(2);

            $("#txtTotal").val(parseFloat(MainTotal).toFixed(2));
            $("#txtPending").val(parseFloat(MainTotal).toFixed(2));
        }
        function CheckDuplicateItem(itemCode, row) {
            var allUnits = [];
            var itemtext = itemCode;
            var Item = itemCode.split("-")[0].trim();
            var ddlWhs = $("select[name='ddlWhs']").val().trim();
            var rowCnt_Material = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblItem  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var itemCode = $("input[name='AutoMatCodes']", this).val().split("-")[0].trim();
                var LineNum = $("input[name='hdnLineNum']", this).val();

                if (itemCode != "") {
                    if (parseInt(row) != parseInt(LineNum)) {
                        if (Item == itemCode) {
                            cnt = 1;
                            errRow = row;
                            $('#AutoMatCodes' + row).val('');
                            errormsg = 'Material = ' + itemCode + ' is already seleted at row : ' + rowCnt_Material;
                            event.preventDefault();
                            return false;
                        }
                    }
                }
                //}

                rowCnt_Material++;
            });

            if (cnt == 1) {
                $('#AutoMatCodes' + row).val('');
                ClearMaterialRow(row);
                ModelMsg(errormsg, 3);
                event.preventDefault();
                return false;
            }

            var ind = $('#CountRowMaterial').val();
            if (ind == row) {
                AddMoreRow();
            }

        }
        function ClearMaterialRow(row) {
            var rowCnt_Material = 1;
            var cnt = 0;
            var lineNum = 0;
            $('#tblItem > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var itemCode = $("input[name='AutoMatCodes']", this).val();
                if (itemCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Material++;
            });

            if (cnt > 1) {
                var rowCnt_Material = 1;
                $('#tblItem > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Material) {
                        var itemCode = $("input[name='AutoMatCodes']", this).val();
                        if (itemCode == "") {
                            $(this).remove();
                            CalculateSum(1);
                        }
                    }

                    rowCnt_Material++;
                });
            }
            $('#tblItem > tbody > tr').each(function (row1, tr) {
                lineNum++;
                $(".txtSrNo", this).text(lineNum);
            });
        }
        function btnSubmit_Click() {

            $.blockUI({
                message: '<img src="../Images/loadingbd.gif" />',
                css: {
                    padding: 0,
                    margin: 0,
                    width: '15%',
                    top: '36%',
                    left: '40%',
                    textAlign: 'center',
                    cursor: 'wait'
                }
            });

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();

            if (!IsValid) {
                $.unblockUI();
                event.preventDefault();
                return false;
            }

            var TableData_Material = [];

            var totalItemcnt = 0;
            var cnt = 0;

            rowCnt_Material = 0;

            $('#tblItem  > tbody > tr').each(function (row, tr) {
                var ItemCode = $("input[name='AutoMatCodes']", this).val();
                if (ItemCode != "" && $("select[name='ddlUnit']", this).val() != null && Number($("input[name='txtReciept']", this).val()) > 0) {
                    totalItemcnt = 1;
                    var Data = $("select[name='ddlUnit']", this).val().trim().split(',');
                    //var UOMName = $("select[name='ddlUnit']", this).val().trim();
                    var Price = $("input[name='hdnDiscountPrice']", this).val();
                    var AvlQty = $(".tdAvailable", this).text();
                    var SubTotal = $("input[name='hdnDiscountSubTotal']", this).val();
                    var txtReciept = $("input[name='txtReciept']", this).val();
                    var TotalQty = $(".tdTotalQty", this).text();
                    var Tax = $("input[name='hdnDiscountTax']", this).val();
                    var Total = $("input[name='hdnDiscountTotal']", this).val();
                    var ItemID = $("input[name='hdnItemID']", this).val();
                    var MainID = $("input[name='hdnMainID']", this).val();
                    var PriceTax = $("input[name='hdnMaterialPriceTax']", this).val();
                    var UnitPrice = $("input[name='hdnMaterialUnitPrice']", this).val();
                    var TaxID = $("input[name='hdnMaterialTaxID']", this).val();

                    if (ItemCode != "" && txtReciept == "0") {
                        cnt = 1;
                        $.unblockUI();
                        errormsg = 'Please enter Reciept Quantity in Row: ' + (parseInt(rowCnt_Material) + 1);
                        event.preventDefault();
                        return false;
                    }

                    var obj = {
                        ItemID: ItemID,
                        ItemCode: ItemCode,
                        Price: Price,
                        AvlQty: AvlQty,
                        txtReciept: txtReciept,
                        TotalQty: TotalQty,
                        SubTotal: SubTotal,
                        Tax: Tax,
                        Total: Total,
                        MainID: MainID,
                        UnitID: Data[0],
                        MapQuantity: Data[3],
                        PriceTax: PriceTax,
                        UnitPrice: UnitPrice,
                        TaxID: TaxID
                    };
                    TableData_Material.push(obj);
                }
                rowCnt_Material++;
            });

            if (totalItemcnt == 0) {
                $.unblockUI();
                ModelMsg("Please select atleast one Item", 3);
                event.preventDefault();
                return false;
            }
            if (cnt == 1) {
                $.unblockUI();
                ModelMsg(errormsg, 3);
                event.preventDefault();
                return false;
            }


            $('#hidJsonInputMaterial').val(JSON.stringify(TableData_Material));

            var TableData_Scheme = [];
            var rowCnt_Scheme = 0;
            var totalItemcnt = 0;
            cnt = 0;

            var ddlWhs = $("select[name='ddlWhs']").val().trim();
            // var Vehicle = $("#txtVehicle").val().trim();
            var SubTotal = $("#txtBillAmount").val();
            var TotalPrice = $("#txtTotal").val();
            var Discount = $('#txtDiscount').val();
            var txtPaid = $('#txtPaid').val();
            var txtBillNumber = $('#txtBillNumber').val();
            var txtRounding = $('#txtRounding').val();
            var txtTax = $('#txtTax').val();
            var txtNotes = $('#txtNotes').val();
            var txtDate = $('#txtDate').val();
            var txtPending = $('#txtPending').val();
            var paidTo = $('#txtPaidTo').val();
            var Division = $("select[name='ddlDivision']").val().trim();
            var postData = {

                ddlWhs: ddlWhs,
                //Vehicle: Vehicle,
                SubTotal: SubTotal,
                Total: TotalPrice,
                Tax: txtTax,
                Paid: txtPaid,
                Discount: Discount,
                BillNumber: txtBillNumber,
                Rounding: txtRounding,
                Notes: txtNotes,
                Date: txtDate,
                Pending: txtPending,
                paidTo: paidTo,
                Division: Division
            }
            $('#hidJsonOrderDetail').val(JSON.stringify(postData));

            var successMSG = false;
            var MaterialData = $('#hidJsonInputMaterial').val();

            var HeaderData = $('#hidJsonOrderDetail').val();
            var successMSG = true;
            if (successMSG == false) {
                $.unblockUI();
                event.preventDefault();
                return false;
            }
            else {
                var successMSG = true;
                var sv = $.ajax({
                    url: 'PurchaseOrder.aspx/SaveData',
                    type: 'POST',
                    //async: false,
                    dataType: 'json',
                    // traditional: true,
                    data: JSON.stringify({ hidJsonInputMaterial: MaterialData, hidJsonInputHeader: HeaderData }),
                    contentType: 'application/json; charset=utf-8'
                });

                var sendcall = 0;
                sv.success(function (result) {

                    if (result.d == "") {
                        $.unblockUI();
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d.indexOf("ERROR=") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d.split('=')[1].trim();
                        ModelMsg(ErrorMsg, 2);
                        event.preventDefault();
                        return false;
                    }
                    if (result.d.indexOf("SUCCESS=") >= 0) {
                        var SuccessMsg = result.d.split('=')[1].trim();
                        var OrderNo = result.d.split('#')[1].trim();
                        sendcall = 1;

                        if (sendcall == 1) {

                            alert(SuccessMsg);
                            location.reload(true);
                            event.preventDefault();
                            return false;
                        }

                    }

                });

                sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                });
            }


        }
        function btnAutoItems_Click() {
            var ddlWhs = $("select[name='ddlWhs']").val().trim();
            var division = $("select[name='ddlDivision']").val().trim();
            if (ddlWhs != 0 && division != 0) {
                $.ajax({
                    url: 'PurchaseOrder.aspx/LoadItems',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ DivisionID: division, WhsID: ddlWhs }),
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    success: function (result) {

                        if (result.d == "") {
                            event.preventDefault();
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            event.preventDefault();
                            return false;
                        }
                        else {
                            Units = result.d[0];
                            gridItems = result.d[1];

                            $('#tblItem  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                            var cnt = 0;
                            $('#CountRowMaterial').val(0);
                            for (var i = 0; i < gridItems.length; i++) {
                                AddMoreRow();
                                cnt = $('#CountRowMaterial').val();

                                $("#ddlUnit" + " option[value!='0']").remove();
                                $("#ddlUnit" + cnt).append('<option value="' + Units[i]["Value"] + '">' + Units[i]["Text"] + '</option>');

                                var Data = new Array();

                                if ($("#ddlUnit" + cnt).val() != null)
                                    Data = $("#ddlUnit" + cnt).val().split(',');
                                var itemCode = gridItems[i]["ItemCode"];
                                $('#AutoMatCodes' + cnt).val(itemCode + "-" + gridItems[i]["ItemName"]);
                                $('#tdPrice' + cnt).text(Number(Data[1]).toFixed(2));
                                $('#hdnItemID' + cnt).val(gridItems[i]["ItemID"]);
                                $('#hdnMaterialTaxID' + cnt).val(gridItems[i]["TaxID"]);
                                $('#hdnMaterialUnitPrice' + cnt).val(Data[1]);
                                $('#hdnMaterialPriceTax' + cnt).val(Data[2]);

                                $('#hdnDiscountPrice' + cnt).val(Data[1]);
                                $('#hdnDiscountTax' + cnt).val(Data[2]);

                                $('#tdAvailable' + cnt).text(gridItems[i]["AvailQty"]);

                                $('#txtReciept' + cnt).focus();
                                $('#txtReciept' + cnt).select();

                            }
                            var main = $('.tblItem');
                            var FooterContainer = $(main).find('.table-header-gradient');

                            FooterContainer.find('#lblFootAvailable').val('0.0');
                            FooterContainer.find('#lblFootReceipt').val('0.0');
                            FooterContainer.find('#lblFootTotalQty').val('0.0');
                            FooterContainer.find('#lblFootSubTotal').val('0.0');
                            FooterContainer.find('#lblFootTax').val('0.0');
                            FooterContainer.find('#lblFootTotalPrice').val('0.0');

                            //isNaN(SubTotal) ? SubTotal = 0 : 0;
                            //isNaN(Tax) ? Tax = 0 : 0;
                            //isNaN(TotalPrice) ? TotalPrice = 0 : 0;

                            $('.txtBillAmount').val('0.0');
                            $('.txtTax').val('0.0');
                            $('.txtTotal').val('0.0');
                            $('.txtRounding').val('0.0');
                            $('.txtPending').val('0.0');
                        }
                        AddMoreRow();
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {

                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        event.preventDefault();
                        return false;
                    }
                });
            }
            else {
                ModelMsg("Select Division and WareHouse", 3);
            }
        }
        function btnItemWiseEntry_Click() {
            $('#tblItem tbody > tr').remove();
            AddMoreRow();
            //$('.btnExcelUpload').removeAttr('style');
            //$('.btnDownload').removeAttr('style');
        }
        function btnAllActiveItem_Click() {
            $('#tblItem tbody > tr').remove();
            AddMoreRow();
            $('.btnExcelUpload').attr('style', 'display:none;');
            $('.btnDownload').attr('style', 'display:none;');
            ItemLoadonButton(1);
        }
        function btnLastFivePO_Click() {
            $('#tblItem tbody > tr').remove();
            AddMoreRow();
            $('.btnExcelUpload').attr('style', 'display:none;');
            $('.btnDownload').attr('style', 'display:none;');
            ItemLoadonButton(2);
        }
        function btnExcelUpload_Click() {
            $('#myCopyModal').modal();
        }
        function btnDownload_Click() {
            window.open("../Document/CSV Formats/BulkUploadPOEntry.csv");
        }
        function ItemLoadonButton(Option) {

            $.blockUI({
                message: '<img src="../Images/loadingbd.gif" />',
                css: {
                    padding: 0,
                    margin: 0,
                    width: '15%',
                    top: '36%',
                    left: '40%',
                    textAlign: 'center',
                    cursor: 'wait'
                }
            });

            var ddlWhs = $("select[name='ddlWhs']").val().trim();
            var division = $("select[name='ddlDivision']").val().trim();
            if (ddlWhs != 0 && division != 0) {
                $.ajax({
                    url: 'PurchaseOrder.aspx/LoadItemsOnDemand',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ DivisionID: division, WhsID: ddlWhs, OptionId: Option }),
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    success: function (result) {
                        $.unblockUI();
                        if (result.d == "") {
                            $.unblockUI();
                            event.preventDefault();
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            $.unblockUI();
                            ModelMsg(ErrorMsg, 3);

                            event.preventDefault();
                            return false;
                        }
                        else {
                            Units = result.d[0];
                            gridItems = result.d[1];

                            $('#tblItem  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                            var cnt = 0;
                            $('#CountRowMaterial').val(0);
                            for (var i = 0; i < gridItems.length; i++) {
                                AddMoreRow();
                                cnt = $('#CountRowMaterial').val();

                                $("#ddlUnit" + " option[value!='0']").remove();
                                $("#ddlUnit" + cnt).append('<option value="' + Units[i]["Value"] + '">' + Units[i]["Text"] + '</option>');

                                var Data = new Array();

                                if ($("#ddlUnit" + cnt).val() != null)
                                    Data = $("#ddlUnit" + cnt).val().split(',');
                                var itemCode = gridItems[i]["ItemCode"];
                                $('#AutoMatCodes' + cnt).val(itemCode + "-" + gridItems[i]["ItemName"]);
                                $('#tdPrice' + cnt).text(Number(Data[1]).toFixed(2));
                                $('#hdnItemID' + cnt).val(gridItems[i]["ItemID"]);
                                $('#hdnMaterialTaxID' + cnt).val(gridItems[i]["TaxID"]);
                                $('#hdnMaterialUnitPrice' + cnt).val(Data[1]);
                                $('#hdnMaterialPriceTax' + cnt).val(Data[2]);

                                $('#hdnDiscountPrice' + cnt).val(Data[1]);
                                $('#hdnDiscountTax' + cnt).val(Data[2]);

                                $('#tdAvailable' + cnt).text(gridItems[i]["AvailQty"]);

                                $('#txtReciept' + cnt).focus();
                                $('#txtReciept' + cnt).select();

                            }
                            var main = $('.tblItem');
                            var FooterContainer = $(main).find('.table-header-gradient');

                            FooterContainer.find('#lblFootAvailable').val('0.0');
                            FooterContainer.find('#lblFootReceipt').val('0.0');
                            FooterContainer.find('#lblFootTotalQty').val('0.0');
                            FooterContainer.find('#lblFootSubTotal').val('0.0');
                            FooterContainer.find('#lblFootTax').val('0.0');
                            FooterContainer.find('#lblFootTotalPrice').val('0.0');

                            //isNaN(SubTotal) ? SubTotal = 0 : 0;
                            //isNaN(Tax) ? Tax = 0 : 0;
                            //isNaN(TotalPrice) ? TotalPrice = 0 : 0;

                            $('.txtBillAmount').val('0.0');
                            $('.txtTax').val('0.0');
                            $('.txtTotal').val('0.0');
                            $('.txtRounding').val('0.0');
                            $('.txtPending').val('0.0');
                        }
                        AddMoreRow();
                    },
                    scroller: {
                        loadingIndicator: true
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        $.unblockUI();
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        event.preventDefault();
                        return false;
                    }
                });
            }
            else {
                ModelMsg("Select Division and WareHouse", 3);
            }
        }
        function UploadFile() {
            var fileUpload = $("#fileToUpload").get(0);
            var files = fileUpload.files;

            var fileData = new FormData();

            fileData.append(files[0].name, files[0]);

            $.ajax({
                url: '/Test/uploadFile',
                type: 'post',
                datatype: 'json',
                contentType: false,
                processData: false,
                async: false,
                data: fileData,
                success: function (response) {
                    alert(response);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">

                    <input type="hidden" id="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                    <input type="hidden" id="hidJsonOrderDetail" name="hidJsonOrderDetail" value="" />

                    <div class="input-group form-group">
                        <label class="input-group-addon">Order Date</label>
                        <input type="text" id="txtDate" name="txtDate" disabled="disabled" class="datepick form-control" tabindex="8" />

                    </div>
                </div>
                <div class="col-lg-5">
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Warehouse</label>
                        <select id="ddlWhs" name="ddlWhs" class="form-control" tabindex="2"></select>

                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Division # Plant</label>
                        <select id="ddlDivision" name="ddlDivision" class="form-control" onchange="OnDivisionChange()" tabindex="3"></select>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Bill Number</label>
                        <input type="text" class="form-control" tabindex="4" disabled="disabled" id="txtBillNumber" name="txtBillNumber" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Vendor</label>
                        <input type="text" class="form-control" tabindex="4" disabled="disabled" runat="server" id="txtVendor" name="txtVendor" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Vehicle No.</label>
                        <input type="text" class="form-control" tabindex="3" id="txtVehicle" style="background-color: rgb(250, 255, 189);" name="txtVehicle" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Template</label>
                        <input type="text" class="form-control" id="txtTemplate" name="txtTemplate" style="background-color: rgb(250, 255, 189);" tabindex="5" />
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Notes</label>
                        <textarea name="txtNotes" id="txtNotes" cols="40" rows="2" class="form-control" tabindex="17"></textarea>
                    </div>
                </div>
            </div>
            <%--  <input class="btn btn-default" id="btnAutoItems" type="button" value="Auto Order" onclick="btnAutoItems_Click()" />
            <input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="Cancel()" class="btn btn-default" tabindex="19" style="float:right;" />
            <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btn btn-default" onclick="btnSubmit_Click()" tabindex="18" style="float:right;margin-right: 3px;" />--%>

            <input class="btn btn-default" id="btnAutoItems" type="button" value="Auto Order" onclick="btnAutoItems_Click()" />
            <input class="btn btn-default btnItemWiseEntry" id="btnItemWiseEntry" type="button" value="Item Wise Entry" onclick="btnItemWiseEntry_Click()" />
            <input class="btn btn-default btnAllActiveItem" id="btnAllActiveItem" type="button" value="All Active Item Display" onclick="btnAllActiveItem_Click()" />
            <input class="btn btn-default btnLastFivePO" id="btnLastFivePO" type="button" value="Last 5 PO Unique Item Display" onclick="btnLastFivePO_Click()" />
            <input class="btn btn-default btnExcelUpload" id="btnExcelUpload" type="button" value="Excel Upload" onclick="btnExcelUpload_Click()" style="display: none;" />
            <input class="btn btn-default btnDownload" id="btnDownload" type="button" value="Download Format" onclick="btnDownload_Click()" style="display: none;" />
            <input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="Cancel()" class="btn btn-default" tabindex="19" style="float: right;" />
            <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btn btn-default" onclick="btnSubmit_Click()" tabindex="18" style="float: right; margin-right: 3px;" />

            <br />
            <input type="hidden" id="CountRowMaterial" />
            <div id="tbl">
                <table id="tblItem" class="table" border="1" tabindex="6">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 3%;">Sr</th>
                            <th style="width: 40%;">Item Code & Name</th>
                            <th style="width: 10%">Unit</th>
                            <th style="width: 6%; text-align: right;">Rate</th>
                            <th style="width: 6%; text-align: right;">Stock</th>
                            <th style="width: 6%; text-align: right;">Order</th>
                            <th style="width: 6%; text-align: right;">Total Qty</th>
                            <th style="width: 8%; text-align: right;">Gross Amt</th>
                            <th style="width: 6%; text-align: right;">GST</th>
                            <th style="width: 8%; text-align: right;">Net Amount</th>
                            <th style="display: none">ID</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                    <tfoot>
                        <tr class="table-header-gradient">
                            <th></th>
                            <th></th>
                            <th></th>
                            <th></th>
                            <th>
                                <label id="lblFootAvailable" class="lblFootAvailable" style="display: none"></label>
                            </th>
                            <th>
                                <label id="lblFootReceipt" class="lblFootReceipt"></label>
                            </th>
                            <th>
                                <label id="lblFootTotalQty" class="lblFootTotalQty"></label>
                            </th>
                            <th>
                                <label id="lblFootSubTotal" class="lblFootSubTotal"></label>
                            </th>
                            <th>
                                <label id="lblFootTax" class="lblFootTax"></label>
                            </th>
                            <th>
                                <label id="lblFootTotalPrice" class="lblFootTotalPrice"></label>
                            </th>

                            <th style="display: none">ID</th>
                        </tr>
                    </tfoot>
                </table>
            </div>
            <div class="row" style="display: none;">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon" style="text-align: right;">Gross Amount</label>
                        <input type="text" id="txtBillAmount" name="txtBillAmount" class="txtBillAmount form-control" value="0.0" tabindex="9" style="text-align: right;" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon" style="text-align: right;">GST Amount</label>
                        <input type="text" id="txtTax" name="txtTax" class="txtTax form-control" value="0.0" tabindex="10" style="text-align: right;" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon" style="text-align: right;">Rounding</label>
                        <input type="text" id="txtRounding" name="txtRounding" class="txtRounding form-control" value="0.0" tabindex="11" style="text-align: right;" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon" style="text-align: right;">Net Amount</label>
                        <input type="text" id="txtTotal" name="txtTotal" class="txtTotal form-control" value="0.0" tabindex="12" style="text-align: right;" />
                    </div>
                </div>
                <div class="col-lg-3 _textArea">
                    <div class="col-lg-4" style="display: none;">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Paid</label>
                            <input type="text" id="txtPaid" name="txtPaid" class="txtPaid form-control" value="0.0" tabindex="13" />
                        </div>
                        <div class="input-group form-group">
                            <label class="input-group-addon">Pending</label>
                            <input type="text" id="txtPending" name="txtPending" class="txtPending form-control" value="0.0" tabindex="14" />
                        </div>
                        <div class="input-group form-group">
                            <label class="input-group-addon">Paid To</label>
                            <input type="text" id="txtPaidTo" name="txtPaidTo" class="txtPaidTo form-control" tabindex="15" />
                        </div>
                        <div class="input-group form-group" style="display: none;">
                            <label class="input-group-addon">Discount</label>
                            <input type="text" id="txtDiscount" name="txtDiscount" class="txtDiscount form-control" value="0.0" tabindex="16" />
                        </div>
                    </div>
                </div>

            </div>

        </div>

    </div>
    <!-- Modal -->
    <!-- Bootstrap Modal Dialog -->
    <div class="modal fade" id="myCopyModal" role="dialog" aria-labelledby="myCopyModalLabel" aria-hidden="true" tabindex='-1'>
        <div class="modal-dialog" style="width: 30% !important;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" onclick="CloseModal()" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">
                        <asp:Label ID="lblModalTitle" runat="server" Text="Upload CSV File of Item For  Purchase Order"></asp:Label></h4>
                </div>
                <div class="modal-body" style="height: 60px !important;">
                    <div class="col-lg-12">
                        <div class="input-group form-group">
                            <asp:Label ID="lblfromDateSeq" runat="server" Text="Select File" CssClass="input-group-addon"></asp:Label>
                            <asp:FileUpload ID="flCUpload" runat="server" CssClass="form-control" />
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="saveData" CommandName="saveData" runat="server" Text="Submit" CssClass="btn btn-default" OnClick="btnSaveData_Click" />
                </div>
            </div>
        </div>
    </div>
    <!-- /.modal -->
</asp:Content>

