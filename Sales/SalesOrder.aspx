<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="SalesOrder.aspx.cs" Inherits="Sales_SalesOrder" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <style>
        .req:after {
            content: "*";
            color: red;
        }

        .search {
            background-color: lightyellow;
        }

        table#tblMaterialDetail {
            width: 100%;
            margin-top: 0px !important;
            margin-bottom: 0px !important;
            position: relative;
        }

            table#tblMaterialDetail tbody {
                width: 100%;
            }

            table#tblMaterialDetail thead tr {
                position: relative;
            }

            table#tblMaterialDetail tfoot tr {
                position: relative;
            }

        .border-la {
            float: left;
            width: 100%;
            height: 1px;
            padding-right: 10px;
            background: #000;
        }
    </style>
    <script type="text/javascript">

        //$('#CountRowMaterial').val(0);

        var availableCustomer_temp = [];
        var availableCustomer = [];
        var availableTemplate = [];
        var availableVehicle = [];
        var availableOrderForm = [];
        var availableItems = [];

        $(document).ready(function () {

            $("#tblMaterialDetail").tableHeadFixer('60vh');

            $('#CountRowMaterial').val(0);
            $('#AutoOrderForm').val("");

            ClearControls();

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

            $.ajax({
                url: 'SalesOrder.aspx/LoadData',
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
                        return false;
                    }
                    else {

                        var customer = result.d[0];
                        var template = result.d[1];
                        var vehicle = result.d[2];
                        var orderform = result.d[3];
                        var warehouse = result.d[4];
                        var tempcustomer = result.d[5];

                        availableCustomer_temp = [];
                        availableCustomer = [];
                        availableTemplate = [];
                        availableVehicle = [];
                        availableOrderForm = [];

                        for (var i = 0; i < tempcustomer.length; i++) {
                            availableCustomer_temp.push(tempcustomer[i]);
                        }

                        for (var i = 0; i < customer.length; i++) {
                            availableCustomer.push(customer[i]);
                        }

                        for (var i = 0; i < template.length; i++) {
                            availableTemplate.push(template[i]);
                        }

                        for (var i = 0; i < vehicle.length; i++) {
                            availableVehicle.push(vehicle[i]);
                        }

                        for (var i = 0; i < orderform.length; i++) {
                            availableOrderForm.push(orderform[i]);
                        }

                        $("#ddlWhs option[value!='0']").remove();

                        for (var i = 0; i < warehouse.length; i++) {
                            $("#ddlWhs").append('<option value="' + warehouse[i].Value + '">' + warehouse[i].Text + '</option>');
                        }

                        $("#AutoCustomer").autocomplete({
                            source: availableCustomer,
                            minLength: 0,
                            scroll: true
                        });
                        $("#AutoCustomer").on('change keyup', function () {
                            var data = $("#AutoCustomer").val();
                            if (data == "") {
                                //ClearControls();
                            }
                        });

                        $('#AutoCustomer').on('change', function () {
                            $('#AutoCustomer').val(this.value);
                            if (this.value != "") {
                                GetItemCustomerWise(this.value);
                            }
                        }).change();

                        $('#AutoCustomer').on('autocompleteselect', function (e, ui) {
                            $('#AutoCustomer').val(ui.item.value);
                            GetItemCustomerWise(ui.item.value);
                        });

                        $("#AutoTemplate").autocomplete({
                            source: availableTemplate,
                            minLength: 0,
                            scroll: true
                        });

                        $("#AutoVehicle").autocomplete({
                            source: availableVehicle,
                            minLength: 0,
                            scroll: true
                        });

                        $("#AutoOrderForm").autocomplete({
                            source: availableOrderForm,
                            minLength: 0,
                            scroll: true
                        });

                        $('#AutoOrderForm').on('change', function () {
                            if ($('#AutoOrderForm').val() != "") {
                                FillOrder($('#AutoOrderForm').val().split("-")[0].trim());
                            }
                        });

                        $('#AutoOrderForm').on('autocompleteselect', function (e, ui) {
                            $('#AutoOrderForm').val(ui.item.value);
                            FillOrder(ui.item.value.split("-")[0].trim());
                        });
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });

        });

        function ClearControls() {

            SetReadOnly(false);

            $('#AutoOrderForm').val('');
            $("#chkExisting").val('0');
            $("#chkTemp").val('0');
            $("#AutoCustomer").val('');
            $("#AutoVehicle").val('');
            $("#txtMobile").val('');

            var today = '<%=DateTime.Now.ToShortDateString()%>';

            $('#txtDate').val(today);

            $("#txtSubTotal").val(0);
            $("#txtTax").val(0);
            $("#txtRounding").val(0);
            $("#txtTotal").val(0);
            $("#txtPending").val(0);
            $("#txtNotes").val(0);

            $("#txtSearchMaterial").val('');
            var cnt = 1;
            $("#tblMaterialDetail > tbody > tr").each(function () {
                if (cnt > 0) {
                    $(this).remove();
                }// remove other rows except first row.
            });

            $('#CountRowMaterial').val('0');
            AddMoreRowMaterial();
            CalculateSum(1);
        }

        function FillOrder(odrderid) {
            var cnt = 1;
            $("#tblMaterialDetail > tbody > tr").each(function () {
                if (cnt > 0) {
                    $(this).remove();       // remove other rows except first row.
                }
                cnt++;
            });
            $('#CountRowMaterial').val(0);

            $.ajax({
                url: 'SalesOrder.aspx/GetOrder',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ odrderID: odrderid }),

                success: function (result) {
                    if (result == "") {
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
                        $("#AutoCustomer").val(result.d[0]);
                        $("#AutoVehicle").val(result.d[1]);
                        $("#body_txtBillNumber").val(result.d[2]);
                        $("#body_txtNotes").val(result.d[3]);
                        $("#txtMobile").val(result.d[4]);

                        $('#chkTemp').prop('checked', result.d[6]);

                        GetItemCustomerWise(result.d[0].split('-')[0].trim())

                        cnt = 1;
                        for (var i = 0; i < result.d[5].length; i++) {

                            AddMoreRowMaterial();

                            $('#AutoMatCodes' + cnt).val(result.d[5][i].ItemCode);
                            GetItemDetailsByCode(result.d[5][i].ItemCode, cnt);

                            $('#tdPrice' + cnt).text(result.d[5][i].PRICE);
                            $('#txtReqQty' + cnt).val(result.d[5][i].Quantity);
                            $('#hdnMainID' + cnt).val(result.d[5][i].MainID);
                            $('#hdnMaterialTaxID' + cnt).val(result.d[5][i].TaxID);
                            CalculateSum(cnt);
                            $('#hdnDiscountPrice' + cnt).val(result.d[5][i].Price);
                            $('#hdnDiscountTax' + cnt).val(result.d[5][i].Tax);
                            $('#hdnDiscountSubTotal' + cnt).val(result.d[5][i].SubTotal);
                            $('#hdnDiscountTotal' + cnt).val(result.d[5][i].Total);
                            cnt++;
                        }

                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });

            AddMoreRowMaterial();
        }



        function GetItemCustomerWise(custCode) {
            if (custCode != "") {

                var customerCode = custCode.split('-')[0].trim();
                var ddlWhs = $("select[name='ddlWhs']").val();
                var chktemp = $('#chkTemp').is(':checked');
                var chkexisting = $('#chkExisting').is(':checked');

                $.ajax({
                    url: 'SalesOrder.aspx/LoadItemsCustomerWise',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ CustomerCode: customerCode, WareHouse: ddlWhs, ChkTemp: chktemp, chkExisting: chkexisting }),

                    success: function (result) {
                        if (result == "") {
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
                            var items = result.d[0];

                            availableItems = [];

                            for (var i = 0; i < items.length; i++) {
                                availableItems.push(items[i]);
                            }

                            $("#AutoMatCodes1").autocomplete({
                                source: availableItems,
                                minLength: 0,
                                scroll: true
                            });

                            $("#txtMobile").val(result.d[1]);
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        event.preventDefault();
                        return false;
                    }
                });
            }
        }

        function summary() {

            var Total = Number($('.txtSubTotal').val()) + Number($('.txtTax').val());

            $('.txtRounding').val(Number(Math.round(Total) - Total).toFixed(2));

            $('.txtTotal').val(Number(Total + Number($('.txtRounding').val())).toFixed(2));

            $('.txtPending').val(Number(Number($('.txtTotal').val())).toFixed(2));
        }

        function AddMoreRowMaterial() {

            $('table#tblMaterialDetail tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowMaterial').val();
            ind = parseInt(ind) + 1;
            $('#CountRowMaterial').val(ind);

            var str = "";
            str = "<tr id='trMaterial" + ind + "'>"
                + "<td><input type='text' id='AutoMatCodes" + ind + "' name='AutoMatCode' class='form-control search' /></td>"
                + "<td><select id='ddlUnit" + ind + "' name='ddlUnit' class='form-control' /></td>"
                + "<td id='tdPrice" + ind + "' class='tdPrice'></td>"
                + "<td id='tdAvailable" + ind + "' class='tdAvailable'></td>"
                + "<td><input type='text' id='txtReqQty" + ind + "' name='txtReqQty' maxlength='10' value='0' class='form-control allownumericwithdecimal' onfocus='SetQtyDataFocus(this);' onblur='SetQtyDataBlur(this);' /></td>"
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

            $('#tblMaterialDetail > tbody').append(str);


            $('#ddlUnit' + ind).on('change', function () {
                SetUnitPrice(ind);
            });

            $("#AutoMatCodes" + ind).autocomplete({
                source: availableItems,
                minLength: 0,
                scroll: true
            });

            $('#AutoMatCodes' + ind).on('change keyup', function () {
                if ($('#AutoMatCodes' + ind).val() == "") {
                    ClearMaterialRow(ind);
                }
            });

            $('#AutoMatCodes' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoMatCodes' + ind).val(ui.item.value);
                GetItemDetailsByCode(ui.item.value, ind);
            });

            $('#AutoMatCodes' + ind).on('blur', function (e, ui) {
                if ($('#AutoMatCodes' + ind).val().trim() != "")
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
            });


            $("#txtReqQty" + ind).on('change keyup paste', function (event) {
                CalculateSum(ind);

            });

            // allow decimal values only
            $(".allownumericwithdecimal").keydown(function (e) {
                // Allow: backspace, delete, tab, escape, enter
                if ($.inArray(e.keyCode, [46, 8, 9, 13]) !== -1 ||
                    // Allow: Ctrl+A, Command+A
                    ((e.keyCode == 65) && (e.metaKey === true)) ||
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
            var FootDispatch = 0;
            var FootTotalQty = 0;
            var FootSubTotal = 0;
            var FootTax = 0;
            var FootTotalPrice = 0;

            $('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {

                if ($("input[name='AutoMatCode']", this).val() != "") {
                    var Data = new Array();

                    if ($("select[name='ddlUnit']", this).val() != null)
                        Data = $("select[name='ddlUnit']", this).val().split(',');

                    $(".tdPrice", this).text(Data[1]);

                    var Price = $(".tdPrice", this).text();
                    if (Price == "") {
                        Price = 0;
                    }

                    var EnterQty = $("input[name='txtReqQty']", this).val();
                    if (EnterQty == "") {
                        EnterQty = 0;
                    }

                    var Available = $(".tdAvailable", this).text();
                    if (Available == "") {
                        Available = 0;
                    }


                    $(".tdTotalQty", this).text((EnterQty * Data[3]).toFixed(2));
                    $(".tdTax", this).text((Number(Data[2]) * EnterQty).toFixed(2));

                    $(".tdSubTotal", this).text((Number(Price) * parseFloat(EnterQty)).toFixed(2));
                    $(".tdTotalPrice", this).text((Number($(".tdSubTotal", this).text()) + Number($(".tdTax", this).text())).toFixed(2));


                    if (!$("input[name='txtReqQty']", this).is(':disabled')) {
                        $("input[name='hdnDiscountTax']", this).val((Number(Data[2]) * EnterQty).toFixed(2));

                        $("input[name='hdnDiscountSubTotal']", this).val((Number(Price) * parseFloat(EnterQty)).toFixed(2));
                        $("input[name='hdnDiscountTotal']", this).val((Number($(".tdSubTotal", this).text()) + Number($(".tdTax", this).text())).toFixed(2));
                    }


                    FootAvailable = parseFloat(parseFloat(FootAvailable) + parseFloat(Available)).toFixed(2);
                    FootDispatch = parseFloat(parseFloat(FootDispatch) + parseFloat(EnterQty)).toFixed(2);

                    FootTotalQty = parseFloat(parseFloat(FootTotalQty) + parseFloat($(".tdTotalQty", this).text())).toFixed(2);
                    FootSubTotal = parseFloat(parseFloat(FootSubTotal) + parseFloat($(".tdSubTotal", this).text())).toFixed(2);

                    FootTax = parseFloat(parseFloat(FootTax) + parseFloat($(".tdTax", this).text())).toFixed(2);
                    FootTotalPrice = parseFloat(parseFloat(FootTotalPrice) + parseFloat($(".tdTotalPrice", this).text())).toFixed(2);
                }
                rowCnt_Material++;
            });

            $("#lblFootAvailable").text(FootAvailable);
            $("#lblFootDispatch").text(FootDispatch);
            $("#lblFootTotalQty").text(FootTotalQty);
            $("#lblFootSubTotal").text(FootSubTotal);
            $("#lblFootTax").text(FootTax);
            $("#lblFootTotalPrice").text(FootTotalPrice);

            $("#txtSubTotal").val(FootSubTotal);
            $("#txtTax").val(FootTax);
            $("#txtTotal").val(FootTotalPrice);
            $("#txtPending").val(FootTotalPrice);
            CalculateSum_General();
        }

        function GetItemDetailsByCode(itemCode, row) {
            var allUnits = [];
            var itemtext = itemCode;
            var Item = itemCode.split("-")[0].trim();
            var customercode = $("#AutoCustomer").val().split("-")[0].trim();
            var ddlWhs = $("select[name='ddlWhs']").val();
            var rowCnt_Material = 1;
            var cnt = 0;
            var errRow = 0;
            var chktemp = $('#chkTemp').is(':checked');
            var chkexisting = $('#chkExisting').is(':checked');

            $('#tblMaterialDetail  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var itemCode = $("input[name='AutoMatCode']", this).val().split("-")[0].trim();
                //var isActive = $("input[name='txtisDeleteIDMaterial']", this).val();
                var LineNum = $("input[name='hdnLineNum']", this).val();
                //if (isActive == 'true') {
                if (itemCode != "") {
                    if (parseInt(row) != parseInt(LineNum)) {
                        if (Item == itemCode) {
                            cnt = 1;
                            errRow = row;
                            //$("input[name='AutoMatCode']", this).val('');                            
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
                    url: 'SalesOrder.aspx/GetItemDetails',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ itemCode: Item, customer: customercode, WareHouse: ddlWhs, ChkTemp: chktemp, chkExisting: chkexisting }),

                    success: function (result) {
                        if (result == "") {
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
                            var units = result.d[0];

                            $("#ddlUnit" + row + " option[value!='0']").remove();

                            for (var i = 0; i < units.length; i++) {
                                $("#ddlUnit" + row).append('<option value="' + units[i].Value + '">' + units[i].Text + '</option>');
                            }

                            var Data = new Array();

                            if ($("#ddlUnit" + row).val() != null)
                                Data = $("#ddlUnit" + row).val().split(',');


                            $('#tdPrice' + row).text(Data[1]);
                            $('#hdnItemID' + row).val(result.d[1].ItemID);
                            $('#hdnMaterialTaxID' + row).val(result.d[1].TaxID);
                            $('#hdnMaterialUnitPrice' + row).val(Data[1]);
                            $('#hdnMaterialPriceTax' + row).val(Data[2]);

                            $('#hdnDiscountPrice' + row).val(Data[1]);
                            $('#hdnDiscountTax' + row).val(Data[2]);

                            $('#tdAvailable' + row).text(result.d[1].AvailQty);

                            $('#txtReqQty' + row).focus();
                            $('#txtReqQty' + row).select();
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

        function CheckDuplicateItem(itemCode, row) {
            var allUnits = [];
            var itemtext = itemCode;
            var Item = itemCode.split("-")[0].trim();
            var customercode = $("#AutoCustomer").val().split("-")[0].trim();
            var ddlWhs = $("select[name='ddlWhs']").val();
            var rowCnt_Material = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblMaterialDetail  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var itemCode = $("input[name='AutoMatCode']", this).val().split("-")[0].trim();
                var LineNum = $("input[name='hdnLineNum']", this).val();
                //var isActive = $("input[name='txtisDeleteIDMaterial']", this).val();

                //if (isActive == 'true') {
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
                AddMoreRowMaterial();
            }

        }

        function ClearMaterialRow(row) {
            var rowCnt_Material = 1;
            var cnt = 0;
            $('#tblMaterialDetail > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var itemCode = $("input[name='AutoMatCode']", this).val();
                if (itemCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Material++;
            });

            if (cnt > 1) {
                var rowCnt_Material = 1;
                $('#tblMaterialDetail > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Material) {
                        var itemCode = $("input[name='AutoMatCode']", this).val();
                        if (itemCode == "") {
                            $(this).remove();
                            CalculateSum(1);
                        }
                    }

                    rowCnt_Material++;
                });
            }

        }

        function SetUnitPrice(row) {
            CalculateSum(row);
        }

        function SetExistingCheckboxValue(obj) {

            $("#chkTemp").attr('disabled', false);

            $("#AutoCustomer").val('');
            $('#txtMobile').val('');

            if ($('#chkExisting').is(":checked")) {

                $("#AutoCustomer").addClass('search');

                if ($('#chkTemp').is(":checked")) {

                    $("#AutoCustomer").autocomplete({
                        source: availableCustomer_temp,
                        minLength: 0,
                        scroll: true
                    });
                }
                else {
                    $("#AutoCustomer").autocomplete({
                        source: availableCustomer,
                        minLength: 0,
                        scroll: true
                    });

                }
            }
            else {
                $('#chkTemp').prop('checked', true);
                $("#chkTemp").attr('disabled', true);

                $("#AutoCustomer").removeClass('search');

                $("#AutoCustomer").autocomplete({
                    source: '',
                    minLength: 0,
                    scroll: true
                });

            }
        }

        function SetReadOnly(readonly) {

            $("#chkExisting").attr('disabled', readonly);
            $("#chkTemp").attr('disabled', readonly);
            $("#AutoCustomer").attr('disabled', readonly);
        }

        function CalculateSum_General() {

            var SubTotal = $("#txtSubTotal").val();
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
            //var rowCnt_Material = 1;
            var totalItemcnt = 0;
            var cnt = 0;
            //$('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {
            //    var MainID = $("input[name='hdnMainID']", this).val();
            //    if (MainID == "1") {
            //        $(this).remove();
            //    }
            //    rowCnt_Material++;
            //});

            rowCnt_Material = 0;

            $('#tblMaterialDetail  > tbody > tr').each(function (row, tr) {
                var ItemCode = $("input[name='AutoMatCode']", this).val();
                if (ItemCode != "") {
                    totalItemcnt = 1;
                    var Data = $("select[name='ddlUnit']", this).val().split(',');
                    var UOMName = $("select[name='ddlUnit']", this).val();
                    var Price = $("input[name='hdnDiscountPrice']", this).val();
                    var AvlQty = $(".tdAvailable", this).text();
                    var SubTotal = $("input[name='hdnDiscountSubTotal']", this).val();
                    var RequestQty = $("input[name='txtReqQty']", this).val();
                    var TotalQty = $(".tdTotalQty", this).text();
                    var Tax = $("input[name='hdnDiscountTax']", this).val();
                    var Total = $("input[name='hdnDiscountTotal']", this).val();
                    var ItemID = $("input[name='hdnItemID']", this).val();
                    var MainID = $("input[name='hdnMainID']", this).val();
                    var PriceTax = $("input[name='hdnMaterialPriceTax']", this).val();
                    var UnitPrice = $("input[name='hdnMaterialUnitPrice']", this).val();
                    var TaxID = $("input[name='hdnMaterialTaxID']", this).val();

                    if (ItemCode != "" && RequestQty == "0") {
                        cnt = 1;
                        $.unblockUI();
                        errormsg = 'Please enter Order Quantity in Row: ' + (parseInt(rowCnt_Material) + 1);
                        event.preventDefault();
                        return false;
                    }

                    var obj = {
                        ItemID: ItemID,
                        ItemCode: ItemCode,
                        Price: Price,
                        AvlQty: AvlQty,
                        RequestQty: RequestQty,
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

            var totalItemcnt = 0;
            cnt = 0;

            var AutoCustomer = $('#AutoCustomer').val().split("-")[0].trim();
            var AutoTemplate = $('#AutoTemplate').val();
            var AutoVehicle = $('#AutoVehicle').val().split("-")[0].trim();
            var AutoOrderForm = $('#AutoOrderForm').val().split("-")[0].trim();
            var ChkTemp = $('#chkTemp').is(':checked');
            var chkExisting = $('#chkExisting').is(':checked');

            var ddlWhs = $("select[name='ddlWhs']").val();

            var SubTotal = $("#txtSubTotal").val();
            var TotalPrice = $("#txtTotal").val();

            var txtBillNumber = $('#body_txtBillNumber').val();
            var txtRounding = $('#txtRounding').val();
            var txtTax = $('#txtTax').val();
            var txtNotes = $('#body_txtNotes').val();

            var txtMobile = $('#txtMobile').val();
            var txtDate = $('#txtDate').val();
            var txtPending = $('#txtPending').val();

            var postData = {
                AutoCustomer: AutoCustomer,
                AutoTemplate: AutoTemplate,
                AutoVehicle: AutoVehicle,
                AutoOrderForm: AutoOrderForm,
                ChkTemp: ChkTemp,
                chkExisting: chkExisting,
                ddlWhs: ddlWhs,
                SubTotal: SubTotal,
                Total: TotalPrice,
                Tax: txtTax,
                BillNumber: txtBillNumber,
                Rounding: txtRounding,
                Notes: txtNotes,
                Mobile: txtMobile,
                Date: txtDate,
                Pending: txtPending
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
                    url: 'SalesOrder.aspx/SaveData',
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

                        alert(SuccessMsg);
                        location.reload(true);
                        event.preventDefault();
                        return false;
                    }
                });

                sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                });
            }

            if (sendcall == 0) {
                $.unblockUI();
                event.preventDefault();
                sendcall = 1;
                return false;
            }
        }

        function chkUpdate(chk) {

            ClearControls();

            if ($(chk).is(':checked')) {

                SetReadOnly(false);

                $('.divtxtDate').show();
                $('.divtxtDocNo').hide();
            }
            else {

                SetReadOnly(true);

                $('.divtxtDate').hide();
                $('.divtxtDocNo').show();
            }

        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="chkUpdate(this);" data-size="large" data-on-text="Add" data-off-text="Update" id="chkMode" checked="checked" tabindex="1" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <input type="hidden" id="hidJsonInputMaterial" name="hidJsonInputMaterial" value="" />
                <input type="hidden" id="hidJsonOrderDetail" name="hidJsonOrderDetail" value="" />
                <div class="col-lg-4">
                    <div class="divtxtDate input-group form-group">
                        <label class="input-group-addon">Date</label>
                        <input type="text" id="txtDate" name="txtDate" class="datepick form-control" onkeyup="return ValidateDate(this);" tabindex="2" />
                    </div>
                    <div class="divtxtDocNo input-group form-group" style="display: none;">
                        <label class="input-group-addon">Doc No</label>
                        <input type="text" id="AutoOrderForm" name="AutoOrderForm" class="form-control search" value=""
                            data-val-required="Field is required" data-val="true" maxlength="250" />
                        <span class="field-validation-valid" data-valmsg-for="AutoOrderForm" data-valmsg-replace="true"></span>
                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Existing Customer</label>
                        <span class="form-control">
                            <input type="checkbox" id="chkExisting" name="chkExisting" onchange="SetExistingCheckboxValue(this);" checked="checked" tabindex="5" />
                        </span>
                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Temp</label>
                        <span class="form-control">
                            <input type="checkbox" id="chkTemp" name="chkTemp" onchange="SetExistingCheckboxValue(this);" tabindex="8" />
                        </span>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Customer</label>
                        <input type="text" id="AutoCustomer" name="AutoCustomer" class="form-control search" value=""
                            data-val-required="Field is required" data-val="true" tabindex="3" />
                        <span class="field-validation-valid" data-valmsg-for="AutoCustomer" data-valmsg-replace="true"></span>
                    </div>
                    <div class="input-group form-group" style="display: none;">
                        <label class="input-group-addon">Template</label>
                        <input type="text" id="AutoTemplate" name="AutoTemplate" class="form-control search" value=""
                            data-val-required="Field is required" data-val="true" />
                        <span class="field-validation-valid" data-valmsg-for="AutoTemplate" data-valmsg-replace="true"></span>
                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Vehicle No.</label>
                        <input type="text" id="AutoVehicle" name="AutoVehicle" class="form-control search" value=""
                            data-val-required="Field is required" data-val="true" tabindex="6" />
                        <span class="field-validation-valid" data-valmsg-for="AutoVehicle" data-valmsg-replace="true"></span>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Warehouse</label>
                        <select id="ddlWhs" name="ddlWhs" class="form-control" tabindex="4"></select>
                    </div>
                    <div class="input-group form-group">
                        <label class="input-group-addon">Mobile No</label>
                        <input type="text" class="form-control" id="txtMobile" name="txtMobile" data-bv-notempty="true" data-bv-notempty-message="Field is required" maxlength="10" tabindex="7" />
                    </div>
                </div>
            </div>
            <div class="row">
                <input type="hidden" id="CountRowMaterial" />
                <div class="col-lg-12">
                    <div class="input-group form-group" style="width: 100%">
                        <input type="text" id="txtSearchMaterial" data-val="false" class="form-control" placeholder="Type to Search" style="background-image: url('../Images/Search.png'); background-position: right; background-repeat: no-repeat; width: 100%" tabindex="9" />
                    </div>
                </div>
            </div>
            <div class="border-la">&nbsp;</div>
            <table id="tblMaterialDetail" class="table" border="1" tabindex="10">
                <thead>
                    <tr class="table-header-gradient">
                        <th style="width: 20%;">Item Code - Name</th>
                        <th style="width: 8%">Unit</th>
                        <th style="width: 8%;">Price</th>
                        <th style="width: 8%;">Available</th>
                        <th style="width: 8%;">Order</th>
                        <th style="width: 8%;">Total Qty</th>
                        <th style="width: 8%;">SubTotal</th>
                        <th style="width: 8%;">Tax</th>
                        <th style="width: 8%">Total Price</th>
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
                        <th>
                            <label id="lblFootAvailable"></label>
                        </th>
                        <th>
                            <label id="lblFootDispatch"></label>
                        </th>
                        <th>
                            <label id="lblFootTotalQty"></label>
                        </th>
                        <th>
                            <label id="lblFootSubTotal" class="lblFootSubTotal"></label>
                        </th>
                        <th>
                            <label id="lblFootTax"></label>
                        </th>
                        <th>
                            <label id="lblFootTotalPrice" class="lblFootTotalPrice"></label>
                        </th>
                        <th style="display: none">ID</th>
                    </tr>
                </tfoot>
            </table>
            <div id="divdata" runat="server" class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <span class="input-group-addon">BillNumber</span>
                        <asp:TextBox runat="server" ID="txtBillNumber" TabIndex="11" CssClass="form-control" Enabled="false" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <span class="input-group-addon">Sub Total</span>
                        <input type="text" id="txtSubTotal" tabindex="12" class="txtSubTotal form-control" disabled="disabled" />
                    </div>
                    <div class="input-group form-group">
                        <span class="input-group-addon">Tax</span>
                        <input type="text" id="txtTax" tabindex="13" class="txtTax form-control" disabled="disabled" />
                    </div>
                    <div class="input-group form-group">
                        <span class="input-group-addon">Rounding</span>
                        <input type="text" id="txtRounding" tabindex="14" class="txtRounding form-control" disabled="disabled" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <span class="input-group-addon">Total</span>
                        <input type="text" id="txtTotal" tabindex="15" class="txtTotal form-control" disabled="disabled" />
                    </div>
                    <div class="input-group form-group">
                        <span class="input-group-addon">Pending</span>
                        <input type="text" id="txtPending" tabindex="16" class="txtPending form-control" disabled="disabled" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12 _textArea">
                    <div class="input-group form-group">
                        <span class="input-group-addon">Notes</span>
                        <asp:TextBox runat="server" ID="txtNotes" TabIndex="17" TextMode="MultiLine" CssClass="form-control" Style="resize: none;" />
                    </div>
                </div>
            </div>
            <br />
            <input type="submit" value="Save" class="btn btn-default" tabindex="18" id="btnSubmit" onclick="return btnSubmit_Click();" />
            <input type="submit" value="Cancel" id="btnCancel" class="btn btn-default" tabindex="19" onclick="btnCancel_Click();" />
        </div>
    </div>
</asp:Content>

