<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="CustomerWiseClaimContriMaster.aspx.cs" Inherits="Master_CustomerWiseClaimContriMaster" %>

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
        var availableParent = [];

        var Version = '<% = Version%>';
        //  var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        var IpAddress;

        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome
            try {
                var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
                var pc = new myPeerConnection({
                    iceServers: []
                }),
                    noop = function () { },
                    localIPs = {},
                    ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
                    key;
            }
            catch (err) {

            }

            function iterateIP(ip) {
                if (!localIPs[ip]) onNewIP(ip);
                localIPs[ip] = true;
            }
            try {
                //create a bogus data channel
                pc.createDataChannel("");

                // create offer and set local description
                pc.createOffer(function (sdp) {
                    sdp.sdp.split('\n').forEach(function (line) {
                        if (line.indexOf('candidate') < 0) return;
                        line.match(ipRegex).forEach(iterateIP);
                    });

                    pc.setLocalDescription(sdp, noop, noop);
                }, noop);

                //listen for candidate events
                pc.onicecandidate = function (ice) {
                    if (!ice || !ice.candidate || !ice.candidate.candidate || !ice.candidate.candidate.match(ipRegex)) return;
                    ice.candidate.candidate.match(ipRegex).forEach(iterateIP);
                };
            }
            catch (err) {

            }
        }
        // Usage
        getUserIP(function (ip) {
            if (IpAddress == undefined)
                IpAddress = ip;
            try {
                if ($("#hdnIPAdd").val() == 0 || $("#hdnIPAdd").val() == "" || $("#hdnIPAdd").val() == undefined) {
                    $("#hdnIPAdd").val(ip);
                }
            }
            catch (err) {

            }
        });

        var availableCustomer = [];

        $(document).ready(function () {

            ClearControls();
            $("#hdnIPAdd").val(IpAddress);
            $("#gvCustomer").tableHeadFixer('76vh');

            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            if ($('.gvMissdata > tbody').length > 0) {
                $('.divMissData').removeAttr('style');
                $('.gvMissdata').attr('style', 'display:block;');
                $('.divCustEntry').attr('style', 'display:none;');
                $('.divClaimReport').attr('style', 'display:none;');
            }
            var aryJSONColTable = [];

            aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
            aryJSONColTable.push({ "width": "202px", "sClass": "dtbodyCenter", "aTargets": 1 });
            aryJSONColTable.push({ "width": "112px", "sClass": "dtbodyCenter", "aTargets": 2 });
            aryJSONColTable.push({ "width": "62px", "aTargets": 3 });
            aryJSONColTable.push({ "width": "62px", "aTargets": 4 });
            aryJSONColTable.push({ "width": "76px", "aTargets": 5 });
            aryJSONColTable.push({ "width": "70px", "aTargets": 6 });//"sClass": "dtbodyLeft",
            aryJSONColTable.push({ "width": "35px", "aTargets": 7 });
            aryJSONColTable.push({ "width": "150px", "aTargets": 8 });
            aryJSONColTable.push({ "width": "74px", "aTargets": 9 });
            aryJSONColTable.push({ "width": "75px", "aTargets": 10 });
            aryJSONColTable.push({ "width": "300px", "aTargets": 11 });

            $('#gvCustomer').DataTable({
                bFilter: false,
                scrollCollapse: true,
                "sExtends": "collection",
                scrollX: true,
                scrollY: '65vh',
                responsive: true,
                "bPaginate": false,
                ordering: false,
                "bInfo": false,
                "autoWidth": false,
                destroy: true,
                scroller: true,
                "aoColumnDefs": aryJSONColTable,
            });


            //$(".txtCustCode").autocomplete({
            //    source: function (request, response) {
            //        $.ajax({
            //            type: "POST",
            //            url: "CustomerWiseClaimContriMaster.aspx/SearchCustomerByType",
            //            dataType: "json",
            //            data: "{ 'prefixText': '" + request.term + "','DivisionID': '" + $('.ddlDivision').val() + "'}",
            //            contentType: "application/json; charset=utf-8",
            //            success: function (data) {
            //                response($.map(data.d, function (item) {
            //                    return {
            //                        label: item.Text,
            //                        value: item.Text,
            //                        id: item.Value
            //                    };
            //                }))
            //            },
            //            error: function (XMLHttpRequest, textStatus, errorThrown) {
            //            }
            //        });
            //    },
            //    select: function (event, ui) {
            //        $(".txtCustCode").val(ui.item.value);
            //    },
            //    change: function (event, ui) {
            //        if (!ui.item) {
            //            $('.txtCustCode').val("");
            //        }
            //    },
            //    minLength: 1
            //});

            //Start Customer Textbox
            $(document).on('keyup', '.AutoCustCode', function () {
                //var textValue = $(this).val();
                //var currentRow = $(this).closest("tr");
                // var col1 = currentRow.find("td:eq(0)").text();

                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoCustCode", '');
                $('#AutoCustCode' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'CustomerWiseClaimContriMaster.aspx/SearchCustomerByType',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','DivisionID': '" + $('.ddlDivision').val() + "'}",
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
                        of: $('#AutoCustCode' + col1),
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
                    select: function (event, ui) {
                        $('#AutoCustCode' + col1).val(ui.item.value + " ");
                        $('#hdnCustomerID' + col1).val(ui.item.id);
                        $('#AutoPriceCode' + col1).val("");
                        $('#tdFromDate' + col1).text('');
                        $('#tdToDate' + col1).text('');
                        $('#txtCompContri' + col1).val("");
                        $('#txtDistContri' + col1).val("");
                        $('#chkIsActive' + col1).prop('checked', false);
                        $('#chkIsActive' + col1).attr("disabled", false);
                    },
                    change: function (event, ui) {
                        ChangeData(this);
                        if (!ui.item) {
                            $('#AutoCustCode' + col1).val("");
                            $('#hdnCustomerID' + col1).val(0);
                            $('#AutoPriceCode' + col1).val("");
                            $('#tdFromDate' + col1).text('');
                            $('#tdToDate' + col1).text('');
                            $('#txtCompContri' + col1).val("");
                            $('#txtDistContri' + col1).val("");
                            $('#chkIsActive' + col1).prop('checked', false);
                            $('#chkIsActive' + col1).attr("disabled", false);
                        }
                    },
                    minLength: 1
                });
            });
            //$('#AutoCustCode' + ind).on('autocompleteselect', function (e, ui) {
            //    $('#AutoCustCode' + ind).val(ui.item.value);
            //    //GetCustomerDetailsByCode(ui.item.value, ind);
            //});


            // $('#AutoCustCode' + ind).on('change keyup', function () {
            $('.AutoCustCode').on('change keyup', function () {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                if ($('#AutoCustCode' + col1).val() == "") {
                    ClearCustomerRow(col1);
                }
            });
            // $('#AutoCustCode' + ind).on('blur', function (e, ui) {
            $('.AutoCustCode').on('blur', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoCustCode", '');
                if ($('#AutoCustCode' + col1).val().trim() != "") {
                    if ($('#AutoCustCode' + col1).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Customer", 3);
                        $('#AutoCustCode' + col1).val("");
                        $('#hdnCustomerID' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoCustCode' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    CheckDuplicateCustomer($('#AutoCustCode' + col1).val().trim(), $('#hdnPriceListID' + col1).val().trim(), $('#tdFromDate' + col1).val().trim(), $('#tdToDate' + col1).val().trim(), col1);
                }
            });

            //End Customer Textbox
            //Start Price Textbox
            $(document).on('keyup', '.AutoPriceCode', function () {
                //var textValue = $(this).val();
                //var currentRow = $(this).closest("tr");
                // var col1 = currentRow.find("td:eq(0)").text();

                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoPriceCode", '');
                $('#AutoPriceCode' + col1).autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            url: 'CustomerWiseClaimContriMaster.aspx/LoadPriceByCustType',
                            type: 'POST',
                            dataType: 'json',
                            data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','CustType': '3','DivisionID': '" + $('.ddlDivision').val() + "'}",
                            async: false,
                            contentType: 'application/json; charset=utf-8',
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
                                alert('Something is wrong...' + XMLHttpRequest.responseText);
                                return false;
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $('#AutoPriceCode' + col1),
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
                    select: function (event, ui) {
                        $('#AutoPriceCode' + col1).val(ui.item.value + " ");
                        $('#hdnPriceListID' + col1).val(ui.item.id);
                    },
                    change: function (event, ui) {
                        ChangeData(this);
                        if (!ui.item) {
                            $('#AutoPriceCode' + col1).val("");
                            $('#hdnPriceListID' + col1).val(0);
                        }
                    },
                    minLength: 0,
                    scroll: true
                });
            });
            //$('#AutoPriceCode' + ind).on('autocompleteselect', function (e, ui) {
            //    $('#AutoPriceCode' + ind).val(ui.item.value);
            //    GetCustomerDetailsByCode(ui.item.value, ind);
            //});

            //$('#AutoPriceCode' + ind).on('change keyup', function () {
            //    if ($('#AutoPriceCode' + ind).val() == "") {
            //        ClearCustomerRow(ind);
            //    }
            //});

            //  $('#AutoPriceCode' + ind).on('blur', function (e, ui) {
            $('.AutoPriceCode').on('blur', function (e, ui) {
                var txtId = $(this).attr("id");
                var col1 = txtId.replace("AutoPriceCode", '');
                if ($('#AutoPriceCode' + col1).val().trim() != "") {
                    if ($('#AutoPriceCode' + col1).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Pricegroup", 3);
                        $('#AutoPriceCode' + col1).val("");
                        $('#hdnPriceListID' + col1).val('0');
                        return;
                    }
                    var txt = $('#AutoPriceCode' + col1).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    //CheckDuplicatePriceGroup($('#AutoPriceCode' + ind).val().trim(), ind);
                }
            });

            //End Price Textbox
        });

        function ToDataURL(url, callback) {
            var xhr = new XMLHttpRequest();
            xhr.onload = function () {
                var reader = new FileReader();
                reader.onloadend = function () {
                    callback(reader.result);
                }
                reader.readAsDataURL(xhr.response);
            };
            xhr.open('GET', url);
            xhr.responseType = 'blob';
            xhr.send();
        }

        //Two Date Compare 
        function ProcessDate(date) {
            var parts = date.split("/");
            return new Date(parts[2], parts[1] - 1, parts[0]);
        }

        function AddMoreRow() {

            $('table#gvCustomer tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowCustomer').val();
            ind = parseInt(ind) + 1;
            $('#CountRowCustomer').val(ind);

            var str = "";
            str = "<tr id='trClaimContri" + ind + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                + "<td><input type='text' id='AutoCustCode" + ind + "' name='AutoCustCode' class='form-control search AutoCustCode' style='background-color: rgb(250, 255, 189);'/></td>"
                + "<td><input type='text' id='AutoPriceCode" + ind + "' name='AutoPriceCode' class='form-control search AutoPriceCode' style='background-color: rgb(250, 255, 189);'/></td>"
                //+ "<td id='tdPriceGroup" + ind + "' class='tdPriceGroup'></td>"
                + "<td><input type='text' id='tdFromDate" + ind + "'name='tdFromDate' onchange='ChangeData(this);' class='form-control startdate search' onpaste='return false;' style='background-color: rgb(250, 255, 189);'/></td>"
                + "<td><input type='text' id='tdToDate" + ind + "'name='tdToDate' onchange='ChangeData(this);' class='form-control enddate search' onpaste='return false;' style='background-color: rgb(250, 255, 189);'/></td>"
                + "<td><input type='text' id='txtCompContri" + ind + "'name='txtCompContri' onchange='ChangeData(this);' class='form-control search allownumericwithdecimal txtCompContri' onpaste='return false;' style='background-color: rgb(250, 255, 189);'/></td>"
                + "<td><input type='text' id='txtDistContri" + ind + "'name='txtDistContri' onchange='ChangeData(this);' class='form-control search allownumericwithdecimal txtDistContri' onpaste='return false;' style='background-color: rgb(250, 255, 189);'/></td>"
                + "<td><input type='checkbox' id='chkIsActive" + ind + "' name='chkIsActive' onchange='ChangeData(this);' class='checkbox'/></td>"
                + "<td id='tdParentName" + ind + "' class='tdParentName'></td>"
                + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
                + "<td id='tdUpdateDate" + ind + "' class='tdUpdateDate'></td>"
                // + "<td id='tdIpAdd" + ind + "' class='tdIpAdd'></td>"
                + "<td><input type='text' id='txtRemarks" + ind + "' name='txtRemarks' class='form-control txtRemarks'   maxLength='100' onchange='ChangeData(this);' /></td>"
                + "<input type='hidden' id='hdnCustomerID" + ind + "' name='hdnCustomerID'  /></td>"
                + "<input type='hidden' id='hdnRateClaimID" + ind + "' name='hdnRateClaimID'  /></td>"
                + "<input type='hidden' id='hdnDivisionID" + ind + "' name='hdnDivisionID'  /></td>"
                + "<input type='hidden' id='hdnPriceListID" + ind + "' name='hdnPriceListID'  /></td>"
                + "<input type='hidden' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /></tr>";

            $('#gvCustomer > tbody').append(str);

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
            $('.startdate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2017, 6, 1),
                onSelect: function (FromDate, inst) {
                    CheckDuplicateCustomer($('#AutoCustCode' + ind).val().trim(), $('#hdnPriceListID' + ind).val().trim(), $('#tdFromDate' + ind).val().trim(), $('#tdFromDate' + ind).val().trim(), ind);
                }
            });

            $('.enddate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2017, 6, 1),
                onSelect: function (FromDate, inst) {
                    CheckDuplicateCustomer($('#AutoCustCode' + ind).val().trim(), $('#hdnPriceListID' + ind).val().trim(), $('#tdToDate' + ind).val().trim(), $('#tdToDate' + ind).val().trim(), ind);
                }
            });

            //Start Customer Textbox

            $('#AutoCustCode' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: 'CustomerWiseClaimContriMaster.aspx/SearchCustomerByType',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','DivisionID': '" + $('.ddlDivision').val() + "'}",
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
                select: function (event, ui) {
                    $('#AutoCustCode' + ind).val(ui.item.value + " ");
                    $('#hdnCustomerID' + ind).val(ui.item.id);
                    $('#AutoPriceCode' + ind).val("");
                    $('#tdFromDate' + ind).text('');
                    $('#tdToDate' + ind).text('');
                    $('#txtCompContri' + ind).val("");
                    $('#txtDistContri' + ind).val("");
                    $('#chkIsActive' + ind).prop('checked', false);
                    $('#chkIsActive' + ind).attr("disabled", false);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoCustCode' + ind).val("");
                        $('#hdnCustomerID' + ind).val(0);
                        $('#AutoPriceCode' + ind).val("");
                        $('#tdFromDate' + ind).text('');
                        $('#tdToDate' + ind).text('');
                        $('#txtCompContri' + ind).val("");
                        $('#txtDistContri' + ind).val("");
                        $('#chkIsActive' + ind).prop('checked', false);
                        $('#chkIsActive' + ind).attr("disabled", false);
                    }
                },
                minLength: 1
            });
            //$('#AutoCustCode' + ind).on('autocompleteselect', function (e, ui) {
            //    $('#AutoCustCode' + ind).val(ui.item.value);
            //    //GetCustomerDetailsByCode(ui.item.value, ind);
            //});

            $('#AutoCustCode' + ind).on('change keyup', function () {
                if ($('#AutoCustCode' + ind).val() == "") {
                    ClearCustomerRow(ind);
                }
            });

            $('#AutoCustCode' + ind).on('blur', function (e, ui) {
                if ($('#AutoCustCode' + ind).val().trim() != "") {
                    if ($('#AutoCustCode' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Customer", 3);
                        $('#AutoCustCode' + ind).val("");
                        $('#hdnCustomerID' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoCustCode' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    CheckDuplicateCustomer($('#AutoCustCode' + ind).val().trim(), $('#hdnPriceListID' + ind).val().trim(), $('#tdFromDate' + ind).val().trim(), $('#tdToDate' + ind).val().trim(), ind);
                }
            });

            //End Customer Textbox

            //Start Price Textbox
            $('#AutoPriceCode' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: 'CustomerWiseClaimContriMaster.aspx/LoadPriceByCustType',
                        type: 'POST',
                        dataType: 'json',
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','CustType': '3','DivisionID': '" + $('.ddlDivision').val() + "'}",
                        async: false,
                        contentType: 'application/json; charset=utf-8',
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
                            alert('Something is wrong...' + XMLHttpRequest.responseText);
                            return false;
                        }
                    });
                },
                select: function (event, ui) {
                    $('#AutoPriceCode' + ind).val(ui.item.value + " ");
                    $('#hdnPriceListID' + ind).val(ui.item.id);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoPriceCode' + ind).val("");
                        $('#hdnPriceListID' + ind).val(0);
                    }
                },
                minLength: 0,
                scroll: true
            });

            //$('#AutoPriceCode' + ind).on('autocompleteselect', function (e, ui) {
            //    $('#AutoPriceCode' + ind).val(ui.item.value);
            //    GetCustomerDetailsByCode(ui.item.value, ind);
            //});

            //$('#AutoPriceCode' + ind).on('change keyup', function () {
            //    if ($('#AutoPriceCode' + ind).val() == "") {
            //        ClearCustomerRow(ind);
            //    }
            //});

            $('#AutoPriceCode' + ind).on('blur', function (e, ui) {
                if ($('#AutoPriceCode' + ind).val().trim() != "") {
                    if ($('#AutoPriceCode' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Pricegroup", 3);
                        $('#AutoPriceCode' + ind).val("");
                        $('#hdnPriceListID' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoPriceCode' + ind).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    //CheckDuplicatePriceGroup($('#AutoPriceCode' + ind).val().trim(), ind);
                }
            });

            //End Price Textbox

            var lineNum = 1;
            $('#gvCustomer > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

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
                        //if (isNaN(myval)) {
                        //    //$(this).val('');
                        //    //e.preventDefault();
                        //    return false;
                        //}
                    }
                    return;
                }
                // Ensure that it is a number and stop the keypress
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });
        }

        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
        }


        function CheckDuplicateCustomer(CustCode, ItemPriceListID, ItemFromDate, ItemToDate, row) {
            var Item = CustCode.split("-")[0].trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#gvCustomer  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                if ($("input[name='AutoCustCode']", this).val() != "") {
                    var CustCode = $("input[name='AutoCustCode']", this).val().split("-")[0].trim();
                    var PriceListID = $("input[name='hdnPriceListID']", this).val();
                    var LineNum = $("input[name='hdnLineNum']", this).val();
                    var FromDate = $("input[name='tdFromDate']", this).val();
                    var ToDate = $("input[name='tdToDate']", this).val();
                    var CompContri = $("input[name='CompContri']", this).val();
                    var DistContri = $("input[name='DistContri']", this).val();

                    if (CustCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == CustCode // && ItemPriceListID == PriceListID
                            ) {
                                if ((new Date(ProcessDate(FromDate)) <= new Date(ProcessDate(ItemFromDate)) && new Date(ProcessDate(ToDate)) >= new Date(ProcessDate(ItemToDate)))
                                    || (new Date(ProcessDate(ItemFromDate)) <= new Date(ProcessDate(FromDate)) && new Date(ProcessDate(ItemToDate)) >= new Date(ProcessDate(ToDate)))
                                    || (new Date(ProcessDate(FromDate)) <= new Date(ProcessDate(ItemFromDate)) && new Date(ProcessDate(ItemFromDate)) <= new Date(ProcessDate(ToDate)))
                                    || (new Date(ProcessDate(FromDate)) <= new Date(ProcessDate(ItemToDate)) && new Date(ProcessDate(ItemToDate)) <= new Date(ProcessDate(ToDate)))
                                ) {
                                    cnt = 1;
                                    errRow = row;
                                    //$('#AutoCustCode' + row).val('');
                                    //$('#hdnCustomerID' + ind).val('0');
                                    //$('#AutoPriceCode' + row).val('');
                                    //$('#hdnPriceListID' + ind).val(0);
                                    $('#chkIsActive' + row).prop('checked', false);
                                    $('#chkIsActive' + row).attr("disabled", false);
                                    $('#tdFromDate' + row).val('');
                                    $('#tdToDate' + row).val('');
                                    $('#txtCompContri' + row).val('');
                                    $('#txtDistContri' + row).val('');

                                    errormsg = 'From date and To date is already set for customer = ' + CustCode + ' at row : ' + rowCnt_Customer;
                                    return false;
                                }
                            }
                            if ((Number(DistContri) + Number(CompContri)) > 100) {
                                cnt = 1;
                                errRow = row;
                                //$('#AutoCustCode' + row).val('');
                                //$('#hdnCustomerID' + ind).val('0');
                                //$('#AutoPriceCode' + row).val('');
                                //$('#hdnPriceListID' + ind).val(0);
                                $('#chkIsActive' + row).prop('checked', false);
                                $('#chkIsActive' + row).attr("disabled", false);
                                $('#tdFromDate' + row).val('');
                                $('#tdToDate' + row).val('');
                                $('#txtCompContri' + row).val('');
                                $('#txtDistContri' + row).val('');

                                errormsg = 'Comp Contri. and Dist Contri. Can not exceed limit 100 % for ' + CustCode;
                                return false;
                            }
                        }
                    }
                    //}

                    rowCnt_Customer++;
                }
            });

            if (cnt == 1) {
                //$('#AutoCustCode' + row).val('');
                //ClearCustomerRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowCustomer').val();
            if (ind == row) {
                $('table#gvCustomer tr#NoROW').remove();
                AddMoreRow();
            }

        }

        function CheckDuplicatePriceGroup(PriceCode, row) {

            var Item = PriceCode.split("-")[0].trim();
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#gvCustomer  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                if ($("input[name='AutoPriceCode']", this).val() != "") {
                    var PriceCode = $("input[name='AutoPriceCode']", this).val().split("-")[0].trim();
                    var LineNum = $("input[name='hdnLineNum']", this).val();
                    var CompContri = $("input[name='CompContri']", this).val();
                    var DistContri = $("input[name='DistContri']", this).val();

                    if (PriceCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == PriceCode) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoCustCode' + row).val('');
                                $('#AutoPriceCode' + row).val('');
                                $('#chkIsActive' + row).prop('checked', false);
                                $('#chkIsActive' + row).attr("disabled", false);
                                $('#tdFromDate' + row).text('');
                                $('#tdToDate' + row).text('');
                                $('#txtCompContri' + row).text('');
                                $('#txtDistContri' + row).text('');

                                errormsg = 'Pricecode = ' + PriceCode + ' is already seleted at row : ' + rowCnt_Customer;
                                return false;
                            }
                            if ((Number(DistContri) + Number(CompContri)) > 100) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoCustCode' + row).val('');
                                $('#AutoPriceCode' + row).val('');
                                $('#chkIsActive' + row).prop('checked', false);
                                $('#chkIsActive' + row).attr("disabled", false);
                                $('#tdFromDate' + row).text('');
                                $('#tdToDate' + row).text('');
                                $('#txtCompContri' + row).text('');
                                $('#txtDistContri' + row).text('');

                                errormsg = 'Comp Contri. and Dist Contri. Can not exceed limit 100 % for ' + PriceCode;
                                return false;
                            }
                        }
                    }
                    //}

                    rowCnt_Customer++;
                }
            });

            if (cnt == 1) {
                $('#AutoPriceCode' + row).val('');
                ClearCustomerRow(row);
                ModelMsg(errormsg, 3);
                return false;
            }

            var ind = $('#CountRowCustomer').val();
            if (ind == row) {
                AddMoreRow();
            }
        }

        function ClearCustomerRow(row) {

            var rowCnt_Customer = 1;
            var cnt = 0;

            $('#gvCustomer > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='AutoCustCode']", this).val();
                if (CustCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#gvCustomer > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var CustCode = $("input[name='AutoCustCode']", this).val();
                        if (CustCode == "") {
                            $(this).remove();
                        }
                    }

                    rowCnt_Customer++;
                });
            }

            var lineNum = 1;
            $('#gvCustomer > tbody > tr').each(function (row, tr) {
                $(".txtSrNo", this).text(lineNum);
                lineNum++;
            });

        }

        function FillData() {

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

            $.ajax({
                url: 'CustomerWiseClaimContriMaster.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ DivisionID: $('.ddlDivision').val() }),
                success: function (result) {
                    $.unblockUI();

                    if (result.d == "") {
                        //ClearAll();
                        $.unblockUI();
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        event.preventDefault();
                        return false;
                    }
                    else {
                        //var items = result.d[0];
                        var items = JSON.parse(result.d)
                        if (items.length > 0) {
                            $('#gvCustomer  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                            var row = 1;
                            $('#CountRowCustomer').val(0);

                            for (var i = 0; i < items.length; i++) {
                                //AddMoreRow();
                                //row = $('#CountRowCustomer').val();

                                //$('#hdnRateClaimID' + row).val(items[i].RateClaimID);
                                //$('#hdnCustomerID' + row).val(items[i].CustomerID);
                                //$('#hdnDivisionID' + row).val(items[i].DivisionID);
                                //$('#hdnPriceListID' + row).val(items[i].PriceListID);
                                //$('#AutoCustCode' + row).val(items[i].CustDesc);
                                //$('#AutoPriceCode' + row).val(items[i].PriceDesc);
                                //$('#tdFromDate' + row).val(items[i].FromDate);
                                //$('#tdToDate' + row).val(items[i].ToDate);
                                //$('#txtCompContri' + row).val(items[i].CompCont);
                                //$('#txtDistContri' + row).val(items[i].DistCont);
                                //$('#chkIsActive' + row).prop("checked", items[i].IsActive);
                                //$('#tdParentName' + row).text(items[i].ParentName);
                                //$('#tdUpdateBy' + row).text(items[i].UpdatedBy);
                                //$('#tdUpdateDate' + row).text(items[i].UpdatedDate);
                                //$('#tdIpAdd' + row).text(items[i].IPAddress);

                                $('table#gvCustomer tr#NoROW').remove();  // Remove NO ROW

                                var ind = $('#CountRowCustomer').val();
                                ind = parseInt(ind) + 1;
                                $('#CountRowCustomer').val(ind);

                                var str = "";
                                str = "<tr id='trClaimContri" + ind + "'>"
                                    + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                                    + "<td><input type='text' id='AutoCustCode" + ind + "' name='AutoCustCode' class='form-control search AutoCustCode' value='" + items[i].CustDesc + "' style='background-color: rgb(250, 255, 189);'/></td>"
                                    + "<td><input type='text' id='AutoPriceCode" + ind + "' name='AutoPriceCode' class='form-control search AutoPriceCode' value='" + items[i].PriceDesc + "' style='background-color: rgb(250, 255, 189);'/></td>"
                                    + "<td><input type='text' id='tdFromDate" + ind + "'name='tdFromDate' onchange='ChangeData(this);' class='form-control startdate search' value='" + items[i].FromDate + "' onpaste='return false;' style='background-color: rgb(250, 255, 189);'/></td>"
                                    + "<td><input type='text' id='tdToDate" + ind + "'name='tdToDate' onchange='ChangeData(this);' class='form-control enddate search' value='" + items[i].ToDate + "' onpaste='return false;' style='background-color: rgb(250, 255, 189);'/></td>"
                                    + "<td><input type='text' id='txtCompContri" + ind + "'name='txtCompContri' onchange='ChangeData(this);' class='form-control search allownumericwithdecimal txtCompContri' value='" + items[i].CompCont + "' onpaste='return false;' style='background-color: rgb(250, 255, 189);'/></td>"
                                    + "<td><input type='text' id='txtDistContri" + ind + "'name='txtDistContri' onchange='ChangeData(this);' class='form-control search allownumericwithdecimal txtDistContri' onpaste='return false;' value='" + items[i].DistCont + "' style='background-color: rgb(250, 255, 189);'/></td>"
                                    + "<td><input type='checkbox' id='chkIsActive" + ind + "' name='chkIsActive' onchange='ChangeData(this);' class='checkbox'/></td>"
                                    + "<td id='tdParentName" + ind + "' class='tdParentName'>" + items[i].ParentName + "</td>"
                                    + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'>" + items[i].UpdatedBy + "</td>"
                                    + "<td id='tdUpdateDate" + ind + "' class='tdUpdateDate'>" + items[i].UpdatedDate + "</td>"
                                    + "<td><input type='text' id='txtRemarks" + ind + "' name='txtRemarks' class='form-control txtRemarks' onchange='ChangeData(this);' value='" + items[i].Remarks + "' maxlength='100'/></td>"
                                    // + "<td id='tdIpAdd" + ind + "' class='tdIpAdd' >" + items[i].IPAddress + "</td>"
                                    + "<input type='hidden' id='hdnCustomerID" + ind + "' name='hdnCustomerID'  value='" + items[i].CustomerID + "'/></td>"
                                    + "<input type='hidden' id='hdnRateClaimID" + ind + "' name='hdnRateClaimID' value='" + items[i].RateClaimID + "'  /></td>"
                                    + "<input type='hidden' id='hdnDivisionID" + ind + "' name='hdnDivisionID'  value='" + items[i].DivisionID + "'/></td>"
                                    + "<input type='hidden' id='hdnPriceListID" + ind + "' name='hdnPriceListID' value='" + items[i].PriceListID + "' /></td>"
                                    + "<input type='hidden' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                                    + "<input type='hidden' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /></tr>";
                                //$("#trClaimContri" + row).find("#chkIsActive" + row).prop("checked", items[i].IsActive);
                                //$('#chkIsActive' + row).prop("checked", items[i].IsActive);
                                $('#gvCustomer > tbody').append(str);
                                $('#trClaimContri' + ind).find('input[type="checkbox"]').prop("checked", items[i].Active);
                            }

                            // $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
                            $('.startdate').datepicker({
                                numberOfMonths: 1,
                                dateFormat: 'dd/mm/yy',
                                changeMonth: true,
                                changeYear: true,
                                minDate: new Date(2017, 6, 1),
                                onSelect: function (FromDate, inst) {
                                    CheckDuplicateCustomer($('#AutoCustCode' + ind).val().trim(), $('#hdnPriceListID' + ind).val().trim(), $('#tdFromDate' + ind).val().trim(), $('#tdFromDate' + ind).val().trim(), ind);
                                    ChangeData(this);
                                }
                            });

                            $('.enddate').datepicker({
                                numberOfMonths: 1,
                                dateFormat: 'dd/mm/yy',
                                changeMonth: true,
                                changeYear: true,
                                minDate: new Date(2017, 6, 1),
                                onSelect: function (FromDate, inst) {
                                    CheckDuplicateCustomer($('#AutoCustCode' + ind).val().trim(), $('#hdnPriceListID' + ind).val().trim(), $('#tdToDate' + ind).val().trim(), $('#tdToDate' + ind).val().trim(), ind);
                                    ChangeData(this);
                                }
                            });
                            ////Start Customer Textbox

                            //$('#AutoCustCode' + ind).autocomplete({
                            //    source: function (request, response) {
                            //        $.ajax({
                            //            type: "POST",
                            //            url: 'CustomerWiseClaimContriMaster.aspx/SearchCustomerByType',
                            //            dataType: "json",
                            //            data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','DivisionID': '" + $('.ddlDivision').val() + "'}",
                            //            contentType: "application/json; charset=utf-8",
                            //            success: function (data) {
                            //                response($.map(data.d, function (item) {
                            //                    return {
                            //                        label: item.Text,
                            //                        value: item.Text,
                            //                        id: item.Value
                            //                    };
                            //                }))
                            //            },
                            //            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            //            }
                            //        });
                            //    },
                            //    select: function (event, ui) {
                            //        $('#AutoCustCode' + ind).val(ui.item.value + " ");
                            //        $('#hdnCustomerID' + ind).val(ui.item.id);
                            //        $('#AutoPriceCode' + ind).val("");
                            //        $('#tdFromDate' + ind).text('');
                            //        $('#tdToDate' + ind).text('');
                            //        $('#txtCompContri' + ind).val("");
                            //        $('#txtDistContri' + ind).val("");
                            //        $('#chkIsActive' + ind).prop('checked', false);
                            //        $('#chkIsActive' + ind).attr("disabled", false);
                            //    },
                            //    change: function (event, ui) {
                            //        ChangeData(this);
                            //        if (!ui.item) {
                            //            $('#AutoCustCode' + ind).val("");
                            //            $('#hdnCustomerID' + ind).val(0);
                            //            $('#AutoPriceCode' + ind).val("");
                            //            $('#tdFromDate' + ind).text('');
                            //            $('#tdToDate' + ind).text('');
                            //            $('#txtCompContri' + ind).val("");
                            //            $('#txtDistContri' + ind).val("");
                            //            $('#chkIsActive' + ind).prop('checked', false);
                            //            $('#chkIsActive' + ind).attr("disabled", false);
                            //        }
                            //    },
                            //    minLength: 1
                            //});
                            ////$('#AutoCustCode' + ind).on('autocompleteselect', function (e, ui) {
                            ////    $('#AutoCustCode' + ind).val(ui.item.value);
                            ////    //GetCustomerDetailsByCode(ui.item.value, ind);
                            ////});

                            //$('#AutoCustCode' + ind).on('change keyup', function () {
                            //    if ($('#AutoCustCode' + ind).val() == "") {
                            //        ClearCustomerRow(ind);
                            //    }
                            //});

                            //$('#AutoCustCode' + ind).on('blur', function (e, ui) {
                            //    if ($('#AutoCustCode' + ind).val().trim() != "") {
                            //        if ($('#AutoCustCode' + ind).val().indexOf('-') == -1) {
                            //            ModelMsg("Select Proper Customer", 3);
                            //            $('#AutoCustCode' + ind).val("");
                            //            $('#hdnCustomerID' + ind).val('0');
                            //            return;
                            //        }
                            //        var txt = $('#AutoCustCode' + ind).val().trim();
                            //        if (txt == "undefined" || txt == "") {
                            //            //ModelMsg("Enter Item Code Or Name", 3);
                            //            return false;
                            //        }
                            //        CheckDuplicateCustomer($('#AutoCustCode' + ind).val().trim(), $('#hdnPriceListID' + ind).val().trim(), $('#tdFromDate' + ind).val().trim(), $('#tdToDate' + ind).val().trim(), ind);
                            //    }
                            //});

                            ////End Customer Textbox
                            ////Start Price Textbox
                            //$('#AutoPriceCode' + ind).autocomplete({
                            //    source: function (request, response) {
                            //        $.ajax({
                            //            url: 'CustomerWiseClaimContriMaster.aspx/LoadPriceByCustType',
                            //            type: 'POST',
                            //            dataType: 'json',
                            //            data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','CustType': '3','DivisionID': '" + $('.ddlDivision').val() + "'}",
                            //            async: false,
                            //            contentType: 'application/json; charset=utf-8',
                            //            success: function (data) {
                            //                response($.map(data.d, function (item) {
                            //                    return {
                            //                        label: item.Text,
                            //                        value: item.Text,
                            //                        id: item.Value
                            //                    };
                            //                }))
                            //            },
                            //            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            //                alert('Something is wrong...' + XMLHttpRequest.responseText);
                            //                return false;
                            //            }
                            //        });
                            //    },
                            //    select: function (event, ui) {
                            //        $('#AutoPriceCode' + ind).val(ui.item.value + " ");
                            //        $('#hdnPriceListID' + ind).val(ui.item.id);
                            //    },
                            //    change: function (event, ui) {
                            //        ChangeData(this);
                            //        if (!ui.item) {
                            //            $('#AutoPriceCode' + ind).val("");
                            //            $('#hdnPriceListID' + ind).val(0);
                            //        }
                            //    },
                            //    minLength: 0,
                            //    scroll: true
                            //});

                            ////$('#AutoPriceCode' + ind).on('autocompleteselect', function (e, ui) {
                            ////    $('#AutoPriceCode' + ind).val(ui.item.value);
                            ////    GetCustomerDetailsByCode(ui.item.value, ind);
                            ////});

                            ////$('#AutoPriceCode' + ind).on('change keyup', function () {
                            ////    if ($('#AutoPriceCode' + ind).val() == "") {
                            ////        ClearCustomerRow(ind);
                            ////    }
                            ////});

                            //$('#AutoPriceCode' + ind).on('blur', function (e, ui) {
                            //    if ($('#AutoPriceCode' + ind).val().trim() != "") {
                            //        if ($('#AutoPriceCode' + ind).val().indexOf('-') == -1) {
                            //            ModelMsg("Select Proper Pricegroup", 3);
                            //            $('#AutoPriceCode' + ind).val("");
                            //            $('#hdnPriceListID' + ind).val('0');
                            //            return;
                            //        }
                            //        var txt = $('#AutoPriceCode' + ind).val().trim();
                            //        if (txt == "undefined" || txt == "") {
                            //            //ModelMsg("Enter Item Code Or Name", 3);
                            //            return false;
                            //        }
                            //        //CheckDuplicatePriceGroup($('#AutoPriceCode' + ind).val().trim(), ind);
                            //    }
                            //});

                            ////End Price Textbox

                            var lineNum = 1;
                            $('#gvCustomer > tbody > tr').each(function (row, tr) {
                                $(".txtSrNo", this).text(lineNum);
                                lineNum++;
                            });

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
                                        //if (isNaN(myval)) {
                                        //    //$(this).val('');
                                        //    //e.preventDefault();
                                        //    return false;
                                        //}
                                    }
                                    return;
                                }
                                // Ensure that it is a number and stop the keypress
                                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                                    e.preventDefault();
                                }
                            });

                        }
                    }
                    AddMoreRow();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
        }

        //function GetCustomerDetailsByCode(CustCode, row) {

        //    var CustCode = CustCode.split("-")[0].trim();
        //    var rowCnt_Material = 1;
        //    var cnt = 0;
        //    var errRow = 0;

        //    $('#gvCustomer  > tbody > tr').each(function (row1, tr) {
        //        if ($("input[name='AutoCustCode']", this).val() != "") {
        //            // post table's data to Submit form using Json Format
        //            var Item = $("input[name='AutoCustCode']", this).val().split("-")[0].trim();
        //            var LineNum = $("input[name='hdnLineNum']", this).val();
        //            var CompContri = $("input[name='CompContri']", this).val();
        //            var DistContri = $("input[name='DistContri']", this).val();

        //            if (CustCode != "") {
        //                if (parseInt(row) != parseInt(LineNum)) {
        //                    if (Item == CustCode) {
        //                        cnt = 1;
        //                        errRow = row;
        //                        return false;
        //                    }
        //                    if ((Number(DistContri) + Number(CompContri)) > 100) {
        //                        cnt = 1;
        //                        errRow = row;
        //                        $('#AutoCustCode' + row).val('');
        //                        $('#AutoPriceCode' + row).val('');
        //                        $('#chkIsActive' + row).prop('checked', false);
        //                        $('#chkIsActive' + row).attr("disabled", false);
        //                        $('#tdFromDate' + row).text('');
        //                        $('#tdToDate' + row).text('');
        //                        $('#txtCompContri' + row).text('');
        //                        $('#txtDistContri' + row).text('');

        //                        errormsg = 'Comp Contri. and Dist Contri. Can not exceed limit 100 % for ' + CustCode;
        //                        return false;
        //                    }
        //                }
        //            }
        //            //}
        //            rowCnt_Material++;
        //        }
        //    });

        //    if (cnt == 1) {
        //        return false;
        //    }
        //    else {

        //        $.ajax({
        //            url: 'CustomerWiseClaimContriMaster.aspx/GetCustomerDetail',
        //            type: 'POST',
        //            dataType: 'json',
        //            async: false,
        //            contentType: 'application/json; charset=utf-8',
        //            data: JSON.stringify({ CustCode: CustCode, DivisionID: $('.ddlDivision').val() }),

        //            success: function (result) {
        //                if (result == "") {
        //                    return false;
        //                }
        //                else if (result.d.indexOf("ERROR=") >= 0) {
        //                    var ErrorMsg = result.d[0].split('=')[1].trim();
        //                    ModelMsg(ErrorMsg, 3);
        //                    $("input[name='AutoCustCode']", this).val() == "";
        //                    return false;
        //                }
        //                else {
        //                    $('#chkIsActive' + row).prop("checked", result.d[0].Active);
        //                    $('#hdnCustomerID' + row).val(result.d[0].CustomerID);
        //                    //$('#tdCustName' + row).text(result.d[0].CustomerName);
        //                    $('#tdPriceGroup' + row).text(result.d[0].PriceGroup);
        //                    $('#tdFromDate' + row).val(result.d[0].FromDate);
        //                    $('#tdToDate' + row).val(result.d[0].ToDate);
        //                    $('#txtCompContri' + row).val(result.d[0].CompContri);
        //                    $('#txtDistContri' + row).val(result.d[0].DistContri);
        //                    $('#tdParentName' + row).text(result.d[0].ParentName);
        //                    $('#tdUpdateBy' + row).text(result.d[0].UpdateBy);
        //                    $('#tdUpdateDate' + row).text(result.d[0].UpdateDate);
        //                    $('#tdIpAdd' + row).text(result.d[0].IpAddress);
        //                }
        //            },
        //            error: function (XMLHttpRequest, textStatus, errorThrown) {
        //                alert('Something is wrong...' + XMLHttpRequest.responseText);
        //                return false;
        //            }
        //        });
        //    }

        //    $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
        //}

        function ClearControls() {
            $('.divCustEntry').attr('style', 'display:none;');
            $('.divClaimReport').attr('style', 'display:none;');
            $('.divMissData').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('.divUpload').attr('style', 'display:none;');

            $('#gvCustomer tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvClaimHistory')) {
                $('.gvClaimHistory').DataTable().destroy();
            }

            $('.gvClaimHistory tbody').empty();
            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divClaimReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');
            }
            else {
                $('.divCustEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');
                $('.divUpload').removeAttr('style');

                $('#CountRowCustomer').val(0);
                AddMoreRow();
                FillData();
            }
        }

        function Cancel() {
            window.location = "../Master/CustomerWiseClaimContriMaster.aspx";
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
                return false;
            }

            var TableData_Customer = [];

            var totalItemcnt = 0;
            var cnt = 0;

            rowCnt_Customer = 0;

            $('#gvCustomer  > tbody > tr').each(function (row, tr) {
                var CustCode = $("input[name='AutoCustCode']", this).val();
                var IsChange = $("input[name='IsChange']", this).val().trim();
                if (CustCode != "" && IsChange == "1") {
                    totalItemcnt = 1;
                    var CustomerID = $("input[name='hdnCustomerID']", this).val().trim();
                    var RateClaimID = $("input[name='hdnRateClaimID']", this).val().trim();
                    var PriceListID = $("input[name='hdnPriceListID']", this).val().trim();
                    var FromDate = $("input[name='tdFromDate']", this).val();
                    var ToDate = $("input[name='tdToDate']", this).val();
                    var CompContri = $("input[name='txtCompContri']", this).val();
                    var DistContri = $("input[name='txtDistContri']", this).val();
                    var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                    var IPAddress = $("#hdnIPAdd").val();
                    var IsChange = $("input[name='IsChange']", this).val().trim();
                    var Remarks = $("input[name='txtRemarks']", this).val();
                    if (PriceListID == "" || PriceListID == 0) {
                        ModelMsg('Please select proper Pricing Group at row : ' + totalItemcnt, 3);
                        IsValid = false;
                    }

                    if (FromDate == "") {
                        ModelMsg('Please select proper FromDate at row : ' + totalItemcnt, 3);
                        IsValid = false;
                    }
                    if (ToDate == "") {
                        ModelMsg('Please select proper ToDate at row : ' + totalItemcnt, 3);
                        IsValid = false;
                    }
                    if ((Number(CompContri) + Number(DistContri)) != 100) {
                        ModelMsg('Contribution must be 100 only at row : ' + totalItemcnt, 3);
                        IsValid = false;
                    }

                    var obj = {
                        RateClaimID: RateClaimID,
                        CustomerID: CustomerID,
                        PriceListID: PriceListID,
                        FromDate: FromDate,
                        ToDate: ToDate,
                        CompContri: CompContri,
                        DistContri: DistContri,
                        IsActive: IsActive,
                        //  IPAddress: IPAddress,
                        IsChange: IsChange,
                        Remarks: Remarks
                    };
                    TableData_Customer.push(obj);
                }
                rowCnt_Customer++;
            });

            if (totalItemcnt == 0) {
                $.unblockUI();
                ModelMsg("Please change the data of atleast one Item", 3);
                return false;
            }
            if (cnt == 1) {
                $.unblockUI();
                ModelMsg(errormsg, 3);
                return false;
            }

            var CustomerData = JSON.stringify(TableData_Customer);
            var fileUpload = $("[id*=ORCLMUpload]");
            fileUpload.remove();
            var successMSG = true;

            if (IsValid) {
                var sv = $.ajax({
                    url: 'CustomerWiseClaimContriMaster.aspx/SaveData',
                    type: 'POST',
                    //async: false,
                    dataType: 'json',
                    // traditional: true,
                    data: JSON.stringify({ hidJsonInputCustomer: CustomerData, DivisionID: $('.ddlDivision').val() }),
                    contentType: 'application/json; charset=utf-8'
                });

                var sendcall = 0;

                sv.success(function (result) {

                    if (result.d == "") {
                        $.unblockUI();
                        return false;
                    }
                    else if (result.d.indexOf("ERROR=") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d.split('=')[1].trim();
                        ModelMsg(ErrorMsg, 2);
                        location.reload(true);
                        return false;
                    }
                    else if (result.d.indexOf("WARNING=") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d.split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        //setInterval('location.reload()', 7000);
                        return false;
                    }
                    if (result.d.indexOf("SUCCESS=") >= 0) {
                        var SuccessMsg = result.d.split('=')[1].trim();
                        alert(SuccessMsg);
                        location.reload(true);
                        return false;
                    }

                });

                sv.error(function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    return false;
                });
            }
            else {
                $.unblockUI();
            }
        }

        function ChangeContri(txt) {
            if (txt != undefined) {
                var Container = $(txt).parent().parent();
                var CompContri = Container.find('.txtCompContri').val();
                var DistContri = Container.find('.txtDistContri').val();
                if (Number(CompContri) > 0 && Number(CompContri) > 0 && Number(DistContri) > 0 != '' && ((Number(CompContri) + Number(DistContri)) != 100)) {
                    ModelMsg("Contribution must be 100 only", 3);
                    return;
                }
            }
        }

        function ExportXLS(xlsx, numrows) {
            var sheet = xlsx.xl.worksheets['sheet1.xml'];
            var clR = $('row', sheet);

            //update Row
            clR.each(function () {
                var attr = $(this).attr('r');
                var ind = parseInt(attr);
                ind = ind + numrows;
                $(this).attr("r", ind);
            });

            // Create row before data
            $('row c ', sheet).each(function () {
                var attr = $(this).attr('r');
                var pre = attr.substring(0, 1);
                var ind = parseInt(attr.substring(1, attr.length));
                ind = ind + numrows;
                $(this).attr("r", pre + ind);
            });

            return sheet;
        }

        function Addrow(index, data) {
            msg = '<row r="' + index + '">'
            for (i = 0; i < data.length; i++) {
                var key = data[i].key;
                var value = data[i].value;
                msg += '<c t="inlineStr" r="' + key + index + '">';
                msg += '<is>';
                if (value != "" && Array.isArray(value))
                    value = value[0].replace(/&/g, '&amp;') + value[1].replace(/&/g, '&amp;');
                else
                    value = value.replace(/&/g, '&amp;');
                msg += '<t>' + value + '</t>';
                msg += '</is>';
                msg += '</c>';
            }
            msg += '</row>';
            return msg;
        }

        function GetReport() {

            if ($('.chkIsReport').find('input').is(':checked')) {

                ClearControls();

                $.ajax({
                    url: 'CustomerWiseClaimContriMaster.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ strFromDate: $('.fromdate').val(), strToDate: $('.todate').val(), strCustomer: $('.txtCustCode').val(), strIsHistory: $('.chkIsHistory').find('input').is(':checked'), DivisionID: $('.ddlDivision').val() }),

                    success: function (result) {
                        if (result.d[0] == "") {
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoPriceCode']", this).val() == "";
                            return false;
                        }
                        else {

                            var ReportData = JSON.parse(result.d[0]);
                            var str = "";

                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + ReportData[i].SRNo + "</td>"
                                    + "<td>" + ReportData[i].CustomerName + "</td>"
                                    + "<td>" + ReportData[i].PriceGroup + "</td>"
                                    + "<td>" + ReportData[i].FromDate + "</td>"
                                    + "<td>" + ReportData[i].ToDate + "</td>"
                                    + "<td>" + ReportData[i].CompCont + "</td>"
                                    + "<td>" + ReportData[i].DistCont + "</td>"
                                    + "<td>" + ReportData[i].Active + "</td>"
                                    + "<td>" + ReportData[i].UpdatedBy + "</td>"
                                    + "<td>" + ReportData[i].UpdatedOn + "</td>"
                                    + "<td>" + ReportData[i].ParentCode + "</td>"
                                    + "<td>" + ReportData[i].ParentName + "</td>"
                                    //  + "<td>" + ReportData[i].IPAddress + "</td>"
                                    + "<td>" + ReportData[i].Remarks + "</td>"
                                    + "<td>" + ReportData[i].RateClaimID + "</td></tr>"

                                $('.gvClaimHistory > tbody').append(str);
                            }
                            $('.divClaimReport').removeAttr('style');
                            $('.gvMissdata tbody').empty();
                            $('.divMissData').attr('style', 'display:none;');
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvClaimHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }
                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                    $('.gvClaimHistory').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '62vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        autowidth: false,
                        'columnDefs': [{
                            "targets": [3, 4, 9],
                            "orderable": false
                        }],
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                        {
                            extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                            customize: function (csv) {
                                var data = $("#lnkTitle").text() + '\n';
                                data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                data += 'Division,' + $('.ddlDivision option:selected').text() + '\n';
                                data += 'Customer,' + (($('.txtCustCode').length > 0 && $('.txtCustCode').val() != "") ? $('.txtCustCode').val() : "All") + '\n';
                                data += 'Is History,' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + '\n';
                                data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                data += 'Created on,' + jsDate.toString() + '\n';
                                return data + csv;
                            },
                            exportOptions: {
                                format: {
                                    body: function (data, row, column, node) {
                                        //check if type is input using jquery
                                        return (data == "&nbsp;" || data == "") ? " " : data;
                                        var D = data;
                                    },
                                    footer: function (data, row, column, node) {
                                        //check if type is input using jquery
                                        return (data == "&nbsp;" || data == "") ? " " : data;
                                        var D = data;
                                    }
                                }
                            }
                        },
                        {
                            extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                            customize: function (xlsx) {

                                sheet = ExportXLS(xlsx, 7);

                                var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                var r2 = Addrow(3, [{ key: 'A', value: 'Division' }, { key: 'B', value: $('.ddlDivision option:selected').text() }]);
                                var r3 = Addrow(4, [{ key: 'A', value: 'Customer' }, { key: 'B', value: (($('.txtCustCode').length > 0 && $('.txtCustCode').val() != "") ? $('.txtCustCode').val() : "All") }]);
                                var r4 = Addrow(5, [{ key: 'A', value: 'Is History' }, { key: 'B', value: ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") }]);
                                var r5 = Addrow(6, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                var r6 = Addrow(7, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + sheet.childNodes[0].childNodes[1].innerHTML;
                            }
                        },
                        {
                            extend: 'pdfHtml5',
                            orientation: 'landscape', //landscape
                            pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                            title: $("#lnkTitle").text(),
                            footer: 'true',
                            exportOptions: {
                                //columns: ':visible',
                                search: 'applied',
                                order: 'applied',
                                columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13]
                            },
                            customize: function (doc) {
                                doc.content.splice(0, 1);
                                doc.pageMargins = [20, 80, 20, 30];
                                doc.defaultStyle.fontSize = 7;
                                doc.styles.tableHeader.fontSize = 6;
                                doc.styles.tableFooter.fontSize = 6;
                                //doc['content']['0'].table.widths = ['2%', '25%', '15%', '7%', '7%', '5%', '5%', '5%', '20%', '10%', '5%'];
                                doc['header'] = (function () {
                                    return {
                                        columns: [
                                            {
                                                alignment: 'left',
                                                fontSize: 10,
                                                text: [{ text: $("#lnkTitle").text() + '\n' },
                                                { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                { text: 'Division : ' + ($('.ddlDivision option:Selected').text() + "\n") },
                                                { text: 'Customer : ' + (($('.txtCustCode').length > 0 && $('.txtCustCode').val() != "") ? $('.txtCustCode').val() + "\n" : "All \n") },
                                                { text: 'Is History : ' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False" + "\n") }],
                                                height: 350,
                                            }
                                            ,
                                            {
                                                alignment: 'right',
                                                width: 70,
                                                height: 45,
                                                image: imagebase64
                                            }
                                        ],
                                        margin: 20
                                    }
                                });
                                doc['footer'] = (function (page, pages) {
                                    return {
                                        columns: [
                                            {
                                                alignment: 'left',
                                                fontSize: 8,
                                                text: ['Created on: ', { text: jsDate.toString() }]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['UserId : ', { text: $('.hdnUserName').val() }]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['Version : ', { text: Version }]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
                                            }
                                        ],
                                        margin: 20
                                    }
                                });

                                var objLayout = {};
                                objLayout['hLineWidth'] = function (i) { return .5; };
                                objLayout['vLineWidth'] = function (i) { return .5; };
                                objLayout['hLineColor'] = function (i) { return '#000'; };
                                objLayout['vLineColor'] = function (i) { return '#000'; };
                                objLayout['paddingLeft'] = function (i) { return 4; };
                                objLayout['paddingRight'] = function (i) { return 4; };
                                doc.content[0].layout = objLayout;
                                var rowCount = doc.content[0].table.body.length;
                                for (i = 1; i < rowCount; i++) {// rows alignment setting by default left
                                    doc.content[0].table.body[i][0].alignment = 'center';
                                    doc.content[0].table.body[i][3].alignment = 'center';
                                    doc.content[0].table.body[i][4].alignment = 'center';
                                    doc.content[0].table.body[i][5].alignment = 'right';
                                    doc.content[0].table.body[i][6].alignment = 'right';
                                    doc.content[0].table.body[i][9].alignment = 'center';
                                    doc.content[0].table.body[i][12].alignment = 'right';
                                    // doc.content[0].table.body[i][13].alignment = 'right';
                                };
                                doc.content[0].table.body[0][0].alignment = 'center';
                                doc.content[0].table.body[0][1].alignment = 'left';
                                doc.content[0].table.body[0][2].alignment = 'left';
                                doc.content[0].table.body[0][3].alignment = 'center';
                                doc.content[0].table.body[0][4].alignment = 'center';
                                doc.content[0].table.body[0][5].alignment = 'right';
                                doc.content[0].table.body[0][6].alignment = 'right';
                                doc.content[0].table.body[0][7].alignment = 'left';
                                doc.content[0].table.body[0][8].alignment = 'left';
                                doc.content[0].table.body[0][9].alignment = 'center';
                                doc.content[0].table.body[0][10].alignment = 'left';
                                doc.content[0].table.body[0][11].alignment = 'left';
                                doc.content[0].table.body[0][12].alignment = 'right';
                                //   doc.content[0].table.body[0][13].alignment = 'right';
                            }
                        }]
                    });
                }
            }
        }
        function downloadDoc() {
            window.open("../Document/CSV Formats/RateClaimDiff.csv");
        }

    </script>

    <style>
        .ui-widget {
            font-size: 12px;
        }

        .ui-datepicker {
            z-index: 9 !important;
        }

        .search {
            font-size: 10px !important;
            height: 25px;
            background-color: rgb(250, 255, 189);
            padding: 6px;
        }

        input.txtCompContri, input.txtDistContri {
            text-align: right;
        }

        td.txtSrNo {
            text-align: center;
        }



        .dtbodyCenter {
            text-align: center;
        }

        .dtbodyLeft {
            text-align: left;
        }

        .dtbodyRight {
            text-align: right;
        }

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        th.table-header-gradient {
            z-index: 9;
        }

        #page-content-wrapper {
            overflow: hidden;
        }

        .gvMissdata {
            font-size: 11px;
        }


        table.gvCustomer.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100% !important;
            margin: 0;
            table-layout: auto;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        .txtRemarks {
            width: 300px !important;
            font-size: 10px !important;
            height: 25px !important;
            padding: 6px !important;
        }

        table#gvCustomer.dataTable tbody th {
            padding-left: 6px !important;
            position: relative;
        }

        #gvCustomer {
            margin-top: 0px !important;
        }

        table#gvCustomer.dataTable tbody td {
            /*overflow: auto;*/
            white-space: nowrap;
            overflow-x: scroll;
        }

            table#gvCustomer.dataTable tbody td::-webkit-scrollbar {
                display: none;
            }

        /* Hide scrollbar for IE, Edge and Firefox */
        .gvCustomer {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">View Report</label>
                        <asp:CheckBox runat="server" CssClass="chkIsReport form-control" onchange="ClearControls();" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Division</label>
                        <asp:DropDownList runat="server" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" onchange="ClearControls();" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="divViewDetail">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtFromDate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtToDate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group" id="divDistributor" runat="server">
                            <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtCustCode" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtCustCode form-control" autocomplete="off"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-2">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Is History</label>
                            <asp:CheckBox runat="server" ID="chkIsHistory" CssClass="chkIsHistory form-control" />
                        </div>
                    </div>
                </div>
                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" class="btnSubmit btn btn-default" onclick="btnSubmit_Click()" />
                        <input type="button" id="btnSearch" name="btnSearch" value="Process" class="btnSearch btn btn-default" onclick="GetReport();" />
                        &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" onclick="Cancel()" class="btn btn-default" />
                    </div>
                </div>
            </div>
            <div class="row divUpload">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Claim Contri" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="ORCLMUpload" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        &nbsp<asp:Button ID="btnCLMUpload" runat="server" Text="Upload" OnClick="btnCLMUpload_Click" CssClass="btn btn-success btnCLMUpload" Style="display: inline" />
                        &nbsp<asp:Button ID="btnDownload" runat="server" Text="Download Format" CssClass="btn btn-info" OnClientClick="downloadDoc(); return false;" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <input type="hidden" id="CountRowCustomer" />
                    <div id="divCustEntry" class="divCustEntry" runat="server" style="max-height: 80vh; position: absolute;">
                        <table id="gvCustomer" class="table table-bordered" border="1" tabindex="1" style="border-collapse: collapse; font-size: 10px;">
                            <thead>
                                <tr class="table-header-gradient">
                                    <th style="width: 4%; text-align: center;">Sr</th>
                                    <th style="width: 15%">Dealer Code & Name</th>
                                    <th style="width: 9%">Pricing Group</th>
                                    <th style="width: 5%">From Date</th>
                                    <th style="width: 5% !important">To Date</th>
                                    <th style="width: 5%">Comp. Contri %</th>
                                    <th style="width: 5%">Dist. Contri. %</th>
                                    <th>Active</th>
                                    <th style="width: 10%;">Current Parent Code & Name</th>
                                    <th style="width: 8%;">Last Update By</th>
                                    <th style="width: 8%;">Last Update On</th>
                                    <th>Remarks</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div id="divClaimReport" runat="server" class="divClaimReport">
                <table id="gvClaimHistory" class="gvClaimHistory table table-bordered nowrap" style="overflow: auto; font-size: 11px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 2%; text-align: center;">Sr</th>
                            <th style="width: 17%">Customer Code & Name</th>
                            <th style="width: 8%">PriceGroup</th>
                            <th style="width: 6%; text-align: center;">FromDate</th>
                            <th style="width: 6%; text-align: center;">ToDate</th>
                            <th style="width: 4%; text-align: right;">CompCont %</th>
                            <th style="width: 4%; text-align: right;">DistCont %</th>
                            <th style="width: 4%;">Active</th>
                            <th style="width: 5%;">Update By</th>
                            <th style="width: 5%;">Update On</th>
                            <th style="width: 5%;">Parent Code</th>
                            <th style="width: 5%;">Parent Name</th>
                            <th style="width: 5%;">Remarks</th>
                            <th style="width: 5%; text-align: right;">RateClaim ID</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <div class="divMissData" runat="server" id="divMissData">
                <div class="row">
                    <div class="col-lg-12">
                        <asp:GridView ID="gvMissdata" runat="server" Font-Size="11px" CssClass="gvMissdata table tbl" Width="100%" AutoGenerateColumns="false"
                            HeaderStyle-CssClass="table table-striped table-bordere table-header-gradient">
                            <Columns>
                                <asp:TemplateField HeaderText="No.">
                                    <ItemTemplate>
                                        <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Division Code" HeaderText="Division Code" HeaderStyle-Width="10%" />
                                <asp:BoundField DataField="Customer Code" HeaderText="Customer Code" HeaderStyle-Width="10%" />
                                <asp:BoundField DataField="PriceCode" HeaderText="Price Code" HeaderStyle-Width="10%" />
                                <asp:BoundField DataField="From Date" HeaderText="From Date" HeaderStyle-Width="7%" />
                                <asp:BoundField DataField="To Date" HeaderText="To Date" HeaderStyle-Width="7%" />
                                <asp:BoundField DataField="Comp Contri" HeaderText="Comp Contri" HeaderStyle-Width="7%" />
                                <asp:BoundField DataField="Dist Contri" HeaderText="Dist Contri" HeaderStyle-Width="6%" />
                                <asp:BoundField DataField="Active" HeaderText="Active" HeaderStyle-Width="6%" />
                                <asp:BoundField DataField="ErrorMsg" HeaderText="ErrorMsg" HeaderStyle-Width="60%" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

