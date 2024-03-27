<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="ScanningTypeMaster.aspx.cs" Inherits="Master_ScanningTypeMaster" %>

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
       // var LogoURL = '../Images/LOGO.png';
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

        $(document).ready(function () {
            BindScanning();
            ClearControls();
            $("#tblCustomer").tableHeadFixer('80vh');
            //$("#gvScanningTypeHistory").tableHeadFixer('80vh');

            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            //FillData();
            var clicked = false;
            $(document).on('click', '.btnEdit', function () {
                var checkBoxes = $(this).closest('tr').find('.chkEdit');
                if (checkBoxes.prop("checked") == true) {
                    checkBoxes.prop("checked", false);
                    $(this).closest('tr').find('.search,.checkbox').prop('disabled', false);
                    $(this).val('Update');
                } else {
                    checkBoxes.prop("checked", true);
                    $(this).closest('tr').find('.search,.checkbox').prop('disabled', true);
                    $(this).val('Edit');
                }
            });

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

        function AddMoreRow() {
           
            $('table#tblCustomer tr#NoROW').remove();  // Remove NO ROW

            /// Add Dynamic Row to the existing Table
            var ind = $('#CountRowCustomer').val();
           
            ind = parseInt(ind) + 1;
            $('#CountRowCustomer').val(ind);

            var str = "";
            str = "<tr id='trOSTM" + ind + "'>"
                + "<td class='txtSrNo' id='txtSrNo" + ind + "'>" + ind + "</td>"
                 + "<td><input type='checkbox' id='chkEdit" + ind + "' class='chkEdit' checked/>"
                + "<input type='button' class='btnEdit btnEditDelete' id='btnEdit" + ind + "' name='btnEdit' value = 'Edit' /></td>"
                + "<td><input type='button' class='btnDelete btnEditDelete' id='btnDelete" + ind + "' name='btnDelete' value = 'Delete' onclick='RemoveScaningTypeRow(" + ind + ");' /></td>"
                + "<td><input type='text' id='AutoEmpGroup" + ind + "' name='AutoEmpGroup' onchange='ChangeData(this);' class='form-control search ' /></td>"
                + "<td><input type='text' id='AutoEmpName" + ind + "' name='AutoEmpName' onchange='ChangeData(this);' class='form-control search ' /></td>"
                  + "<td><input type='text' id='AutoCustName" + ind + "' name='AutoCustName' onchange='ChangeData(this);' class='form-control search' /></td>"
                + "<td><input type='checkbox' id='chkmanual" + ind + "' name='chkmanual'  onchange='ChangeDataManual(this);' class='checkbox'/></td>"
                + "<td><input type='checkbox' id='chkCamscanning" + ind + "' name='chkCamscanning' onchange='ChangeDataCamScanning(this);'  class='checkbox'/></td>"
                + "<td><input type='checkbox' id='chkBoth" + ind + "' name='chkBoth' onchange='ChangeDataBoth(this);'  class='checkbox'/></td>"
                + "<td><input type='checkbox' id='chkIsActive" + ind + "' name='chkIsActive' onchange='ChangeData(this);'  class='checkbox'/></td>"
                 + "<td id='tdCreatedBy" + ind + "' class='tdCreatedBy'></td>"
                  + "<td id='tdCreatedDate" + ind + "' class='tdCreatedDate'></td>"
                 + "<td id='tdUpdateBy" + ind + "' class='tdUpdateBy'></td>"
                  + "<td id='tdUpdateDate" + ind + "' class='tdUpdateDate'></td>"
                + "<input type='hidden' class='hdnScanningTypeId' id='hdnScanningTypeId" + ind + "' name='hdnScanningTypeId'  /></td>"
                + "<input type='hidden' class='hdnEmpGroupId' id='hdnEmpGroupId" + ind + "' name='hdnEmpGroupId'  /></td>"
                + "<input type='hidden' class='hdnEmpId' id='hdnEmpId" + ind + "' name='hdnEmpId'  /></td>"
                + "<input type='hidden' class='hdnCustId' id='hdnCustId" + ind + "' name='hdnCustId'  /></td>"
                 + "<input type='hidden' class='IsChange' id='IsChange" + ind + "' name='IsChange' value='0' /></td>"
                + "<input type='hidden' class='hdnLineNum' id='hdnLineNum" + ind + "' name='hdnLineNum' value='" + ind + "' /></tr>";

            $('#tblCustomer > tbody').append(str);

            $('.chkEdit').hide();
            $('.chkEdit').prop("checked", true);
            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 0);
            var table = document.getElementById("tblCustomer");
            //Start Employee Group Textbox
            $('#AutoEmpGroup' + ind).autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: 'ScanningTypeMaster.aspx/SearchEmployeeGroup',
                        type: "POST",
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "'}",
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
                    $('#AutoEmpGroup' + ind).val(ui.item.value + " ");
                    $('#hdnEmpGroupId' + ind).val(ui.item.id);
                    $('#AutoEmpName' + ind).val("");
                    $('#hdnEmpId' + ind).val(0);
                    $('#AutoCustName' + ind).val("");
                    $('#hdnCustId' + ind).val(0);
                    $('#tdFromDate' + ind).text('');
                    $('#tdToDate' + ind).text('');
                    $('#txtCompContri' + ind).val("");
                    $('#txtDistContri' + ind).val("");
                    $('#chkIsActive' + ind).prop('checked', false);
                    $('#chkIsActive' + ind).attr("disabled", false);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoEmpGroup' + ind).val("");
                        $('#hdnEmpGroupId' + ind).val(0);
                        $('#AutoEmpName' + ind).val("");
                        $('#hdnEmpId' + ind).val(0);
                        $('#AutoCustName' + ind).val("");
                        $('#hdnCustId' + ind).val(0);
                        $('#tdFromDate' + ind).text('');
                        $('#tdToDate' + ind).text('');
                        $('#txtCompContri' + ind).val("");
                        $('#txtDistContri' + ind).val("");
                        $('#chkIsActive' + ind).prop('checked', false);
                        $('#chkIsActive' + ind).attr("disabled", false);
                    }
                },
                open: function (event, ui) {
                    var txttopposition = $('#AutoEmpGroup' + ind).position().top;
                    var bottomPosition = $(document).height();
                    var $input = $(event.target),
                        $results = $input.autocomplete("widget"),
                         inputHeight = $input.height(),
                        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoEmpGroup' + ind).position().top : table.offsetHeight, // $('#AutoCustName' + ind).position().top,// ind >= 6 ? $('#AutoCustName' + ind).position().top : table.offsetHeight, //$results.position().top,
                        height = $results.height(),
                        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top; //top - height;//ind >= 6 ? top - height : top;
                    $results.css("top", newTop + "px");
                },
                //open: function (event, ui) {

                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //         inputHeight = $input.height(),
                //        top = $('#AutoEmpGroup' + ind).position().top,//ind >= 6 ? $('#AutoEmpGroup' + ind).position().top : table.offsetHeight, //$results.position().top,
                //        height = $results.height(),

                //    newTop = top;//ind >= 6 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},
                minLength: 1
            });

            $('#AutoEmpGroup' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoEmpGroup' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoEmpGroup' + ind).on('change keyup', function () {
                if ($('#AutoEmpGroup' + ind).val() == "") {
                    ClearCustomerRow(ind);
                }
            });

            $('#AutoEmpGroup' + ind).on('blur', function (e, ui) {
                if ($('#AutoEmpGroup' + ind).val().trim() != "") {
                    if ($('#AutoEmpGroup' + ind).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Employee Group", 3);
                        $('#AutoEmpGroup' + ind).val("");
                        $('#hdnEmpGroupId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoEmpGroup' + ind).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblCustomer > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateCustomer($('#AutoEmpGroup' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoCustName' + ind).val().trim(), ind, 1);
                    //CheckDuplicateCustomer($('#AutoEmpGroup' + ind).val().trim(), $('#hdnPriceListID' + ind).val().trim(), $('#tdFromDate' + ind).val().trim(), $('#tdToDate' + ind).val().trim(), ind);
                }
            });


            //Start Employee  Textbox
            $('#AutoEmpName' + ind).autocomplete({
                source: function (request, response) {
                    var EmpGroupId = $("#AutoEmpGroup" + ind).val() != "" && $("#AutoEmpGroup" + ind).val() != undefined ? $("#AutoEmpGroup" + ind).val().split("#")[2].trim() : "0";
                    $.ajax({
                        type: "POST",
                        url: 'ScanningTypeMaster.aspx/SearchEmployee',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strEmpGroupId':'" + EmpGroupId + "'}",
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
                    //   $('#AutoEmpGroup' + ind).val(ui.item.value + " ");
                    $('#hdnEmpId' + ind).val(ui.item.id);
                    $('#AutoEmpName' + ind).val("");
                    $('#AutoCustName' + ind).val("");
                    $('#hdnCustId' + ind).val(0);
                    $('#tdFromDate' + ind).text('');
                    $('#tdToDate' + ind).text('');
                    $('#txtCompContri' + ind).val("");
                    $('#txtDistContri' + ind).val("");
                    $('#chkIsActive' + ind).prop('checked', false);
                    $('#chkIsActive' + ind).attr("disabled", false);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoEmpName' + ind).val("");
                        $('#hdnEmpId' + ind).val(0);
                        $('#AutoCustName' + ind).val("");
                        $('#hdnCustId' + ind).val(0);
                        $('#tdFromDate' + ind).text('');
                        $('#tdToDate' + ind).text('');
                        $('#txtCompContri' + ind).val("");
                        $('#txtDistContri' + ind).val("");
                        $('#chkIsActive' + ind).prop('checked', false);
                        $('#chkIsActive' + ind).attr("disabled", false);
                    }
                },
                open: function (event, ui) {
                    var txttopposition = $('#AutoEmpName' + ind).position().top;
                    var bottomPosition = $(document).height();
                    var $input = $(event.target),
                        $results = $input.autocomplete("widget"),
                         inputHeight = $input.height(),
                        top = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? $('#AutoEmpName' + ind).position().top : table.offsetHeight, // $('#AutoCustName' + ind).position().top,// ind >= 6 ? $('#AutoCustName' + ind).position().top : table.offsetHeight, //$results.position().top,
                        height = $results.height(),
                        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top; //top - height;//ind >= 6 ? top - height : top;
                    $results.css("top", newTop + "px");
                },
                //open: function (event, ui) {

                //    var $input = $(event.target),
                //        $results = $input.autocomplete("widget"),
                //         inputHeight = $input.height(),
                //        top = $('#AutoEmpName' + ind).position().top,//ind >= 6 ? $('#AutoEmpName' + ind).position().top : table.offsetHeight, //$results.position().top,
                //        height = $results.height(),

                //    newTop = top;//ind >= 6 ? top - height : top;
                //    $results.css("top", newTop + "px");
                //},
                minLength: 1
            });
            $('#AutoEmpName' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoEmpName' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoEmpName' + ind).on('change keyup', function () {
                if ($('#AutoEmpName' + ind).val() == "") {
                    ClearCustomerRow(ind);
                }
            });

            $('#AutoEmpName' + ind).on('blur', function (e, ui) {
                if ($('#AutoEmpName' + ind).val().trim() != "") {
                    if ($('#AutoEmpName' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Employee", 3);
                        $('#AutoEmpName' + ind).val("");
                        $('#hdnEmpId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoEmpName' + ind).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblCustomer > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateCustomer($('#AutoEmpGroup' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoCustName' + ind).val().trim(), ind, 2);
                }
            });

            //End Customer Textbox

            //Start Cust Textbox
            $('#AutoCustName' + ind).autocomplete({
                source: function (request, response) {


                    var EmpGroupId = $("#AutoEmpGroup" + ind).val() != "" && $("#AutoEmpGroup" + ind).val() != undefined ? $("#AutoEmpGroup" + ind).val().split("#")[2].trim() : "0";
                    var EmpId = $("#AutoEmpName" + ind).val() != "" && $("#AutoEmpName" + ind).val() != undefined ? $("#AutoEmpName" + ind).val().split("-")[2].trim() : "0";
                    $.ajax({
                        type: "POST",
                        url: 'ScanningTypeMaster.aspx/SearchCustomer',
                        dataType: "json",
                        data: "{ 'prefixText': '" + (request.term != '' ? request.term : '*') + "','strEmpGroupId':'" + EmpGroupId + "','strEmpId':'" + EmpId + "'}",
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
                    $('#AutoCustName' + ind).val(ui.item.value + " ");
                    $('#hdnCustId' + ind).val(ui.item.value.split("-")[2].trim());
                    $('#chkIsActive' + ind).prop('checked', false);
                    $('#chkIsActive' + ind).attr("disabled", false);
                },
                change: function (event, ui) {
                    if (!ui.item) {
                        $('#AutoCustName' + ind).val("");
                        $('#hdnCustId' + ind).val(0);
                    }
                },
                open: function (event, ui) {
                    var txttopposition = $('#AutoCustName' + ind).position().top;
                    var bottomPosition = $(document).height();
                    var $input = $(event.target),
                        $results = $input.autocomplete("widget"),
                         inputHeight = $input.height(),
                        top = parseInt(txttopposition) <= 260 ? txttopposition+10 : parseInt(bottomPosition) >= 600 ? $('#AutoCustName' + ind).position().top : table.offsetHeight, // $('#AutoCustName' + ind).position().top,// ind >= 6 ? $('#AutoCustName' + ind).position().top : table.offsetHeight, //$results.position().top,
                        height = $results.height(),
                        newTop = parseInt(txttopposition) <= 260 ? txttopposition + 10 : parseInt(bottomPosition) >= 600 ? top - height : top; //top - height;//ind >= 6 ? top - height : top;
                    $results.css("top", newTop + "px");
                },
                minLength: 1
            });


            $('#AutoCustName' + ind).on('autocompleteselect', function (e, ui) {
                $('#AutoCustName' + ind).val(ui.item.value);
                //GetCustomerDetailsByCode(ui.item.value, ind);
            });

            $('#AutoCustName' + ind).on('change keyup', function () {
                if ($('#AutoCustName' + ind).val() == "") {
                    ClearCustomerRow(ind);
                    $('#hdnCustId' + ind).val(0);

                }
            });

            $('#AutoCustName' + ind).on('blur', function (e, ui) {
                if ($('#AutoCustName' + ind).val().trim() != "") {
                    if ($('#AutoCustName' + ind).val().indexOf('-') == -1) {
                        ModelMsg("Select Proper Customer Name", 3);
                        $('#AutoCustName' + ind).val("");
                        $('#hdnCustId' + ind).val('0');
                        return;
                    }
                    var txt = $('#AutoCustName' + ind).val().trim();

                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                    var lineNum = 1;
                    $('#tblCustomer > tbody > tr').each(function (row, tr) {
                        $(".txtSrNo", this).text(lineNum);
                        lineNum++;
                    });
                    CheckDuplicateCustomer($('#AutoEmpGroup' + ind).val().trim(), $('#AutoEmpName' + ind).val().trim(), $('#AutoCustName' + ind).val().trim(), ind, 3);
                }
            });
        }

        function CheckDuplicateCustomer(EmpGroupCode, ItemEmpId, ItemCustomerId, row, ChkType) {
            var Item = "";
            var oldEmpGroupCode = EmpGroupCode;
            if (EmpGroupCode != "") {
                Item = EmpGroupCode.split("#")[2].trim();
            }
            var rowCnt_Customer = 1;
            var cnt = 0;
            var errRow = 0;

            $('#tblCustomer  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                //if ($("input[name='AutoEmpGroup']", this).val() != "") {
                var EmpGroupCode = $("input[name='AutoEmpGroup']", this).val() != "" ? $("input[name='AutoEmpGroup']", this).val().split("#")[2].trim() : "";
                var EmpId = $("input[name='hdnEmpId']", this).val();
                var LineNum = $("input[name='hdnLineNum']", this).val();
                var CustomerId = $("input[name='hdnCustId']", this).val();
                if (ChkType == 1) {
                    if (EmpGroupCode != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (Item == EmpGroupCode) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoEmpGroup' + ind).val("");
                                $('#hdnEmpGroupId' + ind).val(0);
                                $('#AutoEmpName' + ind).val("");
                                $('#hdnEmpId' + ind).val(0);
                                $('#AutoCustName' + ind).val("");
                                $('#hdnCustId' + ind).val(0);
                                $('#hdnEmpId' + ind).val(0);
                                $('#chkIsActive' + row).prop('checked', false);
                                $('#chkIsActive' + row).attr("disabled", false);
                                errormsg = 'Employee Group is already set for = ' + oldEmpGroupCode + ' at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 2) {
                    if (EmpId != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (ItemEmpId.split("-").pop().trim() == EmpId) {
                                cnt = 1;
                                errRow = row;
                                $('#AutoEmpName' + row).val('');
                                // $('#AutoCustName' + row).val('');
                                errormsg = 'Employee is already set for = ' + ItemEmpId + ' at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                }
                else if (ChkType == 3) {
                    if (CustomerId != "") {
                        if (parseInt(row) != parseInt(LineNum)) {
                            if (ItemCustomerId.split("-")[2].trim() == CustomerId) {
                                cnt = 1;
                                errRow = row;
                                //$('#AutoEmpName' + row).val('');
                                $('#AutoCustName' + row).val('');
                                errormsg = 'Customer is already set for customer = ' + ItemCustomerId + ' at row : ' + rowCnt_Customer;
                                return false;
                            }
                        }
                    }
                }
                //}
                rowCnt_Customer++;
                //}
            });

            if (cnt == 1) {
                //$('#AutoCustCode' + row).val('');
                if (ChkType == 1) {
                    $('#AutoEmpGroup' + row).val("");
                }
                else if (ChkType == 2) {
                    $('#AutoEmpName' + row).val('');
                }
                else {
                    $('#AutoCustName' + row).val('');
                }
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

            $('#tblCustomer > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format

                var CustCode = $("input[name='AutoEmpGroup']", this).val();
                if (CustCode == "") {
                    //$(this).remove();
                }
                cnt++;

                rowCnt_Customer++;
            });

            if (cnt > 1) {
                var rowCnt_Customer = 1;
                $('#tblCustomer > tbody > tr').each(function (row1, tr) {
                    // post table's data to Submit form using Json Format                    
                    if (cnt != rowCnt_Customer) {
                        var ScanningTypeId = $("input[name='hdnScanningTypeId']", this).val();
                        var EmpGroup = $("input[name='AutoEmpGroup']", this).val();
                        var EmpName = $("input[name='AutoEmpName']", this).val();
                        var CustName = $("input[name='AutoCustName']", this).val();
                        if (EmpGroup == "" && EmpName == "" && CustName == "") {
                            $(this).remove();
                        }
                    }

                    rowCnt_Customer++;
                });
            }
            var lineNum = 1;
            $('#tblCustomer > tbody > tr').each(function (row, tr) {
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
            $('#tblCustomer  > tbody > tr').each(function (row1, tr) {
                // post table's data to Submit form using Json Format
                $(this).remove();
            });

            var IsValid = true;

            $.ajax({
                url: 'ScanningTypeMaster.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ ModuleId: $('.ddlModule').val(), ScanningId: $('.ddlScanningAt').val() }),
                success: function (result) {
                    $.unblockUI();
                    console.log(result.d[0].length);
                    if (result.d[0].length == 0) {
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
                        var items = result.d[0];

                        if (items.length > 0) {
                            $('#tblCustomer  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                            var trHTML = '';
                            var row = 1;
                            $('#CountRowCustomer').val(0);
                            var ind = $('#CountRowCustomer').val();
                            //  ind = parseInt(ind) + 1;

                            $('#CountRowCustomer').val(ind);
                            var ind = 0;
                            // $('#CountRowCustomer').val(0);
                            for (var i = 0; i < items.length; i++) {
                                AddMoreRow();
                                row = $('#CountRowCustomer').val();
                                $('#chkEdit' + row).click();
                                $('#chkEdit' + row).prop("checked", false);

                                $('#AutoEmpGroup' + row).val(items[i].EmpGroupName);
                                $('#AutoEmpName' + row).val(items[i].EmpName);
                                $('#AutoCustName' + row).val(items[i].CustomerName);

                                if (items[i].ManualKeypadEntry == false) {
                                    $('#chkmanual' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkmanual' + row).prop("checked", true);
                                }

                                if (items[i].CameraScanning == false) {
                                    $('#chkCamscanning' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkCamscanning' + row).prop("checked", true);
                                }

                                if (items[i].Both == false) {
                                    $('#chkBoth' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkBoth' + row).prop("checked", true);
                                }

                                if (items[i].IsActive == false) {
                                    $('#chkIsActive' + row).prop("checked", false);
                                }
                                else {
                                    $('#chkIsActive' + row).prop("checked", true);
                                }

                                $('#tdCreatedBy' + row).text(items[i].CreatedBy);
                                $('#tdCreatedDate' + row).text(items[i].CreatedDate);
                                $('#tdUpdateBy' + row).text(items[i].UpdatedBy);
                                $('#tdUpdateDate' + row).text(items[i].UpdatedDate);
                                $('#hdnScanningTypeId' + row).val(items[i].OSTMID);
                                $('#hdnEmpGroupId' + row).val(items[i].EmpGroupId);
                                $('#hdnCustId' + row).val(items[i].CustomerId);
                                $('#hdnEmpId' + row).val(items[i].EmpId);
                                $('.chkEdit').prop("checked", false);
                                $('.btnEdit').click();
                            }
                        }
                        else {
                            $('#tblCustomer  > tbody > tr').each(function (row1, tr) {
                                // post table's data to Submit form using Json Format
                                $(this).remove();
                            });
                        }
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

        function GetReport() {

            if ($('.chkIsReport').find('input').is(':checked')) {
                ClearControls();

                $('.gvScanningTypeHistory tbody').empty();
                $.ajax({
                    url: 'ScanningTypeMaster.aspx/LoadReport',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    contentType: 'application/json; charset=utf-8',
                    data: "{ 'strIsHistory': '" + $('.chkIsHistory').find('input').is(':checked') + "','ModuleId': '" + $('.ddlModule').val() + "','ScanningAtId': '" + $('.ddlScanningAt').val() + "'}",
                    success: function (result) {
                        if (result.d[0] == "" || result.d[0] == undefined) {
                            return false;
                        }
                        else if (result.d[0].indexOf("ERROR=") >= 0) {
                            var ErrorMsg = result.d[0].split('=')[1].trim();
                            ModelMsg(ErrorMsg, 3);
                            $("input[name='AutoCustCode']", this).val() == "";
                            return false;
                        }
                        else {

                            var ReportData = JSON.parse(result.d[0]);
                            var str = "";

                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + ReportData[i].SRNo + "</td>"
                                        + "<td>" + ReportData[i].EmpGroupName + "</td>"
                                        + "<td>" + ReportData[i].EmpName + "</td>"
                                        //+ "<td>" + ReportData[i].CityName + "</td>"
                                        + "<td>" + ReportData[i].CustomerName + "</td>"
                                        + "<td>" + ReportData[i].ManualKeyPadEntry + "</td>"
                                        + "<td>" + ReportData[i].CameraScanning + "</td>"
                                        + "<td>" + ReportData[i].Both + "</td>"
                                        + "<td>" + ReportData[i].IsActive + "</td>"
                                        + "<td>" + ReportData[i].CreatedBy + "</td>"
                                        + "<td>" + ReportData[i].CreatedDate + "</td>"
                                        + "<td>" + ReportData[i].UpdatedBy + "</td>"
                                        + "<td>" + ReportData[i].UpdatedDate + "</td> </tr>"
                                //+ "<td>" + ReportData[i].Employee + "</td>

                                $('.gvScanningTypeHistory > tbody').append(str);
                            }

                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert('Something is wrong...' + XMLHttpRequest.responseText);
                        return false;
                    }
                });

                if ($('.gvScanningTypeHistory tbody tr').length > 0) {

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }

                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: false });

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 2 });
                    //aryJSONColTable.push({ "width": "60px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyLeft", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "7px", "sClass": "dtbodyLeft", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "7px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "10px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "150px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "20px", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 11 });
                    //aryJSONColTable.push({ "width": "30px", "aTargets": 12 });
                    //aryJSONColTable.push({ "width": "30px", "aTargets": 13 });
                    //aryJSONColTable.push({ "width": "200px", "aTargets": 11 });

                    $('.gvScanningTypeHistory').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '58vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "bSort": false,
                        "aoColumnDefs": aryJSONColTable,
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                           {
                               extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (csv) {
                                   var data = $("#lnkTitle").text() + '\n';
                                   data += 'Module,' + $('.ddlModule option:selected').text() + '\n';
                                   data += 'Scanning At,' + $('.ddlScanningAt option:selected').text() + '\n';
                                   data += 'With History,' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + '\n';
                                   data += 'UserId,' + $('.hdnUserName').val() + '\n';
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
                               extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString() + '_' + new Date().toLocaleTimeString('en-US'),
                               customize: function (xlsx) {

                                   sheet = ExportXLS(xlsx, 6);

                                   var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                   var r1 = Addrow(2, [{ key: 'A', value: 'Module' }, { key: 'B', value: $('.ddlModule option:selected').text() }]);
                                   var r2 = Addrow(3, [{ key: 'A', value: 'Scanning At' }, { key: 'B', value: $('.ddlScanningAt option:selected').text() }]);
                                   var r3 = Addrow(4, [{ key: 'A', value: 'With History' }, { key: 'B', value: ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") }]);
                                   var r4 = Addrow(5, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                   var r5 = Addrow(6, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
                               }
                           },
                           {
                               extend: 'pdfHtml5',
                               orientation: 'landscape', //portrait
                               pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                               title: $("#lnkTitle").text(),
                               footer: 'false',
                               exportOptions: {
                                   columns: ':visible',
                                   search: 'applied',
                                   order: 'applied'
                               },
                               customize: function (doc) {
                                   doc.content.splice(0, 1);
                                   var now = new Date();
                                   doc.pageMargins = [20, 70, 20, 30];
                                   doc.defaultStyle.fontSize = 6;
                                   doc.styles.tableHeader.fontSize = 8;
                                   doc.styles.tableFooter.fontSize = 6;
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: false,
                                                   text: [
                                                       { text: $("#lnkTitle").text() + '\n' },
                                                       { text: 'Module : ' + $('.ddlModule option:selected').text() + "\n" },
                                                       { text: 'Scanning At : ' + $('.ddlScanningAt option:selected').text() + "\n" },
                                                       { text: 'With History : ' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + "\n" },
                                                       { text: 'User Name : ' + $('.hdnUserName').val() + "\n" },
                                                         { text: 'Created On : ' + jsDate.toString() + "\n" },
                                                   ],
                                                   fontSize: 10,
                                                   height: 350,
                                               },
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
                                       doc.content[0].table.body[i][5].alignment = 'left';
                                       doc.content[0].table.body[i][6].alignment = 'left';
                                       doc.content[0].table.body[i][9].alignment = 'left';
                                       doc.content[0].table.body[i][11].alignment = 'left';
                                   };
                                   doc.content[0].table.body[0][0].alignment = 'center';
                                   doc.content[0].table.body[0][1].alignment = 'left';
                                   doc.content[0].table.body[0][2].alignment = 'left';
                                   doc.content[0].table.body[0][3].alignment = 'left';
                                   doc.content[0].table.body[0][4].alignment = 'left';
                                   doc.content[0].table.body[0][5].alignment = 'left';
                                   doc.content[0].table.body[0][6].alignment = 'left';
                                   doc.content[0].table.body[0][7].alignment = 'left';
                                   doc.content[0].table.body[0][8].alignment = 'left';
                                   doc.content[0].table.body[0][9].alignment = 'left';
                                   doc.content[0].table.body[0][10].alignment = 'left';
                                   doc.content[0].table.body[0][11].alignment = 'left';
                               }
                           }]
                    });
                }
            }
        }

        function BindScanning() {
            var ModuleId = $('.ddlModule').val();
            var select = $('.ddlScanningAt');
            var elmts = { 1: "Complain Registration", 2: "AM", 3: "BM", 4: "PM", 5: "Un Plan Task" };
            var Vadilalpulse = { 1: "Asset Audit", 2: "Order Taking Time Scanning", 3: "Complain Registration" };
            $(select).find("option").remove();
            if (ModuleId == 1) {
                for (var key in Vadilalpulse) {
                    var el = document.createElement("option");
                    el.textContent = Vadilalpulse[key];
                    el.value = key;
                    select.append(el);
                }
            }
            else {
                for (var key in elmts) {
                    var el = document.createElement("option");
                    el.textContent = elmts[key];
                    el.value = key;
                    select.append(el);
                }
            }
            ClearControls();
        }

        function ClearControls() {

            $('.divCustEntry').attr('style', 'display:none;');
            $('.divScanningReport').attr('style', 'display:none;');
            $('.divMissData').attr('style', 'display:none;');
            $('.btnSubmit').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#tblCustomer tbody').empty();

            if ($.fn.DataTable.isDataTable('.gvScanningTypeHistory')) {
                $('.gvScanningTypeHistory').DataTable().destroy();
            }

            $('.gvScanningTypeHistory tbody').empty();
            if ($('.chkIsReport').find('input').is(':checked')) {
                $('.divScanningReport').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.divViewDetail').removeAttr('style');
            }
            else {
                $('.divCustEntry').removeAttr('style');
                $('.btnSubmit').removeAttr('style');

                $('#CountRowCustomer').val(0);
                FillData();
                AddMoreRow();
            }
        }

        function RemoveScaningTypeRow(row) {

            var OFFSIID = $('table#tblCustomer tr#trOSTM' + row).find(".hdnScanningTypeId").val();
            $('table#tblCustomer tr#trOSTM' + row).find(".IsChange").val("1");
            $('table#tblCustomer tr#trOSTM' + row).remove();
            $('table#tblCustomer tr#trOSTM' + row).find(".IsDeleted").val("1");
            var deleteIDs = $('#hdnDeleteIDs').val();
            var deletedIDs = OFFSIID + ",";
            deleteIDs += deletedIDs;
            $('#hdnDeleteIDs').val(deleteIDs);
            $('table#tblCustomer tr#trOSTM' + (row + 1)).focus();
            $('#hdnIsRowDeleted').val("1");
        }

        function Cancel() {
            window.location = "../Master/ScanningTypeMaster.aspx";
        }

        function ChangeDataManual(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var Ischkmanual = $(txt).parent().parent().find("input[name='chkmanual']", this).is(':checked');
            var IschkCamscanning = $(txt).parent().parent().find("input[name='chkCamscanning']", this).is(':checked');
            var IschkBoth = $(txt).parent().parent().find("input[name='chkBoth']").is(':checked');
            if (Ischkmanual == true && IschkCamscanning == false) {
                $(txt).parent().parent().find("input[name='chkmanual']").prop('checked', true);
                $(txt).parent().parent().find("input[name='chkCamscanning']").prop('checked', false);
                $(txt).parent().parent().find("input[name='chkBoth']").prop('checked', false);
            }
            else if (Ischkmanual == true && IschkCamscanning == true) {
                $(txt).parent().parent().find("input[name='chkmanual']").prop('checked', true);
                $(txt).parent().parent().find("input[name='chkCamscanning']").prop('checked', true);
                $(txt).parent().parent().find("input[name='chkBoth']").prop('checked', true);
            }
            else {
                $(txt).parent().parent().find("input[name='chkmanual']").prop('checked', false);
                $(txt).parent().parent().find("input[name='chkBoth']").prop('checked', false);
            }
        }

        function ChangeDataCamScanning(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var Ischkmanual = $(txt).parent().parent().find("input[name='chkmanual']", this).is(':checked');
            var IschkCamscanning = $(txt).parent().parent().find("input[name='chkCamscanning']", this).is(':checked');
            var IschkBoth = $(txt).parent().parent().find("input[name='chkBoth']").is(':checked');
            if (Ischkmanual == false && IschkCamscanning == true) {
                $(txt).parent().parent().find("input[name='chkmanual']").prop('checked', false);
                $(txt).parent().parent().find("input[name='chkCamscanning']").prop('checked', true);
                $(txt).parent().parent().find("input[name='chkBoth']").prop('checked', false);
            }
            else if (Ischkmanual == true && IschkCamscanning == true) {
                $(txt).parent().parent().find("input[name='chkmanual']").prop('checked', true);
                $(txt).parent().parent().find("input[name='chkCamscanning']").prop('checked', true);
                $(txt).parent().parent().find("input[name='chkBoth']").prop('checked', true);
            }
            else {
                $(txt).parent().parent().find("input[name='chkCamscanning']").prop('checked', false);
                $(txt).parent().parent().find("input[name='chkBoth']").prop('checked', false);
            }
        }

        function ChangeDataBoth(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var Ischkmanual = $(txt).parent().parent().find("input[name='chkmanual']", this).is(':checked');
            var IschkCamscanning = $(txt).parent().parent().find("input[name='chkCamscanning']", this).is(':checked');
            var IschkBoth = $(txt).parent().parent().find("input[name='chkBoth']").is(':checked');
            if (IschkBoth == true) {
                $(txt).parent().parent().find("input[name='chkmanual']").prop('checked', true);
                $(txt).parent().parent().find("input[name='chkCamscanning']").prop('checked', true);
                $(txt).parent().parent().find("input[name='chkBoth']").prop('checked', true);
            }
            else {
                $(txt).parent().parent().find("input[name='chkmanual']").prop('checked', false);
                $(txt).parent().parent().find("input[name='chkCamscanning']").prop('checked', false);
                $(txt).parent().parent().find("input[name='chkBoth']").prop('checked', false);
            }
        }

        function ChangeData(txt) {
            $(txt).parent().parent().find("input[name='IsChange']").val("1");
            var ind = $('#CountRowCustomer').val();
            var row = Number($(txt).parent().parent().find("input[name='hdnLineNum']").val());
            if (ind == row) {
                AddMoreRow();
            }
            //CheckDuplicateCust($(txt).parent().parent().find("input[name='AutoCustCode']").val(), Number($(txt).parent().parent().find("input[name='hdnLineNum']").val()));
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

            $('#tblCustomer  > tbody > tr').each(function (row, tr) {
                var EmpGroupCode = $("input[name='AutoEmpGroup']", this).val();
                var EmpName = $("input[name='AutoEmpName']", this).val();
                var CustName = $("input[name='AutoCustName']", this).val();
                // $("#AutoCustName" + ind).val() != "" && $("#AutoCustName" + ind).val() != undefined ? $("#AutoCustName" + ind).val().split("-")[2].trim() : "0";
                var EmpId = $("input[name='hdnEmpId']", this).val().trim();
                var EmpGroupId = $("input[name='hdnEmpGroupId']", this).val().trim();
                var CustId = $("input[name='hdnCustId']", this).val().trim();
                var IsDeleted = $('#hdnIsRowDeleted').val();
                if (CustName == "") {
                    CustId = 0;
                    $("input[name='hdnCustId']", this).val(0);
                }
                var IsChange = $("input[name='IsChange']", this).val().trim();
                var Ischkmanual = $("input[name='chkmanual']", this).is(':checked');
                var IschkCamscanning = $("input[name='chkCamscanning']", this).is(':checked');
                var IschkBoth = $("input[name='chkBoth']", this).is(':checked');
                if ((EmpGroupCode != "" || EmpName != "" || CustName != '') && (IsChange == "1" || IsDeleted == 1)) {
                    if ((Ischkmanual != false || IschkCamscanning != false)) {
                        totalItemcnt = 1;
                        var ScanningTypeId = $("input[name='hdnScanningTypeId']", this).val().trim();
                        EmpGroupId = $("input[name='hdnEmpGroupId']", this).val().trim();
                        EmpId = $("input[name='hdnEmpId']", this).val().trim();
                        CustId = $("input[name='hdnCustId']", this).val().trim();
                        //CustId = $("input[name='AutoCustName']", this).val() != "" && $("input[name='AutoCustName']", this).val() != undefined ? $("input[name='AutoCustName']", this).val().split("-")[2].trim() : "0";
                        var Ischkmanual = $("input[name='chkmanual']", this).is(':checked');
                        var IschkCamscanning = $("input[name='chkCamscanning']", this).is(':checked');
                        var IschkBoth = $("input[name='chkBoth']", this).is(':checked');
                        var IsActive = $("input[name='chkIsActive']", this).is(':checked');
                        var IPAddress = $("#hdnIPAdd").val();
                        var IsChange = $("input[name='IsChange']", this).val().trim();

                        var obj = {
                            ScanningTypeId: ScanningTypeId,
                            EmpGroupId: EmpGroupId,
                            EmpId: EmpId,
                            CustomerId: CustId,
                            Ischkmanual: Ischkmanual,
                            IschkCamscanning: IschkCamscanning,
                            IschkBoth: IschkBoth,
                            IsActive: IsActive,
                            IPAddress: IPAddress,
                            IsChange: IsChange
                        };
                        TableData_Customer.push(obj);
                    }
                    else {
                        $.unblockUI();
                        IsValid = false;
                        ModelMsg("Please select atleast one Item", 3);
                        return false;
                    }
                }

                rowCnt_Customer++;
            });

            if (totalItemcnt == 0) {
                $.unblockUI();
                ModelMsg("Please select atleast one Item", 3);
                return false;
            }
            if (cnt == 1) {
                $.unblockUI();
                ModelMsg(errormsg, 3);
                return false;
            }
            var CustomerData = JSON.stringify(TableData_Customer);


            var successMSG = true;

            if (IsValid) {
                var sv = $.ajax({
                    url: 'ScanningTypeMaster.aspx/SaveData',
                    type: 'POST',
                    //async: false,
                    dataType: 'json',
                    // traditional: true,
                    data: JSON.stringify({ hidJsonInputScanningType: CustomerData, ModuleId: $('.ddlModule').val(), ScanningId: $('.ddlScanningAt').val(), IsAnyRowDeleted: $('#hdnIsRowDeleted').val(), DeletedIDs: $('#hdnDeleteIDs').val() }),
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
                        return false;
                    }
                    else if (result.d.indexOf("WARNING=") >= 0) {
                        $.unblockUI();
                        var ErrorMsg = result.d.split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
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

        .ui-autocomplete {
            position: absolute;
        }
        /*ul.ui-autocomplete { top: 217.125px !important;
            z-index: 100000000;
            position: absolute;
        }*/
        /*body {
            overflow:hidden;
        }*/
        /*table#gvScanningTypeHistory.dataTable tbody th, table.dataTable tbody td {
            padding: 5px 10px;
        }*/

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

        table.gvScanningTypeHistory.table.table-bordered.nowrap.no-footer.dataTable {
            width: 100% !important;
            margin: 0;
            table-layout: auto;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        /*table.gvScanningTypeHistory td:nth-child(1), table.gvScanningTypeHistory td:nth-child(4), table.gvScanningTypeHistory td:nth-child(5) {
            text-align: left;
        }

        table.gvScanningTypeHistory td:nth-child(6), table.gvScanningTypeHistory td:nth-child(7) {
            text-align: left;
        }*/
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnIsRowDeleted" ClientIDMode="Static" Value="0" />
    <asp:HiddenField runat="server" ID="hdnDeleteIDs" ClientIDMode="Static" Value="" />
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Module</label>
                        <asp:DropDownList runat="server" ID="ddlModule" CssClass="ddlModule form-control" TabIndex="1" onchange="BindScanning();">
                            <asp:ListItem Value="1">Vadilal Pulse</asp:ListItem>
                            <asp:ListItem Value="2">Chill Fix</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Scanning At</label>
                        <asp:DropDownList runat="server" ID="ddlScanningAt" CssClass="ddlScanningAt form-control" TabIndex="2" onchange="ClearControls();">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <label class="input-group-addon">View Report</label>
                        <asp:CheckBox runat="server" CssClass="chkIsReport form-control" TabIndex="3" onchange="ClearControls();" />
                    </div>
                </div>
                <div class="divViewDetail">
                    <div class="col-lg-2">
                        <div class="input-group form-group">
                            <label class="input-group-addon">With History</label>
                            <asp:CheckBox runat="server" ID="chkIsHistory" TabIndex="4" CssClass="chkIsHistory form-control" />
                        </div>
                    </div>
                </div>
                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <input type="button" id="btnSubmit" name="btnSubmit" value="Submit" tabindex="5" class="btnSubmit btn btn-default" onclick="btnSubmit_Click()" />
                        <input type="button" id="btnSearch" name="btnSearch" value="Process" tabindex="6" class="btnSearch btn btn-default" onclick="GetReport();" />
                        &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" tabindex="7" onclick="Cancel()" class="btn btn-default" />
                    </div>
                </div>
            </div>
            <input type="hidden" id="CountRowCustomer" />
            <div id="divCustEntry" class="divCustEntry" runat="server" style="max-height: 80vh; position: absolute; overflow: hidden;">
                <table id="tblCustomer" class="table table-bordered" border="1" tabindex="8" style="width: 100%; border-collapse: collapse; font-size: 10px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="width: 2%; text-align: center;">Sr</th>
                            <th style="width: 3.5%">Edit</th>
                            <th style="width: 3.5%">Delete</th>
                            <th style="width: 9%">Employee Group</th>
                            <th style="width: 9%">Employee</th>
                            <th style="width: 10%">Dealer / Dist / SS / SLOC / Plant</th>
                            <th style="width: 4%">Keypad Entry</th>
                            <th style="width: 5%">Camera Scanning</th>
                            <th style="width: 3%">Both</th>
                            <th style="width: 3%;">Active</th>
                            <th style="width: 7%;">Entry By</th>
                            <th style="width: 5%;">Entry Date/Time</th>
                            <th style="width: 7%;">Updated By</th>
                            <th style="width: 5%;">Update Date/Time</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <div id="divScanningReport" class="divScanningReport" style="max-height: 30vh; overflow-y: auto;">
                <table id="gvScanningTypeHistory" class="gvScanningTypeHistory table table-bordered nowrap" style="width: 100%; font-size: 10px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="text-align: center; width: 2%;">Sr</th>
                            <th style="width: 10%">Employee Group</th>
                            <th style="width: 10%">Employee</th>
                            <th style="width: 10%">Dealer / Dist / SS / SLOC / Plant</th>
                            <th style="width: 3%; text-align: left;">Keypad Entry</th>
                            <th style="width: 4%; text-align: left;">Camera Scanning</th>
                            <th style="width: 3%; text-align: left;">Both</th>
                            <th style="width: 3%;">Active</th>
                            <th style="width: 5%;">Entry By</th>
                            <th style="width: 5%;">Entry Date/Time</th>
                            <th style="width: 5%;">Update By</th>
                            <th style="width: 5%;">
                            Update Date/Time</t>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>

